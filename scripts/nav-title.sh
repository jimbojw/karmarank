#!/bin/bash
# Ensure NAV_TITLE comment exists in all chapters
# Usage: nav-title.sh BUILD_DIR CHAPTERS...

set -e

BUILD_DIR="$1"
shift
CHAPTERS=("$@")

FAILED=0

for chapter in "${CHAPTERS[@]}"; do
	BASENAME=$(basename "$chapter")
	
	# Check if NAV_TITLE comment already exists
	if grep -q "^<!-- NAV_TITLE:" "$chapter" 2>/dev/null; then
		continue
	fi
	
	# Add NAV_TITLE comment after H1
	TEMP_FILE="$BUILD_DIR/nav_title_temp_$BASENAME"
	H1_LINE=$(grep -n '^# ' "$chapter" | head -1 | cut -d: -f1)
	if [ -z "$H1_LINE" ]; then
		echo "✗ Error: No H1 found in $chapter" >&2
		FAILED=$((FAILED + 1))
		continue
	fi
	sed -n "1,$H1_LINE p" "$chapter" > "$TEMP_FILE"
	echo "<!-- NAV_TITLE: @inherit -->" >> "$TEMP_FILE"
	tail -n +$((H1_LINE + 1)) "$chapter" >> "$TEMP_FILE"
	mv "$TEMP_FILE" "$chapter"
done

if [ $FAILED -gt 0 ]; then
	echo "✗ Found $FAILED error(s)" >&2
	exit 1
fi

echo "✓ NAV_TITLE comments ensured"

