#!/bin/bash

# process-capacities-export.sh
# Processes Capacities export: extracts zip, combines daily notes, converts PDFs, copies images

set -e  # Exit on any error

SOURCE_DIR="source"
EXPORT_DIR="source/capacities-export"
OUTPUT_FILE="source/journal.md"
ASSETS_DIR="assets"
ARCHIVE_DIR="archive"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}📦 Processing Capacities export...${NC}"

# ============================================================================
# STEP 0: Find and Extract Zip File
# ============================================================================

echo -e "${GREEN}📦 Step 0: Looking for export zip file...${NC}"

# Find most recent .zip file in source directory
ZIP_FILE=$(find "$SOURCE_DIR" -maxdepth 1 -name "*.zip" -type f -print0 | xargs -0 ls -t | head -n 1)

if [ -z "$ZIP_FILE" ]; then
    echo -e "${RED}❌ Error: No .zip file found in $SOURCE_DIR${NC}"
    echo "Please place your Capacities export zip file in: $SOURCE_DIR"
    exit 1
fi

echo "  Found: $(basename "$ZIP_FILE")"

# Clear and recreate export directory
if [ -d "$EXPORT_DIR" ]; then
    echo "  Clearing old export directory..."
    rm -rf "$EXPORT_DIR"
fi
mkdir -p "$EXPORT_DIR"

# Extract zip file
echo "  Extracting..."
unzip -q "$ZIP_FILE" -d "$EXPORT_DIR"
echo -e "${GREEN}  ✓ Extracted successfully${NC}"

# Archive the zip file with timestamp
mkdir -p "$ARCHIVE_DIR"
TIMESTAMP=$(date "+%Y-%m-%d_%H-%M-%S")
ARCHIVE_NAME="capacities-export-${TIMESTAMP}.zip"
mv "$ZIP_FILE" "$ARCHIVE_DIR/$ARCHIVE_NAME"
echo -e "${GREEN}  ✓ Archived to: $ARCHIVE_DIR/$ARCHIVE_NAME${NC}"

# ============================================================================
# STEP 0.5: Clear Previous Output
# ============================================================================

echo -e "${GREEN}🧹 Cleaning previous output...${NC}"

