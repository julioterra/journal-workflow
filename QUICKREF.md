# 🎯 Quick Reference

Common commands and tasks for your journal workflow.

## 📝 Basic Workflow

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
./process-capacities-export.sh

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
./process-capacities-export.sh
# Requires: .zip file in source/ directory
# Creates: source/journal.md and copies assets
```

### preprocess-capacities.sh
```bash
./preprocess-capacities.sh [title] [author] [input-file]
# Default title: "Journal"
# Default author: "Julio Terra"
# Default input: "source/journal.md"
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

### Change Name Color
Edit `templates/journal-template.tex` (line ~66):
```latex
\definecolor{namecolor}{RGB}{220,20,60}  % Crimson
```

### Change Font
Edit `templates/journal-template.tex` (line ~14):
```latex
\setmainfont{Corundum Text Book}[
  BoldFont={Corundum Text Bold}
]

% Popular alternatives:
% \setmainfont{Palatino}
% \setmainfont{Garamond}
% \setmainfont{Baskerville}
% \setmainfont{Georgia}
% \setmainfont{Hoefler Text}
```

**Check available fonts:**
```bash
fc-list : family | sort | uniq
```

### Add a Person to Recognition List
Edit `filters/name-filter.lua`:
```lua
local common_names = {
  Andrea = true,
  Rose = true,
  Luca = true,
  Mila = true,
  YourName = true,  -- Add here
}
```

### Add a New Index Type
See README.md "Adding a New Index Type" section for complete instructions.

Quick summary:
1. Add `\makeindex[name=newtype,title=NewType,columns=2]` in template
2. Add `newtype` to build.sh makeindex loop
3. Update filters to route entries
4. Add `\printindexsection{NewType}{newtype}` in template

## 📏 Page Size Presets

Edit `templates/journal-template.tex`, geometry section (line ~22):

### Standard Sizes
```latex
% Current: 6" × 9" (Trade Paperback)
paperwidth=6in, paperheight=9in

% Digest: 5" × 8"
paperwidth=5in, paperheight=8in

% Crown Quarto: 7.44" × 9.68"
paperwidth=7.44in, paperheight=9.68in

% A5: 5.83" × 8.27"
paperwidth=5.83in, paperheight=8.27in

% US Letter: 8.5" × 11"
paperwidth=8.5in, paperheight=11in
```

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
xelatex --version
fc-list --version  # Font config
```

### Check LaTeX Installation
```bash
which xelatex
pdflatex --version
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

The workflow uses 5 filters in this order:

1. **filter-media-links.lua** - Clean media references
2. **remove-object-embeds.lua** - Remove standalone embedded pages
3. **add-index-entries.lua** - Route objects to indexes
4. **name-filter.lua** - Process people's names
5. **tag-filter.lua** - Process hashtags

## 📇 Index Categories

The system generates 6 separate indexes:

| Index | Contains | Filter |
|-------|----------|--------|
| **Books** | Book references | add-index-entries.lua |
| **Definitions** | Defined terms | add-index-entries.lua |
| **Organizations** | Schools, companies | add-index-entries.lua |
| **People** | People's names | name-filter.lua + add-index-entries.lua |
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
./process-capacities-export.sh

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
| Names not recognized | Add to `name-filter.lua` common_names table |
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
