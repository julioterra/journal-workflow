-- remove-todo-sections.lua
-- Removes "To Dos" sections and all their content from the document

function Pandoc(doc)
  local new_blocks = {}
  local skip_until_level = nil
  local i = 1

  while i <= #doc.blocks do
    local block = doc.blocks[i]

    -- Check if we're currently skipping content
    if skip_until_level then
      -- Check if this is a heading at the same or higher level (lower number)
      if block.t == "Header" and block.level <= skip_until_level then
        -- Stop skipping - we've reached the next section
        skip_until_level = nil
        -- Don't skip this block, process it normally
      else
        -- Still in the To Dos section, skip this block
        i = i + 1
        goto continue
      end
    end

    -- Check if this is a "To Dos" heading
    if block.t == "Header" then
      local heading_text = pandoc.utils.stringify(block.content)
      if heading_text == "To Dos" then
        -- Start skipping content until we hit the next heading at this level or higher
        skip_until_level = block.level
        i = i + 1
        goto continue
      end
    end

    -- Keep this block
    table.insert(new_blocks, block)
    i = i + 1

    ::continue::
  end

  doc.blocks = new_blocks
  return doc
end

return {{Pandoc = Pandoc}}
