#!/bin/bash
# Common functions for navigation header/footer generation
# This file should be sourced by nav-header.sh and nav-footer.sh

# Extract nav_title from a chapter file
# Handles @inherit special value
# Usage: extract_nav_title chapter_file
# Returns: title string (or empty if error)
extract_nav_title() {
	local chapter="$1"
	
	# Fail fast if NAV_TITLE comment missing
	if ! grep -q "^<!-- NAV_TITLE:" "$chapter" 2>/dev/null; then
		echo "✗ Error: Missing NAV_TITLE comment in $chapter" >&2
		return 1
	fi
	
	local nav_title_raw=$(grep "^<!-- NAV_TITLE:" "$chapter" | sed 's/^<!-- NAV_TITLE: *\(.*\) -->/\1/')
	if [ "$nav_title_raw" = "@inherit" ]; then
		local nav_title=$(grep '^# ' "$chapter" | head -1 | sed 's/^# *//')
		if [ -z "$nav_title" ]; then
			echo "✗ Error: @inherit specified but no H1 found in $chapter" >&2
			return 1
		fi
		echo "$nav_title"
	else
		echo "$nav_title_raw"
	fi
}

# Build navigation line from previous/next chapter info
# Usage: build_nav_line prev_title prev_file next_title next_file
# Returns: navigation line string
build_nav_line() {
	local prev_title="$1"
	local prev_file="$2"
	local next_title="$3"
	local next_file="$4"
	
	local prev_text=""
	local next_text=""
	
	if [ -n "$prev_file" ] && [ -n "$prev_title" ]; then
		prev_text="[← $prev_title](./$prev_file)"
	fi
	
	if [ -n "$next_file" ] && [ -n "$next_title" ]; then
		next_text="[$next_title →](./$next_file)"
	fi
	
	if [ -n "$prev_text" ] && [ -n "$next_text" ]; then
		echo "$prev_text | [TOC](../README.md#table-of-contents) | $next_text"
	elif [ -n "$prev_text" ]; then
		echo "$prev_text | [TOC](../README.md#table-of-contents)"
	elif [ -n "$next_text" ]; then
		echo "[TOC](../README.md#table-of-contents) | $next_text"
	else
		echo "[TOC](../README.md#table-of-contents)"
	fi
}

# Build complete NAV_HEADER block
# Usage: build_nav_header prev_title prev_file next_title next_file
# Returns: complete header block with markers and separator
build_nav_header() {
	local nav_line=$(build_nav_line "$@")
	echo "<!-- NAV_HEADER_START -->"
	echo "$nav_line"
	echo ""
	echo "---"
	echo "<!-- NAV_HEADER_END -->"
}

# Build complete NAV_FOOTER block
# Usage: build_nav_footer prev_title prev_file next_title next_file
# Returns: complete footer block with markers and separator
build_nav_footer() {
	local nav_line=$(build_nav_line "$@")
	echo "<!-- NAV_FOOTER_START -->"
	echo "---"
	echo ""
	echo "$nav_line"
	echo "<!-- NAV_FOOTER_END -->"
}

