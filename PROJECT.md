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
│   ├── build.sh                      # Main build script
│   ├── build-clean.sh                # Build with preprocessing
│   ├── preprocess.sh                 # Fix character encoding
│   ├── preprocess-capacities.sh      # Capacities-specific preprocessing
│   └── process-capacities-export.sh  # Extract and process exports
│
├── 📁 Working Directories
│   ├── source/            # Put your markdown files here
│   │   ├── journal.md             # Combined journal (generated)
│   │   └── capacities-export/     # Extracted Capacities data
│   ├── output/            # PDFs appear here (cleaned on build)
│   ├── templates/         # LaTeX templates
│   │   └── journal-template.tex
│   ├── filters/           # Lua filters for processing
│   │   ├── task-list-filter.lua
│   │   ├── filter-media-links.lua
│   │   ├── remove-object-embeds.lua
│   │   ├── landscape-table-filter.lua
│   │   ├── add-index-entries.lua
│   │   └── tag-filter.lua
│   ├── assets/            # Images, PDFs, fonts
│   └── logs/              # Build logs
│
├── ⚙️ Configuration
│   ├── .vscode/
│   │   └── settings.json  # VS Code settings
│   └── .gitignore         # Git ignore rules
│
└── 🎯 Sample Content
    └── source/capacities-export/  # Your extracted Capacities data
```

## Key Components Explained

### 📝 LaTeX Template (`journal-template.tex`)
- **Purpose**: Defines the look and feel of your PDF
- **What it does**:
  - Sets page size (6" × 9" book format)
  - Defines fonts (Verdigris MVB Pro Text for body text)
  - Configures LuaLaTeX font fallback for color emoji support
  - Creates custom commands for tags, names, and index entries
  - Sets up 6 separate indexes using imakeidx
  - Defines colors, margins, headers, footers
  - Configures nested list indentation
- **Customizable**: Yes! Change colors, fonts, layout, add new indexes

### 🎬 Filter Pipeline (6 Lua Filters)

#### 1. task-list-filter.lua
- **Purpose**: Preserve task list structure and convert checkboxes
- **What it does**:
  - Preserves markdown task list structure
  - Converts `[ ]` and `[x]` to LaTeX checkbox commands
  - Maintains proper nesting for multi-level lists
- **Processing order**: First

#### 2. filter-media-links.lua
- **Purpose**: Clean up media links from Capacities
- **What it does**:
  - Removes Capacities metadata links after images
  - Filters out video embeds (they don't work in PDFs)
  - Converts video links to plain text
- **Processing order**: Second

#### 3. remove-object-embeds.lua
- **Purpose**: Remove standalone embedded objects and convert inline page links to plain text
- **What it does**:
  - Finds paragraphs with only a link to Pages/*.md
  - Reads the linked file's frontmatter
  - Removes if link text matches file title
  - Converts inline page links to plain text (links won't work in hardcover books)
- **Processing order**: Third
- **Expandable**: Can add other object types beyond Pages

#### 4. landscape-table-filter.lua
- **Purpose**: Adaptive table orientation and styling
- **What it does**:
  - Analyzes table dimensions (columns, rows)
  - Calculates natural width and content density
  - Determines optimal orientation (portrait vs. landscape)
  - Applies sans-serif font (Helvetica Neue)
  - Adds zebra striping and professional formatting
  - Defers landscape tables to dedicated pages
- **Processing order**: Fourth
- **Smart logic**:
  - Portrait: Low density, fits in width (< 100%)
  - Landscape: High density, wide (> 100%), or 15+ rows

#### 5. add-index-entries.lua
- **Purpose**: Route references to appropriate indexes
- **What it does**:
  - Reads Capacities object metadata (type, title)
  - Routes to correct index: Books, Definitions, Organizations, People, Projects
  - Generates LaTeX `\index[category]{entry}` commands
- **Processing order**: Fifth

#### 6. tag-filter.lua
- **Purpose**: Process hashtags
- **What it does**:
  - Finds all `#tags` in your text
  - Converts to LaTeX `\tag{}` commands
  - Applies background color highlighting (customizable per tag)
  - Adds to Tags index
  - Handles consecutive tags: `#tag1#tag2#tag3`
- **Processing order**: Sixth (last)

### 🔧 Build Script (`build.sh`)
- **Purpose**: One command to convert markdown → PDF
- **What it does**:
  1. Cleans output directory (unless --keep-output flag)
  2. Runs Pandoc with all Lua filters
  3. Converts task list checkboxes to Wingdings 2 characters (sed post-processing)
  4. First LuaLaTeX pass (creates .idx files)
  5. Runs makeindex on all 6 index files
  6. Final LuaLaTeX pass (includes formatted indexes)
  7. Opens the result
