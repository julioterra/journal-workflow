-- landscape-table-filter.lua
-- Applies smart styling to tables: landscape rotation, font switching, and dynamic sizing

-- Helper function to estimate content density in a table
local function estimate_content_density(el)
  local total_chars = 0
  local cell_count = 0

  -- Count characters in table body
  if el.bodies then
    for _, body in ipairs(el.bodies) do
      for _, row in ipairs(body.body) do
        for _, cell in ipairs(row.cells) do
          -- Walk through cell content and count characters
          local cell_text = pandoc.utils.stringify(cell.contents)
          total_chars = total_chars + #cell_text
          cell_count = cell_count + 1
        end
      end
    end
  end

  -- Return average characters per cell
  if cell_count > 0 then
    return total_chars / cell_count
  end
  return 0
end

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

  -- Estimate content density (avg characters per cell)
  local avg_chars_per_cell = estimate_content_density(el)
  local is_dense = avg_chars_per_cell > 50  -- Consider dense if >50 chars/cell

  -- Determine font size based on table dimensions
  -- Reduced by 1 point across the board:
  -- Small (9pt): < 5 columns AND < 10 rows
  -- Smaller (8pt): 5+ columns OR 10+ rows
  -- Smallest (7pt): 5+ columns AND 10+ rows
  local font_size = "small"  -- ~9pt (reduced from 10pt)
  if column_count >= 5 and row_count >= 10 then
    font_size = "scriptsize"  -- ~7pt (reduced from 8pt)
  elseif column_count >= 5 or row_count >= 10 then
    font_size = "footnotesize"  -- ~8pt (reduced from 9pt)
  end

  -- Determine if table should be in landscape
  -- Landscape if: 5+ columns OR (2+ columns with dense content)
  local use_landscape = column_count >= 5 or (column_count >= 2 and is_dense)

  -- Build the LaTeX wrapper
  local blocks = {}

  -- For dense tables with fewer than 5 columns, add page break before
  if column_count < 5 and is_dense then
    table.insert(blocks, pandoc.RawBlock('latex', '\\clearpage'))
  end

  -- Start table environment with font changes and spacing adjustments
  local table_setup = '{\\tablefont\\' .. font_size
  table_setup = table_setup .. '\\renewcommand{\\arraystretch}{1.5}'  -- Add vertical row spacing

  -- Adjust column spacing based on table width
  if column_count >= 5 then
    -- Very tight spacing for wide tables to prevent excessive gaps
    -- Using minimal spacing so columns don't stretch unnecessarily
    table_setup = table_setup .. '\\setlength{\\tabcolsep}{0.5pt}'
  else
    -- More generous spacing for small tables (< 5 columns)
    table_setup = table_setup .. '\\setlength{\\tabcolsep}{12pt}'  -- Significantly more space
  end

  -- Add zebra striping (subtle alternating row colors)
  -- Start on row 2 to skip header row
  table_setup = table_setup .. '\\rowcolors{2}{tablerowlight}{tablerowdark}'

  table.insert(blocks, pandoc.RawBlock('latex', table_setup))

  -- Add landscape environment for wide tables or dense tables
  if use_landscape then
    table.insert(blocks, pandoc.RawBlock('latex', '\\begin{landscape}'))
    -- Remove footers on all landscape pages (including multi-page tables)
    table.insert(blocks, pandoc.RawBlock('latex', '\\pagestyle{empty}'))
    -- Center the table horizontally in landscape mode
    table.insert(blocks, pandoc.RawBlock('latex', '\\centering'))
    -- For tables with 5-6 columns, constrain width to prevent over-stretching
    -- This helps columns with short content (like scores) not get too wide
    if column_count >= 5 and column_count <= 6 then
      -- Use a narrower linewidth for table calculations (6 inches instead of full landscape width)
      table.insert(blocks, pandoc.RawBlock('latex', '\\begingroup\\setlength{\\linewidth}{6in}'))
    end
  end

  -- Insert the actual table
  table.insert(blocks, el)

  -- Close width constraint if used
  if use_landscape and column_count >= 5 and column_count <= 6 then
    table.insert(blocks, pandoc.RawBlock('latex', '\\endgroup'))
  end

  -- Close landscape environment
  if use_landscape then
    table.insert(blocks, pandoc.RawBlock('latex', '\\end{landscape}'))
    -- Restore page style after landscape
    table.insert(blocks, pandoc.RawBlock('latex', '\\pagestyle{fancy}'))
  end

  -- Close font environment
  table.insert(blocks, pandoc.RawBlock('latex', '}'))

  -- For dense tables with fewer than 5 columns, add page break after
  if column_count < 5 and is_dense then
    table.insert(blocks, pandoc.RawBlock('latex', '\\clearpage'))
  end

  return blocks
end
