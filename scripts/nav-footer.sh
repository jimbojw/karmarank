#!/bin/bash
# Update navigation footers in all chapters
# Usage: nav-footer.sh BUILD_DIR CHAPTERS...

set -e

BUILD_DIR="$1"
shift
CHAPTERS=("$@")

FAILED=0
PREV_BASENAME=""
PREV_NAV_TITLE=""

for chapter in "${CHAPTERS[@]}"; do
	BASENAME=$(basename "$chapter")
	
	# Extract nav_title from comment (fail fast if missing)
	if ! grep -q "^<!-- NAV_TITLE:" "$chapter" 2>/dev/null; then
		echo "✗ Error: Missing NAV_TITLE comment in $chapter" >&2
		FAILED=$((FAILED + 1))
		continue
	fi
	
	NAV_TITLE_RAW=$(grep "^<!-- NAV_TITLE:" "$chapter" | sed 's/^<!-- NAV_TITLE: *\(.*\) -->/\1/')
	if [ "$NAV_TITLE_RAW" = "@inherit" ]; then
		NAV_TITLE=$(grep '^# ' "$chapter" | head -1 | sed 's/^# *//')
		if [ -z "$NAV_TITLE" ]; then
			echo "✗ Error: @inherit specified but no H1 found in $chapter" >&2
			FAILED=$((FAILED + 1))
			continue
		fi
	else
		NAV_TITLE="$NAV_TITLE_RAW"
	fi
	
	PREV_TEXT=""
	NEXT_TEXT=""
	
	# Determine previous chapter link
	if [ -n "$PREV_BASENAME" ]; then
		PREV_TEXT="[← $PREV_NAV_TITLE](./$PREV_BASENAME)"
	fi
	
	# Determine next chapter (peek ahead)
	NEXT_BASENAME=""
	NEXT_NAV_TITLE=""
	FOUND_CURRENT=0
	for next_chapter in "${CHAPTERS[@]}"; do
		if [ $FOUND_CURRENT -eq 1 ]; then
			NEXT_BASENAME=$(basename "$next_chapter")
			if ! grep -q "^<!-- NAV_TITLE:" "$next_chapter" 2>/dev/null; then
				echo "✗ Error: Missing NAV_TITLE comment in $next_chapter" >&2
				FAILED=$((FAILED + 1))
				break
			fi
			NEXT_NAV_TITLE_RAW=$(grep "^<!-- NAV_TITLE:" "$next_chapter" | sed 's/^<!-- NAV_TITLE: *\(.*\) -->/\1/')
			if [ "$NEXT_NAV_TITLE_RAW" = "@inherit" ]; then
				NEXT_NAV_TITLE=$(grep '^# ' "$next_chapter" | head -1 | sed 's/^# *//')
			else
				NEXT_NAV_TITLE="$NEXT_NAV_TITLE_RAW"
			fi
			NEXT_TEXT="[$NEXT_NAV_TITLE →](./$NEXT_BASENAME)"
			break
		fi
		if [ "$next_chapter" = "$chapter" ]; then
			FOUND_CURRENT=1
		fi
	done
	
	# Build navigation line
	NAV_LINE=""
	if [ -n "$PREV_TEXT" ] && [ -n "$NEXT_TEXT" ]; then
		NAV_LINE="$PREV_TEXT | [Index](../README.md#table-of-contents) | $NEXT_TEXT"
	elif [ -n "$PREV_TEXT" ]; then
		NAV_LINE="$PREV_TEXT | [Index](../README.md#table-of-contents)"
	elif [ -n "$NEXT_TEXT" ]; then
		NAV_LINE="[Index](../README.md#table-of-contents) | $NEXT_TEXT"
	else
		NAV_LINE="[Index](../README.md#table-of-contents)"
	fi
	
	# Check if footer already exists
	if grep -q "<!-- NAV_FOOTER_START -->" "$chapter" 2>/dev/null; then
		# Replace existing footer
		TEMP_FILE="$BUILD_DIR/nav_temp_$BASENAME"
		# Remove footer section and trailing blank lines, then add exactly one newline
		sed '/<!-- NAV_FOOTER_START -->/,/<!-- NAV_FOOTER_END -->/d' "$chapter" | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' > "$TEMP_FILE"
		printf '\n' >> "$TEMP_FILE"
		echo "<!-- NAV_FOOTER_START -->" >> "$TEMP_FILE"
		echo "---" >> "$TEMP_FILE"
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

