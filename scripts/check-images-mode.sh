#!/bin/bash
# Check that light/dark image pairs are correctly formatted
# Usage: check-images-mode.sh MD_FILES...

set -e

SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/images-mode-common.sh"

ALL_MD=("$@")

if [ ${#ALL_MD[@]} -eq 0 ]; then
	echo "Usage: check-images-mode.sh MD_FILES..." >&2
	exit 1
fi

FAILED=0

check_file() {
	local md_file="$1"
	local line_num=0
	
	while IFS= read -r line || [ -n "$line" ]; do
		line_num=$((line_num + 1))
		
		# Check for link-wrapped images first
		if is_link_wrapped_image_line "$line"; then
			# Extract components
			if extract_link_wrapped_image_components "$line"; then
				# Generate expected format
				local expected=$(build_link_wrapped_image_pair "$link_wrapped_alt" "$link_wrapped_base" "$link_wrapped_target")
				
				# Extract actual match from line
				local actual=$(extract_link_wrapped_image_match "$line")
				
				# Compare
				if [ "$actual" != "$expected" ]; then
					echo "✗ $md_file:$line_num: Link-wrapped image format mismatch"
					echo "  Expected: $expected"
					echo "  Actual:   $actual"
					FAILED=$((FAILED + 1))
				fi
			fi
		else
			# Regular (naked) images - use existing logic
			local light_dark_images=$(extract_light_dark_images "$line")
			
			if [ -n "$light_dark_images" ]; then
				# Process in pairs
				local images=()
				while IFS= read -r img_match || [ -n "$img_match" ]; do
					if [ -z "$img_match" ]; then
						break
					fi
					if parse_image_match "$img_match"; then
						images+=("${line_num}|${img_alt}|${img_path}|${img_hash}|${img_variant}|${img_base_name}")
					fi
				done <<< "$light_dark_images"
				
				# Validate pairs
				local i=0
				while [ $i -lt ${#images[@]} ]; do
					IFS='|' read -r img_line alt path hash var base <<< "${images[$i]}"
					
					if [ $((i + 1)) -ge ${#images[@]} ]; then
						echo "✗ $md_file:$img_line: Unpaired $var image: $base"
						FAILED=$((FAILED + 1))
						break
					fi
					
					IFS='|' read -r img_line2 alt2 path2 hash2 var2 base2 <<< "${images[$((i + 1))]}"
					
					if [ "$base" != "$base2" ] || [ "$var" = "$var2" ]; then
						echo "✗ $md_file:$img_line: Image pair mismatch: $base ($var) and $base2 ($var2)"
						FAILED=$((FAILED + 1))
						i=$((i + 1))
						continue
					fi
					
					# Validate format
					local light_hash dark_hash
					if [ "$var" = "light" ]; then
						light_hash="$hash"
						dark_hash="$hash2"
					else
						dark_hash="$hash"
						light_hash="$hash2"
					fi
					
					if [ "$light_hash" != "#gh-light-mode-only" ]; then
						echo "✗ $md_file:$img_line: Light image missing or incorrect hash (expected #gh-light-mode-only, got '${light_hash:-none}')"
						FAILED=$((FAILED + 1))
					fi
					
					if [ "$dark_hash" != "#gh-dark-mode-only" ]; then
						echo "✗ $md_file:$img_line2: Dark image missing or incorrect hash (expected #gh-dark-mode-only, got '${dark_hash:-none}')"
						FAILED=$((FAILED + 1))
					fi
					
					if [ "$alt" != "$alt2" ]; then
						echo "✗ $md_file:$img_line: Alt text mismatch for $base (light: '$alt', dark: '$alt2')"
						FAILED=$((FAILED + 1))
					fi
					
					i=$((i + 2))
				done
			fi
		fi
	done < "$md_file"
}

for md_file in "${ALL_MD[@]}"; do
	if [ -f "$md_file" ]; then
		check_file "$md_file"
	fi
done

if [ $FAILED -eq 0 ]; then
	echo "✓ All light/dark image pairs are correctly formatted"
	exit 0
else
	echo "✗ Found $FAILED image mode error(s)"
	exit 1
fi