- **Usage**:
  - `./build.sh source/your-file.md` (clean build)
  - `./build.sh source/your-file.md --keep-output` (preserve files)
- **Important**: Now cleans output by default to prevent stale file bugs

### 📦 Export Processor (`process-capacities-export.sh`)
- **Purpose**: Automate Capacities export processing
- **What it does**:
  1. Validates specified .zip file exists
  2. Extracts to source/capacities-export/
  3. Combines all daily notes chronologically
  4. Copies images to assets/Images/Media/
  5. Copies PDFs to assets/PDFs/Media/
  6. Generates source/journal.md
  7. Builds reference map for index entries
- **Usage**: `./process-capacities-export.sh <zip-file>`
- **Example**: `./process-capacities-export.sh source/test.zip`
- **Parameters**: Zip file path (required)

### 🎨 Capacities Preprocessor (`preprocess-capacities.sh`)
- **Purpose**: Convert Capacities markdown structure for LaTeX
- **What it does**:
  - Converts Capacities toggle structure
  - Removes #PersonalJournal tags
  - Converts top-level tags to headings
  - Removes mentions from headings (prevents duplicate index entries)
  - Uncomments image references
- **Usage**: `./preprocess-capacities.sh "Title" "Author" source/journal.md`
- **Parameters**:
  - `$1`: Document title (default: "Journal")
  - `$2`: Author name (default: "Julio Terra")
  - `$3`: Input file (default: "source/journal.md")

