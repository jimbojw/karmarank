#!/bin/bash
# Common functions for light/dark image mode checking and fixing
# This file should be sourced by check-images-mode.sh and fix-images-mode.sh

# Extract light/dark images from a line
# Usage: extract_light_dark_images line
# Returns: newline-separated list of image matches (or empty)
extract_light_dark_images() {
	local line="$1"
	echo "$line" | grep -oE '!\[[^]]*\]\([^)]*\.(light|dark)\.png(#[^)]*)?\)' || true
}

# Parse an image match into components
# Usage: parse_image_match img_match
# Sets global vars: img_alt img_path_base img_variant img_hash img_path img_base_name
# Returns: 0 if successful, 1 if parse failed
parse_image_match() {
	local img_match="$1"
	
	# Parse components using sed capture groups
	# Pattern: ![alt](base.variant.png#hash)
	# Captures: \1=alt, \2=base_path, \3=variant, \4=hash (with #)
	local parsed=$(echo "$img_match" | sed -E 's%!\[([^]]*)\]\(([^)#]+)\.(light|dark)\.png(#[^)]*)?\)%\1|\2|\3|\4%')
	
	if [ "$parsed" = "$img_match" ]; then
		# Pattern didn't match
		return 1
	fi
	
	IFS='|' read -r img_alt img_path_base img_variant img_hash <<< "$parsed"
	
	# Construct full path and base name
	img_path="${img_path_base}.${img_variant}.png"
	img_base_name=$(basename "$img_path_base")
	
	return 0
}

# Build correctly formatted image pair
# Usage: build_image_pair alt base_path
# Returns: formatted pair string
build_image_pair() {
	local alt="$1"
	local base_path="$2"
	
	echo "![${alt}](${base_path}.light.png#gh-light-mode-only)![${alt}](${base_path}.dark.png#gh-dark-mode-only)"
}

# Extract all light/dark images from a file
# Usage: extract_images_from_file md_file
# Returns: array of image info strings (format: line_num|alt|path|hash|variant|base_name)
# Note: This sets a global array IMAGES_ARRAY
extract_images_from_file() {
	local md_file="$1"
	local line_num=0
	IMAGES_ARRAY=()
	
	while IFS= read -r line || [ -n "$line" ]; do
		line_num=$((line_num + 1))
		
		local light_dark_images=$(extract_light_dark_images "$line")
		
		if [ -n "$light_dark_images" ]; then
			while IFS= read -r img_match || [ -n "$img_match" ]; do
				if [ -z "$img_match" ]; then
					break
				fi
				
				if parse_image_match "$img_match"; then
					IMAGES_ARRAY+=("${line_num}|${img_alt}|${img_path}|${img_hash}|${img_variant}|${img_base_name}")
				fi
			done <<< "$light_dark_images"
		fi
	done < "$md_file"
}

