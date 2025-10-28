#!/bin/bash

# build-clean.sh - Preprocess and convert markdown to PDF

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo -e "${GREEN}📚 Journal to PDF Converter (with preprocessing)${NC}"
echo "================================================"

if [ $# -eq 0 ]; then
    echo -e "${YELLOW}Usage: ./build-clean.sh <markdown-file> [--skip-preprocess]${NC}"
    echo "Example: ./build-clean.sh source/2025-10-21.md"
    exit 1
fi

INPUT_FILE="$1"
SKIP_PREPROCESS="$2"

if [ ! -f "$INPUT_FILE" ]; then
    echo -e "${RED}Error: Input file '$INPUT_FILE' not found!${NC}"
    exit 1
fi

# Preprocess to fix encoding unless --skip-preprocess is specified
if [ "$SKIP_PREPROCESS" != "--skip-preprocess" ]; then
    echo "🔧 Fixing character encoding..."
    ./preprocess.sh "$INPUT_FILE"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Warning: Preprocessing had issues, but continuing...${NC}"
    fi
    echo ""
fi

# Run the main build
echo "🔄 Building PDF..."
./build.sh "$INPUT_FILE"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 Complete! Your journal PDF is ready.${NC}"
fi
