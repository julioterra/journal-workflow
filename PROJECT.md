# 📦 Journal Workflow - Project Overview

## What You've Got

This is a complete, ready-to-use system for converting your Capacities journal markdown exports into beautiful, print-ready PDF books.

```
journal-workflow/
│
├── 📄 Documentation
│   ├── README.md          # Main guide - start here!
│   ├── INSTALL.md         # Step-by-step installation
│   ├── QUICKREF.md        # Command cheat sheet
│   └── PROJECT.md         # This file
│
├── 🔨 Build Scripts
│   ├── build.sh           # Main build script
│   ├── build-clean.sh     # Build with preprocessing
│   └── preprocess.sh      # Fix character encoding
│
├── 📁 Working Directories
│   ├── source/            # Put your markdown files here
│   │   └── 2025-10-21.md  # Sample file (your content)
│   ├── output/            # PDFs appear here
│   ├── templates/         # LaTeX templates
│   │   └── journal-template.tex
│   ├── filters/           # Lua filters for processing
│   │   ├── tag-filter.lua
│   │   └── name-filter.lua
│   └── assets/            # Images, fonts, etc.
│
├── ⚙️ Configuration
│   ├── .vscode/
│   │   └── settings.json  # VS Code settings
│   ├── .gitignore         # Git ignore rules
│   └── config/            # Future config files
│
└── 🎯 Sample Content
    └── source/2025-10-21.md  # Your sample journal entry
```

## Key Components Explained

### 📝 LaTeX Template (`journal-template.tex`)
- **Purpose**: Defines the look and feel of your PDF
- **What it does**:
  - Sets page size (6" × 9" book format)
  - Defines fonts (Palatino for body text)
  - Creates custom commands for tags and names
  - Sets up indexes
  - Defines colors, margins, headers, footers
- **Customizable**: Yes! Change colors, fonts, layout

### 🏷️ Tag Filter (`tag-filter.lua`)
- **Purpose**: Process hashtags in your markdown
- **What it does**:
  - Finds all `#tags` in your text
  - Converts them to LaTeX `\tag{}` commands
  - Makes them appear colored in the PDF
  - Adds them to the tag index
- **Example**: `#PersonalJournal` → Blue, indexed tag

### 👤 Name Filter (`name-filter.lua`)
- **Purpose**: Extract and highlight people's names
- **What it does**:
  - Finds Capacities person links: `[Andrea](https://app...)`
  - Converts to LaTeX `\person{}` commands
  - Makes names appear colored in PDF
  - Adds them to the names index
  - Requires names to be in a recognition list
- **Customizable**: Add your frequent contacts to the list

### 🔧 Build Script (`build.sh`)
- **Purpose**: One command to convert markdown → PDF
- **What it does**:
  1. Takes your markdown file
  2. Runs it through Pandoc
  3. Applies both Lua filters
  4. Uses the LaTeX template
  5. Generates PDF with XeLaTeX
  6. Opens the result
- **Usage**: `./build.sh source/your-file.md`