# Clear assets directories
if [ -d "$ASSETS_DIR/PDFs/Media" ]; then
    rm -rf "$ASSETS_DIR/PDFs/Media"/*
    echo "  ✓ Cleared PDFs"
fi

if [ -d "$ASSETS_DIR/Images/Media" ]; then
    rm -rf "$ASSETS_DIR/Images/Media"/*
    echo "  ✓ Cleared images"
fi

# Recreate directories to ensure they exist
mkdir -p "$ASSETS_DIR/PDFs/Media"
mkdir -p "$ASSETS_DIR/Images/Media"

echo -e "${GREEN}  ✓ Output directories cleared${NC}"

# ============================================================================
# STEP 1: Combine Daily Notes
# ============================================================================

echo -e "${GREEN}📝 Step 1: Combining daily notes...${NC}"

# Create/clear output file with front matter
cat > "$OUTPUT_FILE" << 'EOF'
---
title: Journal
type: Combined
---

EOF

# Find and sort all daily note files
daily_note_count=0
if [ -d "$EXPORT_DIR/DailyNotes" ]; then
    find "$EXPORT_DIR/DailyNotes" -name "*.md" -type f | sort | while read file; do
        filename=$(basename "$file" .md)
        echo "  + $filename"
        
        # Extract date from filename and format as heading
        if [[ $filename =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2})$ ]]; then
            # Convert YYYY-MM-DD to readable format
            date_formatted=$(date -j -f "%Y-%m-%d" "$filename" "+%B %d, %Y" 2>/dev/null || echo "$filename")
            echo -e "\n# $date_formatted\n" >> "$OUTPUT_FILE"
        else
            echo -e "\n# $filename\n" >> "$OUTPUT_FILE"
        fi
        
        # Skip front matter and append content
        awk '/^---$/ {p++; next} p >= 2' "$file" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        
        daily_note_count=$((daily_note_count + 1))
    done
    
    echo -e "${GREEN}  ✓ Combined $daily_note_count daily notes${NC}"
else
    echo -e "${RED}  ⚠ Warning: DailyNotes directory not found${NC}"
fi

# ============================================================================
# STEP 2: Process PDFs (only those referenced in journal)
# ============================================================================

echo -e "${GREEN}📄 Step 2: Processing referenced PDFs...${NC}"

pdf_count=0
if [ -d "$EXPORT_DIR/PDFs/Media" ]; then
    # Extract all PDF filenames referenced in the journal
    referenced_pdfs=$(grep -o 'PDFs/Media/[^)]*\.pdf' "$OUTPUT_FILE" | sed 's/.*\///' | sort -u)
    
    if [ -z "$referenced_pdfs" ]; then
        echo -e "${YELLOW}  ⚠ No PDF references found in journal${NC}"
    else
        while IFS= read -r pdf_name; do
            # URL decode the filename
            pdf_name_decoded=$(printf '%b' "${pdf_name//%/\\x}")
            pdf_path="$EXPORT_DIR/PDFs/Media/$pdf_name_decoded"
            
            if [ -f "$pdf_path" ]; then
                filename=$(basename "$pdf_path" .pdf)
                echo "  + $filename.pdf"
                
                # Check number of pages
                page_count=$(mdls -name kMDItemNumberOfPages -raw "$pdf_path" 2>/dev/null || echo "1")
                
                if [ "$page_count" -gt 1 ]; then
                    # Multi-page: convert each page separately
                    for ((page=0; page<page_count; page++)); do
                        magick -density 150 "$pdf_path[$page]" -quality 85 \
                            "$ASSETS_DIR/PDFs/Media/${filename}-${page}.jpg"
                    done
                    echo "    → Converted to $page_count pages"
                else
                    # Single page: convert to single JPG
                    magick -density 150 "$pdf_path" -quality 85 \
                        "$ASSETS_DIR/PDFs/Media/${filename}.jpg"
                    echo "    → Converted to JPG"
                fi
                
                pdf_count=$((pdf_count + 1))
            else
                echo -e "${YELLOW}  ⚠ Referenced PDF not found: $pdf_name_decoded${NC}"
            fi
        done <<< "$referenced_pdfs"
        
        echo -e "${GREEN}  ✓ Processed $pdf_count PDFs${NC}"
    fi
else
    echo -e "${RED}  ⚠ Warning: PDFs/Media directory not found${NC}"
fi

# ============================================================================
# STEP 3: Copy Images (only those referenced in journal)
# ============================================================================

echo -e "${GREEN}🖼️  Step 3: Copying referenced images...${NC}"

image_count=0
if [ -d "$EXPORT_DIR/Images/Media" ]; then
    # Extract all image filenames referenced in the journal
    referenced_images=$(grep -o 'Images/Media/[^)]*\.(png\|jpg\|jpeg\|gif)' "$OUTPUT_FILE" | sed 's/.*\///' | sort -u)
    
    if [ -z "$referenced_images" ]; then
        echo -e "${YELLOW}  ⚠ No image references found in journal${NC}"
    else
        while IFS= read -r img_name; do
            # URL decode the filename
            img_name_decoded=$(printf '%b' "${img_name//%/\\x}")
            img_path="$EXPORT_DIR/Images/Media/$img_name_decoded"
            
            if [ -f "$img_path" ]; then
                echo "  + $img_name_decoded"
                cp "$img_path" "$ASSETS_DIR/Images/Media/"
                image_count=$((image_count + 1))
            else
                echo -e "${YELLOW}  ⚠ Referenced image not found: $img_name_decoded${NC}"
            fi
        done <<< "$referenced_images"
        
        echo -e "${GREEN}  ✓ Copied $image_count images${NC}"
    fi
else
    echo -e "${RED}  ⚠ Warning: Images/Media directory not found${NC}"
fi

# ============================================================================
# Summary
# ============================================================================

echo ""
echo -e "${BLUE}✅ Export processing complete!${NC}"
echo ""
echo "Output:"
echo "  📝 Combined journal: $OUTPUT_FILE"
echo "  📄 PDFs converted:   $pdf_count files → $ASSETS_DIR/PDFs/Media/"
echo "  🖼️  Images copied:    $image_count files → $ASSETS_DIR/Images/Media/"
echo "  📦 Archived zip:     $ARCHIVE_DIR/$ARCHIVE_NAME"
echo ""
echo "Next steps:"
echo "  1. Run: ./preprocess-capacities.sh $OUTPUT_FILE"
echo "  2. Run: ./build.sh $OUTPUT_FILE"