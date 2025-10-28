#!/bin/bash

# preprocess.sh - Fix character encoding issues in markdown files

INPUT_FILE="$1"

if [ $# -eq 0 ]; then
    echo "Usage: ./preprocess.sh <markdown-file>"
    exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' not found!"
    exit 1
fi

# Create a backup
cp "$INPUT_FILE" "${INPUT_FILE}.bak"

# Fix common encoding issues
# These are double-encoded UTF-8 characters showing as â€" â€™ etc.

sed -i '' \
  -e 's/â€"/—/g' \
  -e "s/â€™/'/g" \
  -e 's/â€œ/"/g' \
  -e 's/â€/"/g' \
  -e 's/â€¦/…/g' \
  -e 's/Â / /g' \
  -e 's/â€"/-/g' \
  "$INPUT_FILE"

echo "✅ Encoding fixed! Backup saved as ${INPUT_FILE}.bak"