### 🧹 Preprocess Script (`preprocess.sh`)
- **Purpose**: Fix character encoding issues
- **What it does**:
  - Finds garbled characters (â€", â€™, etc.)
  - Replaces with correct UTF-8 characters
  - Creates a backup (.bak file)
- **When to use**: If you see weird characters in output

### 🔄 Combined Script (`build-clean.sh`)
- **Purpose**: Preprocess + build in one command
- **What it does**:
  1. Fixes encoding issues
  2. Builds the PDF
- **Usage**: `./build-clean.sh source/your-file.md`

## Workflow Visualization

```
Your Capacities Export (Markdown)
          ↓
    preprocess.sh (optional)
    [Fixes encoding]
          ↓
    Pandoc + Filters
    ├─ name-filter.lua [Finds people]
    └─ tag-filter.lua  [Finds tags]
          ↓
    LaTeX Template
    [Applies styling]
          ↓
    XeLaTeX Engine
    [Generates PDF]
          ↓
    Beautiful PDF! 📕
    - Colored tags
    - Highlighted names
    - Professional layout
    - Indexes included
```

## What Works Now

✅ **Single file conversion** - Convert one journal entry
✅ **Tag highlighting** - All hashtags colored and indexed
✅ **Name extraction** - People's names colored and indexed  
✅ **Professional typography** - Book-quality layout
✅ **Print-ready format** - 6" × 9" with proper margins
✅ **Automatic indexes** - Names and tags at the back
✅ **Character encoding fixes** - Clean up export issues
✅ **VS Code integration** - Settings ready for LaTeX Workshop

## What's Coming

🚧 **Batch processing** - Combine multiple days/months
🚧 **URL footnotes** - External links as footnotes
🚧 **Image handling** - Resize and place images properly
🚧 **Custom front matter** - Title page, dedication
🚧 **Month dividers** - Chapter breaks for each month
🚧 **Statistics page** - Word count, entry count
🚧 **Date formatting** - Prettier date displays
🚧 **Table of contents** - Monthly TOC generation

## Getting Started Path

1. **Install Everything** → Follow `INSTALL.md`
2. **First Build Test** → Use the sample file
3. **Review Output** → See what it creates
4. **Customize** → Tweak colors, fonts, layout
5. **Add Your Content** → Process your journal entries
6. **Iterate** → Refine until perfect
7. **Print** → Send to printer or print-on-demand

## Tech Stack

| Component | Purpose | Why This Choice |
|-----------|---------|-----------------|
| Pandoc | Markdown → LaTeX | Industry standard, powerful |
| XeLaTeX | LaTeX → PDF | Unicode support, modern fonts |
| Lua | Filtering/Processing | Built into Pandoc, fast |
| VS Code | Editor | Best free editor, great extensions |
| LaTeX Workshop | Live preview | Makes editing easier |
| Book class | Document type | Professional book layout |

## Customization Hotspots

**Most Common Tweaks:**
1. Colors (template: `\definecolor` lines)
2. Fonts (template: `\setmainfont` lines)
3. Page size (template: `geometry` package)
4. Name list (name-filter: `common_names` table)
5. Margins (template: geometry settings)

**Less Common:**
- Header/footer style
- Chapter formatting
- Index appearance
- Table styling
- Link behavior

## File Size Expectations

| Content | Typical Size |
|---------|-------------|
| Single day | 10-50 KB (markdown) → 100-500 KB (PDF) |
| One month | 300 KB - 1.5 MB (markdown) → 2-5 MB (PDF) |
| Full year | 3-15 MB (markdown) → 15-50 MB (PDF) |

*Sizes increase with images*

## Print Specifications

**Current Settings:**
- **Trim size**: 6" × 9" (152 mm × 229 mm)
- **Binding**: Perfect bound (left side)
- **Interior**: Black & white
- **Paper**: Cream or white (your choice)
- **Resolution**: 300+ DPI (PDF native)

**Printing Options:**
- Self-print at home/office
- Local print shop
- Print-on-demand services:
  - Lulu.com
  - Blurb.com
  - Amazon KDP (Kindle Direct Publishing)
  - IngramSpark

## Development Roadmap

### Phase 1: ✅ Basic Pipeline (Complete!)
- Template creation
- Filter development  
- Build scripts
- Documentation

### Phase 2: 🚧 Enhancements (Next)
- Batch processing
- Better character handling
- Image optimization
- URL/footnote system

### Phase 3: 🔮 Advanced Features (Future)
- Multiple template options
- Interactive configuration
- Statistics generation
- Web preview

### Phase 4: 🎨 Polish (Future)
- Professional themes
- Export presets
- Cloud integration
- Mobile-friendly preview

## Questions & Answers

**Q: Do I need to know LaTeX?**
A: No! The template is ready to use. You can customize by example.

**Q: Can I change the book size?**
A: Yes! Edit the geometry settings in the template.

**Q: How do I add more names?**
A: Edit `filters/name-filter.lua` and add to the `common_names` list.

**Q: Can I use this for other content?**
A: Yes! It works with any markdown content.

**Q: What if I want different colors?**
A: Edit the `\definecolor` lines in the template. Use RGB values 0-255.

**Q: How do I print this?**
A: Use the PDF from `output/` with any print service or home printer.

## Support & Learning

- Read through all `.md` files in the project
- Check `QUICKREF.md` for quick answers
- Look at the sample file for markdown structure
- Experiment with small changes
- Test often with your sample file

## Success Metrics

You'll know it's working when you see:
- ✅ PDF opens automatically after build
- ✅ Tags appear in blue color
- ✅ Names appear in red color  
- ✅ Indexes show at the back
- ✅ Layout looks professional
- ✅ Ready to print or share

---

**Ready to begin?** Start with `INSTALL.md` → then try `./build.sh source/2025-10-21.md`
