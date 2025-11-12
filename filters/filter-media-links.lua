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

-- Convert inline video links to plain text (keep text, remove link)
function Link(el)
  local target = el.target or ""
  if target:match("%.mp4$") or target:match("%.mov$") or target:match("%.avi$") or 
     target:match("%.mkv$") or target:match("%.webm$") then
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

-- Remove Capacities link paragraphs following images/figures
function Pandoc(doc)
  local new_blocks = {}
  local i = 1
  
  while i <= #doc.blocks do
    local current = doc.blocks[i]
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
    
    -- If this is an image block, check if next is a Capacities link
    if is_image_block and i < #doc.blocks then
      local next = doc.blocks[i + 1]
      
      if next.t == "Para" then
        local is_capacities_link_only = false
        local link_count = 0
        local non_space = 0
        
        for _, el in ipairs(next.content) do
          if el.t == "Link" and (el.target:match("^https://app%.capacities%.io/") or el.target:match("%.md$")) then
            link_count = link_count + 1
          end
          if el.t ~= "Space" and el.t ~= "SoftBreak" and el.t ~= "LineBreak" then
            non_space = non_space + 1
          end
        end
        
        is_capacities_link_only = (link_count == 1 and non_space == 1)
        
        if is_capacities_link_only then
          -- Skip the link paragraph
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
    else
      table.insert(new_blocks, current)
      i = i + 1
    end
  end
  
  doc.blocks = new_blocks
  return doc
end

return {{Figure = Figure, Link = Link, Pandoc = Pandoc}}
