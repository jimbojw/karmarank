#!/bin/bash
# Update README.md table of contents
# Usage: readme.sh BUILD_DIR README_FILE CHAPTERS...

set -e

SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/readme-common.sh"

BUILD_DIR="$1"
README_FILE="$2"
shift 2
CHAPTERS=("$@")

if [ -z "$BUILD_DIR" ] || [ -z "$README_FILE" ] || [ ${#CHAPTERS[@]} -eq 0 ]; then
	echo "Usage: readme.sh BUILD_DIR README_FILE CHAPTERS..." >&2
	exit 1
fi

NEW_README="$BUILD_DIR/README.new"

# Generate TOC using shared function
TOC_BLOCK=$(build_toc "${CHAPTERS[@]}")

# Extract content before TOC_START
sed '/<!-- TOC_START -->/,$d' "$README_FILE" > "$NEW_README"
# Append generated TOC
echo "$TOC_BLOCK" >> "$NEW_README"
# Append content after TOC_END
sed '1,/<!-- TOC_END -->/d' "$README_FILE" >> "$NEW_README"

mv "$NEW_README" "$README_FILE"

echo "✓ README.md updated"

