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
- **Custom LaTeX template** with beautiful typography (Corundum Text Book font)
- **Print-ready dimensions** (6" × 9" book format)
- **Six separate indexes**: Books, Definitions, Organizations, People, Projects, and Tags
- **Tag highlighting**: All `#tags` are colored blue and indexed
- **Object embed removal**: Standalone embedded page references are filtered out
- **Media link filtering**: Clean handling of images and videos
- **Clean builds**: Output directory cleared by default (prevents stale file bugs)
- **Capacities export processing**: Automated workflow for processing Capacities exports
- **Character encoding fixes**: Handles UTF-8 encoding issues
- **Clean typography**: Professional margins, headers, and footers

### 🚧 Coming Soon
- Support for emojis
- Ability to handle complex tables
- Enhanced formatting for tags
- Output configuration via build.sh flags

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
- Tags in **blue** color (#testing, #workflow, etc.)
- Object references indexed in all 6 indexes
- Professional book layout

If the test works, you're ready to build your own journal!

## Build Your Own Print-Ready Journal

### Step 1
Export your content from Capacities and place the downloaded `.zip` file in the `source/` directory of the project. Follow these steps to download your daily notes from Capacities:
1. Go to the `Daily Notes` page in Capacities 
2. Use the filter to set a date range
3. Choose `export` from the `...` menu on the top right corner of the window
4. Select the `Export folder containing all subpages` checkbox from the pop-up modal

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
- **Tags** like #PersonalJournal in **blue** 
- **Six Indexes** in the back for the following object types: Organizations, Projects, People, Books, Definitions, and Tags

## 📚 Understanding the Filters

The workflow uses four Lua filters to process your markdown:

### 1. filter-media-links.lua
- Removes Capacities metadata links after images
- Filters out video embeds (mp4, mov, avi, etc.)
- Converts inline video links to plain text

### 2. remove-object-embeds.lua
- Removes standalone embedded object links (Pages/*.md)
- Converts inline page links to plain text (links won't work in hardcover books)
- Prevents embedded page content from appearing in final PDF

### 3. add-index-entries.lua
- Routes references to appropriate index categories
- Handles: People, Organizations, Projects, Definitions, Books
- Reads metadata from linked .md files

### 4. tag-filter.lua
- Finds hashtags like `#PersonalJournal`
- Converts to LaTeX `\tag{}` commands
- Colors tags blue
- Adds to Tags index
- Handles multiple consecutive tags: `#tag1#tag2#tag3`

## 📇 Understanding the Indexing System

The workflow generates **six separate indexes** using LaTeX's `imakeidx` package:

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
3. Runs XeLaTeX (first pass - creates .idx files)
4. Runs makeindex on all 6 index files
5. Runs XeLaTeX (final pass - includes indexes)

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
```

**Parameters:**
- `$1` - Title for the document (default: "Journal")
- `$2` - Author name (default: "Julio Terra")
- `$3` - Input file path (default: "source/journal.md")

**What it does:**
- Converts Capacities toggle structure
- Removes #PersonalJournal tags
- Converts top-level tags to headings (#ToDos → ## To Dos)
- Removes mentions from headings (prevents index duplicates)
- Uncomments image links

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

The template currently uses **Corundum Text Book**. If you don't have this font, you'll need to change it.

**1. Check available fonts on your system:**
```bash
fc-list : family | sort | uniq
```

**2. Edit the template** (`templates/journal-template.tex` around line 14):
```latex
\setmainfont{Corundum Text Book}[
  BoldFont={Corundum Text Bold}
]
```

**3. Replace with an available font:**
```latex
% Popular choices:
\setmainfont{Palatino}          % Classic serif
\setmainfont{Garamond}          % Elegant serif
\setmainfont{Baskerville}       % Traditional serif
\setmainfont{Georgia}           % Screen-friendly serif
\setmainfont{Hoefler Text}      % macOS default
\setmainfont{Crimson Text}      % Free Google font
```

**Note:** If a font has separate files for bold/italic, specify them:
```latex
\setmainfont{My Font}[
  BoldFont={My Font Bold},
  ItalicFont={My Font Italic},
  BoldItalicFont={My Font Bold Italic}
]
```

### Changing Colors

Edit `templates/journal-template.tex` (around line 65):

```latex
\definecolor{tagcolor}{RGB}{100,149,237}      % Tags (cornflower blue)
\definecolor{namecolor}{RGB}{220,20,60}       % Names (crimson)
\definecolor{linkcolor}{RGB}{70,70,120}       % Links (steel blue)
\definecolor{headingcolor}{RGB}{0,0,0}        % Headings (black)
```

RGB values range from 0-255 for each color component.

### Changing Page Size

Edit the geometry settings in the template (around line 22):

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


## 🐛 Troubleshooting

### "Command not found: pandoc"
```bash
brew install pandoc
```

### "Command not found: xelatex"
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
