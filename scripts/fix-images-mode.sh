#!/bin/bash
# Fix light/dark image pair formatting
# Usage: fix-images-mode.sh BUILD_DIR MD_FILES...

set -e

SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/images-mode-common.sh"

BUILD_DIR="$1"
shift
ALL_MD=("$@")

if [ -z "$BUILD_DIR" ] || [ ${#ALL_MD[@]} -eq 0 ]; then
	echo "Usage: fix-images-mode.sh BUILD_DIR MD_FILES..." >&2
	exit 1
fi

fix_file() {
	local md_file="$1"
	local basename=$(basename "$md_file")
	local temp_file="$BUILD_DIR/images_mode_temp_$basename"
	
	> "$temp_file"  # Create empty temp file
	
	while IFS= read -r line || [ -n "$line" ]; do
		# Check if this line has light/dark images
		if echo "$line" | grep -qE '\.(light|dark)\.png'; then
			# Apply the fix regex - handles both single images and pairs
			# Pattern matches: ![alt](base.variant.png#hash) optionally followed by ![alt](base.variant.png#hash)
			# Replaces with: ![alt](base.light.png#gh-light-mode-only)![alt](base.dark.png#gh-dark-mode-only)
			local fixed_line=$(echo "$line" | sed -E 's%!\[([^]]*)\]\(([^)#]+)\.(light|dark)\.png(#[^)]*)?\)(!\[([^]]*)\]\(\2\.(light|dark)\.png(#[^)]*)?\))?%![\1](\2.light.png#gh-light-mode-only)![\1](\2.dark.png#gh-dark-mode-only)%')
			echo "$fixed_line" >> "$temp_file"
		else
			# No images, copy line as-is
			echo "$line" >> "$temp_file"
		fi
	done < "$md_file"
	
	mv "$temp_file" "$md_file"
}

for md_file in "${ALL_MD[@]}"; do
	if [ -f "$md_file" ]; then
		fix_file "$md_file"
	fi
done

echo "✓ Image mode formatting fixed"

