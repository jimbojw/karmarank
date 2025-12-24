#!/bin/bash
# Check README.md table of contents
# Usage: check-readme.sh README_FILE CHAPTERS...

set -e

SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/readme-common.sh"

README_FILE="$1"
shift
CHAPTERS=("$@")

if [ -z "$README_FILE" ] || [ ${#CHAPTERS[@]} -eq 0 ]; then
	echo "Usage: check-readme.sh README_FILE CHAPTERS..." >&2
	exit 1
fi

# Generate expected TOC using shared function
EXPECTED_TOC=$(build_toc "${CHAPTERS[@]}")

# Extract actual TOC from README
if ! grep -q "<!-- TOC_START -->" "$README_FILE" 2>/dev/null; then
	echo "✗ Missing TOC_START marker in $README_FILE"
	exit 1
fi

if ! grep -q "<!-- TOC_END -->" "$README_FILE" 2>/dev/null; then
	echo "✗ Missing TOC_END marker in $README_FILE"
	exit 1
fi

ACTUAL_TOC=$(sed -n '/<!-- TOC_START -->/,/<!-- TOC_END -->/p' "$README_FILE")

# Normalize line endings for comparison (handle potential trailing newline differences)
EXPECTED_TOC=$(echo -n "$EXPECTED_TOC" | sed '$a\')
ACTUAL_TOC=$(echo -n "$ACTUAL_TOC" | sed '$a\')

if [ "$ACTUAL_TOC" != "$EXPECTED_TOC" ]; then
	echo "✗ README.md TOC does not match expected format"
	echo "  Expected:"
	echo "$EXPECTED_TOC" | sed 's/^/    /'
	echo "  Actual:"
	echo "$ACTUAL_TOC" | sed 's/^/    /'
	exit 1
fi

echo "✓ README.md TOC matches expected format"
exit 0

