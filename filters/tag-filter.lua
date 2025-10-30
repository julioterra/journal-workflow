-- tag-filter.lua
-- Converts #tags to colored, indexed tags in LaTeX output
-- Displays tags in lowercase with spaces (e.g., #DomesticStaff → #domestic staff)
-- Keeps all-caps acronyms unchanged (e.g., #MWT → #MWT)

-- Function to convert CamelCase to lowercase with spaces
function camel_to_lower_spaced(str)
  -- Check if the string is all uppercase (acronym)
  if str:match("^[A-Z]+$") then
    return str:lower()  -- Convert acronyms to lowercase without spaces
  end
  
  -- Insert space before capital letters
  local spaced = str:gsub("(%u)", " %1")
  -- Remove leading space and convert to lowercase
  return spaced:gsub("^%s+", ""):lower()
end

function Inlines(inlines)
  local result = {}
  
  for i, el in ipairs(inlines) do
    if el.t == "Str" then
      local text = el.text
      local processed = false
      
      if text:match("#") then
        processed = true
        local position = 1
        
        while position <= #text do
          local char = text:sub(position, position)
          
          if char == "#" then
            local next_char = text:sub(position + 1, position + 1)
            
            if next_char:match("[%w_%-]") then
              -- Extract tag name
              local tag_start = position + 1
              local tag_end = tag_start
              
              while tag_end <= #text do
                local c = text:sub(tag_end, tag_end)
                if c:match("[%w_%-]") then
                  tag_end = tag_end + 1
                else
                  break
                end
              end
              
              local tag_original = text:sub(tag_start, tag_end - 1)
              local tag_display = camel_to_lower_spaced(tag_original)
              
              -- Pass both: display name and original for color lookup
              table.insert(result, pandoc.RawInline('latex', 
                string.format("\\tag{%s}{%s} ", tag_display, tag_original)))
              position = tag_end
            else
              table.insert(result, pandoc.Str("#"))
              position = position + 1
            end
          else
            local text_start = position
            local text_end = position
            
            while text_end <= #text and text:sub(text_end, text_end) ~= "#" do
              text_end = text_end + 1
            end
            
            local regular_text = text:sub(text_start, text_end - 1)
            if regular_text ~= "" then
              table.insert(result, pandoc.Str(regular_text))
            end
            position = text_end
          end
        end
      end
      
      if not processed then
        table.insert(result, el)
      end
    else
      table.insert(result, el)
    end
  end
  
  return result
end

return {
  {Inlines = Inlines}
}