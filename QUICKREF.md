# 🎯 Quick Reference

Common commands and tasks for your journal workflow.

## 📝 Basic Workflow

### Build a Single Entry
```bash
# With automatic encoding fixes
./build-clean.sh source/your-file.md

# Without preprocessing (if file is already clean)
./build.sh source/your-file.md
```

### Fix Encoding Issues Only
```bash
./preprocess.sh source/your-file.md
```

### Open Output Folder
```bash
open output/
```

## 🎨 Customization Quick Edits

### Change Tag Color
Edit `templates/journal-template.tex`, find:
```latex
\definecolor{tagcolor}{RGB}{100,149,237}
```
Change the RGB values (0-255 for each).

### Change Name Color
```latex
\definecolor{namecolor}{RGB}{220,20,60}
```

### Change Font
```latex
\setmainfont{Palatino}  % Try: Garamond, Baskerville, Georgia
```

### Add a Person to Recognition List
Edit `filters/name-filter.lua`, add to the list:
```lua
local common_names = {
  Andrea = true,
  Rose = true,
  YourName = true,  -- Add here
}
```

## 📏 Page Size Presets

Edit `templates/journal-template.tex`, geometry section:

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

### View LaTeX Log
```bash
cat output/*.log | tail -50
```

### Check Pandoc Version
```bash
pandoc --version
```

### Check LaTeX Installation
```bash
which xelatex
pdflatex --version
```

### Test Lua Filter Syntax
```bash
pandoc --lua-filter=filters/tag-filter.lua --to=native << EOF
This is a #test
EOF
```

## 📊 File Organization

### Recommended Structure
```
source/
  ├── 2025-01/
  │   ├── 2025-01-01.md
  │   ├── 2025-01-02.md
  │   └── ...
  ├── 2025-02/
  └── ...
```

### Naming Convention
- Daily notes: `YYYY-MM-DD.md`
- Monthly compilations: `YYYY-MM.md`
- Annual journal: `YYYY-journal.md`

## 🚀 Batch Processing (Coming Soon)

Ideas for processing multiple files:
```bash
# Process all files in a directory
for file in source/2025-01/*.md; do
  ./build.sh "$file"
done

# Combine month into single PDF
cat source/2025-01/*.md > source/2025-01-combined.md
./build.sh source/2025-01-combined.md
```

## 💡 Pro Tips

1. **Keep originals safe**: The preprocessing script creates `.bak` backups
2. **Test changes**: Always test template changes with a small file first
3. **Version control**: Consider using git to track your template changes
4. **Print test**: Print one page at actual size before printing the whole book
5. **PDF review**: Always review the PDF at 100% zoom before sending to print

## 🔗 Useful Links

- [Pandoc Manual](https://pandoc.org/MANUAL.html)
- [LaTeX Colors](https://latexcolor.com/)
- [Google Fonts](https://fonts.google.com/) (for system fonts)
- [Book Sizes Reference](https://en.wikipedia.org/wiki/Book_size)

## 📞 Common Issues

| Problem | Solution |
|---------|----------|
| Tags not colored | Check Lua filter syntax, verify LaTeX template has `\tag{}` command |
| Names not recognized | Add names to `name-filter.lua` list |
| Wrong page size | Edit geometry settings in template |
| Font not found | Use `fc-list` to see available fonts |
| Build fails | Check `output/*.log` file for errors |

---

**Tip:** Bookmark this file! Keep it open in a VS Code tab for quick reference.
