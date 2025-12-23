#!/bin/bash
# Prepare title page markdown
# Usage: prepare-title-page.sh METADATA OUTPUT_FILE DATE VERSION HASH [RELEASE_MODE]

set -e

METADATA="$1"
OUTPUT_FILE="$2"
DATE="$3"
VERSION="$4"
HASH="$5"
RELEASE_MODE="$6"

# Ensure output directory exists
mkdir -p "$(dirname "$OUTPUT_FILE")"

TITLE=$(grep "^title:" "$METADATA" | cut -d'"' -f2)
SUBTITLE=$(grep "^subtitle:" "$METADATA" | cut -d'"' -f2)
AUTHOR=$(grep "^author:" "$METADATA" | cut -d'"' -f2)

echo "# $TITLE" > "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "*$SUBTITLE*" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "By $AUTHOR" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

if [ -z "$RELEASE_MODE" ]; then
	echo "Build: $VERSION ($DATE-$HASH)" >> "$OUTPUT_FILE"
else
	echo "Version: $VERSION" >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"

echo "✓ Title page prepared"

