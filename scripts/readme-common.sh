#!/bin/bash
# Common functions for README table of contents generation
# This file should be sourced by readme.sh and check-readme.sh

# Build table of contents from chapters
# Usage: build_toc CHAPTERS...
# Returns: complete TOC block with markers
build_toc() {
	echo "<!-- TOC_START -->"
	echo ""
	for f in "$@"; do
		local title=$(grep "^# " "$f" | head -n 1 | sed 's/^# //')
		echo "- [$title]($f)"
	done
	echo ""
	echo "<!-- TOC_END -->"
}

