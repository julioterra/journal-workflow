-- landscape-table-filter.lua
-- Wraps tables in a landscape environment for better display of wide tables

function Table(el)
  -- Wrap the table in landscape environment
  -- Using RawBlock to inject LaTeX commands before and after the table
  local landscape_begin = pandoc.RawBlock('latex', '\\begin{landscape}')
  local landscape_end = pandoc.RawBlock('latex', '\\end{landscape}')

  -- Return a list of blocks: begin, table, end
  return {landscape_begin, el, landscape_end}
end
