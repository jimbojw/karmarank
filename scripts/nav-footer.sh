#!/bin/bash
# Update navigation footers in all chapters
# Usage: nav-footer.sh BUILD_DIR CHAPTERS...

set -e

# Source common functions
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/nav-common.sh"

BUILD_DIR="$1"
shift
CHAPTERS=("$@")

FAILED=0
PREV_BASENAME=""
PREV_NAV_TITLE=""

for chapter in "${CHAPTERS[@]}"; do
	BASENAME=$(basename "$chapter")
	
	# Extract nav_title (fail fast if missing)
	NAV_TITLE=$(extract_nav_title "$chapter")
	if [ $? -ne 0 ]; then
		FAILED=$((FAILED + 1))
		continue
	fi
	
	# Determine next chapter (peek ahead)
	NEXT_BASENAME=""
	NEXT_NAV_TITLE=""
	FOUND_CURRENT=0
	for next_chapter in "${CHAPTERS[@]}"; do
		if [ $FOUND_CURRENT -eq 1 ]; then
			NEXT_BASENAME=$(basename "$next_chapter")
			NEXT_NAV_TITLE=$(extract_nav_title "$next_chapter")
			if [ $? -ne 0 ]; then
				FAILED=$((FAILED + 1))
				break
			fi
			break
		fi
		if [ "$next_chapter" = "$chapter" ]; then
			FOUND_CURRENT=1
		fi
	done
	
	# Build navigation line using shared function
	NAV_LINE=$(build_nav_line "$PREV_NAV_TITLE" "$PREV_BASENAME" "$NEXT_NAV_TITLE" "$NEXT_BASENAME")
	
	# Check if footer already exists
	if grep -q "<!-- NAV_FOOTER_START -->" "$chapter" 2>/dev/null; then
		# Replace existing footer
		TEMP_FILE="$BUILD_DIR/nav_temp_$BASENAME"
		# Remove footer section and trailing blank lines, then add exactly one newline
		sed '/<!-- NAV_FOOTER_START -->/,/<!-- NAV_FOOTER_END -->/d' "$chapter" | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' > "$TEMP_FILE"
		printf '\n' >> "$TEMP_FILE"
		echo "<!-- NAV_FOOTER_START -->" >> "$TEMP_FILE"
		echo "---" >> "$TEMP_FILE"
		echo "" >> "$TEMP_FILE"
		echo "$NAV_LINE" >> "$TEMP_FILE"
		echo "<!-- NAV_FOOTER_END -->" >> "$TEMP_FILE"
		mv "$TEMP_FILE" "$chapter"
	else
		# Append new footer
		TEMP_FILE="$BUILD_DIR/nav_append_temp_$BASENAME"
		# Remove trailing blank lines, then add exactly one newline
		sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$chapter" > "$TEMP_FILE"
		printf '\n' >> "$TEMP_FILE"
		echo "<!-- NAV_FOOTER_START -->" >> "$TEMP_FILE"
		echo "---" >> "$TEMP_FILE"
		echo "" >> "$TEMP_FILE"
		echo "$NAV_LINE" >> "$TEMP_FILE"
		echo "<!-- NAV_FOOTER_END -->" >> "$TEMP_FILE"
		mv "$TEMP_FILE" "$chapter"
	fi
	
	PREV_BASENAME="$BASENAME"
	PREV_NAV_TITLE="$NAV_TITLE"
done

if [ $FAILED -gt 0 ]; then
	echo "✗ Found $FAILED error(s)" >&2
	exit 1
fi

echo "✓ Navigation footers updated"
