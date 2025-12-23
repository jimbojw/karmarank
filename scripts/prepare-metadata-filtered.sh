#!/bin/bash
# Prepare filtered metadata (excludes styling fields)
# Usage: prepare-metadata-filtered.sh METADATA OUTPUT_FILE DATE VERSION HASH [RELEASE_MODE]

set -e

METADATA="$1"
OUTPUT_FILE="$2"
DATE="$3"
VERSION="$4"
HASH="$5"
RELEASE_MODE="$6"

# Ensure output directory exists
mkdir -p "$(dirname "$OUTPUT_FILE")"

echo "---" > "$OUTPUT_FILE"
grep -E "^(title|subtitle|author|lang|license|rights|version):" "$METADATA" >> "$OUTPUT_FILE"
echo "date: $DATE" >> "$OUTPUT_FILE"
if [ -z "$RELEASE_MODE" ]; then
	echo "build: $VERSION ($DATE-$HASH)" >> "$OUTPUT_FILE"
fi
echo "---" >> "$OUTPUT_FILE"

echo "✓ Metadata filtered"

