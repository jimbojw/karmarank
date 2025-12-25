#!/bin/bash
# Check that PNG files exist for all excalidraw files
# Usage: check-images.sh IMAGES_DIR

set -e

IMAGES_DIR="$1"

FAILED=0

if [ -d "$IMAGES_DIR" ]; then
	# Determine where to look for PNG files
	# If excalidraw files are in a subdirectory (e.g., src/), PNGs are in the parent
	PNG_DIR=$(dirname "$IMAGES_DIR")
	
		for excalidraw in "$IMAGES_DIR"/*.excalidraw; do
		if [ -f "$excalidraw" ]; then
			BASENAME=$(basename "$excalidraw" .excalidraw)
			LIGHT_PNG_FILE="$PNG_DIR/$BASENAME.light.png"
			if [ ! -f "$LIGHT_PNG_FILE" ]; then
				echo "✗ Missing light PNG for $excalidraw"
				FAILED=$((FAILED + 1))
			elif [ ! "$LIGHT_PNG_FILE" -nt "$excalidraw" ]; then
				echo "✗ Light PNG is out of date: $LIGHT_PNG_FILE (older than $excalidraw)"
				FAILED=$((FAILED + 1))
			fi
			DARK_PNG_FILE="$PNG_DIR/$BASENAME.dark.png"
			if [ ! -f "$DARK_PNG_FILE" ]; then
				echo "✗ Missing dark PNG for $excalidraw"
				FAILED=$((FAILED + 1))
			elif [ ! "$DARK_PNG_FILE" -nt "$excalidraw" ]; then
				echo "✗ Dark PNG is out of date: $DARK_PNG_FILE (older than $excalidraw)"
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

