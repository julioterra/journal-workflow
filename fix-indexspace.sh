#!/usr/bin/env bash
# fix-indexspace.sh
# Adds \indexspace before each top-level \item \textbf line in a .ind file.
# Creates a .bak backup before modifying the file.

file="$1"
if [ -z "$file" ]; then
  echo "Usage: $0 <file.ind>"
  exit 1
fi

if [ ! -f "$file" ]; then
  echo "Error: file '$file' not found."
  exit 1
fi

# Backup the original
cp "$file" "${file}.bak"
echo "🔄 Backed up $file to ${file}.bak"

tmp="${file}.tmp"
> "$tmp"

prev_nonblank=""

# Scan line-by-line
while IFS= read -r line || [ -n "$line" ]; do
  trimmed="$(echo "$line" | sed 's/^[[:space:]]*//')"

  # Detect top-level category
  if [[ "$trimmed" == \\item\ \\textbf* ]]; then
    # Check if previous nonblank line isn't an \indexspace
    prev_trimmed="$(echo "$prev_nonblank" | sed 's/^[[:space:]]*//')"
    if [[ ! "$prev_trimmed" =~ ^\\indexspace ]]; then
      echo "" >> "$tmp"
      echo "  \\indexspace" >> "$tmp"
      echo "" >> "$tmp"
    fi
  fi

  echo "$line" >> "$tmp"

  # Update tracker if this line isn’t blank
  if [ -n "$(echo "$line" | tr -d '[:space:]')" ]; then
    prev_nonblank="$line"
  fi
done < "$file"

# Replace original with updated version
mv "$tmp" "$file"
echo "✅ Updated $file (backup saved as ${file}.bak)"
