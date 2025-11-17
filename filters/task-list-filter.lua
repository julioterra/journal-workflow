-- task-list-filter.lua
-- Converts task lists to checkboxlist environment with Wingdings checkboxes

-- Wingdings 2 checkbox symbols (scaled down 30%, raised 0.15ex)
local EMPTY_BOX = '\\item[{\\raisebox{0.15ex}{\\scalebox{0.7}{\\wingdingsii\\symbol{"F0A3}}}}]'        -- Unchecked
local CHECKED_BOX = '\\item[{\\raisebox{0.15ex}{\\scalebox{0.7}{\\wingdingsii\\symbol{"F053}}}}]'      -- Checked
local BULLET_ITEM = '\\item'  -- Regular bullet for non-checkbox items

function BulletList(el)
  -- Check if this is a task list by looking for task list items
  local has_tasks = false
  for _, item in ipairs(el.content) do
    if item[1] and item[1].content and item[1].content[1] then
      local first = item[1].content[1]
      if first.t == 'Str' and (first.text == '☐' or first.text == '☒') then
        has_tasks = true
        break
      end
    end
  end

  -- If not a task list, return unchanged
  if not has_tasks then
    return el
  end

  -- Build checkboxlist environment
  local result = {pandoc.RawBlock('latex', '\\begin{checkboxlist}')}

  -- Process each item
  for _, item in ipairs(el.content) do
    local item_type = nil

    -- Check first element for checkbox
    if item[1] and item[1].content and item[1].content[1] then
      local first = item[1].content[1]
      if first.t == 'Str' then
        if first.text == '☐' then
          item_type = 'unchecked'
          -- Remove checkbox from content
          table.remove(item[1].content, 1)
          -- Remove space after checkbox if present
          if item[1].content[1] and item[1].content[1].t == 'Space' then
            table.remove(item[1].content, 1)
          end
        elseif first.text == '☒' then
          item_type = 'checked'
          -- Remove checkbox from content
          table.remove(item[1].content, 1)
          -- Remove space after checkbox if present
          if item[1].content[1] and item[1].content[1].t == 'Space' then
            table.remove(item[1].content, 1)
          end
        end
      end
    end

    -- Add item with appropriate label
    if item_type == 'unchecked' then
      table.insert(result, pandoc.RawBlock('latex', EMPTY_BOX))
    elseif item_type == 'checked' then
      table.insert(result, pandoc.RawBlock('latex', CHECKED_BOX))
    else
      -- Regular bullet item within checkboxlist
      table.insert(result, pandoc.RawBlock('latex', BULLET_ITEM))
    end

    -- Add item content
    for _, block in ipairs(item) do
      table.insert(result, block)
    end
  end

  table.insert(result, pandoc.RawBlock('latex', '\\end{checkboxlist}'))

  return result
end
