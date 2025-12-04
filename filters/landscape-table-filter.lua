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

-- Helper function to calculate optimal column widths based on per-column content density
-- Returns array of width percentages (as decimals, e.g., 0.25 for 25%)
local function calculate_column_widths(el, column_count)
  -- Array to store character counts per column
  local col_chars = {}
  local col_max_chars = {}
  local col_longest_word = {}

  -- Initialize arrays
  for i = 1, column_count do
    col_chars[i] = 0
    col_max_chars[i] = 0
    col_longest_word[i] = 0
  end

  -- Count characters in each column and track longest word
  if el.bodies then
    for _, body in ipairs(el.bodies) do
      for _, row in ipairs(body.body) do
        for col_idx, cell in ipairs(row.cells) do
          if col_idx <= column_count then
            local cell_text = pandoc.utils.stringify(cell.contents)
            local char_count = #cell_text
            col_chars[col_idx] = col_chars[col_idx] + char_count

            -- Track max cell length for this column
            if char_count > col_max_chars[col_idx] then
              col_max_chars[col_idx] = char_count
            end

            -- Find longest word in this cell
            for word in cell_text:gmatch("%S+") do
              local word_len = #word
              if word_len > col_longest_word[col_idx] then
                col_longest_word[col_idx] = word_len
              end
            end
          end
        end
      end
    end
  end

  -- Calculate total characters across all columns
  local total_chars = 0
  for i = 1, column_count do
    -- Weight: 75% total chars + 25% max char
    -- Favors columns with consistently more content over columns with one long cell
    col_chars[i] = (0.75 * col_chars[i]) + (0.25 * col_max_chars[i])
    total_chars = total_chars + col_chars[i]
  end

  -- If no content, return equal widths
  if total_chars == 0 then
    local equal_width = 1.0 / column_count
    local widths = {}
    for i = 1, column_count do
      widths[i] = equal_width
    end
    return widths
  end

  -- Calculate raw percentages
  local widths = {}
  for i = 1, column_count do
    widths[i] = col_chars[i] / total_chars
  end

  -- Calculate per-column minimum widths based on longest word
  -- Estimate: assume ~80 characters fit comfortably in full linewidth
  -- Add small buffer (2 chars) and use absolute floor of 8%
  local col_min_widths = {}
  for i = 1, column_count do
    local word_based_min = (col_longest_word[i] + 2) / 80
    -- Use max of word-based minimum and absolute floor of 8%
    col_min_widths[i] = math.max(0.08, word_based_min)
    -- Cap at 20% to prevent one long word from dominating
    col_min_widths[i] = math.min(0.20, col_min_widths[i])
  end

  -- Apply per-column minimum width constraints
  local needs_adjustment = true
  local max_iterations = 10  -- Prevent infinite loops
  local iteration = 0

  while needs_adjustment and iteration < max_iterations do
    needs_adjustment = false
    iteration = iteration + 1

    -- Find columns below their minimum
    local below_min = {}
    local below_min_total = 0
    local above_min = {}
    local above_min_total = 0

    for i = 1, column_count do
      if widths[i] < col_min_widths[i] then
        table.insert(below_min, i)
        below_min_total = below_min_total + (col_min_widths[i] - widths[i])
        needs_adjustment = true
      else
        table.insert(above_min, i)
        above_min_total = above_min_total + widths[i]
      end
    end

    if needs_adjustment then
      -- Set below-minimum columns to their minimum
      for _, i in ipairs(below_min) do
        widths[i] = col_min_widths[i]
      end

      -- Redistribute the taken space from above-minimum columns proportionally
      if #above_min > 0 and above_min_total > 0 then
        local taken_space = 0
        for _, i in ipairs(below_min) do
          taken_space = taken_space + col_min_widths[i]
        end
        local remaining = 1.0 - taken_space

        for _, i in ipairs(above_min) do
          widths[i] = (widths[i] / above_min_total) * remaining
        end
      end
    end
  end

  -- Ensure widths sum to 1.0 (handle rounding errors)
  local sum = 0
  for i = 1, column_count do
    sum = sum + widths[i]
  end

  -- Adjust last column to make total exactly 1.0
  if sum > 0 and sum ~= 1.0 then
    widths[column_count] = widths[column_count] + (1.0 - sum)
  end

  return widths
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

  -- Calculate optimal column widths based on per-column content density
  local column_widths = calculate_column_widths(el, column_count)

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

  -- Apply dynamic column widths based on content density
  -- Replace Pandoc's default widths with calculated optimal widths
  -- Pandoc uses format: p{(\linewidth - N\tabcolsep) * \real{0.XXXX}}
  local col_idx = 1
  table_latex = table_latex:gsub('\\real{(0%.[0-9]+)}', function(old_width)
    if col_idx <= column_count and column_widths[col_idx] then
      -- Format width with 4 decimal places for precision
      local new_width = string.format("%.4f", column_widths[col_idx])
      col_idx = col_idx + 1
      return '\\real{' .. new_width .. '}'
    end
    return '\\real{' .. old_width .. '}'
  end)

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
