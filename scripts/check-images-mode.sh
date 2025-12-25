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
	
	# Extract all light/dark images using common function
	extract_images_from_file "$md_file"
	local images=("${IMAGES_ARRAY[@]}")
	
	# Process images in pairs
	local i=0
	while [ $i -lt ${#images[@]} ]; do
		IFS='|' read -r line1 alt1 path1 hash1 var1 base1 <<< "${images[$i]}"
		
		# Check if there's a next image
		if [ $((i + 1)) -ge ${#images[@]} ]; then
			echo "✗ $md_file:$line1: Unpaired $var1 image: $base1"
			FAILED=$((FAILED + 1))
			break
		fi
		
		IFS='|' read -r line2 alt2 path2 hash2 var2 base2 <<< "${images[$((i + 1))]}"
		
		# Check if they're adjacent (same line or consecutive)
		if [ "$line1" -ne "$line2" ] && [ "$line2" -ne $((line1 + 1)) ]; then
			echo "✗ $md_file:$line1: Unpaired $var1 image: $base1 (next image on line $line2)"
			FAILED=$((FAILED + 1))
			i=$((i + 1))
			continue
		fi
		
		# Check if they're a matching pair
		if [ "$base1" != "$base2" ] || [ "$var1" = "$var2" ]; then
			echo "✗ $md_file:$line1: Image pair mismatch: $base1 ($var1) and $base2 ($var2)"
			FAILED=$((FAILED + 1))
			i=$((i + 1))
			continue
		fi
		
		# They're a valid pair! Validate format
		local light_line light_alt light_path light_hash
		local dark_line dark_alt dark_path dark_hash
		
		if [ "$var1" = "light" ]; then
			light_line="$line1" light_alt="$alt1" light_path="$path1" light_hash="$hash1"
			dark_line="$line2" dark_alt="$alt2" dark_path="$path2" dark_hash="$hash2"
		else
			dark_line="$line1" dark_alt="$alt1" dark_path="$path1" dark_hash="$hash1"
			light_line="$line2" light_alt="$alt2" light_path="$path2" light_hash="$hash2"
		fi
		
		# Check hash tags
		if [ "$light_hash" != "#gh-light-mode-only" ]; then
			echo "✗ $md_file:$light_line: Light image missing or incorrect hash (expected #gh-light-mode-only, got '${light_hash:-none}')"
			FAILED=$((FAILED + 1))
		fi
		
		if [ "$dark_hash" != "#gh-dark-mode-only" ]; then
			echo "✗ $md_file:$dark_line: Dark image missing or incorrect hash (expected #gh-dark-mode-only, got '${dark_hash:-none}')"
			FAILED=$((FAILED + 1))
		fi
		
		# Check alt text matches
		if [ "$light_alt" != "$dark_alt" ]; then
			echo "✗ $md_file:$light_line: Alt text mismatch for $base1 (light: '$light_alt', dark: '$dark_alt')"
			FAILED=$((FAILED + 1))
		fi
		
		# Move to next pair
		i=$((i + 2))
	done
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

