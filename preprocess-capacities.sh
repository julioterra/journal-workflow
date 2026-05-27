#!/bin/bash

# preprocess-capacities.sh
# Converts Capacities toggle structure and handles PDF images

# Parse arguments
SKIP_DEINDENT=true
TITLE="${1:-Journal}"
AUTHOR="${2:-Julio Terra}"
INPUT_FILE="${3:-source/journal.md}"

# Check for --toggle-deindent flag
for arg in "$@"; do
    if [ "$arg" = "--toggle-deindent" ]; then
        SKIP_DEINDENT=false
    fi
done

if [ $# -eq 0 ]; then
    echo "Usage: ./preprocess-capacities.sh [title] [author] [input-file] [--toggle-deindent]"
    echo "  --toggle-deindent: Remove 4-space indentation from Capacities toggle groups"
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
# Use --toggle-deindent flag if your export has toggle-based indentation.
if [ "$SKIP_DEINDENT" = false ]; then
    echo "🔧 Removing toggle indentation (4 spaces from each line)..."
    sed -i '' 's/^    //' "$INPUT_FILE"
else
    echo "⏭️  Skipping toggle deindentation (default behavior)"
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

# Step 1e: Normalize Capacities blockquote soft breaks.
#
# WHY: When Shift+Return is used inside a Capacities quote block, the export
#      represents the break as a zero-width space (U+200B, UTF-8 bytes
#      E2 80 8B) — either alone on a line, or as a prefix on a continuation
#      paragraph. Pandoc treats ZWSP as a printable character, not whitespace,
#      so the blockquote survives only via lazy continuation and the entire
#      region collapses into one paragraph. Worse, anywhere Capacities emits
#      a TRULY blank line inside the quote (e.g. after a numbered list), the
#      blockquote terminates and the rest of the quoted content escapes into
#      body text. The same collapse also breaks per-paragraph emphasis (the
#      `*italic*` runs can span the collapse) so closing `*` markers can lose
#      their partners and end up rendered as literal asterisks.
#
# WHAT: Rewrite the ZWSP convention into proper Markdown blockquote syntax,
#       but only INSIDE detected `>`-quote regions, so ZWSPs elsewhere in
#       body text (a different soft-break pattern Capacities also uses) are
#       left untouched.
#
# HOW:  Single-pass perl state machine, line by line:
#         - Enter a quote region on any line starting with `>` (after optional
#           leading whitespace).
#         - While inside, rewrite:
#             * ZWSP-only lines               → `>`     (paragraph break in quote)
#             * lines that start with a ZWSP  → `> …`   (strip ZWSP, prefix `> `)
#             * a truly blank line followed by a ZWSP-prefixed line → `>` for
#               the blank too (catches the Capacities post-list artifact that
#               would otherwise terminate the quote).
#         - Exit the region on any other non-blank line.
#       Buffered blank lines are held in @buf so we can decide retroactively
#       whether they continue the quote (next line is ZWSP/`>`) or end it.
echo "🔧 Normalizing blockquote soft breaks..."
perl -i -ne '
BEGIN { our $in_quote = 0; our @buf = (); }

# A new or continuing `>`-marked quote line
if (/^\s*>/) {
    # Buffered blanks before a `>` line are intentional. In Capacities a
    # truly blank line between two `>` paragraphs is the signal that the
    # author wants TWO SEPARATE quotes (not one multi-paragraph quote).
    # Emit the blanks verbatim so Pandoc splits them naturally. Note this
    # only affects the `>`-then-blank-then-`>` case; ZWSP-pattern soft-break
    # continuations of the same quote are handled in the branches below.
    print for @buf; @buf = ();
    $in_quote = 1;
    print;
    next;
}

if ($in_quote) {
    # ZWSP-only line: paragraph gap inside the quote
    if (/^\s*\xE2\x80\x8B\s*$/) {
        print ">\n" for @buf; @buf = ();
        print ">\n";
        next;
    }
    # ZWSP-prefixed continuation: strip the ZWSP and prefix `> `
    if (/^\s*\xE2\x80\x8B(.*)$/s) {
        print ">\n" for @buf; @buf = ();
        print "> $1";
        next;
    }
    # Truly blank line: buffer; lookahead on the next line decides whether
    # this is a quote continuation (next line is a `>` or ZWSP line) or a
    # real paragraph break that ends the quote.
    if (/^\s*$/) {
        push @buf, $_;
        next;
    }
    # Anything else ends the quote. Buffered blanks were a real paragraph
    # break, so emit them verbatim.
    $in_quote = 0;
    print for @buf; @buf = ();
    print;
    next;
}

# Outside any quote region — pass through unchanged. @buf is only filled
# while $in_quote is true, so this flush is a no-op safety net.
print for @buf; @buf = ();
print;

END { print for @buf; }
' "$INPUT_FILE"

# Step 1f: Balance italic emphasis across blockquote paragraph boundaries.
#
# WHY: In Capacities, a long italicized quote is one continuous span — the
#      author opens `*` once at the start and closes `*` once at the end,
#      and Capacities renders the soft line breaks in between as part of
#      the same italic span. When Step 1e converts those soft breaks into
#      proper Markdown paragraph breaks (`>` empty lines), Pandoc parses
#      emphasis paragraph-by-paragraph: the opening `*` in paragraph 1
#      can no longer find its closing `*` in paragraph N. Pandoc gives up
#      pairing them, the intermediate paragraphs lose their italics, and
#      the orphaned `*` characters render as literal asterisks.
#
# WHAT: Inside `>`-quote regions, re-balance italic markers across
#       paragraph boundaries. Each `> ...` text line becomes its own
#       self-balanced italic context, but italic spans that originally
#       crossed boundaries are reconstructed by closing at the end of
#       one line and reopening at the start of the next.
#
# HOW:  Single-pass perl state machine:
#       - Track `$italic_should_continue` across `> ...` text lines in the
#         same quote region.
#       - For each text line:
#           * If `$italic_should_continue` is true, prepend `*` to the
#             line content AFTER any `>` prefix and any list marker
#             (so `> 1. text` becomes `> 1. *text` — preserves list
#             parsing).
#           * Scan the resulting content for italic state changes.
#             `**` is treated as a bold marker (skipped, no italic toggle).
#             `\*` is treated as an escape (the `*` is literal).
#           * If italic is open at end of line, append `*` to close it
#             and set `$italic_should_continue = 1` for the next line.
#       - `>` empty lines pass through; state carries across them.
#       - State resets when the quote region ends.
#
# Bold (`**`) is detected so it doesn't confuse the italic counter, but
# bold spans across paragraph boundaries are not re-balanced — the data
# doesnt need it and bold-across-paragraphs is a rarer pattern.
echo "🔧 Balancing italic emphasis across blockquote paragraphs..."
perl -i -ne '
BEGIN { our $in_quote = 0; our $italic_should_continue = 0; }

sub scan_italic_end_state {
    my ($text, $start_state) = @_;
    my $open = $start_state;
    my $n = length($text);
    my $i = 0;
    while ($i < $n) {
        my $c = substr($text, $i, 1);
        if ($c eq "\\" && $i + 1 < $n) {
            $i += 2;
            next;
        }
        if ($c eq "*") {
            if ($i + 1 < $n && substr($text, $i + 1, 1) eq "*") {
                $i += 2;
                next;
            }
            $open = !$open;
            $i += 1;
            next;
        }
        $i += 1;
    }
    return $open;
}

if (/^\s*>/) {
    if (!$in_quote) {
        $in_quote = 1;
        $italic_should_continue = 0;
    }
    if (/^\s*>\s*$/) {
        print;
        next;
    }
    chomp(my $line = $_);
    if ($line =~ /^(\s*>\s*(?:\d+[.)]\s+|[-+*]\s+)?)(.*)$/s) {
        my $prefix  = $1;
        my $content = $2;
        if ($italic_should_continue) {
            $content = "*" . $content;
        }
        my $end_state = scan_italic_end_state($content, 0);
        if ($end_state) {
            $content .= "*";
            $italic_should_continue = 1;
        } else {
            $italic_should_continue = 0;
        }
        print $prefix, $content, "\n";
    } else {
        print;
    }
    next;
}

