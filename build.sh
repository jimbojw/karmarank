#!/bin/bash

# Build script for generating HTML and PDF from Markdown sources
# Note: ePub support disabled due to math rendering issues

set -e

CONTENT_DIR="content"
OUTPUT_DIR="output"
TEMPLATE_DIR="templates"
METADATA="metadata.yaml"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Copy images directory to output (for HTML)
if [ -d "images" ] && [ "$(ls -A images 2>/dev/null)" ]; then
    echo "Copying images to output directory..."
    cp -r images "$OUTPUT_DIR/"
fi

# Get list of chapters in order
CHAPTERS=($(ls "$CONTENT_DIR"/*.md | sort))

# Versioning logic
VERSION=$(grep "version:" "$METADATA" | cut -d'"' -f2)
HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "dev")
DATE=$(date +%Y-%m-%d)
FULL_VERSION="$VERSION ($DATE-$HASH)"
echo "Build Version: $FULL_VERSION"

if [ ${#CHAPTERS[@]} -eq 0 ]; then
    echo "Error: No markdown files found in $CONTENT_DIR/"
    exit 1
fi

echo "Found ${#CHAPTERS[@]} chapters:"
for chapter in "${CHAPTERS[@]}"; do
    echo "  - $(basename "$chapter")"
done

# Build combined book (single HTML file)
echo ""
echo "Building combined HTML..."
pandoc \
    "${CHAPTERS[@]}" \
    --metadata-file="$METADATA" \
    --template="$TEMPLATE_DIR/book.html" \
    --standalone \
    --toc \
    --toc-depth=2 \
    --mathjax \
    --metadata date="$FULL_VERSION" \
    --output="$OUTPUT_DIR/book.html"

echo "✓ Combined HTML: $OUTPUT_DIR/book.html"

# Build combined Markdown (concatenated)
echo ""
echo "Building combined Markdown..."
{
    cat "$METADATA"
    echo ""
    # Extract title, subtitle, author from metadata for H1 headers
    TITLE=$(grep "^title:" "$METADATA" | cut -d'"' -f2)
    SUBTITLE=$(grep "^subtitle:" "$METADATA" | cut -d'"' -f2)
    AUTHOR=$(grep "^author:" "$METADATA" | cut -d'"' -f2)
    
    echo "# $TITLE"
    echo ""
    echo "**$SUBTITLE**"
    echo ""
    echo "By $AUTHOR"
    echo ""
    echo "> Version: $FULL_VERSION"
    echo ""
    awk 'FNR==1{print ""}1' "${CHAPTERS[@]}"
} > "$OUTPUT_DIR/book.md"
echo "✓ Combined Markdown: $OUTPUT_DIR/book.md"

# Build Plain Text (ASCII style)
echo ""
echo "Building Plain Text..."
pandoc \
    "${CHAPTERS[@]}" \
    --metadata-file="$METADATA" \
    --to plain \
    --standalone \
    --columns=72 \
    --metadata date="$FULL_VERSION" \
    --output="$OUTPUT_DIR/book.txt"
echo "✓ Plain Text: $OUTPUT_DIR/book.txt"

# Build PDF (requires LaTeX)
if command -v pdflatex &> /dev/null; then
    echo ""
    echo "Building PDF..."
    
    # Check for SVG conversion tool (for PDF)
    SVG_CONVERTER=""
    if command -v rsvg-convert &> /dev/null; then
        SVG_CONVERTER="rsvg-convert"
    elif command -v inkscape &> /dev/null; then
        SVG_CONVERTER="inkscape"
    fi
    
    if [ -n "$SVG_CONVERTER" ]; then
        echo "  Using $SVG_CONVERTER for SVG conversion"
    else
        echo "  ⚠ No SVG converter found (rsvg-convert or inkscape). SVG images may not render in PDF."
        echo "  Install librsvg2-bin for rsvg-convert, or inkscape for better SVG support."
    fi
    
    pandoc \
        "${CHAPTERS[@]}" \
        --metadata-file="$METADATA" \
        --from=markdown+tex_math_dollars+tex_math_double_backslash \
        --pdf-engine=pdflatex \
        --toc \
        --toc-depth=2 \
        --variable=geometry:margin=1.5in \
        --metadata date="$FULL_VERSION" \
        $([ -n "$SVG_CONVERTER" ] && echo "--variable=graphics") \
        --output="$OUTPUT_DIR/book.pdf"
    echo "✓ PDF: $OUTPUT_DIR/book.pdf"
else
    echo ""
    echo "⚠ Skipping PDF (pdflatex not found. Install texlive-latex-base for PDF support)"
fi

# Build ePub (disabled - math rendering issues in ePub readers)
# Uncomment below to enable ePub generation:
# echo ""
# echo "Building ePub..."
# pandoc \
#     "${CHAPTERS[@]}" \
#     --metadata-file="$METADATA" \
#     --toc \
#     --toc-depth=2 \
#     --mathml \
#     --css="$TEMPLATE_DIR/epub.css" \
#     --output="$OUTPUT_DIR/book.epub"
# echo "✓ ePub: $OUTPUT_DIR/book.epub"

echo ""
echo "Build complete! Output files in $OUTPUT_DIR/"

# Build Landing Page (index.html)
echo ""
echo "Building Landing Page..."
pandoc \
    "index.md" \
    --metadata-file="$METADATA" \
    --template="$TEMPLATE_DIR/book.html" \
    --standalone \
    --metadata date="$FULL_VERSION" \
    --output="$OUTPUT_DIR/index.html"
echo "✓ Landing Page: $OUTPUT_DIR/index.html"