### 🧹 Encoding Fixer (`preprocess.sh`)
- **Purpose**: Fix character encoding issues
- **What it does**:
  - Finds garbled characters (â€", â€™, etc.)
  - Replaces with correct UTF-8 characters
  - Creates a backup (.bak file)
- **When to use**: If you see weird characters in output
- **Usage**: `./preprocess.sh source/journal.md`

### 🔄 Combined Script (`build-clean.sh`)
- **Purpose**: Preprocess + build in one command
- **What it does**:
  1. Runs preprocess.sh (unless --skip-preprocess)
  2. Runs build.sh
- **Usage**:
  - `./build-clean.sh source/your-file.md`
  - `./build-clean.sh source/your-file.md --skip-preprocess`

## Workflow Visualization

### Complete Capacities Workflow

```
Capacities Export (.zip)
          ↓
process-capacities-export.sh source/export.zip
    [Extract, combine, copy assets]
          ↓
source/journal.md created
          ↓
preprocess-capacities.sh
    [Structure conversion, cleanup]
          ↓
Pandoc + Lua Filters
    ├─ task-list-filter.lua        [Preserve checkboxes]
    ├─ filter-media-links.lua      [Clean media]
    ├─ remove-object-embeds.lua    [Remove embeds]
    ├─ add-index-entries.lua       [Route to indexes]
    └─ tag-filter.lua              [Find tags]
          ↓
sed Post-Processing
    [Convert checkboxes to Wingdings 2]
          ↓
LaTeX Template
    [Apply styling, emoji fallback, indexes]
          ↓
LuaLaTeX First Pass
    [Generate .idx files for 6 indexes]
          ↓
makeindex × 6
    [Process each .idx → .ind]
          ↓
LuaLaTeX Final Pass
    [Include formatted indexes]
          ↓
Beautiful PDF! 📕
    - Color emoji support
    - Colored tags and names
    - Professional layout
    - Task list checkboxes
    - 6 comprehensive indexes
```

### Index Generation Pipeline

```
Markdown with links/tags
          ↓
Filters add: \index[category]{entry}
          ↓
XeLaTeX creates .idx files:
    - books.idx
    - definitions.idx
    - organizations.idx
    - people.idx
    - projects.idx
    - tags.idx
          ↓
makeindex processes each:
    .idx → .ind (formatted)
          ↓
XeLaTeX includes .ind files
          ↓
Indexes appear in PDF
```

## What Works Now

✅ **Capacities export processing** - Automated extraction and combination
✅ **Six separate indexes** - Books, Definitions, Organizations, People, Projects, Tags
✅ **Four Lua filters** - Comprehensive markdown processing
✅ **Tag highlighting** - All hashtags colored and indexed
✅ **Object embed removal** - Clean handling of embedded pages
✅ **Professional typography** - Book-quality layout
✅ **Print-ready format** - 6" × 9" with proper margins
✅ **Character encoding fixes** - Clean up export issues
✅ **Clean builds** - Output cleared by default
✅ **VS Code integration** - Settings ready for LaTeX Workshop

## What's Coming

🚧 **Batch processing** - Process multiple exports
🚧 **URL footnotes** - External links as footnotes
🚧 **Enhanced image handling** - Better sizing and placement
🚧 **Custom front matter** - Title page, dedication
🚧 **Month dividers** - Chapter breaks for each month
🚧 **Statistics page** - Word count, entry count
🚧 **Date formatting** - Prettier date displays

## Getting Started Path

1. **Install Everything** → Follow `INSTALL.md`
2. **Export from Capacities** → Place .zip in source/
3. **Process Export** → Run `./process-capacities-export.sh source/your-export.zip`
4. **Preprocess** → Run `./preprocess-capacities.sh "Title" "Author"`
5. **Build PDF** → Run `./build.sh source/journal.md`
6. **Review Output** → Check your PDF
7. **Customize** → Tweak colors, fonts, layout
8. **Iterate** → Refine until perfect
9. **Print** → Send to printer or print-on-demand

## Tech Stack

| Component | Purpose | Why This Choice |
|-----------|---------|-----------------|
| Pandoc | Markdown → LaTeX | Industry standard, powerful filtering |
| XeLaTeX | LaTeX → PDF | Unicode support, modern fonts |
| imakeidx | Multiple indexes | Separate indexes for each category |
| Lua | Filtering/Processing | Built into Pandoc, fast, flexible |
| VS Code | Editor | Best free editor, great extensions |
| LaTeX Workshop | Live preview | Makes editing easier |
| Book class | Document type | Professional book layout |

## Customization Hotspots

**Most Common Tweaks:**
1. **Colors** - template: `\definecolor` lines around line 65
2. **Fonts** - template: `\setmainfont` around line 14
3. **Page size** - template: `geometry` package around line 22
4. **Margins** - template: geometry settings

**Less Common:**
- Header/footer style (template: fancyhdr section)
- Chapter formatting (template: titleformat)
- Index appearance (template: index section)
- Add new index types (see README.md)
- Filter processing order (build.sh: --lua-filter sequence)

## Adding New Features

### Add a New Index Category

See the detailed guide in README.md for step-by-step instructions on adding new index types (e.g., Locations, Events, etc.).

### Add a New Filter

1. Create filter in `filters/your-filter.lua`
2. Add to build.sh pipeline: `--lua-filter=filters/your-filter.lua \`
3. Position matters - filters run in order
4. Test with small files first

### Modify Filter Behavior

Edit the Lua filter files directly. They're well-commented and use Pandoc's AST structure. See [Lua Filters Guide](https://pandoc.org/lua-filters.html).

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
- **Font**: Corundum Text Book (embedded)

**Printing Options:**
- Self-print at home/office
- Local print shop
- Print-on-demand services:
  - Lulu.com
  - Blurb.com
  - Amazon KDP (Kindle Direct Publishing)
  - IngramSpark

## Development Roadmap

### Phase 1: ✅ Core Pipeline (Complete!)
- Template creation with 6 indexes
- Four-filter processing pipeline
- Build scripts with clean output
- Capacities export automation
- Documentation

### Phase 2: 🚧 Enhancements (Current)
- URL/footnote system
- Enhanced image handling
- Better date formatting
- Statistics generation

### Phase 3: 🔮 Advanced Features (Future)
- Multiple template options
- Interactive configuration
- Batch processing multiple exports
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

**Q: Can I use this for other content?**
A: Yes! It works with any markdown content, not just Capacities exports.

**Q: What if I want different colors?**
A: Edit the `\definecolor` lines in the template. Use RGB values 0-255.

**Q: How do I print this?**
A: Use the PDF from `output/` with any print service or home printer.

**Q: Can I add new index types?**
A: Yes! See README.md for detailed instructions on adding index categories.

**Q: Why does build.sh clean the output directory?**
A: Prevents stale .ind files from masking build issues. Use --keep-output to preserve files.

**Q: What font should I use if I don't have Corundum Text Book?**
A: See README.md's "Changing Fonts" section for alternatives and instructions.

## Support & Learning

- Read through all `.md` files in the project
- Check `QUICKREF.md` for quick answers
- Look at the filter code - it's commented
- Experiment with small changes
- Test often with sample files
- Check logs/ directory when things fail

## Success Metrics

You'll know it's working when you see:
- ✅ PDF opens automatically after build
- ✅ Tags appear in blue color
- ✅ Six indexes show at the back
- ✅ Layout looks professional
- ✅ Fonts are embedded correctly
- ✅ Ready to print or share

---

**Ready to begin?** Start with `INSTALL.md` → then `./process-capacities-export.sh source/your-export.zip` → `./build.sh source/journal.md`
