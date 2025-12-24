#!/bin/bash
# Update navigation elements in chapters
# Usage: nav.sh [title|header|footer|all] BUILD_DIR CHAPTERS...

set -e

SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/nav-common.sh"

COMMAND="${1:-all}"
BUILD_DIR="$2"
shift 2
CHAPTERS=("$@")

if [ -z "$BUILD_DIR" ] || [ ${#CHAPTERS[@]} -eq 0 ]; then
	echo "Usage: nav.sh [title|header|footer|all] BUILD_DIR CHAPTERS..." >&2
	exit 1
fi

FAILED=0

update_nav_title() {
	local failed=0
	for chapter in "${CHAPTERS[@]}"; do
		local basename=$(basename "$chapter")
		
		# Check if NAV_TITLE comment already exists
		if grep -q "^<!-- NAV_TITLE:" "$chapter" 2>/dev/null; then
			continue
		fi
		
		# Add NAV_TITLE comment after H1
		local temp_file="$BUILD_DIR/nav_title_temp_$basename"
		local h1_line=$(grep -n '^# ' "$chapter" | head -1 | cut -d: -f1)
		if [ -z "$h1_line" ]; then
			echo "✗ Error: No H1 found in $chapter" >&2
			failed=$((failed + 1))
			continue
		fi
		sed -n "1,$h1_line p" "$chapter" > "$temp_file"
		echo "<!-- NAV_TITLE: @inherit -->" >> "$temp_file"
		tail -n +$((h1_line + 1)) "$chapter" >> "$temp_file"
		mv "$temp_file" "$chapter"
	done
	
	if [ $failed -eq 0 ]; then
		echo "✓ NAV_TITLE comments ensured"
	else
		echo "✗ Found $failed error(s)" >&2
	fi
	return $failed
}

update_nav_header() {
	local failed=0
	local prev_basename=""
	local prev_nav_title=""
	
	for chapter in "${CHAPTERS[@]}"; do
		local basename=$(basename "$chapter")
		
		# Extract nav_title (fail fast if missing)
		local nav_title=$(extract_nav_title "$chapter")
		if [ $? -ne 0 ]; then
			failed=$((failed + 1))
			continue
		fi
		
		# Determine next chapter (peek ahead)
		local next_basename=""
		local next_nav_title=""
		local found_current=0
		for next_chapter in "${CHAPTERS[@]}"; do
			if [ $found_current -eq 1 ]; then
				next_basename=$(basename "$next_chapter")
				next_nav_title=$(extract_nav_title "$next_chapter")
				if [ $? -ne 0 ]; then
					failed=$((failed + 1))
					break
				fi
				break
			fi
			if [ "$next_chapter" = "$chapter" ]; then
				found_current=1
			fi
		done
		
		# Build complete header block using shared function
		local header_block=$(build_nav_header "$prev_nav_title" "$prev_basename" "$next_nav_title" "$next_basename")
		
		# Check if header already exists
		if grep -q "<!-- NAV_HEADER_START -->" "$chapter" 2>/dev/null; then
			# Replace existing header
			local temp_file="$BUILD_DIR/nav_header_temp_$basename"
			# Remove header section
			sed '/<!-- NAV_HEADER_START -->/,/<!-- NAV_HEADER_END -->/d' "$chapter" > "$temp_file"
			# Insert new header at the very beginning
			{
				echo "$header_block"
				cat "$temp_file"
			} > "$chapter"
			rm "$temp_file"
		else
			# Insert new header at the very beginning
			local temp_file="$BUILD_DIR/nav_header_prepend_temp_$basename"
			{
				echo "$header_block"
				cat "$chapter"
			} > "$temp_file"
			mv "$temp_file" "$chapter"
		fi
		
		prev_basename="$basename"
		prev_nav_title="$nav_title"
	done
	
	if [ $failed -eq 0 ]; then
		echo "✓ Navigation headers updated"
	else
		echo "✗ Found $failed error(s)" >&2
	fi
	return $failed
}

update_nav_footer() {
	local failed=0
	local prev_basename=""
	local prev_nav_title=""
	
	for chapter in "${CHAPTERS[@]}"; do
		local basename=$(basename "$chapter")
		
		# Extract nav_title (fail fast if missing)
		local nav_title=$(extract_nav_title "$chapter")
		if [ $? -ne 0 ]; then
			failed=$((failed + 1))
			continue
		fi
		
		# Determine next chapter (peek ahead)
		local next_basename=""
		local next_nav_title=""
		local found_current=0
		for next_chapter in "${CHAPTERS[@]}"; do
			if [ $found_current -eq 1 ]; then
				next_basename=$(basename "$next_chapter")
				next_nav_title=$(extract_nav_title "$next_chapter")
				if [ $? -ne 0 ]; then
					failed=$((failed + 1))
					break
				fi
				break
			fi
			if [ "$next_chapter" = "$chapter" ]; then
				found_current=1
			fi
		done
		
		# Build complete footer block using shared function
		local footer_block=$(build_nav_footer "$prev_nav_title" "$prev_basename" "$next_nav_title" "$next_basename")
		
		# Check if footer already exists
		if grep -q "<!-- NAV_FOOTER_START -->" "$chapter" 2>/dev/null; then
			# Replace existing footer
			local temp_file="$BUILD_DIR/nav_temp_$basename"
			# Remove footer section and trailing blank lines, then add exactly one newline
			sed '/<!-- NAV_FOOTER_START -->/,/<!-- NAV_FOOTER_END -->/d' "$chapter" | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' > "$temp_file"
			printf '\n' >> "$temp_file"
			echo "$footer_block" >> "$temp_file"
			mv "$temp_file" "$chapter"
		else
			# Append new footer
			local temp_file="$BUILD_DIR/nav_append_temp_$basename"
			# Remove trailing blank lines, then add exactly one newline
			sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$chapter" > "$temp_file"
			printf '\n' >> "$temp_file"
			echo "$footer_block" >> "$temp_file"
			mv "$temp_file" "$chapter"
		fi
		
		prev_basename="$basename"
		prev_nav_title="$nav_title"
	done
	
	if [ $failed -eq 0 ]; then
		echo "✓ Navigation footers updated"
	else
		echo "✗ Found $failed error(s)" >&2
	fi
	return $failed
}

case "$COMMAND" in
	title)
		update_nav_title || FAILED=$?
		;;
	header)
		update_nav_header || FAILED=$?
		;;
	footer)
		update_nav_footer || FAILED=$?
		;;
	all)
		update_nav_title || FAILED=$((FAILED + $?))
		update_nav_header || FAILED=$((FAILED + $?))
		update_nav_footer || FAILED=$((FAILED + $?))
		;;
	*)
		echo "Error: Unknown command '$COMMAND'. Use: title, header, footer, or all" >&2
		exit 1
		;;
esac

exit $FAILED

