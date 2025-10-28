#!/bin/bash

# preprocess-capacities.sh
# Converts Capacities toggle structure and handles PDF images

INPUT_FILE="$1"

if [ $# -eq 0 ]; then
    echo "Usage: ./preprocess-capacities.sh <markdown-file>"
    exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' not found!"
    exit 1
fi

echo "🔧 Processing Capacities export..."

# Create backup
cp "$INPUT_FILE" "${INPUT_FILE}.bak"

# Step 1: Convert structure
sed -i '' 's/^- \(#[a-zA-Z]\)/\1/g' "$INPUT_FILE"
sed -i '' 's/^    //' "$INPUT_FILE"

# Step 2: Uncomment image lines that reference assets
sed -i '' 's/<!-- *\(!\[.*\](assets\/[^)]*)\) *-->/\1/g' "$INPUT_FILE"

# Step 2.5: Fix image paths to include assets/ prefix
sed -i '' 's#\(!\[.*\](\)PDFs/#\1assets/PDFs/#g' "$INPUT_FILE"

# Step 3: Find and convert PDFs
echo "🖼️  Converting PDFs to JPG..."

grep -o '!\[.*\](assets/[^)]*\.pdf)' "$INPUT_FILE" | grep -o 'assets/[^)]*.pdf' | while read pdf_path; do
    # Decode URL encoding
    pdf_path=$(echo "$pdf_path" | sed 's/%20/ /g')
    
    if [ -f "$pdf_path" ]; then
        jpg_path="${pdf_path%.pdf}.jpg"
        
        # Convert PDF to JPG (all pages)
        if command -v magick &> /dev/null; then
            magick "$pdf_path" -density 300 -quality 90 "$jpg_path"
            echo "  ✓ Converted: $(basename "$pdf_path")"
        elif command -v convert &> /dev/null; then
            convert -density 300 "$pdf_path" -quality 90 "$jpg_path"
            echo "  ✓ Converted: $(basename "$pdf_path")"
        fi
    else
        echo "  ✗ Not found: $pdf_path"
    fi
done

# Step 4: Update markdown to reference JPGs
sed -i '' 's/\(!\[.*\](assets\/[^)]*\)\.pdf)/\1.jpg)/g' "$INPUT_FILE"

echo "✅ Complete! Backup: ${INPUT_FILE}.bak"