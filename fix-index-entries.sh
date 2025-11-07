#!/usr/bin/env bash
# fix-index-entries.sh
# Removes stray spaces between \textbf and { in .idx files.
# Creates a .bak backup before modifying the file.

file="$1"

if [ -z "$file" ]; then
  echo "Usage: $0 <file.idx>"
  exit 1
fi

if [ ! -f "$file" ]; then
  echo "Error: file '$file' not found."
  exit 1
fi

echo "🔄 Cleaning index file: $file"

# Create a backup first
cp "$file" "${file}.bak"
echo "📦 Backup created: ${file}.bak"

# Collapse any spaces between \textbf and the opening brace
# e.g. \textbf   {People}  →  \textbf{People}
sed -E 's/\\textbf[[:space:]]+\{([^\}]*)\}/\\textbf{\1}/g' "$file" > "${file}.tmp" \
  && mv "${file}.tmp" "$file"

echo "✅ Fixed stray spaces in index entries: $file"
