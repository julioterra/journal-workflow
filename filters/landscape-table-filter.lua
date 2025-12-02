-- landscape-table-filter.lua
-- Wraps wide tables (5+ columns) in a landscape environment for better display

function Table(el)
  -- Count columns - support both new (Pandoc 2.10+) and old table formats
  local column_count = 0

  if el.colspecs then
    -- Pandoc 2.10+ format: colspecs is a list of (Alignment, ColWidth) pairs
    column_count = #el.colspecs
  elseif el.aligns then
    -- Older Pandoc format: aligns is a list of alignments
    column_count = #el.aligns
  end

  -- Only rotate tables with 5 or more columns to landscape
  if column_count >= 5 then
    local landscape_begin = pandoc.RawBlock('latex', '\\begin{landscape}')
    local landscape_end = pandoc.RawBlock('latex', '\\end{landscape}')

    -- Return a list of blocks: begin, table, end
    return {landscape_begin, el, landscape_end}
  else
    -- Return table as-is for tables with fewer than 5 columns
    return el
  end
end
