# 📔 Journal Workflow: Capacities → Publishing-Ready PDF

A complete Pandoc + LaTeX workflow for converting your Capacities journal (exported in Markdown) into beautifully typeset, print-ready PDFs.

## 📁 Project Structure

```
journal-workflow/
├── source/           # Your markdown files from Capacities
├── templates/        # LaTeX templates
├── filters/          # Lua filters for processing
├── output/           # Generated PDFs (cleaned on each build)
├── assets/           # Images, PDFs, fonts
├── logs/             # Build logs
└── *.sh              # Build and processing scripts
```

## 🎯 Current Features

### ✅ Implemented
- **Capacities export processing**: Automated workflow for processing Capacities exports
- **Custom LaTeX template** with beautiful typography (Verdigris MVB Pro Text font)
- **Customizable book dimensions** defaults to 6" × 9" book format
- **Indexed links to objects**: Books, Definitions, Organizations, People, and Projects
- **Tag handling**: All `#tags` are highlighted with background colors and indexed
- **Media link filtering**: Clean handling of images and pdfs, and removal of videos
- **Object embed removal**: Standalone embedded page references are filtered out
- **Clean builds**: Output directory cleared by default (prevents stale file bugs)
- **Character encoding fixes**: Handles UTF-8 encoding issues
- **Clean typography**: Professional margins, headers, and footers
- **Color emoji support**: Full color emoji rendering with LuaLaTeX and font fallback
- **Task list checkboxes**: Markdown checkboxes render as Wingdings 2 characters
- **Adaptive table orientation**: Automatic landscape/portrait orientation based on content density
- **Smart table formatting**: Sans-serif font, zebra striping, adaptive sizing

### 🚧 Coming Soon
- Enhanced formatting for tags with more color options
- Ability to configure objects that are indexed

## 🚀 Quick Start

### Test Your Installation

Here is how to verify that everything is working using the included test.zip file:

```bash
./process-capacities-export.sh source/test.zip
./preprocess-capacities.sh "journal title" "author name" source/journal.md
./build.sh source/journal.md
```
### Output

