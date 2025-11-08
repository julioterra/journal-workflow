-- link-to-footnote.lua
-- Remove Capacities link paragraphs after images/figures

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

return {{Pandoc = Pandoc}}