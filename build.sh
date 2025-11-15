#!/bin/bash

# build.sh
# Converts markdown to PDF using Pandoc and LaTeX with index support

set -e

# Parse arguments
KEEP_OUTPUT=false
INPUT_FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --keep-output)
            KEEP_OUTPUT=true
            shift
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
    echo "Usage: ./build.sh <input.md> [--keep-output]"
    echo "  --keep-output: Preserve existing files in output directory"
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
echo ""

# Step 1: Convert to .tex file
echo "🔄 Step 1: Converting to LaTeX..."
pandoc "$INPUT_FILE" \
  --from=markdown \
  --to=latex \
  --template="$TEMPLATE" \
  --lua-filter=filters/filter-media-links.lua \
  --lua-filter=filters/add-index-entries.lua \
  --lua-filter=filters/name-filter.lua \
  --lua-filter=filters/tag-filter.lua \
  --toc \
  --toc-depth=2 \
  --number-sections \
  -V documentclass=book \
  -V papersize=custom \
  -V geometry:paperwidth=6in \
  -V geometry:paperheight=9in \
  --standalone \
  -o "$OUTPUT_DIR/$OUTPUT_NAME.tex"

# Step 2: First LaTeX pass (creates .idx)
echo "🔄 Step 2: First LaTeX pass..."
(cd "$OUTPUT_DIR" && xelatex -interaction=nonstopmode "$OUTPUT_NAME.tex" > "../$BUILD_LOG_FILE" 2>&1)

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
(cd "$OUTPUT_DIR" && xelatex -interaction=nonstopmode "$OUTPUT_NAME.tex" > "../$BUILD_LOG_FILE" 2>&1)

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
