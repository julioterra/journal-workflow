-- name-filter.lua
-- Extracts people's names from Capacities links and adds them to the index

-- List of common first names to help identify people
-- You can expand this list or make it more sophisticated
local common_names = {
  Andrea = true,
  Rose = true,
  Luca = true,
  Mila = true,
  Veronica = true,
  Jana = true,
  Izzy = true,
  -- Add more names as needed
}

-- Function to check if a name looks like a person's name
-- Simple heuristic: capitalized, short (1-3 words), in our list, or matches common patterns
function looks_like_person(name)
  -- Check if it's in our known names list
  if common_names[name] then
    return true
  end
  
  -- Check if it starts with a capital letter and is relatively short
  if name:match("^[A-Z][a-z]+$") or name:match("^[A-Z][a-z]+ [A-Z][a-z]+$") then
    return true
  end
  
  return false
end

-- Function to process links
function Link(el)
  local url = el.target
  local link_text = pandoc.utils.stringify(el.content)
  
  -- Check if this is a Capacities internal link (people reference)
  if url:match("^https://app%.capacities%.io/") then
    
    -- If the link text looks like a person's name
    if looks_like_person(link_text) then
      -- Return a LaTeX person command with the name
      -- This will color it and add it to the index
      return pandoc.RawInline('latex', 
        string.format("\\person{%s}{%s}", link_text, canonical_name))
    else
      -- For other internal links, just show the text without the URL
      -- (since Capacities URLs won't work outside the app)
      return pandoc.Emph(el.content)
    end
  end
  
  -- For external links, keep them as-is
  return el
end

return {
  {Link = Link}
}
