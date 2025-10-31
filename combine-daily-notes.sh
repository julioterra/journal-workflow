#!/bin/bash

# combine-daily-notes.sh
# Combines multiple daily note files into one chronological journal

SOURCE_DIR="source/daily-notes"
OUTPUT_FILE="source/combined-journal.md"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Directory '$SOURCE_DIR' not found!"
    exit 1
fi

echo "📚 Combining daily notes..."

# Create/clear output file with front matter
cat > "$OUTPUT_FILE" << 'EOF'
---
title: Journal
type: Combined
---

EOF

# Find all .md files, sort by date (assumes YYYY-MM-DD.md format)
find "$SOURCE_DIR" -name "*.md" -type f | sort | while read file; do
    filename=$(basename "$file" .md)
    echo "  + $filename"
    
    # Extract date from filename and format as heading
    # Convert YYYY-MM-DD to readable format (e.g., October 21, 2025)
    if [[ $filename =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2})$ ]]; then
        year="${BASH_REMATCH[1]}"
        month="${BASH_REMATCH[2]}"
        day="${BASH_REMATCH[3]}"
        
        # Convert to date format
        date_formatted=$(date -j -f "%Y-%m-%d" "$filename" "+%B %d, %Y" 2>/dev/null || echo "$filename")
        echo -e "\n# $date_formatted\n" >> "$OUTPUT_FILE"
    else
        echo -e "\n# $filename\n" >> "$OUTPUT_FILE"
    fi
    
    # Skip front matter (lines between ---) and append content
    awk '/^---$/ {p++; next} p >= 2' "$file" >> "$OUTPUT_FILE"
    
    echo "" >> "$OUTPUT_FILE"
done

echo "✅ Combined $(find "$SOURCE_DIR" -name "*.md" | wc -l) files into $OUTPUT_FILE"