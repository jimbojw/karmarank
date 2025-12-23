#!/bin/bash
# Check that NAV_TITLE comments exist in all chapters
# Usage: check-nav-title.sh CHAPTERS...

set -e

CHAPTERS=("$@")

FAILED=0

for chapter in "${CHAPTERS[@]}"; do
	if ! grep -q "^<!-- NAV_TITLE:" "$chapter" 2>/dev/null; then
		echo "✗ Missing NAV_TITLE comment in $chapter"
		FAILED=$((FAILED + 1))
	fi
done

if [ $FAILED -eq 0 ]; then
	echo "✓ All chapters have NAV_TITLE comments"
	exit 0
else
	echo "✗ Found $FAILED chapter(s) missing NAV_TITLE comment"
	exit 1
fi

