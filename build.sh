#!/bin/bash

# build.sh
# Converts markdown to PDF using Pandoc and LaTeX with index support

set -e

# Parse arguments
KEEP_OUTPUT=false
INPUT_FILE=""
PUBLISHER=""
BLEED=""
TRIM_WIDTH=""
TRIM_HEIGHT=""
MARGIN_TOP=""
MARGIN_BOTTOM=""
MARGIN_INNER=""
MARGIN_OUTER=""
BINDING_OFFSET=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --keep-output)
            KEEP_OUTPUT=true
            shift
            ;;
        --publisher)
            PUBLISHER="$2"
            shift 2
            ;;
        --bleed)
            BLEED="$2"
            shift 2
            ;;
        --trim-width)
            TRIM_WIDTH="$2"
            shift 2
            ;;
        --trim-height)
            TRIM_HEIGHT="$2"
            shift 2
            ;;
        --paperwidth)
            TRIM_WIDTH="$2"
            shift 2
            ;;
        --paperheight)
            TRIM_HEIGHT="$2"
            shift 2
            ;;
        --top)
            MARGIN_TOP="$2"
            shift 2
            ;;
        --bottom)
            MARGIN_BOTTOM="$2"
            shift 2
            ;;
        --inner)
            MARGIN_INNER="$2"
            shift 2
            ;;
        --outer)
            MARGIN_OUTER="$2"
            shift 2
            ;;
        --bindingoffset)
            BINDING_OFFSET="$2"
            shift 2
            ;;
        *)
            INPUT_FILE="$1"
            shift
            ;;
    esac
done

# Load publisher configuration if specified
if [ -n "$PUBLISHER" ]; then
    PUBLISHER_CONFIG="publishers/${PUBLISHER}.conf"
    if [ ! -f "$PUBLISHER_CONFIG" ]; then
        echo "Error: Publisher configuration '$PUBLISHER_CONFIG' not found!"
        exit 1
    fi
    echo "📋 Loading publisher configuration: $PUBLISHER"
    source "$PUBLISHER_CONFIG"
fi

# Set defaults if not specified (either by publisher config or command line)
BLEED="${BLEED:-0in}"
TRIM_WIDTH="${TRIM_WIDTH:-6in}"
TRIM_HEIGHT="${TRIM_HEIGHT:-9in}"
MARGIN_TOP="${MARGIN_TOP:-0.85in}"
MARGIN_BOTTOM="${MARGIN_BOTTOM:-0.85in}"
MARGIN_INNER="${MARGIN_INNER:-0.875in}"
MARGIN_OUTER="${MARGIN_OUTER:-0.625in}"
BINDING_OFFSET="${BINDING_OFFSET:-0in}"

# Calculate paper dimensions (trim + bleed on all sides)
# Convert measurements to points for calculation
function to_points() {
    local value="$1"
    # Remove 'in' suffix and multiply by 72
    echo "$value" | sed 's/in$//' | awk '{print $1 * 72}'
}

function to_inches() {
    local points="$1"
    echo "${points}in"
}

TRIM_WIDTH_PT=$(to_points "$TRIM_WIDTH")
TRIM_HEIGHT_PT=$(to_points "$TRIM_HEIGHT")
BLEED_PT=$(to_points "$BLEED")

PAPER_WIDTH_PT=$(echo "$TRIM_WIDTH_PT + 2 * $BLEED_PT" | bc)
PAPER_HEIGHT_PT=$(echo "$TRIM_HEIGHT_PT + 2 * $BLEED_PT" | bc)

PAPER_WIDTH=$(echo "scale=3; $PAPER_WIDTH_PT / 72" | bc)in
PAPER_HEIGHT=$(echo "scale=3; $PAPER_HEIGHT_PT / 72" | bc)in

# Adjust margins to account for bleed (add bleed to each margin)
MARGIN_TOP_PT=$(to_points "$MARGIN_TOP")
MARGIN_BOTTOM_PT=$(to_points "$MARGIN_BOTTOM")
MARGIN_INNER_PT=$(to_points "$MARGIN_INNER")
MARGIN_OUTER_PT=$(to_points "$MARGIN_OUTER")

MARGIN_TOP_ADJUSTED_PT=$(echo "$MARGIN_TOP_PT + $BLEED_PT" | bc)
MARGIN_BOTTOM_ADJUSTED_PT=$(echo "$MARGIN_BOTTOM_PT + $BLEED_PT" | bc)
MARGIN_INNER_ADJUSTED_PT=$(echo "$MARGIN_INNER_PT + $BLEED_PT" | bc)
MARGIN_OUTER_ADJUSTED_PT=$(echo "$MARGIN_OUTER_PT + $BLEED_PT" | bc)

MARGIN_TOP_ADJUSTED=$(echo "scale=3; $MARGIN_TOP_ADJUSTED_PT / 72" | bc)in
MARGIN_BOTTOM_ADJUSTED=$(echo "scale=3; $MARGIN_BOTTOM_ADJUSTED_PT / 72" | bc)in
MARGIN_INNER_ADJUSTED=$(echo "scale=3; $MARGIN_INNER_ADJUSTED_PT / 72" | bc)in
MARGIN_OUTER_ADJUSTED=$(echo "scale=3; $MARGIN_OUTER_ADJUSTED_PT / 72" | bc)in

