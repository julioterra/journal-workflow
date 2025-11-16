#!/bin/bash

# process-capacities-export.sh
# Processes Capacities export: extracts zip, combines daily notes, converts PDFs, copies images
#
# Usage: ./process-capacities-export.sh <zip-file>
# Example: ./process-capacities-export.sh source/test.zip

set -e  # Exit on any error

SOURCE_DIR="source"
EXPORT_DIR="source/capacities-export"
OUTPUT_FILE="source/journal.md"
ASSETS_DIR="assets"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ============================================================================
# STEP 0: Validate and Extract Zip File
# ============================================================================

echo -e "${BLUE}📦 Processing Capacities export...${NC}"
echo -e "${GREEN}📦 Step 0: Validating export zip file...${NC}"

# Check if zip file parameter was provided
if [ -z "$1" ]; then
    echo -e "${RED}❌ Error: No zip file specified${NC}"
    echo ""
    echo "Usage: $0 <zip-file>"
    echo ""
    echo "Examples:"
    echo "  $0 source/test.zip"
    echo "  $0 source/my-export.zip"
    exit 1
fi

ZIP_FILE="$1"

# Check if file exists
if [ ! -f "$ZIP_FILE" ]; then
    echo -e "${RED}❌ Error: File not found: $ZIP_FILE${NC}"
    exit 1
fi

# Check if it's a zip file
if [[ ! "$ZIP_FILE" =~ \.zip$ ]]; then
    echo -e "${RED}❌ Error: File is not a .zip file: $ZIP_FILE${NC}"
    exit 1
fi

echo "  Processing: $(basename "$ZIP_FILE")"

# Clear and recreate export directory
if [ -d "$EXPORT_DIR" ]; then
    echo "  Clearing old export directory..."
    rm -rf "$EXPORT_DIR"/*
    else
    mkdir -p "$EXPORT_DIR"
fi

# Extract zip file
echo "  Extracting..."
unzip -q -o -X "$ZIP_FILE" -d "$EXPORT_DIR"
echo -e "${GREEN}  ✓ Extracted successfully${NC}"

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
                # Sanitize: if mdls returns "(null)" or non-numeric, default to 1
                if ! [[ "$page_count" =~ ^[0-9]+$ ]]; then
                    page_count=1
                fi

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
    referenced_images=$(grep -oE 'Images/Media/[^)]*\.(png|jpg|jpeg|gif)' "$OUTPUT_FILE" | sed 's|.*\/||' | sort -u)
    
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
# STEP 4: Build Reference Map
# ============================================================================

echo -e "${GREEN}📇 Step 4: Building reference map...${NC}"

REFERENCE_MAP="source/references.json"

# Start JSON file
echo "{" > "$REFERENCE_MAP"

reference_count=0
first_entry=true

# Process all reference folders
for folder in People Organizations Projects Books Definitions; do
    folder_path="$EXPORT_DIR/$folder"
    
    if [ -d "$folder_path" ]; then
        # echo "$folder_path"

        # Find all .md files in this folder
        for ref_file in "$folder_path"/*.md; do
            # echo "ref_file: $ref_file"

            # Find title in front matter of each file
            if [ -f "$ref_file" ]; then
                # Extract title from front matter
                # 🛑 FIX HERE: Pass the loop variable ($ref_file) to awk
                title=$(
                    cat "$ref_file" | \
                    tr -d '\r' | \
                    grep -E '^[ \t]*title:' | \
                    sed -E 's/^[ \t]*title:[ \t]*(.*)/\1/'
                )
                #echo "title: $title"
                
                if [ -n "$title" ]; then
                    # ... (rest of the script is correct for processing and JSON formatting) ...
                    # Get relative path from export root
                    rel_path=$(echo "$ref_file" | sed "s|$EXPORT_DIR/||")
                    
                    # Add comma for subsequent entries
                    if [ "$first_entry" = false ]; then
                        echo "," >> "$REFERENCE_MAP"
                    fi
                    first_entry=false
                    
                    # Add entry to JSON (escape quotes in title)
                    # NOTE: Using a single 'sed' pipeline is usually cleaner for quote escaping
                    title_escaped=$(echo "$title" | sed 's/"/\\"/g') 
                    printf '  "%s": {\n    "name": "%s",\n    "type": "%s"\n  }' \
                        "$rel_path" "$title_escaped" "$folder" >> "$REFERENCE_MAP"
                    
                    reference_count=$((reference_count + 1))
                fi
            fi
        done
    fi
done

# Close JSON file
echo "" >> "$REFERENCE_MAP"
echo "}" >> "$REFERENCE_MAP"

echo -e "${GREEN}  ✓ Mapped $reference_count references${NC}"

# Clean up macOS resource forks that may have been created
find "$EXPORT_DIR" -name "* 2" -type d -exec rm -rf {} + 2>/dev/null || true
find "$EXPORT_DIR" -name "* 3" -type d -exec rm -rf {} + 2>/dev/null || true
find "$EXPORT_DIR" -name "._*" -delete 2>/dev/null || true

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
echo "  📇 References mapped: $reference_count entities → source/references.json"
echo ""
echo "Next steps:"
echo "  1. Run: ./preprocess-capacities.sh \"Title\" \"Author\" $OUTPUT_FILE"
echo "  2. Run: ./build.sh $OUTPUT_FILE"