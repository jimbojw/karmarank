#!/bin/bash
# Build combined man page images filter (map + transform logic)
# Usage: build-man-page-images-filter.sh BUILD_DIR OUTPUT_FILE FILTER_TEMPLATE IMAGES_SRC_DIR
#
# Scans IMAGES_SRC_DIR/*.txt files and creates a Lua map mapping image slug
# (base filename without .txt) to the ASCII art content.

set -e

BUILD_DIR="$1"
OUTPUT_FILE="$2"
FILTER_TEMPLATE="$3"
IMAGES_SRC_DIR="$4"

if [ -z "$BUILD_DIR" ] || [ -z "$OUTPUT_FILE" ] || [ -z "$FILTER_TEMPLATE" ] || [ -z "$IMAGES_SRC_DIR" ]; then
	echo "Usage: build-man-page-images-filter.sh BUILD_DIR OUTPUT_FILE FILTER_TEMPLATE IMAGES_SRC_DIR" >&2
	exit 1
fi

# Ensure output directory exists
mkdir -p "$(dirname "$OUTPUT_FILE")"

echo "-- Auto-generated image ASCII art map" > "$OUTPUT_FILE"
echo "image_ascii_map = {" >> "$OUTPUT_FILE"

# Find all .txt files in src directory
if [ -d "$IMAGES_SRC_DIR" ]; then
	for txt_file in "$IMAGES_SRC_DIR"/*.txt; do
		# Check if file exists (glob might not match anything)
		if [ ! -f "$txt_file" ]; then
			continue
		fi
		
		# Extract base name (e.g., calibration-cylinder.txt -> calibration-cylinder)
		basename=$(basename "$txt_file" .txt)
		
		# Read content and escape Lua string special characters
		# Replace \ with \\, " with \", and newlines with \n
		content=$(cat "$txt_file" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/' | tr -d '\n' | sed 's/\\n$//')
		
		echo "  [\"$basename\"] = \"$content\"," >> "$OUTPUT_FILE"
	done
fi

echo "}" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "-- Transform logic" >> "$OUTPUT_FILE"
cat "$FILTER_TEMPLATE" >> "$OUTPUT_FILE"

echo "✓ Man page images filter created"