TEMPLATE="templates/journal-template.tex"
OUTPUT_DIR="output"
OUTPUT_NAME=$(basename "$INPUT_FILE" .md)
OUTPUT_FILE="$OUTPUT_DIR/$OUTPUT_NAME.pdf"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_DIR="logs"
BUILD_LOG_FILE="$LOG_DIR/build.sh-build.log"
INDEX_LOG_FILE="$LOG_DIR/build.sh-index.log"


if [ -z "$INPUT_FILE" ]; then
    echo "Usage: ./build.sh <input.md> [OPTIONS]"
    echo ""
    echo "Publisher Presets:"
    echo "  --publisher <name>     Load publisher configuration (e.g., blurb)"
    echo ""
    echo "Print Specifications:"
    echo "  --bleed <size>         Bleed amount (default: 0in)"
    echo "  --trim-width <size>    Trim width (default: 6in)"
    echo "  --trim-height <size>   Trim height (default: 9in)"
    echo ""
    echo "Margins:"
    echo "  --top <size>           Top margin (default: 0.75in)"
    echo "  --bottom <size>        Bottom margin (default: 0.75in)"
    echo "  --inner <size>         Inner margin (default: 0.875in)"
    echo "  --outer <size>         Outer margin (default: 0.625in)"
    echo "  --bindingoffset <size> Binding offset (default: 0.25in)"
    echo ""
    echo "Other:"
    echo "  --keep-output          Preserve existing files in output directory"
    echo ""
    echo "Examples:"
    echo "  ./build.sh source/journal.md --publisher blurb"
    echo "  ./build.sh source/journal.md --trim-width 5in --trim-height 8in --bleed 0.125in"
    echo "  ./build.sh source/journal.md --publisher blurb --bleed 0.15in"
    exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' not found!"
    exit 1
fi

# Clean output directory unless --keep-output flag is set
mkdir -p "$OUTPUT_DIR"
if [ "$KEEP_OUTPUT" = false ]; then
    echo "🧹 Cleaning output directory..."
    rm -rf "$OUTPUT_DIR"/*
fi

echo "📚 Journal to PDF Converter"
echo "================================"
echo "📄 Input:    $INPUT_FILE"
echo "📋 Template: $TEMPLATE"
echo "📦 Output:   $OUTPUT_FILE"
if [ "$BLEED" != "0in" ]; then
    echo "📐 Trim:     $TRIM_WIDTH × $TRIM_HEIGHT"
    echo "📏 Bleed:    $BLEED (PDF: $PAPER_WIDTH × $PAPER_HEIGHT)"
else
    echo "📏 Page:     $PAPER_WIDTH × $PAPER_HEIGHT"
fi
echo ""

# Step 1: Convert to .tex file
echo "🔄 Step 1: Converting to LaTeX..."
pandoc "$INPUT_FILE" \
  --from=markdown \
  --to=latex \
  --template="$TEMPLATE" \
  --lua-filter=filters/task-list-filter.lua \
  --lua-filter=filters/remove-todo-sections.lua \
  --lua-filter=filters/remove-object-embeds.lua \
  --lua-filter=filters/add-index-entries.lua \
  --lua-filter=filters/filter-media-links.lua \
  --lua-filter=filters/http-links-to-footnotes.lua \
  --lua-filter=filters/landscape-table-filter.lua \
  --lua-filter=filters/tag-filter.lua \
  --lua-filter=filters/image-page-filter.lua \
  --metadata paperwidth="$PAPER_WIDTH" \
  --metadata paperheight="$PAPER_HEIGHT" \
  --metadata pagedimensions="$PAPER_WIDTH × $PAPER_HEIGHT" \
  --metadata margintop="$MARGIN_TOP_ADJUSTED" \
  --metadata marginbottom="$MARGIN_BOTTOM_ADJUSTED" \
  --metadata margininner="$MARGIN_INNER_ADJUSTED" \
  --metadata marginouter="$MARGIN_OUTER_ADJUSTED" \
  --metadata marginbinding="$BINDING_OFFSET" \
  --toc \
  --toc-depth=2 \
  --number-sections \
  -V documentclass=book \
  -V papersize=custom \
  -V paperwidth="$PAPER_WIDTH" \
  -V paperheight="$PAPER_HEIGHT" \
  --standalone \
  -o "$OUTPUT_DIR/$OUTPUT_NAME.tex"

# Step 2: First LaTeX pass (creates .idx)
echo "🔄 Step 2: First LaTeX pass..."
(cd "$OUTPUT_DIR" && lualatex -interaction=nonstopmode "$OUTPUT_NAME.tex" > "../$BUILD_LOG_FILE" 2>&1)

# Step 3: Build all indexes
echo "📇 Step 3: Building indexes..."
(cd "$OUTPUT_DIR" && {
    for idx in people organizations projects definitions books tags; do
        if [ -f "${idx}.idx" ]; then
            makeindex "${idx}.idx" >> "../$INDEX_LOG_FILE" 2>&1
        fi
    done
})

# Step 4: Final LaTeX pass
echo "🔄 Step 4: Final LaTeX pass..."
(cd "$OUTPUT_DIR" && lualatex -interaction=nonstopmode "$OUTPUT_NAME.tex" > "../$BUILD_LOG_FILE" 2>&1)

echo "✅ Success! PDF created: $OUTPUT_FILE"
echo "🔍 Opening PDF..."
open "$OUTPUT_FILE"

# Check if conversion was successful
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Success! PDF created: $OUTPUT_FILE${NC}"
    
    # Open the PDF (macOS)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "🔍 Opening PDF..."
        open "$OUTPUT_FILE"
    fi
else
    echo -e "${RED}❌ Error: Conversion failed!${NC}"
    exit 1
fi