This will generate a test PDF that should show:
- Tags **highlighted** with background colors (#testing, #workflow, etc.)
- Object references indexed in all 6 indexes
- Color emojis and task list checkboxes
- Images and PDF embeds
- **14 comprehensive table tests** (2-8 columns) with adaptive orientation
  - Portrait orientation for low-density tables
  - Landscape orientation for wide or high-density tables
- Professional book layout

If the test works, you're ready to build your own journal!

## Build Your Own Print-Ready Journal

### Step 1
Export your content from Capacities and place the downloaded `.zip` file in the `source/` directory of the project. Follow these steps to download your daily notes from Capacities:
1. Go to the `Daily Notes` objects page in Capacities 
2. Use the filter to set a date range
3. Choose `export` from the `...` menu on the top right corner of the window
4. Select the `Export folder containing all subpages` checkbox from the pop-up modal

**Important Note:** even if you want to test this set-up on a single journal page you need to download it Daily Notes objects page in Capacities. 

### Step 2
```bash
# Run the process-capacities-export.sh script to extract, combine daily notes, and copy assets
./process-capacities-export.sh source/your-export.zip
```
### Step 3
```bash
# Run preprocess-capacities.sh script to prepare combined journal.md file for build:
./preprocess-capacities.sh "My Journal" "Your Name" source/journal.md
```
**Important Note:** This step contains some preprocessing logic that is tailored to the way I format my journal. You may need to tweak this file to make appropriate adjustments to your content for the build to work properly.   
### Step 4
```bash
# Run build.sh script to convert your capacities journal into a print-ready pdf file:
./build.sh source/journal.md
```

## Understanding the Output

Your PDF will have:
- **Daily Notes** organized by date
- **Images & PDFs** rendered in large format
- **Tags** like #PersonalJournal in **yellow** 
- **Six Indexes** in the back for the following object types: Organizations, Projects, People, Books, Definitions, and Tags

## 📚 Understanding the Filters

The workflow uses five Lua filters to process your markdown:

### 1. task-list-filter.lua
- Preserves task list structure during conversion
- Converts markdown checkboxes to LaTeX checkbox commands
- Maintains proper nesting for multi-level lists

### 2. filter-media-links.lua
- Removes Capacities metadata links after images
- Filters out video embeds (mp4, mov, avi, etc.)
- Converts inline video links to plain text

### 3. remove-object-embeds.lua
- Removes standalone embedded object links (Pages/*.md)
- Converts inline page links to plain text (links won't work in hardcover books)
- Prevents embedded page content from appearing in final PDF

### 4. landscape-table-filter.lua
- Analyzes table dimensions and content density
- Automatically chooses portrait or landscape orientation
- Uses sans-serif font (Helvetica Neue) for better readability
- Applies zebra striping and professional styling
- Defers landscape tables to dedicated pages while allowing content to flow.  
  
### 5. add-index-entries.lua
- Routes references to appropriate index categories
- Handles: People, Organizations, Projects, Definitions, Books
- Reads metadata from linked .md files

### 6. tag-filter.lua
- Finds hashtags like `#PersonalJournal`
- Converts to LaTeX `\tag{}` commands
- Applies background color highlighting (customizable per tag)
- Adds to Tags index
- Handles multiple consecutive tags: `#tag1#tag2#tag3`

## 📇 Understanding the Indexing System

The workflow generates **separate indexes** using LaTeX's `imakeidx` package:

### How It Works

1. **During Pandoc conversion**, filters add `\index[category]{entry}` commands
2. **First LaTeX pass** creates `.idx` files for each index
3. **makeindex** processes each `.idx` file into formatted `.ind` files
4. **Final LaTeX pass** includes the formatted indexes in your PDF

### The Six Indexes

| Index | What It Contains | Added By |
|-------|-----------------|----------|
| **Books** | Book references | add-index-entries.lua |
| **Definitions** | Defined terms and concepts | add-index-entries.lua |
| **Organizations** | Companies, schools, institutions | add-index-entries.lua |
| **People** | People's names | add-index-entries.lua |
| **Projects** | Project references | add-index-entries.lua |
| **Tags** | All hashtags | tag-filter.lua |

### Adding a New Index Type

To add a new index category (e.g., "Locations"):

1. **Update the template** (`templates/journal-template.tex`):
```latex
% Add after existing \makeindex commands (around line 192)
\makeindex[name=locations,title=Locations,columns=2]
```

2. **Update build.sh** to process the new index:
```bash
# Add 'locations' to the loop in Step 3 (around line 86)
for idx in people organizations projects definitions books tags locations; do
```

3. **Update add-index-entries.lua** to route location entries:
```lua
-- Add to the type checking logic
elseif obj_type == "Location" then
  return pandoc.RawInline('latex', '\\index[locations]{' .. canonical_name .. '}')
```

4. **Update the template's index printing section** (around line 333):
```latex
\printindexsection{Locations}{locations}
```

## 🔧 Scripts Reference

### build.sh
Main build script - converts markdown to PDF.

```bash
./build.sh source/journal.md              # Clean build (default)
./build.sh source/journal.md --keep-output  # Preserve output files
```

**What it does:**
1. Cleans output directory (unless --keep-output specified)
2. Runs Pandoc with all filters
3. Converts checkboxes to Wingdings 2 characters
4. Runs LuaLaTeX (first pass - creates .idx files)
5. Runs makeindex on all 6 index files
6. Runs LuaLaTeX (final pass - includes indexes)

### process-capacities-export.sh
Processes Capacities export zip files.

```bash
./process-capacities-export.sh <zip-file>

# Examples:
./process-capacities-export.sh source/test.zip
./process-capacities-export.sh source/my-export.zip
```

**What it does:**
1. Validates the specified .zip file exists
2. Extracts to source/capacities-export/
3. Combines all daily notes into source/journal.md
4. Copies images to assets/Images/Media/
5. Copies PDFs to assets/PDFs/Media/
6. Builds reference map for index entries

**Parameters:**
- `<zip-file>` - Path to the Capacities export zip file (required)

### preprocess-capacities.sh
Preprocesses Capacities markdown for LaTeX.

```bash
./preprocess-capacities.sh "Title" "Author" source/journal.md
./preprocess-capacities.sh "Title" "Author" source/journal.md --toggle-deindent
```

**Parameters:**
- `$1` - Title for the document (default: "Journal")
- `$2` - Author name (default: "Julio Terra")
- `$3` - Input file path (default: "source/journal.md")
- `$4` - Volume (default: "")
- `--toggle-deindent` - Optional flag to remove 4-space indentation from Capacities toggle groups

**What it does:**
- Converts Capacities export structure
- Removes 4-space indentation if --toggle-deindent flag is used (for personal journals with toggles)
- Skips deindentation by default (for test files and properly structured content)
- Removes #PersonalJournal tags
- Converts top-level tags to headings (#ToDos → ## To Dos)
- Removes mentions from headings (prevents index duplicates)
- Uncomments image links
- Converts embedded PDFs to JPG images

### preprocess.sh
Fixes character encoding issues.

```bash
./preprocess.sh source/journal.md
```

**What it does:**
- Fixes double-encoded UTF-8 (â€", â€™, etc.)
- Creates .bak backup
- Works on any markdown file

### build-clean.sh
Combined preprocessing and building.

```bash
./build-clean.sh source/journal.md
./build-clean.sh source/journal.md --skip-preprocess
```

## 🎨 Customization Guide

### Changing Fonts

The template currently uses **Verdigris MVB Pro Text**. If you don't have this font, you'll need to change it.

**1. Check available fonts on your system:**
```bash
# List all fonts
fc-list : family | sort | uniq

# Check if LuaLaTeX can find a specific font
luaotfload-tool --find="Font Name"
```

**2. Edit the template** (`templates/journal-template.tex` around line 25):
```latex
\setmainfont{VerdigrisMVBProText-Rg}[
  Extension={.otf},
  BoldFont={VerdigrisMVBProText-Bd},
  ItalicFont={VerdigrisMVBProText-It},
  BoldItalicFont={VerdigrisMVBProText-BdIt},
  RawFeature={fallback=emojifallback}
]
```

**3. Replace with an available font:**
```latex
% Using font name (LuaLaTeX will search)
\setmainfont{Palatino}[RawFeature={fallback=emojifallback}]

% Or using filename (more reliable for some fonts)
\setmainfont{Palatino-Roman}[
  Extension={.ttf},
  BoldFont={Palatino-Bold},
  ItalicFont={Palatino-Italic},
  BoldItalicFont={Palatino-BoldItalic},
  RawFeature={fallback=emojifallback}
]
```

**Important:** Always keep `RawFeature={fallback=emojifallback}` to maintain emoji support!

**Note:** LuaLaTeX font loading differs from XeLaTeX. Adobe fonts not in the system font database don't work with LuaLaTeX.

### Changing Colors

Edit `templates/journal-template.tex` (around line 65):

```latex
\definecolor{tag-bg-default}{RGB}{255,245,157}    % Tags default (ight yellow)
\definecolor{linkcolor}{RGB}{70,70,120}           % Links (steel blue)
\definecolor{headingcolor}{RGB}{0,0,0}            % Headings (black)
```

RGB values range from 0-255 for each color component.

### Changing Page Size and Margins

Configure page dimensions and margins using command-line arguments with build.sh:

```bash
# Basic page size change
./build.sh source/journal.md --paperwidth 5in --paperheight 8in

# Full geometry customization
./build.sh source/journal.md \
  --paperwidth 5in \
  --paperheight 8in \
  --top 1in \
  --bottom 1in \
  --inner 1in \
  --outer 0.5in \
  --bindingoffset 0.25in
```

**Available geometry options:**
- `--paperwidth <size>` - Paper width (default: 6in)
- `--paperheight <size>` - Paper height (default: 9in)
- `--top <size>` - Top margin (default: 0.75in)
- `--bottom <size>` - Bottom margin (default: 0.75in)
- `--inner <size>` - Inner margin (default: 0.875in)
- `--outer <size>` - Outer margin (default: 0.625in)
- `--bindingoffset <size>` - Binding offset (default: 0.25in)

**Standard book sizes:**

```bash
# 5" × 8" (digest size)
./build.sh source/journal.md --paperwidth 5in --paperheight 8in

# 7" × 10" (royal)
./build.sh source/journal.md --paperwidth 7in --paperheight 10in

# A5 (European standard)
./build.sh source/journal.md --paperwidth 148mm --paperheight 210mm

# 8.5" × 11" (US Letter)
./build.sh source/journal.md --paperwidth 8.5in --paperheight 11in
```

**Note:** If you need to permanently change the defaults, you can edit the default values in `build.sh` (lines 11-17) or the template fallback values in `templates/journal-template.tex` (lines 45-49).

## 😀 Emoji and Checkbox Support

The workflow includes full **color emoji support** using LuaLaTeX and font fallback! Emojis in your markdown will be rendered in full color in the PDF.

### How It Works

The template uses LuaLaTeX with a font fallback chain:
1. **Verdigris MVB Pro Text** - Main body font
2. **Apple Color Emoji** - Full color emojis (macOS)
3. **Wingdings 2** - Checkbox and bullet characters
4. **Menlo** - Symbol fallback

This means emojis like 😀 🎉 ❤️ ✨ will render in full color!

### Checkbox and Bullet Support

**Markdown task lists** are fully supported with proper alignment:

```markdown
- [x] Completed task
- [ ] Incomplete task
- Regular bullet item
```

**Checkboxes** render using Wingdings 2 characters:
- U+F053 (checked box) - scaled to 70%, raised 0.15ex
- U+F0A3 (unchecked box) - scaled to 70%, raised 0.15ex

**Bullets** also use Wingdings 2 characters for consistency:
- Level 1: U+F098 - scaled to 70%, raised 0.15ex
- Level 2: U+F09C - scaled to 70%, raised 0.15ex
- Level 3: U+F09B - scaled to 70%, raised 0.15ex
- Level 4: U+F09A - scaled to 70%, raised 0.15ex

### Font Requirements

⚠️ **REQUIRED: Wingdings 2 font**

**macOS:** Wingdings 2, Apple Color Emoji, and Menlo are all included with the system - everything works out of the box.

**Windows:** Wingdings 2 is included with Windows - you may need to install emoji fonts separately.

**Linux:** You'll need to install both Wingdings 2 and color emoji fonts:
```bash
# Ubuntu/Debian - Install Microsoft fonts and emoji fonts
sudo apt-get install ttf-mscorefonts-installer fonts-noto-color-emoji

# Arch
sudo pacman -S ttf-ms-fonts noto-fonts-emoji
```

After installing fonts, rebuild the font cache:
```bash
fc-cache -fv
```

### Customizing Bullets and Checkboxes

If you want to use different symbols or fonts for bullets/checkboxes:

**1. Change the font** - Edit `templates/journal-template.tex` (around line 35):
```latex
% Replace Wingdings 2 with another symbol font
\newfontfamily\wingdingsii{Wingdings 2}  % Change to your font
```

**2. Change bullet symbols** - Edit `templates/journal-template.tex` (around line 142):
```latex
% Wingdings 2 bullets (scaled to 0.7, raised 0.15ex)
\renewcommand{\labelitemi}{\raisebox{0.15ex}{\scalebox{0.7}{{\wingdingsii\symbol{"F098}}}}}
\renewcommand{\labelitemii}{\raisebox{0.15ex}{\scalebox{0.7}{{\wingdingsii\symbol{"F09C}}}}}
% ... etc

% To use standard LaTeX bullets instead:
\renewcommand{\labelitemi}{\textbullet}
\renewcommand{\labelitemii}{\ensuremath{\circ}}
```

**3. Change checkbox symbols** - Edit `filters/task-list-filter.lua` (around line 5):
```lua
-- Wingdings 2 checkbox symbols (scaled down 30%, raised 0.15ex)
local EMPTY_BOX = '\\item[{\\raisebox{0.15ex}{\\scalebox{0.7}{\\wingdingsii\\symbol{"F0A3}}}}]'
local CHECKED_BOX = '\\item[{\\raisebox{0.15ex}{\\scalebox{0.7}{\\wingdingsii\\symbol{"F053}}}}]'

-- To use standard LaTeX symbols instead:
-- local EMPTY_BOX = '\\item[$\\square$]'
-- local CHECKED_BOX = '\\item[$\\boxtimes$]'
```

**4. Adjust sizing** - Change the `\scalebox{0.7}` value (0.7 = 70% of original size)

**5. Adjust vertical alignment** - Change the `\raisebox{0.15ex}` value (higher = raised more)

### Nested List Indentation

Nested lists (second, third, fourth level) have 2em additional indentation per level for better visual hierarchy.

## 📊 Table Support

The workflow includes **adaptive table formatting** with automatic orientation detection!

### How It Works

The landscape-table-filter.lua analyzes each table and automatically chooses the best orientation:

**Portrait Orientation** - Used when:
- Table is narrow (few columns)
- Content is sparse (low character density)
- Table fits comfortably in portrait width

**Landscape Orientation** - Used when:
- Table is wide (many columns)
- Content is dense (high character density)
- Table would need more than 100% of portrait width
- Table has 15+ rows (multi-page table)

### Table Styling

All tables automatically receive:
- **Sans-serif font** (Helvetica Neue) - More readable for tabular data
- **Zebra striping** - Light gray alternating rows
- **Professional formatting** - Proper spacing, borders, and headers
- **Adaptive column widths** - Automatically calculated based on content
- **Caption styling** - Bold, slightly larger than table content

### Writing Tables in Markdown

Use standard Pandoc table syntax with captions:

```markdown
Table: Contact Information

| Name | Email | Phone |
|:-----|:------|:------|
| John Doe | john@example.com | 555-1234 |
| Jane Smith | jane@example.com | 555-5678 |
```

### Table Orientation Examples

**Portrait** (2-column, sparse content):
```markdown
Table: Simple Contact List

| Name | Email |
|:-----|:------|
| Alice | alice@example.com |
| Bob | bob@example.com |
```

**Landscape** (7-column, dense content):
```markdown
Table: Comprehensive Project Tracking

| Project | Owner | Status | Start | End | Budget | Notes |
|:--------|:------|:-------|:------|:----|:-------|:------|
| Website Redesign | Alice | Active | 2024-01-15 | 2024-06-30 | $50,000 | On track |
| Mobile App | Bob | Planning | 2024-03-01 | 2024-12-31 | $120,000 | Needs approval |
```

### Testing Table Orientation

The included test.zip contains 14 comprehensive table tests (2-8 columns) that demonstrate:
- Sparse vs. dense content handling
- Equal vs. unbalanced column widths
- Portrait vs. landscape orientation selection
- Multi-page table handling

Build the test file to see how different table structures are rendered:
```bash
./process-capacities-export.sh source/test.zip
./preprocess-capacities.sh "Test" "Test User" source/journal.md
./build.sh source/journal.md
```

## 🐛 Troubleshooting

### "Command not found: pandoc"
```bash
brew install pandoc
```

### "Command not found: lualatex"
```bash
brew install --cask mactex
# Then restart Terminal
```

### "Font not found" error
Check available fonts and update the template:
```bash
fc-list : family | sort | uniq
```

### Indexes not appearing
- Check that build.sh processes all 6 index files
- Look at logs/build.sh-index.log for makeindex errors
- Verify .ind files exist in output/

### Build fails
Check the logs:
```bash
cat logs/build.sh-build.log | tail -50
```
You can also check the log files that are automatically saved in the `logs/` directory.  

Common issues:
- Missing LaTeX packages (MacTeX should have everything)
- Syntax errors in markdown
- Missing template or filters
- Font not installed

## 💡 Tips for Best Results

### Writing in Capacities
- Use consistent tag formats: `#tag` not `# tag`
- Link people's names consistently
- Use markdown headings (##, ###) for structure
- Only use H2 - H4, since H1 is used for date titles
- Keep formatting simple (bold, headings, italic, lists)

### Preparing for Print
- Review the PDF at 100% zoom (actual size)
- Check margins look good
- Verify all indexes are complete
- Test print one page to check sizing
- Check that fonts are embedded (they should be automatically)

## 📖 Resources

- [Pandoc Manual](https://pandoc.org/MANUAL.html)
- [LaTeX Documentation](https://www.latex-project.org/help/documentation/)
- [Lua Filters Guide](https://pandoc.org/lua-filters.html)
- [imakeidx Package](https://ctan.org/pkg/imakeidx) - Multiple index support

---

**Questions?** Review this README and try building your first PDF. Check QUICKREF.md for command references and PROJECT.md for detailed architecture information.
