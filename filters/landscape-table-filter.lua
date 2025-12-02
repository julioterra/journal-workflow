-- landscape-table-filter.lua
-- Applies smart styling to tables: landscape rotation, font switching, and dynamic sizing

function Table(el)
  -- Count columns - support both new (Pandoc 2.10+) and old table formats
  local column_count = 0
  if el.colspecs then
    column_count = #el.colspecs
  elseif el.aligns then
    column_count = #el.aligns
  end

  -- Count rows (body rows, not including header)
  local row_count = 0
  if el.bodies then
    -- Pandoc 2.10+ format: bodies is a list of TableBody
    for _, body in ipairs(el.bodies) do
      row_count = row_count + #body.body
    end
  elseif el.rows then
    -- Older format: rows is directly available
    row_count = #el.rows
  end

  -- Determine font size based on table dimensions
  -- Normal (10pt): < 5 columns AND < 10 rows
  -- Medium (8pt): 5+ columns OR 10+ rows
  -- Small (7pt): 5+ columns AND 10+ rows
  local font_size = "normalsize"  -- 10pt
  if column_count >= 5 and row_count >= 10 then
    font_size = "footnotesize"  -- ~8pt in 10pt document, ~7pt in smaller base
  elseif column_count >= 5 or row_count >= 10 then
    font_size = "small"  -- ~9pt
  end

  -- Build the LaTeX wrapper
  local blocks = {}

  -- Start table environment with font changes
  table.insert(blocks, pandoc.RawBlock('latex', '{\\tablefont\\' .. font_size))

  -- Add landscape environment for wide tables (5+ columns)
  if column_count >= 5 then
    table.insert(blocks, pandoc.RawBlock('latex', '\\begin{landscape}'))
  end

  -- Insert the actual table
  table.insert(blocks, el)

  -- Close landscape environment
  if column_count >= 5 then
    table.insert(blocks, pandoc.RawBlock('latex', '\\end{landscape}'))
  end

  -- Close font environment
  table.insert(blocks, pandoc.RawBlock('latex', '}'))

  return blocks
end