if ($in_quote) {
    $in_quote = 0;
    $italic_should_continue = 0;
}
print;
' "$INPUT_FILE"

# Step 2: Uncomment image lines that reference assets
sed -i '' 's/<!-- *\(!\[.*\](assets\/[^)]*)\) *-->/\1/g' "$INPUT_FILE"

# Step 2b: Image paths - graphicspath in template handles the assets/ prefix
sed -i '' 's#](../PDFs/#](PDFs/#g' "$INPUT_FILE"
sed -i '' 's#](../Images/#](Images/#g' "$INPUT_FILE"

# Step 2c: Remove old frontmatter
echo "🗑️  Removing old frontmatter..."
perl -0777 -i -pe 's/^---.*?---\n\n?//s' "$INPUT_FILE"

# Step 2d: Remove horizontal rules (all types)
sed -i '' '/^---$/d' "$INPUT_FILE"
sed -i '' '/^\*\*\*$/d' "$INPUT_FILE"
sed -i '' '/^___$/d' "$INPUT_FILE"

# Step 3: Replace frontmatter with custom metadata
echo "📋 Step 3: Updating frontmatter..."

# Read date range from CSV in export directory (authoritative source)
CSV_FILE=$(find source/capacities-export -maxdepth 1 -name "*.csv" 2>/dev/null | head -1)

