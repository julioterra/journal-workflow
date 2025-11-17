-- remove-object-embeds.lua
-- Remove standalone embed links to Pages/*.md files
-- Convert inline page links to plain text (links won't work in hardcover books)
-- Remove subsection headers that become empty after embed removal

-- Helper function to URL decode a string
local function url_decode(str)
  if not str then return str end
  str = str:gsub("+", " ")
  str = str:gsub("%%(%x%x)", function(h)
    return string.char(tonumber(h, 16))
  end)
  return str
end

-- Helper function to read title from a .md file's frontmatter
local function get_title_from_file(filepath)
  local file = io.open(filepath, "r")
  if not file then return nil end

  local content = file:read("*all")
  file:close()

  -- Look for YAML frontmatter
  local frontmatter = content:match("^%-%-%-\n(.-)%-%-%-")
  if not frontmatter then return nil end

  -- Extract title from frontmatter
  local title = frontmatter:match("title:%s*['\"]?([^'\"\n]+)['\"]?")
  if title then
    -- Trim trailing whitespace
    title = title:gsub("%s+$", "")
  end

  return title
end

-- Helper function to get filename without extension
local function get_filename_without_ext(path)
  local filename = path:match("([^/]+)%.md$")
  return filename and url_decode(filename) or nil
end

-- Process paragraphs to remove standalone Pages embeds and convert inline page links
function Para(el)
  -- Check if paragraph contains only a single link (and maybe whitespace)
  local link = nil
  local non_space_count = 0

  for _, inline in ipairs(el.content) do
    if inline.t == "Link" then
      link = inline
      non_space_count = non_space_count + 1
    elseif inline.t ~= "Space" and inline.t ~= "SoftBreak" and inline.t ~= "LineBreak" then
      non_space_count = non_space_count + 1
    end
  end

  -- Only process if we have exactly one non-space element and it's a link
  if non_space_count == 1 and link then
    local target = link.target or ""

    -- Check if it's a Pages/*.md link
    if target:match("^Pages/.*%.md$") then
      -- Get the link text (trim trailing spaces)
      local link_text = pandoc.utils.stringify(link.content):gsub("%s+$", "")

      -- Construct the full file path (relative to source directory)
      local filepath = "source/capacities-export/" .. url_decode(target)

      -- Get title from the file
      local title = get_title_from_file(filepath)

      -- Get filename without extension
      local filename = get_filename_without_ext(target)

      -- Check if link text matches title or filename (accounting for trailing spaces)
      if (title and link_text == title) or (filename and link_text == filename) then
        -- Remove this paragraph by returning an empty list
        return {}
      end
    end
  end

  -- If we get here, it's not a standalone embed to remove
  -- Walk through inline elements and convert Pages/*.md links to plain text
  local new_content = {}
  for _, inline in ipairs(el.content) do
    if inline.t == "Link" then
      local target = inline.target or ""
      if target:match("^Pages/.*%.md$") then
        -- Convert to plain text (preserve the link text, remove the hyperlink)
        -- Links won't work in hardcover books, and local links won't work in PDFs
        for _, text_elem in ipairs(inline.content) do
          table.insert(new_content, text_elem)
        end
      else
        -- Keep other links as-is
        table.insert(new_content, inline)
      end
    else
      -- Keep non-link elements as-is
      table.insert(new_content, inline)
    end
  end

  el.content = new_content
  return el
end

-- Helper function to check if a paragraph is a standalone Pages embed
local function is_standalone_pages_embed(para)
  if para.t ~= "Para" then return false end

  local link = nil
  local non_space_count = 0

  for _, inline in ipairs(para.content) do
    if inline.t == "Link" then
      link = inline
      non_space_count = non_space_count + 1
    elseif inline.t ~= "Space" and inline.t ~= "SoftBreak" and inline.t ~= "LineBreak" then
      non_space_count = non_space_count + 1
    end
  end

  if non_space_count == 1 and link then
    local target = link.target or ""
    if target:match("^Pages/.*%.md$") then
      local link_text = pandoc.utils.stringify(link.content):gsub("%s+$", "")
      local filepath = "source/capacities-export/" .. url_decode(target)
      local title = get_title_from_file(filepath)
      local filename = get_filename_without_ext(target)

      if (title and link_text == title) or (filename and link_text == filename) then
        return true
      end
    end
  end

  return false
end

-- Process blocks to remove headers that only contain standalone embeds
function Blocks(blocks)
  local result = {}
  local i = 1

  while i <= #blocks do
    local block = blocks[i]

    -- Check if this is a Header (subsection)
    if block.t == "Header" then
      -- Look ahead to see if this section only contains embeds (and blank lines)
      local next_i = i + 1
      local has_content = false
      local all_embeds = true

      -- Scan forward until we hit another header of same/higher level, or end of blocks
      while next_i <= #blocks do
        local next_block = blocks[next_i]

        -- Stop if we hit another header of same or higher level
        if next_block.t == "Header" and next_block.level <= block.level then
          break
        end

        -- Check if this block is content
        if next_block.t == "Para" then
          if is_standalone_pages_embed(next_block) then
            -- It's an embed - mark that we found content
            has_content = true
          else
            -- It's a real paragraph - not just embeds
            all_embeds = false
            has_content = true
            break
          end
        elseif next_block.t ~= "Header" then
          -- Some other block type (list, code, etc.) - not just embeds
          all_embeds = false
          has_content = true
          break
        end

        next_i = next_i + 1
      end

      -- If section only has embeds (no real content), skip the header
      if has_content and all_embeds then
        -- Skip this header by not adding it to result
        -- The embeds themselves will be removed by Para function
        i = i + 1
      else
        -- Keep this header
        table.insert(result, block)
        i = i + 1
      end
    else
      -- Not a header, keep it (Para function will handle embed removal)
      table.insert(result, block)
      i = i + 1
    end
  end

  return result
end

return {{Blocks = Blocks}, {Para = Para}}
