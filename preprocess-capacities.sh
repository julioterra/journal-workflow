#!/bin/bash

# preprocess-capacities.sh
# Converts Capacities toggle structure and handles PDF images

# Parse arguments
SKIP_DEINDENT=false
TITLE="${1:-Journal}"
AUTHOR="${2:-Julio Terra}"
INPUT_FILE="${3:-source/journal.md}"

# Check for --skip-deindent flag
for arg in "$@"; do
    if [ "$arg" = "--skip-deindent" ]; then
        SKIP_DEINDENT=true
    fi
done

if [ $# -eq 0 ]; then
    echo "Usage: ./preprocess-capacities.sh [title] [author] [input-file] [--skip-deindent]"
    echo "  --skip-deindent: Skip removing 4-space indentation from toggle groups"
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

# Step 1a: Remove 4-space indentation from Capacities toggle groups
# NOTE: In Capacities exports, all content within toggle groups is indented with 4 spaces.
# Removing 4 spaces from every line preserves RELATIVE indentation:
#   - 4 spaces (top-level in toggle) → 0 spaces (top-level in markdown)
#   - 8 spaces (nested in toggle)    → 4 spaces (nested in markdown)
# Use --skip-deindent flag if your export doesn't have toggle-based indentation.
if [ "$SKIP_DEINDENT" = false ]; then
    echo "🔧 Removing toggle indentation (4 spaces from each line)..."
    sed -i '' 's/^    //' "$INPUT_FILE"
else
    echo "⏭️  Skipping toggle deindentation (--skip-deindent flag set)"
fi

# Step 1b: Remove blank lines between list items
# Capacities exports include blank lines that break Markdown list nesting
echo "🔧 Removing blank lines between list items..."
perl -i -0pe 's/(\n[ ]*- .*)\n\n([ ]+- )/$1\n$2/g' "$INPUT_FILE"

# Step 1c: Handle different top-level tags
# - PersonalJournal: remove entirely
# - ToDo, FoodJournal, Grateful, WorkStuff: convert to h2 with proper spacing

# Remove PersonalJournal tag
sed -i '' -E '/^#PersonalJournal ?$/d' "$INPUT_FILE"

# Convert other top-level tags to h2 headings (add spaces before capitals, remove #)
sed -i '' 's/^#ToDos$/## To Dos/' "$INPUT_FILE"
sed -i '' 's/^#FoodJournal$/## Food Journal/' "$INPUT_FILE"
sed -i '' 's/^#gratitude$/## Gratitude/' "$INPUT_FILE"
sed -i '' 's/^#WorkStuff$/## Work Stuff/' "$INPUT_FILE"
sed -i '' 's/^#ideas$/## Ideas/' "$INPUT_FILE"

# Step 1d: Remove mentions from headings to avoid index issues
echo "🔧 Removing mentions from headings..."
sed -i '' -E 's/^(#+ .*)\[([^]]+)\]\([^)]+\)/\1\2/g' "$INPUT_FILE"

# Step 2: Uncomment image lines that reference assets
sed -i '' 's/<!-- *\(!\[.*\](assets\/[^)]*)\) *-->/\1/g' "$INPUT_FILE"

# Step 2b: Image paths - graphicspath in template handles the assets/ prefix
sed -i '' 's#](PDFs/#](PDFs/#g' "$INPUT_FILE"
sed -i '' 's#](Images/#](Images/#g' "$INPUT_FILE"

# Step 2c: Remove old frontmatter
echo "🗑️  Removing old frontmatter..."
perl -0777 -i -pe 's/^---.*?---\n\n?//s' "$INPUT_FILE"

# Step 2d: Remove horizontal rules (all types)
sed -i '' '/^---$/d' "$INPUT_FILE"
sed -i '' '/^\*\*\*$/d' "$INPUT_FILE"
sed -i '' '/^___$/d' "$INPUT_FILE"

# Step 3: Replace frontmatter with custom metadata
echo "📋 Step 3: Updating frontmatter..."

# Extract first and last dates from top-level headings (# Date format)
FIRST_DATE=$(grep -m 1 "^# [A-Z]" "$INPUT_FILE" | sed 's/^# //')
LAST_DATE=$(grep "^# [A-Z]" "$INPUT_FILE" | tail -1 | sed 's/^# //')

# Remove old frontmatter (from first --- to second ---, inclusive)
sed -i '' '1{/^---$/!b};:a;/^---$/!{N;ba;};d' "$INPUT_FILE"

# Create new frontmatter
cat > temp_frontmatter.md << EOF
---
title: $TITLE
author: $AUTHOR
dates: $FIRST_DATE - $LAST_DATE
---

EOF

# Prepend new frontmatter
cat temp_frontmatter.md "$INPUT_FILE" > temp_journal.md
mv temp_journal.md "$INPUT_FILE"
rm temp_frontmatter.md

echo "  ✓ Frontmatter updated: $FIRST_DATE - $LAST_DATE"

# Step 4: Find and convert PDFs
echo "🖼️  Converting PDFs to JPG..."

# Step 4: Find and convert PDFs, handle multi-page
echo "🖼️  Converting PDFs to JPG..."

# First pass: convert all PDFs (handle both with and without assets/ prefix)
grep -o '!\[.*\]([^)]*\.pdf)' "$INPUT_FILE" | grep -o '[^(]*\.pdf' | sort -u | while read pdf_path; do
    pdf_path=$(echo "$pdf_path" | sed 's/%20/ /g')
    
    if [ -f "$pdf_path" ]; then
        jpg_base="${pdf_path%.pdf}"
        
        if command -v magick &> /dev/null; then
            magick "$pdf_path" -density 300 -quality 90 "${jpg_base}.jpg"
        elif command -v convert &> /dev/null; then
            convert -density 300 "$pdf_path" -quality 90 "${jpg_base}.jpg"
        fi
        echo "  ✓ Converted: $(basename "$pdf_path")"
    fi
done

# Second pass: update markdown references
# Handle both single-page (file.jpg) and multi-page (file-0.jpg, file-1.jpg, etc.)
grep -n '!\[.*\]([^)]*\.pdf)' "$INPUT_FILE" | while IFS=: read line_num full_line; do
    # Extract the PDF path (with or without assets/ prefix)
    pdf_ref=$(echo "$full_line" | grep -o '[^(]*\.pdf' | sed 's/%20/ /g')
    jpg_base="${pdf_ref%.pdf}"
    
    # Check if it's multi-page
    if [ -f "${jpg_base}-0.jpg" ]; then
        # Multi-page: create references for all pages
        page_num=0
        new_lines=""
        while [ -f "${jpg_base}-${page_num}.jpg" ]; do
            if [ $page_num -gt 0 ]; then
                new_lines="${new_lines}\n"
            fi
            # Extract original alt text
            alt_text=$(echo "$full_line" | sed 's/.*!\[\([^]]*\)\].*/\1/')
            jpg_ref=$(echo "$pdf_ref" | sed 's/ /%20/g')
            new_lines="${new_lines}![${alt_text} (PDF) - Page $((page_num + 1))](${jpg_ref%.pdf}-${page_num}.jpg)"
            page_num=$((page_num + 1))
        done

        # Replace the line
        escaped_line=$(echo "$full_line" | sed 's/[\/&]/\\&/g' | sed 's/\[/\\[/g' | sed 's/\]/\\]/g' | sed 's/\*/\\*/g')
        sed -i '' "${line_num}s|.*|${new_lines}|" "$INPUT_FILE"
        echo "  📄 Multi-page: $(basename "$pdf_ref") → ${page_num} images"
    else
        # Single page: append (PDF) to alt text and change extension
        alt_text=$(echo "$full_line" | sed 's/.*!\[\([^]]*\)\].*/\1/')
        jpg_ref=$(echo "$pdf_ref" | sed 's/ /%20/g')
        replacement="![${alt_text} (PDF)](${jpg_ref%.pdf}.jpg)"
        escaped_line=$(echo "$full_line" | sed 's/[\/&]/\\&/g' | sed 's/\[/\\[/g' | sed 's/\]/\\]/g' | sed 's/\*/\\*/g')
        sed -i '' "${line_num}s|${escaped_line}|${replacement}|" "$INPUT_FILE"
    fi
done

echo "✅ Complete! Backup: ${INPUT_FILE}.bak"

# Step 5: Update markdown to reference JPGs (handle both with and without assets/ prefix)
sed -i '' 's/\(!\[.*\]([^)]*\)\.pdf)/\1.jpg)/g' "$INPUT_FILE"

# Step 6: Add blank lines before and after images for spacing
sed -i '' 's/^\(!\[.*\].*\)$/\n\1\n/' "$INPUT_FILE"

echo "✅ Complete! Backup: ${INPUT_FILE}.bak"