if [ -n "$CSV_FILE" ]; then
    echo "  📋 Reading date range from: $(basename "$CSV_FILE")"
    FIRST_ISO=$(tail -n +2 "$CSV_FILE" | awk -F';' '{print $2}' | tr -d ' ' | sort | head -1)
    LAST_ISO=$(tail -n +2 "$CSV_FILE" | awk -F';' '{print $2}' | tr -d ' ' | sort | tail -1)
    FIRST_DATE=$(date -jf "%Y-%m-%d" "$FIRST_ISO" "+%B %d, %Y" 2>/dev/null || echo "$FIRST_ISO")
    LAST_DATE=$(date -jf "%Y-%m-%d" "$LAST_ISO" "+%B %d, %Y" 2>/dev/null || echo "$LAST_ISO")
else
    echo "  ⚠ No CSV found, falling back to journal headings"
    FIRST_DATE=$(grep -m 1 "^# [A-Z]" "$INPUT_FILE" | sed 's/^# //')
    LAST_DATE=$(grep "^# [A-Z]" "$INPUT_FILE" | tail -1 | sed 's/^# //')
fi

# Extract year, start month, and end month
# Expected format: "Month DD, YYYY"
YEAR=$(echo "$LAST_DATE" | sed -E 's/.*, ([0-9]{4})$/\1/')
START_MONTH=$(echo "$FIRST_DATE" | sed -E 's/^([A-Za-z]+).*/\1/' | tr '[:lower:]' '[:upper:]')
END_MONTH=$(echo "$LAST_DATE" | sed -E 's/^([A-Za-z]+).*/\1/' | tr '[:lower:]' '[:upper:]')

# Only include end_month in frontmatter if it differs from start_month
if [ "$START_MONTH" = "$END_MONTH" ]; then
    END_MONTH_LINE=""
else
    END_MONTH_LINE="end_month: $END_MONTH"
fi

# Remove old frontmatter (from first --- to second ---, inclusive)
# Use awk instead of complex sed for better compatibility
awk 'BEGIN{p=1} /^---$/{if(p){p=0;next}else{p=1;next}} p' "$INPUT_FILE" > "${INPUT_FILE}.tmp" && mv "${INPUT_FILE}.tmp" "$INPUT_FILE"

# Create new frontmatter
cat > temp_frontmatter.md << EOF
---
title: $TITLE
author: $AUTHOR
dates: $FIRST_DATE - $LAST_DATE
year: $YEAR
start_month: $START_MONTH
$END_MONTH_LINE
---

EOF

# Prepend new frontmatter
cat temp_frontmatter.md "$INPUT_FILE" > temp_journal.md
mv temp_journal.md "$INPUT_FILE"
rm temp_frontmatter.md

if [ -n "$END_MONTH_LINE" ]; then
    echo "  ✓ Frontmatter updated: $YEAR ($START_MONTH - $END_MONTH)"
else
    echo "  ✓ Frontmatter updated: $YEAR ($START_MONTH)"
fi

# Step 4: Find and convert PDFs, handle multi-page
echo "🖼️  Converting PDFs to JPG..."

# First pass: convert all PDFs (handle both with and without assets/ prefix)
# Use .* to match paths with parentheses in filenames
# Match from ]( to .pdf) to avoid capturing parentheses in alt text
grep -oE '!\[.*\]\(.*\.pdf\)' "$INPUT_FILE" | grep -oE '\]\(.*\.pdf\)' | sed 's/^..//' | sed 's/)$//' | sort -u | while read pdf_path; do
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
# Use .* to match paths with parentheses in filenames
grep -nE '!\[.*\]\(.*\.pdf\)' "$INPUT_FILE" | while IFS=: read line_num full_line; do
    # Extract the PDF path (with or without assets/ prefix)
    # Match from ]( to .pdf) to avoid capturing parentheses in alt text
    pdf_ref=$(echo "$full_line" | grep -oE '\]\(.*\.pdf\)' | sed 's/^..//' | sed 's/)$//' | sed 's/%20/ /g')
    jpg_base="${pdf_ref%.pdf}"
    
    # Check if it's multi-page (process-capacities-export.sh puts JPGs in assets/)
    if [ -f "assets/${jpg_base}-0.jpg" ]; then
        # Multi-page: create references for all pages
        page_num=0
        new_lines=""
        while [ -f "assets/${jpg_base}-${page_num}.jpg" ]; do
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
        # Replace entire line by line number (avoid pattern matching issues with special chars)
        sed -i '' "${line_num}s|.*|${replacement}|" "$INPUT_FILE"
    fi
done

# Step 5: Add blank lines before and after images for spacing
sed -i '' 's/^\(!\[.*\].*\)$/\n\1\n/' "$INPUT_FILE"

echo "✅ Complete! Backup: ${INPUT_FILE}.bak"