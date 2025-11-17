-- emoji-filter.lua
-- Detects emoji characters and converts them to inline images using Twemoji graphics

-- Function to check if a character is an emoji
-- Covers major emoji Unicode blocks
-- Excludes some symbols that aren't in Twemoji
function is_emoji(codepoint)
  -- Skip checkbox characters that aren't in Twemoji
  if codepoint == 0x2610 or codepoint == 0x2612 then
    return false
  end

  return (codepoint >= 0x1F300 and codepoint <= 0x1F9FF) or  -- Misc Symbols and Pictographs, Emoticons, etc.
         (codepoint >= 0x2600 and codepoint <= 0x26FF) or    -- Misc symbols
         (codepoint >= 0x2700 and codepoint <= 0x27BF) or    -- Dingbats
         (codepoint >= 0x1F600 and codepoint <= 0x1F64F) or  -- Emoticons
         (codepoint >= 0x1F680 and codepoint <= 0x1F6FF) or  -- Transport and Map
         (codepoint >= 0x1F900 and codepoint <= 0x1F9FF) or  -- Supplemental Symbols
         (codepoint >= 0x2300 and codepoint <= 0x23FF) or    -- Misc Technical
         (codepoint >= 0x2B50 and codepoint <= 0x2B55) or    -- Stars and shapes
         (codepoint >= 0x1FA70 and codepoint <= 0x1FAFF) or  -- Extended-A
         (codepoint >= 0x231A and codepoint <= 0x231B) or    -- Watch
         (codepoint >= 0x23E9 and codepoint <= 0x23F3) or    -- Media controls
         (codepoint >= 0x25FD and codepoint <= 0x25FE) or    -- Squares
         (codepoint >= 0x2614 and codepoint <= 0x2615) or    -- Umbrella, coffee
         (codepoint >= 0x2648 and codepoint <= 0x2653) or    -- Zodiac
         (codepoint >= 0x267F and codepoint <= 0x267F) or    -- Wheelchair
         (codepoint >= 0x2693 and codepoint <= 0x2693) or    -- Anchor
         (codepoint >= 0x26A1 and codepoint <= 0x26A1) or    -- Zap
         (codepoint >= 0x26AA and codepoint <= 0x26AB) or    -- Circles
         (codepoint >= 0x26BD and codepoint <= 0x26BE) or    -- Sports
         (codepoint >= 0x26C4 and codepoint <= 0x26C5) or    -- Snow
         (codepoint >= 0x26CE and codepoint <= 0x26CE) or    -- Ophiuchus
         (codepoint >= 0x26D4 and codepoint <= 0x26D4) or    -- No entry
         (codepoint >= 0x26EA and codepoint <= 0x26EA) or    -- Church
         (codepoint >= 0x26F2 and codepoint <= 0x26F3) or    -- Fountain
         (codepoint >= 0x26F5 and codepoint <= 0x26F5) or    -- Sailboat
         (codepoint >= 0x26FA and codepoint <= 0x26FA) or    -- Tent
         (codepoint >= 0x26FD and codepoint <= 0x26FD) or    -- Fuel
         (codepoint >= 0x2705 and codepoint <= 0x2705) or    -- Check mark
         (codepoint >= 0x270A and codepoint <= 0x270B) or    -- Fists
         (codepoint >= 0x2728 and codepoint <= 0x2728) or    -- Sparkles
         (codepoint >= 0x274C and codepoint <= 0x274C) or    -- X
         (codepoint >= 0x274E and codepoint <= 0x274E) or    -- X negative
         (codepoint >= 0x2753 and codepoint <= 0x2755) or    -- Question marks
         (codepoint >= 0x2757 and codepoint <= 0x2757) or    -- Exclamation
         (codepoint >= 0x2795 and codepoint <= 0x2797) or    -- Plus/minus
         (codepoint >= 0x27B0 and codepoint <= 0x27B0) or    -- Curly loop
         (codepoint >= 0x27BF and codepoint <= 0x27BF) or    -- Double curly loop
         (codepoint >= 0x2B1B and codepoint <= 0x2B1C) or    -- Squares
         (codepoint >= 0x2934 and codepoint <= 0x2935) or    -- Arrows
         (codepoint >= 0x2764 and codepoint <= 0x2764) or    -- Heart
         (codepoint == 0xFE0F) or                            -- Variation Selector-16 (emoji presentation)
         (codepoint == 0x200D)                               -- Zero Width Joiner (for compound emojis)
