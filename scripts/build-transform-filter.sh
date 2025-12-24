#!/bin/bash
# Build combined transform filter (map + transform logic)
# Usage: build-transform-filter.sh BUILD_DIR OUTPUT_FILE FILTER_TEMPLATE CHAPTERS...
# 
# ID extraction implementation notes:
# - We follow Pandoc's OBSERVED behavior, not its documentation (which is incorrect)
# - Periods (.) are REMOVED (despite docs claiming they're preserved)
# - Underscores (_) are PRESERVED
# - Formatting (bold, links) is stripped; link text is extracted, not URL
# - Leading/trailing hyphens are removed, multiple hyphens collapsed
# - Case is lowercased, spaces become hyphens
#
# Known edge cases where our implementation differs from Pandoc:
# - Headers with ONLY links: Pandoc extracts link text, we include URL
#   (e.g., "# [Link](url)" -> Pandoc: "link", ours: "linkurl")
# - Headers with ONLY punctuation: Pandoc outputs "# ", we output empty string
#   (e.g., "# !@#$" -> Pandoc: "# ", ours: "")
# These edge cases don't occur in our actual chapter headers.

set -e

BUILD_DIR="$1"
OUTPUT_FILE="$2"
FILTER_TEMPLATE="$3"
shift 3
CHAPTERS=("$@")

# Ensure output directory exists
mkdir -p "$(dirname "$OUTPUT_FILE")"

echo "-- Auto-generated chapter ID map" > "$OUTPUT_FILE"
echo "chapter_id_map = {" >> "$OUTPUT_FILE"

for f in "${CHAPTERS[@]}"; do
	basename=$(basename "$f")
	h1_line=$(grep '^#[^#]' "$f" | head -1)
	if [ -z "$h1_line" ]; then
		echo "Error: No H1 found in $f" >&2
		exit 1
	fi
	h1_text=$(echo "$h1_line" | sed 's/^# *//')
	id=$(echo "$h1_text" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g; s/[^a-z0-9_-]//g; s/--*/-/g; s/^-//; s/-$//')
	if [ -z "$id" ]; then
		echo "Error: Failed to generate ID from H1 in $f" >&2
		echo "H1 was: $h1_line" >&2
		exit 1
	fi
	echo "  [\"$basename\"] = \"$id\"," >> "$OUTPUT_FILE"
done

echo "}" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "-- Transform logic" >> "$OUTPUT_FILE"
cat "$FILTER_TEMPLATE" >> "$OUTPUT_FILE"

echo "✓ Transform filter created"

