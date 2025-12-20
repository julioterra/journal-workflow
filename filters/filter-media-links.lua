-- link-to-footnote.lua
-- Remove Capacities link paragraphs after images/figures
-- Handle video embeds and links

-- Remove video embeds (they come as Figures containing Images with video targets)
function Figure(el)
  -- io.stderr:write("DEBUG: Processing Figure\n")
  
  for i, block in ipairs(el.content) do
    if block.t == "Plain" or block.t == "Para" then
      for j, inline in ipairs(block.content) do
        if inline.t == "Image" then
          local src = inline.src or ""
          -- io.stderr:write("DEBUG: Found Image with src: " .. src .. "\n")
          
          if src:match("%.mp4$") or src:match("%.mov$") or src:match("%.avi$") or 
             src:match("%.mkv$") or src:match("%.webm$") then
            -- io.stderr:write("DEBUG: REMOVING VIDEO!\n")
            return {}
          end
        end
      end
    end
  end
  
  return el
end

-- Convert inline video links and all Capacities .md links to plain text (keep text, remove link)
-- NOTE: add-index-entries filter runs FIRST to extract People/Organizations/etc for indexes
-- Then this filter removes the links (but keeps the text) for the printed output
function Link(el)
  local target = el.target or ""

  -- Remove video links (keep text only)
  if target:match("%.mp4$") or target:match("%.mov$") or target:match("%.avi$") or
     target:match("%.mkv$") or target:match("%.webm$") then
    return el.content  -- Return just the text, not the link
  end

  -- Remove all Capacities .md links (Pages, People, Organizations, etc.) - keep text only
  -- The add-index-entries filter has already processed these for index generation
  if target:match("^https://app%.capacities%.io/") or target:match("%.md$") then
    return el.content  -- Return just the text, not the link
  end

  return el
end

-- Convert video links to plain text (keep the text, remove the link)
--function VideoLink2Text(el)
--  if el.target:match("%.(mp4|mov|avi|mkv|webm)$") then
--    return el.content  -- Return just the text content, not the link
--  end
--  return el
--end

-- Helper function to URL decode a string
local function url_decode(str)
  if not str then return "" end
  str = string.gsub(str, "%%(%x%x)", function(hex)
    return string.char(tonumber(hex, 16))
  end)
  return str
end

-- Helper function to extract page name from URL path
local function get_page_name_from_url(url)
  if not url then return "" end

  -- Extract filename from path (after last /)
  local filename = url:match("([^/]+)$")
  if not filename then return "" end

  -- URL decode
  filename = url_decode(filename)

  -- Remove .md extension
  filename = filename:gsub("%.md$", "")

  return filename
end

-- Helper function to normalize text for comparison
-- Handles date format differences: "2023/11/15:" vs "20231115"
local function normalize_for_comparison(text)
  if not text then return "" end

  -- Remove date separators (2023/11/15 -> 20231115)
  text = text:gsub("(%d%d%d%d)/(%d%d)/(%d%d)", "%1%2%3")
  text = text:gsub("(%d%d%d%d)_(%d%d)_(%d%d)", "%1%2%3")

  -- Remove all colons, commas, periods, and apostrophes
  text = text:gsub("[':,%.]", "")

  -- Remove trailing year (e.g., " 2023" or ", 2023" at end of string)
  text = text:gsub("%s*,?%s*%d%d%d%d%s*$", "")

  -- Normalize whitespace (multiple spaces to single space)
  text = text:gsub("%s+", " ")

  -- Trim leading/trailing whitespace
  text = text:match("^%s*(.-)%s*$")

  -- Convert to lowercase for case-insensitive comparison
  text = text:lower()

  return text
end

