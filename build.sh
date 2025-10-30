#!/bin/bash

# build.sh - Convert journal markdown to PDF using Pandoc + LaTeX

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo -e "${GREEN}📚 Journal to PDF Converter${NC}"
echo "================================"

# Check if source file is provided
if [ $# -eq 0 ]; then
    echo -e "${YELLOW}Usage: ./build.sh <markdown-file>${NC}"
    echo "Example: ./build.sh source/2025-10-21.md"
    exit 1
fi

INPUT_FILE="$1"
BASENAME=$(basename "$INPUT_FILE" .md)
OUTPUT_FILE="output/${BASENAME}.pdf"
TEMPLATE="templates/journal-template.tex"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo -e "${RED}Error: Input file '$INPUT_FILE' not found!${NC}"
    exit 1
fi

# Check if template exists
if [ ! -f "$TEMPLATE" ]; then
    echo -e "${RED}Error: Template '$TEMPLATE' not found!${NC}"
    exit 1
fi

echo "📄 Input:    $INPUT_FILE"
echo "📋 Template: $TEMPLATE"
echo "📦 Output:   $OUTPUT_FILE"
echo ""
echo "🔄 Converting..."

# Run Pandoc with all the filters and options
pandoc "$INPUT_FILE" \
  --from=markdown \
  --to=latex \
  --template="$TEMPLATE" \
  --lua-filter=filters/link-to-footnote.lua \
  --lua-filter=filters/name-filter.lua \
  --lua-filter=filters/tag-filter.lua \
  --pdf-engine=xelatex \
  --toc \
  --toc-depth=2 \
  --number-sections \
  -V documentclass=book \
  -V papersize=custom \
  -V geometry:paperwidth=6in \
  -V geometry:paperheight=9in \
  -o "$OUTPUT_FILE"

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
