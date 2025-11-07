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
    
    -- Look up in reference map
    local ref = references[decoded_target]
    
    if ref then
      -- Create index entry: Name (Type)
      local index_entry = string.format("%s@\\textbf{%s}!%s", ref.type, ref.type, ref.name)
      local index_latex = string.format("\\index{%s}", index_entry)
      
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