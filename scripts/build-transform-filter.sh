#!/bin/bash
# Build combined transform filter (map + transform logic)
# Usage: build-transform-filter.sh BUILD_DIR OUTPUT_FILE FILTER_TEMPLATE CHAPTERS...

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

