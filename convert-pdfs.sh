#!/bin/bash

# convert-pdfs.sh
# Converts PDFs in assets/ to PNG images for embedding

ASSETS_DIR="assets"

echo "🖼️  Converting PDFs to images..."

# Find all PDFs in assets directory
find "$ASSETS_DIR" -name "*.pdf" | while read pdf_file; do
    # Get the directory and filename without extension
    dir=$(dirname "$pdf_file")
    base=$(basename "$pdf_file" .pdf)
    
    # Output PNG file (same location, .png extension)
    png_file="${dir}/${base}.png"
    
    # Convert using ImageMagick (sips on macOS as backup)
    if command -v convert &> /dev/null; then
        # Using ImageMagick
        convert -density 300 "$pdf_file" -quality 90 "$png_file"
        echo "  ✓ $pdf_file → $png_file"
    elif command -v sips &> /dev/null; then
        # Using macOS sips (only works for single-page PDFs)
        sips -s format png "$pdf_file" --out "$png_file" &> /dev/null
        echo "  ✓ $pdf_file → $png_file"
    else
        echo "  ✗ No conversion tool found (install ImageMagick: brew install imagemagick)"
    fi
done

echo "✅ Done!"