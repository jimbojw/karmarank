#!/bin/bash
# Check that NAV_FOOTER blocks are correctly formatted
# Usage: check-nav-footer.sh CHAPTERS...

set -e

CHAPTERS=("$@")

FAILED=0

for chapter in "${CHAPTERS[@]}"; do
	# Check if footer exists
	if ! grep -q "<!-- NAV_FOOTER_START -->" "$chapter" 2>/dev/null; then
		echo "✗ Missing NAV_FOOTER_START in $chapter"
		FAILED=$((FAILED + 1))
		continue
	fi
	
	if ! grep -q "<!-- NAV_FOOTER_END -->" "$chapter" 2>/dev/null; then
		echo "✗ Missing NAV_FOOTER_END in $chapter"
		FAILED=$((FAILED + 1))
		continue
	fi
	
	# Extract footer content
	FOOTER_CONTENT=$(sed -n '/<!-- NAV_FOOTER_START -->/,/<!-- NAV_FOOTER_END -->/p' "$chapter" | sed '1d;$d')
	
	# Check format: should have separator first, then nav line
	# Format: ---\nNAV_LINE\n
	FIRST_LINE=$(echo "$FOOTER_CONTENT" | head -n 1)
	if [ "$FIRST_LINE" != "---" ]; then
		echo "✗ NAV_FOOTER separator (---) must be first line after NAV_FOOTER_START in $chapter"
		FAILED=$((FAILED + 1))
	fi
done

if [ $FAILED -eq 0 ]; then
	echo "✓ All NAV_FOOTER blocks are correctly formatted"
	exit 0
else
	echo "✗ Found $FAILED NAV_FOOTER formatting issue(s)"
	exit 1
fi

