# 🎯 Quick Reference

Common commands and tasks for your journal workflow.

## 📝 Basic Workflow

### Test Your Installation
```bash
# Process the included test.zip file to verify everything works
./process-capacities-export.sh source/test.zip
./preprocess-capacities.sh "Test Journal" "Test User" source/journal.md
./build.sh source/journal.md
```

The test file exercises all filters and generates entries in all 6 indexes.

### Test Emoji and Checkbox Support
```bash
# Build the emoji test file
./build.sh source/emoji-test.md

# View the result
open output/emoji-test.pdf
```

This tests color emoji rendering and task list checkbox formatting.

### Build from Journal Markdown
```bash
# Clean build (clears output directory first)
./build.sh source/journal.md

# Keep existing output files
./build.sh source/journal.md --keep-output

# With preprocessing
./build-clean.sh source/journal.md
```

### Process Capacities Export
```bash
# 1. Place your Capacities export .zip in source/
# 2. Run the processor
./process-capacities-export.sh source/your-export.zip

# 3. Preprocess for LaTeX
./preprocess-capacities.sh "My Journal" "Your Name" source/journal.md

# 4. Build the PDF
./build.sh source/journal.md
```

### Fix Encoding Issues Only
```bash
./preprocess.sh source/journal.md
```

### Open Output Folder
```bash
open output/
```

## 🔧 Script Reference

### build.sh
```bash
./build.sh <input.md>                    # Clean build
./build.sh <input.md> --keep-output      # Preserve output files
```

### process-capacities-export.sh
```bash
./process-capacities-export.sh <zip-file>
# Example: ./process-capacities-export.sh source/test.zip
# Requires: Valid .zip file path
# Creates: source/journal.md and copies assets
```

### preprocess-capacities.sh
```bash
./preprocess-capacities.sh [title] [author] [input-file]
./preprocess-capacities.sh [title] [author] [input-file] --toggle-deindent
# Default title: "Journal"
# Default author: "Julio Terra"
# Default input: "source/journal.md"
# --toggle-deindent: Remove 4-space indentation from Capacities toggle groups (for personal journals)
# Default: Skip deindentation (for test files and properly structured content)
```

### preprocess.sh
```bash
./preprocess.sh <markdown-file>
# Fixes UTF-8 encoding issues
# Creates .bak backup
```

### build-clean.sh
```bash
./build-clean.sh <input.md>
./build-clean.sh <input.md> --skip-preprocess
```

## 🎨 Customization Quick Edits

### Change Tag Color
Edit `templates/journal-template.tex` (line ~65):
```latex
\definecolor{tagcolor}{RGB}{100,149,237}  % Cornflower blue
```
Change RGB values (0-255 each).

### Change Font
Edit `templates/journal-template.tex` (line ~25):
```latex
\setmainfont{VerdigrisMVBProText-Rg}[
  Extension={.otf},
  BoldFont={VerdigrisMVBProText-Bd},
  ItalicFont={VerdigrisMVBProText-It},
  BoldItalicFont={VerdigrisMVBProText-BdIt},
  RawFeature={fallback=emojifallback}
]

% Popular alternatives (keep emoji fallback!):
% \setmainfont{Palatino}[RawFeature={fallback=emojifallback}]
% \setmainfont{Garamond}[RawFeature={fallback=emojifallback}]
```

**Check available fonts:**
```bash
fc-list : family | sort | uniq
luaotfload-tool --find="Font Name"  # Check if LuaLaTeX can find it
```


### Add a New Index Type
See README.md "Adding a New Index Type" section for complete instructions.

Quick summary:
1. Add `\makeindex[name=newtype,title=NewType,columns=2]` in template
2. Add `newtype` to build.sh makeindex loop
3. Update filters to route entries
4. Add `\printindexsection{NewType}{newtype}` in template

## 📏 Page Size and Margins

Configure page dimensions and margins using command-line arguments:

