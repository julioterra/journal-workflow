-- landscape-table-filter.lua
-- Applies smart styling to tables: landscape rotation, font switching, and dynamic sizing

-- Helper function to estimate content density in a table
-- Returns a weighted score combining average and max cell content
-- Weights max content more heavily (60%) as it's a better indicator of needed space
local function estimate_content_density(el)
  local total_chars = 0
  local cell_count = 0
  local max_chars = 0

  -- Count characters in table body
  if el.bodies then
    for _, body in ipairs(el.bodies) do
      for _, row in ipairs(body.body) do
        for _, cell in ipairs(row.cells) do
          -- Walk through cell content and count characters
          local cell_text = pandoc.utils.stringify(cell.contents)
          local char_count = #cell_text
          total_chars = total_chars + char_count
          cell_count = cell_count + 1

          -- Track maximum cell content
          if char_count > max_chars then
            max_chars = char_count
          end
        end
      end
    end
  end

  -- Calculate average
  local avg_chars = 0
  if cell_count > 0 then
    avg_chars = total_chars / cell_count
  end

  -- Return weighted score: 40% average + 60% max
  -- This gives more weight to the longest cell content
  return (0.4 * avg_chars) + (0.6 * max_chars)
end

-- Helper function to detect if a column contains numeric data
local function is_numeric_column(el, col_index)
  local numeric_count = 0
  local total_count = 0

  if el.bodies then
    for _, body in ipairs(el.bodies) do
      for _, row in ipairs(body.body) do
        if row.cells[col_index] then
          local cell_text = pandoc.utils.stringify(row.cells[col_index].contents)
          -- Trim whitespace
          cell_text = cell_text:match("^%s*(.-)%s*$")
          total_count = total_count + 1

          -- Check if cell contains primarily numeric content
          -- Match: optional $, numbers, commas, decimals, optional %
          if cell_text:match("^%$?[%d,%.]+%%?$") then
            numeric_count = numeric_count + 1
          end
        end
      end
    end
  end

  -- Column is numeric if 75% or more cells are numeric
  return total_count > 0 and (numeric_count / total_count) >= 0.75
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

  -- Estimate content density (weighted: 40% avg + 60% max cell chars)
  local content_density = estimate_content_density(el)

  -- Use scriptsize (7pt) for all tables for consistency
  local font_size = "scriptsize"  -- ~7pt

  -- Determine if table should be in landscape based on columns and content density
  -- Logic:
  --   6+ columns: Always landscape (too wide for portrait)
  --   3-5 columns: Landscape if content density > threshold (needs width for dense content)
  --   1-2 columns: Always portrait (narrow enough to fit)
  local density_threshold = 60  -- Weighted score threshold for landscape
  local use_landscape = false

  if column_count >= 6 then
    -- Wide tables always landscape
    use_landscape = true
  elseif column_count >= 3 and column_count <= 5 then
    -- Medium width: check content density
    use_landscape = content_density > density_threshold
  else
    -- 1-2 columns: always portrait
    use_landscape = false
  end

  -- Build the LaTeX wrapper
  local blocks = {}

  -- Start table environment with font changes and spacing adjustments
  local table_setup = '{\\tablefont\\' .. font_size
  -- Use standard row spacing for all tables - let LaTeX handle wrapping naturally
  table_setup = table_setup .. '\\renewcommand{\\arraystretch}{1.8}'

  -- Use uniform column spacing for all tables (8pt)
  table_setup = table_setup .. '\\setlength{\\tabcolsep}{8pt}'

  -- Set thin vertical rules for columns and borders
  table_setup = table_setup .. '\\setlength{\\arrayrulewidth}{0.3pt}'

  -- Center all tables
  table_setup = table_setup .. '\\centering'

  table.insert(blocks, pandoc.RawBlock('latex', table_setup))

  -- Determine if table is likely single-page (for vertical centering)
  -- Multi-page if: 10+ rows AND (6+ cols OR dense content)
  local is_dense = content_density > density_threshold
  local is_likely_multipage = row_count >= 10 and (column_count >= 6 or is_dense)

  -- Add landscape environment for wide tables or dense tables
  if use_landscape then
    table.insert(blocks, pandoc.RawBlock('latex', '\\begin{landscape}'))
    -- Remove footers on all landscape pages (including multi-page tables)
    table.insert(blocks, pandoc.RawBlock('latex', '\\pagestyle{empty}'))

    -- For single-page tables, add vertical centering
    if not is_likely_multipage then
      table.insert(blocks, pandoc.RawBlock('latex', '\\vspace*{\\fill}'))
    end

    -- Center the table horizontally in landscape mode
    table.insert(blocks, pandoc.RawBlock('latex', '\\centering'))
  end

  -- Convert table to LaTeX and add vertical rules between columns
  local table_latex = pandoc.write(pandoc.Pandoc({el}), 'latex')

  -- Modify longtable column specification to add vertical rules and outer borders
  -- Handle two patterns:
  -- 1. Simple columns: {@{}lll@{}} -> {@{}|l|l|l|@{}} (with r for numeric columns)
  table_latex = table_latex:gsub('(@{})([lrc]+)(@{})', function(left, cols, right)
    local new_cols = ''
    for i = 1, #cols do
      local col_char = cols:sub(i,i)
      -- Check if this column is numeric and should be right-aligned
      if col_char == 'l' and is_numeric_column(el, i) then
        col_char = 'r'
      end
      new_cols = new_cols .. '|' .. col_char
    end
    new_cols = new_cols .. '|'  -- Right border
    return left .. new_cols .. right
  end)

  -- 2. Complex paragraph columns: Insert | at start, between columns, and at end
  -- Keep p{} for top-aligned body rows (headers will be manually centered)
  -- Add left border before first column
  table_latex = table_latex:gsub('(@{}\n)(%s*)(>[^p]+)p({[^}]+})', '%1%2|%3p%4')
  -- Add | before subsequent columns
  table_latex = table_latex:gsub('(\n%s*)(>[^p]+)p({[^}]+})', '%1|%2p%3')
  -- Add right border: find }@{}} pattern and insert | before the first }
  table_latex = table_latex:gsub('}(@{}})', '}|%1')

  -- Right-align numeric columns in paragraph tables
  -- Extract column specifications and check each one
  local col_index = 1
  table_latex = table_latex:gsub('(>[^}]+\\arraybackslash})(p{[^}]+})', function(prefix, width)
    local alignment = prefix
    if is_numeric_column(el, col_index) then
      -- Change raggedright to raggedleft for numeric columns
      alignment = alignment:gsub('\\raggedright', '\\raggedleft')
    end
    col_index = col_index + 1
    return alignment .. width
  end)

  -- Replace booktabs rules with standard \hline for continuous borders
  table_latex = table_latex:gsub('\\toprule\\noalign{}', '\\hline')
  table_latex = table_latex:gsub('\\midrule\\noalign{}', '\\hline')
  table_latex = table_latex:gsub('\\bottomrule\\noalign{}', '\\hline')

  -- Adjust column widths for 5-column tables to give last column more space
  if column_count == 5 then
    -- Redistribute widths: make last column wider, narrow score columns
    table_latex = table_latex:gsub('0%.1333%}', '0.12}')  -- Name: 13.33% -> 12%
    table_latex = table_latex:gsub('0%.2667%}', '0.22}')  -- Department: 26.67% -> 22%
    table_latex = table_latex:gsub('0%.2222%}', '0.12}')  -- Q1/Q2 Scores: 22.22% -> 12% each
    table_latex = table_latex:gsub('0%.1556%}', '0.40}')  -- Notes: 15.56% -> 40%
  end

  -- Fix header row minipages (remove them as they interfere with alignment)
  table_latex = table_latex:gsub('\\begin{minipage}%[b%]{\\linewidth}\\raggedright\n', '')
  table_latex = table_latex:gsub('\\end{minipage}', '')

  -- Insert the modified table as raw LaTeX
  table.insert(blocks, pandoc.RawBlock('latex', table_latex))

  -- For single-page tables in landscape, add vertical centering after
  if use_landscape and not is_likely_multipage then
    table.insert(blocks, pandoc.RawBlock('latex', '\\vspace*{\\fill}'))
  end

  -- Close landscape environment
  if use_landscape then
    table.insert(blocks, pandoc.RawBlock('latex', '\\end{landscape}'))
    -- Restore page style after landscape
    table.insert(blocks, pandoc.RawBlock('latex', '\\pagestyle{fancy}'))
  end

  -- Close font environment
  table.insert(blocks, pandoc.RawBlock('latex', '}'))

  return blocks
end
