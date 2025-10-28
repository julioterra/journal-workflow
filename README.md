# 📔 Journal Workflow: Capacities → PDF

A complete Pandoc + LaTeX workflow for converting your Capacities journal (exported in Markdown) into beautifully typeset, print-ready PDFs.

## 📁 Project Structure

```
journal-workflow/
├── source/           # Your markdown files from Capacities
├── templates/        # LaTeX templates
├── filters/          # Lua filters for processing
├── output/           # Generated PDFs
├── assets/           # Images, fonts, etc.
├── config/           # Additional configuration files
├── .vscode/          # VS Code settings
└── build.sh          # Build script
```

## 🎯 Current Features

### ✅ Implemented
- **Custom LaTeX template** with beautiful typography (Palatino font)
- **Print-ready dimensions** (6" × 9" book format)
- **Tag highlighting**: All `#tags` are colored blue and indexed
- **Name extraction**: People's names (from Capacities links) are colored red and indexed
- **Automatic indexes**: Generated for both names and tags
- **Clean typography**: Professional margins, headers, and footers
- **Build script**: One command to convert markdown → PDF

### 🚧 Coming Soon
- Character encoding fixes (those â€" and â€™ issues)
- URL/reference footnotes
- Custom front matter (title page, dedication)
- Batch processing for multiple files
- Advanced styling options
- Image handling improvements

## 🚀 Quick Start

### 1. First Build Test

Let's test the workflow with your sample file:

```bash
cd ~/Documents/journal-workflow  # or wherever you put it
./build.sh source/2025-10-21.md
```

This will create `output/2025-10-21.pdf` and open it automatically!

### 2. Understanding the Output

Look for these features in your PDF:
- **Tags** like #PersonalJournal appear in **blue** and are indexed
- **Names** like Andrea and Rose appear in **red** and are indexed
- **Page numbers** and headers on each page
- **Indexes** at the back for names and tags

## 📝 Adding More Content

### Single File
```bash
# Copy your markdown file to source/
cp ~/path/to/your-journal-entry.md source/

# Build it
./build.sh source/your-journal-entry.md
```

### Multiple Files (Coming Soon)
We'll create a script to combine multiple days/entries into one annual journal.

## 🎨 Customization Guide

### Changing Colors

Edit `templates/journal-template.tex` and modify these lines:

```latex
\definecolor{tagcolor}{RGB}{100,149,237}      % Tags (currently blue)
\definecolor{namecolor}{RGB}{220,20,60}       % Names (currently red)
\definecolor{linkcolor}{RGB}{70,130,180}      % Links
\definecolor{headingcolor}{RGB}{47,79,79}     % Headings
```

### Changing Fonts

In the template:
```latex
\setmainfont{Palatino}              % Main body text
\setsansfont{Helvetica Neue}        % Sans serif
\setmonofont[Scale=0.9]{Menlo}      % Code/monospace
```

Try: Garamond, Baskerville, Hoefler Text, or any font on your Mac.

### Changing Page Size

For different book sizes, modify the geometry settings:

```latex
% Current: 6" × 9" (standard trade paperback)
\usepackage[
  paperwidth=6in,
  paperheight=9in,
  top=0.75in,
  bottom=0.75in,
  inner=0.875in,
  outer=0.625in,
  bindingoffset=0.25in
]{geometry}

% For 5" × 8" (digest size):
paperwidth=5in, paperheight=8in

% For A5 (European standard):
paperwidth=148mm, paperheight=210mm
```

## 🔧 VS Code Setup

### LaTeX Workshop Extension

1. Install "LaTeX Workshop" extension in VS Code
2. Open a `.md` file from the `source/` folder
3. The extension should recognize the project structure
4. Save the file to trigger automatic PDF generation

### Live Preview

- **Method 1**: Use the build script (recommended for now)
- **Method 2**: Configure LaTeX Workshop to watch markdown files (advanced)

## 🐛 Troubleshooting

### Character Encoding Issues

Those `â€"` and `â€™` characters are UTF-8 encoding problems. We'll fix these with:
1. A pre-processing script
2. Or a Lua filter to replace them during conversion

### "Command not found: pandoc"

Make sure Pandoc is installed:
```bash
brew install pandoc
```

### "Command not found: xelatex"

Make sure MacTeX is installed:
```bash
brew install --cask mactex
```

Then restart Terminal.

### Build Fails

Check the error message. Common issues:
- Missing LaTeX packages (MacTeX should have everything)
- Syntax errors in markdown
- Missing template or filters

## 📚 Understanding the Filters

### name-filter.lua
- Finds Capacities links like `[Andrea](https://app.capacities.io/...)`
- Converts them to `\person{Andrea}` LaTeX commands
- Only processes names in a known list (you can expand it)
- Adds names to the index

### tag-filter.lua
- Finds hashtags like `#PersonalJournal`
- Converts them to `\tag{PersonalJournal}` LaTeX commands
- Handles multiple consecutive tags: `#tag1#tag2#tag3`
- Adds tags to the index

## 🎯 Next Steps

1. **Test the build** with your sample file
2. **Review the output PDF** and note what you like/dislike
3. **Identify customizations** you want (colors, fonts, layout)
4. **Expand the name list** in `name-filter.lua` with your frequent contacts
5. **Try with more content** to see how it scales

## 💡 Tips for Best Results

### Writing in Capacities
- Use consistent tag formats: `#tag` not `# tag`
- Link people's names consistently
- Use markdown headings (##, ###) for structure
- Keep formatting simple (bold, italic, lists)

### Preparing for Print
- Review the PDF at 100% zoom (actual size)
- Check margins look good
- Verify indexes are complete
- Test print one page to check sizing

## 🔮 Future Enhancements

Ideas for future development:
- [ ] Photo handling (resize, placement)
- [ ] Custom chapter breaks for each month
- [ ] Statistics page (word count, entry count, etc.)
- [ ] Mood tracking visualization
- [ ] Smart date formatting
- [ ] Automatic TOC generation by month
- [ ] Export configuration presets
- [ ] Web-based preview option

## 📖 Resources

- [Pandoc Manual](https://pandoc.org/MANUAL.html)
- [LaTeX Documentation](https://www.latex-project.org/help/documentation/)
- [Lua Filters Guide](https://pandoc.org/lua-filters.html)
- [VS Code LaTeX Workshop](https://github.com/James-Yu/LaTeX-Workshop)

---

**Questions?** Review this README and try building your first PDF. Then we can iterate on customizations!
