#!/bin/bash
# Check inter-document links in markdown files
# Usage: check-links.sh CHAPTERS...

set -e

CHAPTERS=("$@")

FAILED=0

for chapter in "${CHAPTERS[@]}"; do
	DIR=$(dirname "$chapter")
	LINKS=$(grep -oE '\]\(\./[^)]+\.md[^)]*\)' "$chapter" 2>/dev/null | sed 's/.*(\.\///;s/\.md.*/.md/' | sort -u)
	for link in $LINKS; do
		TARGET="$DIR/$link"
		if [ ! -f "$TARGET" ]; then
			echo "✗ Broken link in $chapter: $link"
			FAILED=$((FAILED + 1))
		fi
	done
done

if [ $FAILED -eq 0 ]; then
	echo "✓ All inter-document links are valid"
	exit 0
else
	echo "✗ Found $FAILED broken link(s)"
	exit 1
fi

