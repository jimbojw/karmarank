#!/bin/bash
# Check that chapter files are numbered sequentially
# Usage: check-chapter-order.sh CHAPTERS...

set -e

CHAPTERS=("$@")

FAILED=0
LAST_NUM=-1

for chapter in "${CHAPTERS[@]}"; do
	if [ -f "$chapter" ]; then
		BASENAME=$(basename "$chapter")
		NUM=$(echo "$BASENAME" | sed -n 's/^\([0-9][0-9]\)-.*/\1/p')
		if [ -n "$NUM" ]; then
			NUM_INT=$(echo "$NUM" | sed 's/^0*//')
			if [ -z "$NUM_INT" ]; then
				NUM_INT=0
			fi
			if [ $NUM_INT -le $LAST_NUM ]; then
				echo "✗ Chapter out of order or duplicate number: $chapter (number $NUM)"
				FAILED=$((FAILED + 1))
			fi
			LAST_NUM=$NUM_INT
		fi
	fi
done

if [ $FAILED -eq 0 ]; then
	echo "✓ Chapter numbering is valid"
	exit 0
else
	echo "✗ Found $FAILED chapter ordering issue(s)"
	exit 1
fi

