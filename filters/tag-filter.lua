-- tag-filter.lua
-- Converts #tags to colored, indexed tags in LaTeX output
-- Displays tags in lowercase with spaces (e.g., #DomesticStaff → #domestic staff)
-- Keeps all-caps acronyms unchanged (e.g., #MWT → #MWT)
-- Supports emoji-prefixed tags (e.g., #🪷Family → #🪷 family)

-- Returns the byte length of the UTF-8 character starting at pos in str
local function utf8_char_len(str, pos)
  local byte = string.byte(str, pos)
  if not byte then return 0 end
  if byte < 0x80 then return 1 end
  if byte < 0xE0 then return 2 end
  if byte < 0xF0 then return 3 end
  return 4
end

-- Build display string: wraps leading emoji in \raisebox{-2pt}{} to shift it down,
-- then applies CamelCase conversion to the remaining text portion
local function build_tag_display(tag_original)
  local first_byte = string.byte(tag_original, 1)
  if first_byte and first_byte >= 0x80 then
    -- Consume leading emoji characters
    local pos = 1
    while pos <= #tag_original do
      local b = string.byte(tag_original, pos)
      if b and b >= 0x80 then
        pos = pos + utf8_char_len(tag_original, pos)
      else
        break
      end
    end
    local emoji_part = tag_original:sub(1, pos - 1)
    local text_part  = tag_original:sub(pos)
    local text_display = text_part ~= "" and camel_to_lower_spaced(text_part) or ""
    if text_display ~= "" then
      return string.format("\\raisebox{-2pt}{%s} %s", emoji_part, text_display)
    else
      return string.format("\\raisebox{-2pt}{%s}", emoji_part)
    end
  else
    return camel_to_lower_spaced(tag_original)
  end
end

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
            
            local next_byte = string.byte(text, position + 1)
            if next_char:match("[%w_%-]") or (next_byte and next_byte >= 0x80) then
              -- Extract tag name (supports leading emoji + alphanumeric)
              local tag_start = position + 1
              local tag_end = tag_start

              while tag_end <= #text do
                local byte = string.byte(text, tag_end)
                if not byte then break end
                if byte >= 0x80 then
                  -- Non-ASCII (emoji/Unicode): consume full UTF-8 character
                  tag_end = tag_end + utf8_char_len(text, tag_end)
                elseif text:sub(tag_end, tag_end):match("[%w_%-]") then
                  tag_end = tag_end + 1
                else
                  break
                end
              end
              
              local tag_original = text:sub(tag_start, tag_end - 1)
              local tag_display = build_tag_display(tag_original)
              
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