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
      local index_latex = string.format("\\index[%s]{%s}", index_name, ref.name)
      
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