end

-- Convert Unicode codepoint sequence to Twemoji filename
function codepoints_to_filename(codepoints)
  local parts = {}
  for _, cp in ipairs(codepoints) do
    table.insert(parts, string.format("%x", cp))
  end

  local filename = table.concat(parts, "-") .. ".png"

  -- Try with variation selector first
  local filepath = string.format("assets/emojis/72x72/%s", filename)
  local file = io.open(filepath, "r")
  if file then
    file:close()
    return filename
  end

  -- Try without trailing variation selector
  if #parts > 0 and parts[#parts] == "fe0f" then
    table.remove(parts)
    filename = table.concat(parts, "-") .. ".png"
    filepath = string.format("assets/emojis/72x72/%s", filename)
    file = io.open(filepath, "r")
    if file then
      file:close()
      return filename
    end
  end

  -- Try with just the base codepoint (for simple emojis)
  filename = string.format("%x.png", codepoints[1])
  return filename
end

function Inlines(inlines)
  local result = {}

  for i, el in ipairs(inlines) do
    if el.t == "Str" then
      local text = el.text
      local has_emoji = false

      -- Check if this string contains any emoji characters
      for _, codepoint in utf8.codes(text) do
        if is_emoji(codepoint) then
          has_emoji = true
          break
        end
      end

      if has_emoji then
        -- Process character by character, collecting emoji sequences
        local current_text = ""
        local emoji_sequence = {}
        local in_compound = false

        local function emit_emoji()
          if #emoji_sequence > 0 then
            -- Output any pending regular text
            if current_text ~= "" then
              table.insert(result, pandoc.Str(current_text))
              current_text = ""
            end

            -- Convert emoji sequence to image
            local filename = codepoints_to_filename(emoji_sequence)
            local img_path = string.format("emojis/72x72/%s", filename)

            -- Use \includegraphics with height matching text
            table.insert(result, pandoc.RawInline('latex',
              string.format("\\raisebox{-.15ex}{\\includegraphics[height=1.0em]{%s}}", img_path)))

            emoji_sequence = {}
            in_compound = false
          end
        end

        for pos, codepoint in utf8.codes(text) do
          if is_emoji(codepoint) then
            -- Zero-width joiner or variation selector keeps the sequence going
            if codepoint == 0x200D or codepoint == 0xFE0F then
              -- Only add if there's already an emoji in the sequence
              if #emoji_sequence > 0 then
                table.insert(emoji_sequence, codepoint)
                in_compound = true
              end
              -- Otherwise skip standalone variation selectors
            elseif in_compound then
              -- Continue the compound emoji sequence
              table.insert(emoji_sequence, codepoint)
              -- Check if next char is joiner/selector, otherwise end sequence
              in_compound = false
            else
              -- New standalone emoji - emit previous if exists
              if #emoji_sequence > 0 then
                emit_emoji()
              end
              table.insert(emoji_sequence, codepoint)
            end
          else
            -- End of emoji sequence
            emit_emoji()
            -- Add regular character
            current_text = current_text .. utf8.char(codepoint)
          end
        end

        -- Handle emoji sequence at end of string
        emit_emoji()

        -- Add any remaining regular text
        if current_text ~= "" then
          table.insert(result, pandoc.Str(current_text))
        end
      else
        -- No emojis in this string, keep as is
        table.insert(result, el)
      end
    else
      -- Not a Str element, keep as is
      table.insert(result, el)
    end
  end

  return result
end

return {
  {Inlines = Inlines}
}