### Standard Sizes
```bash
# 6" × 9" (Trade Paperback) - default
./build.sh source/journal.md

# 5" × 8" (Digest)
./build.sh source/journal.md --paperwidth 5in --paperheight 8in

# 7" × 10" (Royal)
./build.sh source/journal.md --paperwidth 7in --paperheight 10in

# A5 (European)
./build.sh source/journal.md --paperwidth 148mm --paperheight 210mm

# 8.5" × 11" (US Letter)
./build.sh source/journal.md --paperwidth 8.5in --paperheight 11in
```

### Custom Margins
```bash
# Customize all margins
./build.sh source/journal.md \
  --top 1in \
  --bottom 1in \
  --inner 1.25in \
  --outer 0.75in \
  --bindingoffset 0.5in

# Just adjust binding offset
./build.sh source/journal.md --bindingoffset 0.5in
```

### Available Options
- `--paperwidth <size>` (default: 6in)
- `--paperheight <size>` (default: 9in)
- `--top <size>` (default: 0.75in)
- `--bottom <size>` (default: 0.75in)
- `--inner <size>` (default: 0.875in)
- `--outer <size>` (default: 0.625in)
- `--bindingoffset <size>` (default: 0.25in)

## 🔍 Debugging

### View Build Logs
```bash
# Main build log
cat logs/build.sh-build.log | tail -50

# Index generation log
cat logs/build.sh-index.log

# All logs
ls -lt logs/
```

### Check Software Versions
```bash
pandoc --version
lualatex --version
fc-list --version  # Font config
```

### Check LaTeX Installation
```bash
which lualatex
luaotfload-tool --version
kpsewhich imakeidx.sty  # Check for imakeidx package
```

### Test Filter Syntax
```bash
# Test a single filter
pandoc --lua-filter=filters/tag-filter.lua --to=native << EOF
This is a #test
EOF

# Test filter pipeline
pandoc --lua-filter=filters/filter-media-links.lua \
       --lua-filter=filters/remove-object-embeds.lua \
       --to=native source/journal.md | head -100
```

### Verify Index Files
```bash
# Check .idx files were created
ls -la output/*.idx

# Check .ind files were generated
ls -la output/*.ind

# View an index file
cat output/people.ind
```

## 📚 Filter Reference

The workflow uses Lua filters in this order:

1. **task-list-filter.lua** - Preserve task list structure, convert checkboxes
2. **filter-media-links.lua** - Clean media references
3. **remove-object-embeds.lua** - Remove standalone embedded pages, convert inline page links to plain text
4. **landscape-table-filter.lua** - Analyze tables, apply adaptive orientation and styling
5. **add-index-entries.lua** - Route objects to indexes
6. **tag-filter.lua** - Process hashtags, apply background highlighting

## 📊 Table Quick Reference

### Writing Tables in Markdown

```markdown
Table: Your Caption Here

| Column 1 | Column 2 | Column 3 |
|:---------|:---------|:---------|
| Data     | Data     | Data     |
| Data     | Data     | Data     |
```

### Table Orientation Logic

- **Portrait**: Low-density tables, fits in portrait width (< 100%)
- **Landscape**: High-density tables, wide tables (> 100% width), or 15+ rows

The filter automatically analyzes and chooses the best orientation!

### Table Styling

All tables get:
- Sans-serif font (Helvetica Neue)
- Zebra striping (alternating row colors)
- Professional borders and spacing
- Adaptive column widths

### Testing Tables

```bash
# The test.zip includes 14 table tests
./process-capacities-export.sh source/test.zip
./preprocess-capacities.sh "Test" "Test User" source/journal.md
./build.sh source/journal.md
```

## 📇 Index Categories

The system generates 6 separate indexes:

| Index | Contains | Filter |
|-------|----------|--------|
| **Books** | Book references | add-index-entries.lua |
| **Definitions** | Defined terms | add-index-entries.lua |
| **Organizations** | Schools, companies | add-index-entries.lua |
| **People** | People's names | add-index-entries.lua |
| **Projects** | Project references | add-index-entries.lua |
| **Tags** | All hashtags | tag-filter.lua |

