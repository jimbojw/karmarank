#!/bin/bash
# Update README.md table of contents
# Usage: update-readme-toc.sh BUILD_DIR README_FILE CHAPTERS...

set -e

BUILD_DIR="$1"
README_FILE="$2"
shift 2
CHAPTERS=("$@")

TOC_FILE="$BUILD_DIR/readme_toc.tmp"
NEW_README="$BUILD_DIR/README.new"

echo "<!-- TOC_START -->" > "$TOC_FILE"
echo "" >> "$TOC_FILE"

for f in "${CHAPTERS[@]}"; do
	TITLE=$(grep "^# " "$f" | head -n 1 | sed 's/^# //')
	echo "- [$TITLE]($f)" >> "$TOC_FILE"
done

echo "" >> "$TOC_FILE"
echo "<!-- TOC_END -->" >> "$TOC_FILE"

sed '/<!-- TOC_START -->/,$d' "$README_FILE" > "$NEW_README"
cat "$TOC_FILE" >> "$NEW_README"
sed '1,/<!-- TOC_END -->/d' "$README_FILE" >> "$NEW_README"

mv "$NEW_README" "$README_FILE"

echo "✓ README.md updated"

