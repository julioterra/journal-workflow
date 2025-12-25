-- add-index-entries.lua
-- Adds LaTeX index entries for references to people, organizations, etc.

-- URL decode function
local function url_decode(str)
  str = string.gsub(str, "+", " ")
  str = string.gsub(str, "%%(%x%x)", function(h)
    return string.char(tonumber(h, 16))
  end)
  return str
end

-- Escape special LaTeX characters for use in index entries
local function escape_latex(str)
  if not str then return "" end

  -- Escape special LaTeX characters
  str = string.gsub(str, "\\", "\\textbackslash{}")
  str = string.gsub(str, "&", "\\&")
  str = string.gsub(str, "%%", "\\%%")
  str = string.gsub(str, "%$", "\\$")
  str = string.gsub(str, "#", "\\#")
  str = string.gsub(str, "_", "\\_")
  str = string.gsub(str, "{", "\\{")
  str = string.gsub(str, "}", "\\}")
  str = string.gsub(str, "~", "\\textasciitilde{}")
  str = string.gsub(str, "%^", "\\textasciicircum{}")

  return str
end

-- Load reference map
local function load_references()
  local file = io.open("source/references.json", "r")
  if not file then
    io.stderr:write("Warning: references.json not found\n")
    return {}
  end
  
  local content = file:read("*all")
  file:close()
  
  local success, references = pcall(pandoc.json.decode, content)
  if not success then
    io.stderr:write("Warning: Could not parse references.json\n")
    return {}
  end
  
  return references or {}
end

local references = load_references()

-- Process links
function Link(el)
  local target = el.target

  -- Check if this is a reference link (has .md extension)
  if target:match("%.md$") then
    -- URL decode the target
    local decoded_target = url_decode(target)

    -- Remove ../ prefix if present (markdown uses ../People/... but references.json uses People/...)
    decoded_target = decoded_target:gsub("^%.%./", "")

    -- Look up in reference map
    local ref = references[decoded_target]
    
    if ref then
      -- Route to type-specific index (e.g., People → people index)
      local index_name = ref.type:lower()
      -- Escape special LaTeX characters in the name
      local escaped_name = escape_latex(ref.name)
      local index_latex = string.format("\\index[%s]{%s}", index_name, escaped_name)
      
      -- Return the link text followed by invisible index entry (no mbox)
      return {
        pandoc.Span(el.content),
        pandoc.RawInline('latex', index_latex)
      }
    end
  end
  
  -- Not a reference link, return unchanged
  return el
end

return {{Link = Link}}