## 📊 File Organization

### Recommended Structure
```
source/
  ├── capacities-export/       # Extracted Capacities data
  │   ├── DailyNotes/
  │   ├── People/
  │   ├── Organizations/
  │   └── ...
  ├── journal.md               # Generated combined journal
  └── *.zip                    # Capacities export files

output/
  ├── journal.pdf              # Your final PDF
  ├── journal.tex              # Generated LaTeX
  ├── *.idx                    # Raw index files (6)
  └── *.ind                    # Formatted index files (6)

assets/
  ├── Images/Media/            # Copied from Capacities
  └── PDFs/Media/              # Copied from Capacities

logs/
  ├── build.sh-build.log       # Build output
  └── build.sh-index.log       # makeindex output
```

## 💡 Pro Tips

1. **Always use clean builds** - Default behavior now prevents stale file bugs
2. **Keep originals safe** - Preprocessing creates `.bak` backups automatically
3. **Test template changes** - Always test with a small file first
4. **Check fonts** - Use `fc-list` if you see font errors
5. **Version control** - Consider using git for your template customizations
6. **Print test** - Print one page at actual size before printing the whole book
7. **PDF review** - Always review at 100% zoom before sending to print
8. **Check indexes** - Verify all 6 indexes appear and are complete
9. **Monitor logs** - Check logs/ directory when builds fail
10. **Clean output** - Use --keep-output sparingly, clean builds are safer

## 🚀 Common Workflows

### Full Capacities to PDF
```bash
# 1. Export from Capacities, save .zip to source/
# 2. Process the export
./process-capacities-export.sh source/your-export.zip

# 3. Preprocess the combined journal
./preprocess-capacities.sh "2023 Journal" "Your Name" source/journal.md

# 4. Build the PDF
./build.sh source/journal.md

# 5. Review
open output/journal.pdf
```

### Quick Rebuild (Already Processed)
```bash
# If you've already processed and just need to rebuild
./build.sh source/journal.md
```

### Update After Template Changes
```bash
# Clean build ensures all changes take effect
./build.sh source/journal.md
# (output is cleaned automatically)
```

### Debugging Index Issues
```bash
# 1. Check that .idx files were created
ls -la output/*.idx

# 2. Check makeindex log
cat logs/build.sh-index.log

# 3. Verify .ind files exist
ls -la output/*.ind

# 4. If missing, check build.sh processes all 6 indexes
grep "for idx in" build.sh
```

## 🔗 Useful Links

- [Pandoc Manual](https://pandoc.org/MANUAL.html) - Pandoc documentation
- [Lua Filters Guide](https://pandoc.org/lua-filters.html) - Filter development
- [imakeidx Package](https://ctan.org/pkg/imakeidx) - Multiple indexes
- [LaTeX Colors](https://latexcolor.com/) - Color reference
- [Google Fonts](https://fonts.google.com/) - Font inspiration
- [Book Sizes Reference](https://en.wikipedia.org/wiki/Book_size) - Standard sizes

## 📞 Common Issues

| Problem | Solution |
|---------|----------|
| Tags not colored | Check `\tag{}` command in template, verify tag-filter.lua ran |
| Wrong page size | Edit geometry settings in template |
| Font not found | Use `fc-list` to check availability, update template |
| Build fails | Check `logs/build.sh-build.log` for errors |
| Indexes missing | Check `logs/build.sh-index.log`, verify build.sh processes all 6 |
| Stale output | Don't use --keep-output unless necessary |
| Encoding issues | Run `./preprocess.sh` or `./preprocess-capacities.sh` |

## ⌨️ Keyboard Shortcuts (VS Code)

If using VS Code with LaTeX Workshop:

- `Cmd+Alt+B` - Build LaTeX
- `Cmd+Alt+V` - View PDF
- `Cmd+Alt+J` - Jump to PDF location
- `Cmd+Shift+P` - Command palette

---

**Tip:** Bookmark this file! Keep it open in a VS Code tab for quick reference during your workflow.
