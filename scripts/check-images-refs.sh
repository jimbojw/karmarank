#!/bin/bash
# Check that image references in markdown files are valid
# Usage: check-images-refs.sh IMAGES_DIR MD_FILES...

set -e

IMAGES_DIR="$1"
shift
ALL_MD=("$@")

FAILED=0

for md_file in "${ALL_MD[@]}"; do
	if [ -f "$md_file" ]; then
		DIR=$(dirname "$md_file")
		if [ "$DIR" = "." ]; then
			DIR=""
		fi
		IMAGES=$(grep -oE '!\[.*\]\([^)]+images/[^)]+\)' "$md_file" 2>/dev/null | grep -oE '(content/)?images/[^)]+' | sort -u)
		for img_ref in $IMAGES; do
			# Strip hash tag from path (e.g., remove #gh-light-mode-only)
			img_path="${img_ref%%#*}"
			
			TARGET=""
			if [ -n "$DIR" ]; then
				TARGET="$DIR/$img_path"
			else
				TARGET="$img_path"
			fi
			if [ ! -f "$TARGET" ]; then
				TARGET="$IMAGES_DIR/$(basename "$img_path")"
			fi
			if [ ! -f "$TARGET" ]; then
				echo "✗ Broken image reference in $md_file: $img_ref"
				FAILED=$((FAILED + 1))
			fi
		done
	fi
done

if [ $FAILED -eq 0 ]; then
	echo "✓ All image references are valid"
	exit 0
else
	echo "✗ Found $FAILED broken image reference(s)"
	exit 1
fi