-- Helper function to check if a paragraph contains only a Capacities Page link
-- where the link text matches the page name
-- NOTE: Only handles Pages/ folder - NOT People/Organizations/Projects/Books/Definitions
local function is_standalone_page_link(block)
  if block.t ~= "Para" then
    return false
  end

  local link_count = 0
  local non_space = 0
  local capacities_link = nil

  for _, el in ipairs(block.content) do
    -- Only match Pages/ folder or capacities.io URLs, not People/Organizations/etc
    if el.t == "Link" and (el.target:match("^https://app%.capacities%.io/") or el.target:match("/Pages/.*%.md$")) then
      link_count = link_count + 1
      capacities_link = el
    end
    if el.t ~= "Space" and el.t ~= "SoftBreak" and el.t ~= "LineBreak" then
      non_space = non_space + 1
    end
  end

  -- Paragraph must contain only a single Capacities Page link and nothing else (except spaces)
  if not (link_count == 1 and non_space == 1 and capacities_link) then
    return false
  end

  -- Check if link text matches the page name from URL
  local link_text = pandoc.utils.stringify(capacities_link.content)
  local page_name = get_page_name_from_url(capacities_link.target)

  -- Normalize both for comparison (handles date format differences)
  link_text = normalize_for_comparison(link_text)
  page_name = normalize_for_comparison(page_name)

  return link_text == page_name
end

-- Helper function to check if a paragraph contains ANY .md link where text matches filename
-- Used for removing reference links after images (not just Pages/)
local function is_matching_md_link(block)
  if block.t ~= "Para" then
    return false
  end

  local link_count = 0
  local non_space = 0
  local md_link = nil

  for _, el in ipairs(block.content) do
    -- Match ANY .md link or capacities.io URL
    if el.t == "Link" and (el.target:match("^https://app%.capacities%.io/") or el.target:match("%.md$")) then
      link_count = link_count + 1
      md_link = el
    end
    if el.t ~= "Space" and el.t ~= "SoftBreak" and el.t ~= "LineBreak" then
      non_space = non_space + 1
    end
  end

  -- Paragraph must contain only a single .md link and nothing else (except spaces)
  if not (link_count == 1 and non_space == 1 and md_link) then
    return false
  end

  -- Check if link text matches the page name from URL
  local link_text = pandoc.utils.stringify(md_link.content)
  local page_name = get_page_name_from_url(md_link.target)

  -- Normalize both for comparison (handles date format differences)
  link_text = normalize_for_comparison(link_text)
  page_name = normalize_for_comparison(page_name)

  return link_text == page_name
end

-- Remove Capacities link paragraphs (both standalone and following images/figures)
function Pandoc(doc)
  local new_blocks = {}
  local i = 1

  while i <= #doc.blocks do
    local current = doc.blocks[i]

    -- Check if current block is a standalone page link - if so, skip it entirely
    if is_standalone_page_link(current) then
      i = i + 1
      goto continue
    end

    local is_image_block = false

    -- Check if current is a Figure OR a Para with only images
    if current.t == "Figure" then
      is_image_block = true
    elseif current.t == "Para" then
      local only_images = true
      local has_image = false
      for _, el in ipairs(current.content) do
        if el.t == "Image" then
          has_image = true
        elseif el.t ~= "Space" and el.t ~= "SoftBreak" and el.t ~= "LineBreak" then
          only_images = false
        end
      end
      is_image_block = (has_image and only_images)
    end

    -- If this is an image block, check if next is a matching .md link
    if is_image_block and i < #doc.blocks then
      local next = doc.blocks[i + 1]

      if is_matching_md_link(next) then
        -- Skip the .md link paragraph after image
        table.insert(new_blocks, current)
        i = i + 2
      else
        table.insert(new_blocks, current)
        i = i + 1
      end
    else
      table.insert(new_blocks, current)
      i = i + 1
    end

    ::continue::
  end

  doc.blocks = new_blocks
  return doc
end

-- Return filters in correct order:
-- 1. Pandoc runs first to remove standalone page links (while they're still Links)
-- 2. Figure runs to remove video embeds
-- 3. Link runs last to convert remaining inline page/video links to plain text
return {
  {Pandoc = Pandoc},
  {Figure = Figure},
  {Link = Link}
}
