-- landscape-table-filter.lua
-- Applies smart styling to tables: landscape rotation, font switching, and dynamic sizing

-- Global variables for page dimensions (set by Meta function)
local page_width_inches = 6.0  -- Default: 6 inches
local page_height_inches = 9.0  -- Default: 9 inches

-- Helper function to parse dimension strings like "6in", "7.5in", "8.5in"
-- Returns numeric value in inches
local function parse_dimension(dim_str)
  if not dim_str then return nil end
  dim_str = tostring(dim_str)
  local num = dim_str:match("^([%d%.]+)")
  if num then
    return tonumber(num)
  end
  return nil
end

-- Meta function to capture page dimensions from metadata
function Meta(meta)
  if meta.paperwidth then
    local width_str = pandoc.utils.stringify(meta.paperwidth)
    local width = parse_dimension(width_str)
    if width then
      page_width_inches = width
    end
  end

  if meta.paperheight then
    local height_str = pandoc.utils.stringify(meta.paperheight)
    local height = parse_dimension(height_str)
    if height then
      page_height_inches = height
    end
  end

  return meta
end

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
local function calculate_column_widths(el, column_count, page_width_inches)
  -- Array to store character counts per column
  local col_chars = {}
  local col_max_chars = {}
  local col_longest_word = {}
  local col_header_chars = {}
  local col_header_longest_word = {}

  -- Initialize arrays
  for i = 1, column_count do
    col_chars[i] = 0
    col_max_chars[i] = 0
    col_longest_word[i] = 0
    col_header_chars[i] = 0
    col_header_longest_word[i] = 0
  end

  -- Analyze header content first
  if el.head and el.head.rows then
    for _, row in ipairs(el.head.rows) do
      for col_idx, cell in ipairs(row.cells) do
        if col_idx <= column_count then
          local cell_text = pandoc.utils.stringify(cell.contents)
          local char_count = #cell_text
          col_header_chars[col_idx] = col_header_chars[col_idx] + char_count

          -- Find longest word in header
          for word in cell_text:gmatch("%S+") do
            local word_len = #word
            if word_len > col_header_longest_word[col_idx] then
              col_header_longest_word[col_idx] = word_len
            end
          end
        end
      end
    end
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

  -- If no content, return equal widths and natural width of 1.0
  if total_chars == 0 then
    local equal_width = 1.0 / column_count
    local widths = {}
    for i = 1, column_count do
      widths[i] = equal_width
    end
    return widths, 1.0  -- natural_width = 1.0 (full width needed)
  end

  -- Calculate raw percentages
  local widths = {}
  for i = 1, column_count do
    widths[i] = col_chars[i] / total_chars
  end

  -- Calculate per-column minimum widths based on longest word and header content
  -- Scale character estimate based on page width (80 chars at 6", proportionally less for smaller pages)
  -- Account for margins/padding by using 75% of theoretical chars
  local chars_per_linewidth = (80 * (page_width_inches / 6.0)) * 0.75

  local col_min_widths = {}
  for i = 1, column_count do
    -- Body-based minimum (longest word + buffer)
    local body_min = (col_longest_word[i] + 2) / chars_per_linewidth

    -- Header-based minimum: try to fit entire header on one line if short
    -- If header is longer, ensure at least longest word + generous buffer fits
    local header_total_min = col_header_chars[i] / chars_per_linewidth
    local header_word_min = (col_header_longest_word[i] + 4) / chars_per_linewidth
    local header_min = math.max(header_total_min, header_word_min)

    -- Use the maximum of body and header requirements
    local content_min = math.max(body_min, header_min)

    -- Use max of content-based minimum and absolute floor of 8%
    col_min_widths[i] = math.max(0.08, content_min)
  end

  -- Calculate natural width (sum of minimum widths before adjustment)
  -- This represents the minimum width the table actually needs
  -- Do NOT cap individual minimums here - we need accurate total
  local natural_width = 0
  for i = 1, column_count do
    natural_width = natural_width + col_min_widths[i]
  end

  -- Now apply caps for the normalized widths (but natural_width remains uncapped)
  for i = 1, column_count do
    -- Cap at 25% to prevent one long header from dominating in final layout
    col_min_widths[i] = math.min(0.25, col_min_widths[i])
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

  return widths, natural_width
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
  local raw_density = estimate_content_density(el)

  -- Scale density by available space: larger pages have more room per column
  -- Use same scaling factor as threshold (1.5 power) so they balance
  local space_scaling = (page_width_inches / 6.0) ^ 1.5
  local content_density = raw_density / space_scaling

  -- Calculate optimal column widths based on per-column content density
  -- Returns both the widths (normalized to 1.0) and natural_width (sum of minimums before normalization)
  local column_widths, natural_width = calculate_column_widths(el, column_count, page_width_inches)

  -- Use scriptsize (7pt) for all tables for consistency
  local font_size = "scriptsize"  -- ~7pt

  -- Determine if table should be in landscape based on:
  -- 1. Multi-page detection (row count)
  -- 2. Whether content actually fits (natural_width)
  -- 3. Content density (scaled by page width and column count)

  -- Multi-page detection: 10+ rows likely spans pages, better in landscape for alignment
  local is_multipage = row_count >= 10

  -- Calculate density threshold scaled by both page width and column count
  -- Base threshold: 60 for 6" page
  -- Page scaling: Use quadratic scaling to be more aggressive for larger pages
  --   (larger pages have proportionally more space per column)
  -- Column scaling: More columns = lower threshold (content spread thinner)
  --   - Anchored at 3 columns (no adjustment)
  --   - Each column above 3: 15% reduction
  --   - 2 columns: Very high threshold (5x) - 2-column tables rarely need landscape
  --   - 1 column: Extremely high threshold (10x) - should never go landscape
  local page_scaling = (page_width_inches / 6.0) ^ 1.5
  local base_threshold = 60 * page_scaling
  local column_scaling
  if column_count <= 1 then
    column_scaling = 10.0  -- 1-column tables should never go landscape
  elseif column_count == 2 then
    column_scaling = 5.0  -- 2-column tables can handle high density via width adjustment
  else
    column_scaling = 1.0 - ((column_count - 3) * 0.15)
  end
  local density_threshold = base_threshold * column_scaling

  -- Debug output
  io.stderr:write(string.format("Table: cols=%d, rows=%d, natural_width=%.2f, density=%.1f, threshold=%.1f\n",
    column_count, row_count, natural_width, content_density, density_threshold))

  local use_landscape = false
  local reason = ""

  if is_multipage then
    -- Multi-page tables always landscape for better cross-page alignment
    use_landscape = true
    reason = "multi-page"
  elseif natural_width > 1.0 then
    -- Content doesn't fit in portrait - longest words/headers need more space
    use_landscape = true
    reason = string.format("content doesn't fit, needs %.0f%% width", natural_width * 100)
  elseif content_density > density_threshold then
    -- High content density for this column count and page size
    use_landscape = true
    reason = "content density"
  else
    -- Low density and content fits
    use_landscape = false
    reason = "low density, content fits"
  end

  io.stderr:write(string.format("  -> %s (%s)\n", use_landscape and "LANDSCAPE" or "PORTRAIT", reason))

  -- Smart sizing: Only apply width scaling to LANDSCAPE tables on pages >= 6"
  -- Portrait tables always use full width
  -- If natural_width < 1.0, the table doesn't need full page width
  local table_width_scale = 1.0
  if use_landscape and page_width_inches >= 6.0 and natural_width < 1.0 then
    table_width_scale = natural_width
  end

  -- Build the LaTeX wrapper
  local blocks = {}

  -- Add space before table to separate from preceding text
  table.insert(blocks, pandoc.RawBlock('latex', '\\vspace{1.5\\baselineskip}'))

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

  -- First, apply table width scaling if needed
  if table_width_scale < 1.0 then
    -- Replace \linewidth with scaled version, but only in column specifications
    -- Pattern: (\linewidth - N\tabcolsep) where N is a number
    local scale_str = string.format("%.4f", table_width_scale)
    table_latex = table_latex:gsub('%(\\linewidth %- (%d+)\\tabcolsep%)',
      function(n)
        return '(' .. scale_str .. '\\linewidth - ' .. n .. '\\tabcolsep)'
      end)
  end

  -- Then apply per-column width adjustments
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

  -- Trim leading and trailing spaces from all table cells
  -- Match content between & or start/end of row and trim
  table_latex = table_latex:gsub('([&\n])%s+([^&\\\n]+)%s+([&\\])', '%1%2%3')
  table_latex = table_latex:gsub('^%s+([^&\\\n]+)%s+([&\\])', '%1%2')

  -- Make header text bold and colored with background
  -- Format headers by wrapping non-command text in textbf and color, add row background
  -- Trim spaces within the header formatting to prevent alignment issues
  table_latex = table_latex:gsub('(\\caption.-\n\\hline\n)(.-)(\\hline\n\\endfirsthead)', function(caption, header_content, end_marker)
    -- First normalize spaces in header: collapse newlines and multiple spaces to single space
    header_content = header_content:gsub('%s+', ' ')
    -- Add row color and wrap words with formatting
    local formatted = '\\rowcolor{tableheaderbg} ' .. header_content:gsub('([%a][%w%s]*)', function(word)
      -- Trim the word before wrapping
      word = word:match('^%s*(.-)%s*$')
      -- Only format actual words, not LaTeX commands
      if word and word ~= '' and not word:match('^%s*$') then
        return '\\textbf{\\color{tableheadertext}{' .. word .. '}}'
      end
      return ''
    end)
    return caption .. formatted .. end_marker
  end)

  -- Also format repeated headers (between \endfirsthead and \endhead)
  table_latex = table_latex:gsub('(\\endfirsthead\n\\hline\n)(.-)(\\hline\n\\endhead)', function(start, header_content, end_marker)
    -- First normalize spaces in header: collapse newlines and multiple spaces to single space
    header_content = header_content:gsub('%s+', ' ')
    local formatted = '\\rowcolor{tableheaderbg} ' .. header_content:gsub('([%a][%w%s]*)', function(word)
      -- Trim the word before wrapping
      word = word:match('^%s*(.-)%s*$')
      if word and word ~= '' and not word:match('^%s*$') then
        return '\\textbf{\\color{tableheadertext}{' .. word .. '}}'
      end
      return ''
    end)
    return start .. formatted .. end_marker
  end)

  -- Add zebra striping by inserting \rowcolor before each data row
  -- Find the end of table headers and start of data rows
  local row_num = 0
  table_latex = table_latex:gsub('(\\endlastfoot\n)(.-)(\n\\end{longtable})', function(header_end, body, table_end)
    -- Split body into lines and process each row
    local lines = {}
    local in_row = false
    local row_content = ""

    for line in (body .. "\n"):gmatch("([^\n]*)\n") do
      if line:match("\\\\%s*$") then
        -- End of row found
        row_content = row_content .. line
        row_num = row_num + 1
        local color = (row_num % 2 == 1) and 'white' or 'tablerowstripe'
        table.insert(lines, '\\rowcolor{' .. color .. '} ' .. row_content)
        row_content = ""
      elseif line:match("\\hline") or line == "" then
        -- Standalone line (hline or empty)
        if row_content ~= "" then
          table.insert(lines, row_content)
          row_content = ""
        end
        table.insert(lines, line)
      else
        -- Continuation of previous line or start of new row
        if row_content ~= "" then
          row_content = row_content .. "\n" .. line
        else
          row_content = line
        end
      end
    end

    return header_end .. table.concat(lines, "\n") .. table_end
  end)

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

  -- Add space after table to separate from following text
  table.insert(blocks, pandoc.RawBlock('latex', '\\vspace{1.5\\baselineskip}'))

  return blocks
end

-- Remove horizontal rules (---) from output
function HorizontalRule(el)
  return {}
end

-- Return filter with explicit order: Meta must run before Table
return {
  { Meta = Meta },
  { Table = Table, HorizontalRule = HorizontalRule }
}
