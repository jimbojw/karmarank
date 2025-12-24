#!/bin/bash
# Copy referenced images from content/images/ to output/images/
# Usage: copy-images.sh IMAGE_MARKDOWN_FILE SOURCE_IMAGES_DIR OUTPUT_IMAGES_DIR

set -e

IMAGE_MARKDOWN_FILE="$1"
SOURCE_IMAGES_DIR="$2"
OUTPUT_IMAGES_DIR="$3"

if [ -z "$IMAGE_MARKDOWN_FILE" ] || [ -z "$SOURCE_IMAGES_DIR" ] || [ -z "$OUTPUT_IMAGES_DIR" ]; then
	echo "Usage: copy-images.sh IMAGE_MARKDOWN_FILE SOURCE_IMAGES_DIR OUTPUT_IMAGES_DIR" >&2
	exit 1
fi

if [ ! -f "$IMAGE_MARKDOWN_FILE" ]; then
	echo "Error: Image markdown file not found: $IMAGE_MARKDOWN_FILE" >&2
	exit 1
fi

# Create output images directory
mkdir -p "$OUTPUT_IMAGES_DIR"

# Get absolute path of content directory (parent of SOURCE_IMAGES_DIR)
CONTENT_DIR=$(dirname "$SOURCE_IMAGES_DIR")
CONTENT_DIR_ABS=$(cd "$CONTENT_DIR" && pwd)

# Count copied images
COPIED=0
MISSING=0

# Extract image paths from markdown (format: ![](path) or ![alt](path))
# Pattern matches: ![alt](path) or ![](path)
while IFS= read -r image_path; do
	# Skip empty lines
	[ -z "$image_path" ] && continue
	
	# Resolve path relative to content directory
	# This handles ../, ./, and other path components safely
	if command -v realpath >/dev/null 2>&1; then
		# Use realpath if available (GNU coreutils)
		resolved_path=$(realpath -m "$CONTENT_DIR_ABS/$image_path" 2>/dev/null || echo "")
	elif command -v readlink >/dev/null 2>&1; then
		# Fall back to readlink -f (more portable)
		resolved_path=$(readlink -f "$CONTENT_DIR_ABS/$image_path" 2>/dev/null || echo "")
	else
		# Fall back to cd + pwd (most portable)
		# Use a subshell to avoid changing the current directory
		resolved_path=$(
			cd "$CONTENT_DIR_ABS" 2>/dev/null || exit 1
			cd "$(dirname "$image_path")" 2>/dev/null || exit 1
			echo "$(pwd)/$(basename "$image_path")"
		) || resolved_path=""
	fi
	
	# Verify resolved path is under content directory (security check)
	if [ -z "$resolved_path" ] || [[ "$resolved_path" != "$CONTENT_DIR_ABS"/* ]]; then
		echo "Warning: Invalid or unsafe image path: $image_path" >&2
		continue
	fi
	
	# Verify the file actually exists
	if [ ! -f "$resolved_path" ]; then
		echo "Warning: Image not found: $resolved_path" >&2
		MISSING=$((MISSING + 1))
		continue
	fi
	
	# Extract filename from resolved path
	filename=$(basename "$resolved_path")
	
	# Destination file path
	dest_file="$OUTPUT_IMAGES_DIR/$filename"
	
	cp "$resolved_path" "$dest_file"
	COPIED=$((COPIED + 1))
done < <(grep -oE '!\[.*\]\(([^)]+)\)' "$IMAGE_MARKDOWN_FILE" | sed -E 's/!\[.*\]\(([^)]+)\)/\1/')

if [ $MISSING -gt 0 ]; then
	echo "✗ Copied $COPIED image(s), $MISSING missing" >&2
	exit 1
fi

if [ $COPIED -eq 0 ]; then
	echo "Warning: No images found to copy" >&2
	exit 0
fi

echo "✓ Copied $COPIED image(s) to $OUTPUT_IMAGES_DIR"
