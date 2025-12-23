#!/bin/bash
# Check that PNG files exist for all excalidraw files
# Usage: check-images.sh IMAGES_DIR

set -e

IMAGES_DIR="$1"

FAILED=0

if [ -d "$IMAGES_DIR" ]; then
	for excalidraw in "$IMAGES_DIR"/*.excalidraw; do
		if [ -f "$excalidraw" ]; then
			BASENAME=$(basename "$excalidraw" .excalidraw)
			PNG_FILE="$IMAGES_DIR/$BASENAME.png"
			if [ ! -f "$PNG_FILE" ]; then
				echo "✗ Missing PNG for $excalidraw"
				FAILED=$((FAILED + 1))
			elif [ ! "$PNG_FILE" -nt "$excalidraw" ]; then
				echo "✗ PNG is out of date: $PNG_FILE (older than $excalidraw)"
				FAILED=$((FAILED + 1))
			fi
		fi
	done
fi

if [ $FAILED -eq 0 ]; then
	echo "✓ All image files are up to date"
	exit 0
else
	echo "✗ Found $FAILED image issue(s)"
	exit 1
fi

