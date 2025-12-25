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

# Check if a line contains link-wrapped images
# Usage: is_link_wrapped_image_line line
# Returns: 0 if link-wrapped, 1 if not
is_link_wrapped_image_line() {
	local line="$1"
	# Use sed pattern to check if line matches link-wrapped image format
	# If sed successfully matches and transforms, it's link-wrapped
	local test=$(echo "$line" | sed -E 's%\[!\[([^]]*)\]\(([^#)]*)\.(light|dark)\.png(#[^)]*)?\)(!\[[^]]*\]\(\2\.(light|dark)\.png(#[^)]*)?\))?([^]]*)\]\(([^#)]*)(#[^#]*)?\)(\[!\[[^]]*\]\(\2\.(light|dark)\.png(#[^#]*)?\)\]\(\9(#[^)]*)?\))?%MATCH%')
	[ "$test" != "$line" ] && return 0
	return 1
}

# Extract link-wrapped image components from a line
# Usage: extract_link_wrapped_image_components line
# Sets global vars: link_wrapped_alt link_wrapped_base link_wrapped_target
# Returns: 0 if found, 1 if not found
extract_link_wrapped_image_components() {
	local line="$1"
	
	# Use sed to extract: \1=alt, \2=base_path, \9=link_url
	local parsed=$(echo "$line" | sed -E 's%\[!\[([^]]*)\]\(([^#)]*)\.(light|dark)\.png(#[^)]*)?\)(!\[[^]]*\]\(\2\.(light|dark)\.png(#[^)]*)?\))?([^]]*)\]\(([^#)]*)(#[^#]*)?\)(\[!\[[^]]*\]\(\2\.(light|dark)\.png(#[^#]*)?\)\]\(\9(#[^)]*)?\))?%\1|\2|\9%')
	
	if [ "$parsed" = "$line" ]; then
		# Pattern didn't match
		return 1
	fi
	
	IFS='|' read -r link_wrapped_alt link_wrapped_base link_wrapped_url <<< "$parsed"
	
	# Strip hash from link_url to get clean target
	link_wrapped_target="${link_wrapped_url%%#*}"
	
	return 0
}

# Extract link-wrapped image matches from a line
# Usage: extract_link_wrapped_images line
# Returns: newline-separated list of link-wrapped image matches (or empty)
# Handles two formats:
# 1. Two images in one link: [![alt](img.light.png#hash)![alt](img.dark.png#hash)](link)
# 2. Two separate links: [![alt](img.light.png)](link#hash)[![alt](img.dark.png)](link#hash)
extract_link_wrapped_images() {
	local line="$1"
	# Use grep to find all link-wrapped image patterns on the line
	# Match the full pattern including optional second image/link
	echo "$line" | grep -oE '\[!\[[^]]*\]\([^#)]*\.(light|dark)\.png[^)]*\)(!\[[^]]*\]\([^#)]*\.(light|dark)\.png[^)]*\))?[^]]*\]\([^)]+\)(\[!\[[^]]*\]\([^#)]*\.(light|dark)\.png[^)]*\)\]\([^)]+\))?' || true
}

# Parse a link-wrapped image match into components
# Usage: parse_link_wrapped_image line img_match
# Sets global vars: img_alt img_path_base img_variant img_link_target img_link_hash img_path img_base_name img_has_pair
# Returns: 0 if successful, 1 if parse failed
parse_link_wrapped_image() {
	local line="$1"
	local img_match="$2"
	
	# Use the sed pattern to extract components
	# Pattern extracts: \1=alt, \2=base_path, \3=variant, \5=optional_dupe_image, \9=link_target, \10=link_hash
	local parsed=$(echo "$img_match" | sed -E 's%\[!\[([^]]*)\]\(([^#)]*)\.(light|dark)\.png(#[^)]*)?\)(!\[[^]]*\]\(\2\.(light|dark)\.png(#[^)]*)?\))?([^]]*)\]\(([^#)]*)(#[^#]*)?\)(\[!\[[^]]*\]\(\2\.(light|dark)\.png(#[^#]*)?\)\]\(\9(#[^)]*)?\))?%\1|\2|\3|\5|\9|\10%')
	
	if [ "$parsed" = "$img_match" ]; then
		# Pattern didn't match
		return 1
	fi
	
	IFS='|' read -r img_alt img_path_base img_variant opt_dupe img_link_target img_link_hash <<< "$parsed"
	
	# Check if there's a pair (optional duplicate image or separate link)
	local has_pair=false
	if [ -n "$opt_dupe" ] || echo "$img_match" | grep -qE '\]\([^)]+\)\[!\['; then
		has_pair=true
	fi
	
	# Construct full path and base name
	img_path="${img_path_base}.${img_variant}.png"
	img_base_name=$(basename "$img_path_base")
	img_has_pair="$has_pair"
	
	return 0
}

# Build correctly formatted link-wrapped image pair
# Usage: build_link_wrapped_image_pair alt base_path link_target
# Returns: formatted pair string
build_link_wrapped_image_pair() {
	local alt="$1"
	local base_path="$2"
	local link_target="$3"
	
	echo "[![${alt}](${base_path}.light.png)](${link_target}#gh-light-mode-only)[![${alt}](${base_path}.dark.png)](${link_target}#gh-dark-mode-only)"
}

# Extract the link-wrapped image portion from a line
# Usage: extract_link_wrapped_image_match line
# Returns: the matched portion (or empty if no match)
extract_link_wrapped_image_match() {
	local line="$1"
	# Extract the full match using grep
	echo "$line" | grep -oE '\[!\[[^]]*\]\([^#)]*\.(light|dark)\.png[^)]*\)(!\[[^]]*\]\([^#)]*\.(light|dark)\.png[^)]*\))?[^]]*\]\([^)]+\)(\[!\[[^]]*\]\([^#)]*\.(light|dark)\.png[^)]*\)\]\([^)]+\))?' | head -1
}

# Extract all light/dark images from a file
# Usage: extract_images_from_file md_file
# Returns: array of image info strings
# Format for naked images: line_num|image|alt|path|hash|variant|base_name
# Format for link-wrapped: line_num|link_wrapped|alt|path|hash|variant|base_name|link_target|link_hash|has_pair
# Note: This sets a global array IMAGES_ARRAY
extract_images_from_file() {
	local md_file="$1"
	local line_num=0
	IMAGES_ARRAY=()
	
	while IFS= read -r line || [ -n "$line" ]; do
		line_num=$((line_num + 1))
		
		# Check if this is a link-wrapped image line
		if is_link_wrapped_image_line "$line"; then
			if extract_link_wrapped_image_components "$line"; then
				# Store as link_wrapped type with alt, base, and target
				IMAGES_ARRAY+=("${line_num}|link_wrapped|${link_wrapped_alt}|${link_wrapped_base}|${link_wrapped_target}")
			fi
		else
			# Regular (naked) images
			local light_dark_images=$(extract_light_dark_images "$line")
			
			if [ -n "$light_dark_images" ]; then
				while IFS= read -r img_match || [ -n "$img_match" ]; do
					if [ -z "$img_match" ]; then
						break
					fi
					
					if parse_image_match "$img_match"; then
						IMAGES_ARRAY+=("${line_num}|image|${img_alt}|${img_path}|${img_hash}|${img_variant}|${img_base_name}")
					fi
				done <<< "$light_dark_images"
			fi
		fi
	done < "$md_file"
}

