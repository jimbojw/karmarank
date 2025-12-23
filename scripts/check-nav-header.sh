#!/bin/bash
# Check that NAV_HEADER blocks are correctly formatted
# Usage: check-nav-header.sh CHAPTERS...

set -e

# Source common functions for validation
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/nav-common.sh"

CHAPTERS=("$@")

FAILED=0

for chapter in "${CHAPTERS[@]}"; do
	# Check if header exists
	if ! grep -q "<!-- NAV_HEADER_START -->" "$chapter" 2>/dev/null; then
		echo "✗ Missing NAV_HEADER_START in $chapter"
		FAILED=$((FAILED + 1))
		continue
	fi
	
	if ! grep -q "<!-- NAV_HEADER_END -->" "$chapter" 2>/dev/null; then
		echo "✗ Missing NAV_HEADER_END in $chapter"
		FAILED=$((FAILED + 1))
		continue
	fi
	
	# Extract header content
	HEADER_CONTENT=$(sed -n '/<!-- NAV_HEADER_START -->/,/<!-- NAV_HEADER_END -->/p' "$chapter" | sed '1d;$d')
	
	# Check format: should have nav line, then separator
	# Format: NAV_LINE\n---\n
	if ! echo "$HEADER_CONTENT" | grep -q "^---$" >/dev/null 2>&1; then
		echo "✗ NAV_HEADER missing separator (---) in $chapter"
		FAILED=$((FAILED + 1))
	fi
	
	# Check that separator is after nav line (not before)
	NAV_LINE_COUNT=$(echo "$HEADER_CONTENT" | head -n -1 | wc -l | tr -d ' ')
	SEPARATOR_LINE=$(echo "$HEADER_CONTENT" | tail -n 1)
	if [ "$SEPARATOR_LINE" != "---" ]; then
		echo "✗ NAV_HEADER separator (---) must be last line before NAV_HEADER_END in $chapter"
		FAILED=$((FAILED + 1))
	fi
done

if [ $FAILED -eq 0 ]; then
	echo "✓ All NAV_HEADER blocks are correctly formatted"
	exit 0
else
	echo "✗ Found $FAILED NAV_HEADER formatting issue(s)"
	exit 1
fi

