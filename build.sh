#!/bin/bash

# build.sh
# Converts markdown to PDF using Pandoc and LaTeX with index support

set -e

# Parse arguments
KEEP_OUTPUT=false
INPUT_FILE=""
PAPER_WIDTH="6in"
PAPER_HEIGHT="9in"
MARGIN_TOP="0.75in"
MARGIN_BOTTOM="0.75in"
MARGIN_INNER="0.875in"
MARGIN_OUTER="0.625in"
BINDING_OFFSET="0.25in"

while [[ $# -gt 0 ]]; do
    case $1 in
        --keep-output)
            KEEP_OUTPUT=true
            shift
            ;;
        --paperwidth)
            PAPER_WIDTH="$2"
            shift 2
            ;;
        --paperheight)
            PAPER_HEIGHT="$2"
            shift 2
            ;;
        --top)
            MARGIN_TOP="$2"
            shift 2
            ;;
        --bottom)
            MARGIN_BOTTOM="$2"
            shift 2
            ;;
        --inner)
            MARGIN_INNER="$2"
            shift 2
            ;;
        --outer)
            MARGIN_OUTER="$2"
            shift 2
            ;;
        --bindingoffset)
            BINDING_OFFSET="$2"
            shift 2
            ;;
        *)
            INPUT_FILE="$1"
            shift
            ;;
    esac
done

TEMPLATE="templates/journal-template.tex"
OUTPUT_DIR="output"
OUTPUT_NAME=$(basename "$INPUT_FILE" .md)
OUTPUT_FILE="$OUTPUT_DIR/$OUTPUT_NAME.pdf"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_DIR="logs"
BUILD_LOG_FILE="$LOG_DIR/build.sh-build.log"
INDEX_LOG_FILE="$LOG_DIR/build.sh-index.log"


if [ -z "$INPUT_FILE" ]; then
    echo "Usage: ./build.sh <input.md> [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --keep-output        Preserve existing files in output directory"
    echo "  --paperwidth <size>  Paper width (default: 6in)"
    echo "  --paperheight <size> Paper height (default: 9in)"
    echo "  --top <size>         Top margin (default: 0.75in)"
    echo "  --bottom <size>      Bottom margin (default: 0.75in)"
    echo "  --inner <size>       Inner margin (default: 0.875in)"
    echo "  --outer <size>       Outer margin (default: 0.625in)"
    echo "  --bindingoffset <size> Binding offset (default: 0.25in)"
    echo ""
    echo "Example:"
    echo "  ./build.sh source/journal.md --paperwidth 5in --paperheight 8in"
    exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' not found!"
    exit 1
fi

# Clean output directory unless --keep-output flag is set
mkdir -p "$OUTPUT_DIR"
if [ "$KEEP_OUTPUT" = false ]; then
    echo "🧹 Cleaning output directory..."
    rm -rf "$OUTPUT_DIR"/*
fi

echo "📚 Journal to PDF Converter"
echo "================================"
echo "📄 Input:    $INPUT_FILE"
echo "📋 Template: $TEMPLATE"
echo "📦 Output:   $OUTPUT_FILE"
echo "📏 Page:     $PAPER_WIDTH × $PAPER_HEIGHT"
echo ""

# Step 1: Convert to .tex file
echo "🔄 Step 1: Converting to LaTeX..."
pandoc "$INPUT_FILE" \
  --from=markdown \
  --to=latex \
  --template="$TEMPLATE" \
  --lua-filter=filters/task-list-filter.lua \
  --lua-filter=filters/remove-todo-sections.lua \
  --lua-filter=filters/filter-media-links.lua \
  --lua-filter=filters/remove-object-embeds.lua \
  --lua-filter=filters/landscape-table-filter.lua \
  --lua-filter=filters/add-index-entries.lua \
  --lua-filter=filters/tag-filter.lua \
  --metadata paperwidth="$PAPER_WIDTH" \
  --metadata paperheight="$PAPER_HEIGHT" \
  --metadata pagedimensions="$PAPER_WIDTH × $PAPER_HEIGHT" \
  --toc \
  --toc-depth=2 \
  --number-sections \
  -V documentclass=book \
  -V papersize=custom \
  -V paperwidth="$PAPER_WIDTH" \
  -V paperheight="$PAPER_HEIGHT" \
  -V geometry:paperwidth="$PAPER_WIDTH" \
  -V geometry:paperheight="$PAPER_HEIGHT" \
  -V geometry:top="$MARGIN_TOP" \
  -V geometry:bottom="$MARGIN_BOTTOM" \
  -V geometry:inner="$MARGIN_INNER" \
  -V geometry:outer="$MARGIN_OUTER" \
  -V geometry:bindingoffset="$BINDING_OFFSET" \
  --standalone \
  -o "$OUTPUT_DIR/$OUTPUT_NAME.tex"

# Step 2: First LaTeX pass (creates .idx)
echo "🔄 Step 2: First LaTeX pass..."
(cd "$OUTPUT_DIR" && lualatex -interaction=nonstopmode "$OUTPUT_NAME.tex" > "../$BUILD_LOG_FILE" 2>&1)

# Step 3: Build all indexes
echo "📇 Step 3: Building indexes..."
(cd "$OUTPUT_DIR" && {
    for idx in people organizations projects definitions books tags; do
        if [ -f "${idx}.idx" ]; then
            makeindex "${idx}.idx" >> "../$INDEX_LOG_FILE" 2>&1
        fi
    done
})

# Step 4: Final LaTeX pass
echo "🔄 Step 4: Final LaTeX pass..."
(cd "$OUTPUT_DIR" && lualatex -interaction=nonstopmode "$OUTPUT_NAME.tex" > "../$BUILD_LOG_FILE" 2>&1)

echo "✅ Success! PDF created: $OUTPUT_FILE"
echo "🔍 Opening PDF..."
open "$OUTPUT_FILE"

# Check if conversion was successful
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Success! PDF created: $OUTPUT_FILE${NC}"
    
    # Open the PDF (macOS)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "🔍 Opening PDF..."
        open "$OUTPUT_FILE"
    fi
else
    echo -e "${RED}❌ Error: Conversion failed!${NC}"
    exit 1
fi
