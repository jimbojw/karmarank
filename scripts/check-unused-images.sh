#!/bin/bash
# Check for unused images in the images directory
# Usage: check-unused-images.sh IMAGES_DIR MD_FILES...

set -e

IMAGES_DIR="$1"
shift
ALL_MD=("$@")

FAILED=0

if [ -d "$IMAGES_DIR" ]; then
	for img_file in "$IMAGES_DIR"/*.png "$IMAGES_DIR"/*.excalidraw; do
		if [ -f "$img_file" ]; then
			BASENAME=$(basename "$img_file")
			BASENAME_NO_EXT=$(basename "$img_file" .png | sed 's/\.excalidraw$//')
			FOUND=0
			for md_file in "${ALL_MD[@]}"; do
				if [ -f "$md_file" ]; then
					if grep -qE "(images/|content/images/)$BASENAME" "$md_file" 2>/dev/null || \
					   grep -qE "(images/|content/images/)$BASENAME_NO_EXT" "$md_file" 2>/dev/null; then
						FOUND=1
						break
					fi
				fi
			done
			if [ $FOUND -eq 0 ]; then
				echo "✗ Unused image: $img_file"
				FAILED=$((FAILED + 1))
			fi
		fi
	done
fi

if [ $FAILED -eq 0 ]; then
	echo "✓ All images are referenced"
	exit 0
else
	echo "✗ Found $FAILED unused image(s)"
	exit 1
fi

