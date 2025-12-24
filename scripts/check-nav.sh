#!/bin/bash
# Check navigation elements in chapters
# Usage: check-nav.sh [title|links|all] CHAPTERS...

set -e

SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/nav-common.sh"

COMMAND="${1:-all}"
shift
CHAPTERS=("$@")

if [ ${#CHAPTERS[@]} -eq 0 ]; then
	echo "Usage: check-nav.sh [title|links|all] CHAPTERS..." >&2
	exit 1
fi

FAILED=0

check_nav_title() {
	local failed=0
	for chapter in "${CHAPTERS[@]}"; do
		if ! grep -q "^<!-- NAV_TITLE:" "$chapter" 2>/dev/null; then
			echo "✗ Missing NAV_TITLE comment in $chapter"
			failed=$((failed + 1))
		fi
	done
	
	if [ $failed -eq 0 ]; then
		echo "✓ All chapters have NAV_TITLE comments"
	else
		echo "✗ Found $failed chapter(s) missing NAV_TITLE comment"
	fi
	return $failed
}

# Check if navigation block matches expected
# Usage: _check_nav_block block_type chapter basename expected_block
# block_type: "header" or "footer"
_check_nav_block() {
	local block_type="$1"
	local chapter="$2"
	local basename="$3"
	local expected_block="$4"
	
	local marker_start="<!-- NAV_${block_type^^}_START -->"
	local marker_end="<!-- NAV_${block_type^^}_END -->"
	
	if ! grep -q "$marker_start" "$chapter" 2>/dev/null; then
		return 0  # Block doesn't exist, skip
	fi
	
	# Extract actual block (including markers)
	local actual_block=$(sed -n "/$marker_start/,/$marker_end/p" "$chapter")
	
	# Normalize line endings for comparison (handle potential trailing newline differences)
	expected_block=$(echo -n "$expected_block" | sed '$a\')
	actual_block=$(echo -n "$actual_block" | sed '$a\')
	
	if [ "$actual_block" != "$expected_block" ]; then
		echo "✗ NAV_${block_type^^} in $basename does not match expected format"
		echo "  Expected:"
		echo "$expected_block" | sed 's/^/    /'
		echo "  Actual:"
		echo "$actual_block" | sed 's/^/    /'
		return 1
	fi
	
	return 0
}

check_nav_links() {
	local header_failed=0
	local footer_failed=0
	local prev_basename=""
	local prev_nav_title=""
	
	for i in "${!CHAPTERS[@]}"; do
		local chapter="${CHAPTERS[$i]}"
		local basename=$(basename "$chapter")
		
		# Extract nav_title (fail fast if missing)
		local nav_title=$(extract_nav_title "$chapter")
		if [ $? -ne 0 ]; then
			header_failed=$((header_failed + 1))
			footer_failed=$((footer_failed + 1))
			continue
		fi
		
		# Determine next chapter
		local next_basename=""
		local next_nav_title=""
		if [ $((i + 1)) -lt ${#CHAPTERS[@]} ]; then
			local next_chapter="${CHAPTERS[$((i + 1))]}"
			next_basename=$(basename "$next_chapter")
			next_nav_title=$(extract_nav_title "$next_chapter")
			if [ $? -ne 0 ]; then
				header_failed=$((header_failed + 1))
				footer_failed=$((footer_failed + 1))
			fi
		fi
		
		# Generate expected complete blocks (canonical)
		local expected_header=$(build_nav_header "$prev_nav_title" "$prev_basename" "$next_nav_title" "$next_basename")
		local expected_footer=$(build_nav_footer "$prev_nav_title" "$prev_basename" "$next_nav_title" "$next_basename")
		
		# Check NAV_HEADER block
		if ! _check_nav_block "header" "$chapter" "$basename" "$expected_header"; then
			header_failed=$((header_failed + 1))
		fi
		
		# Check NAV_FOOTER block
		if ! _check_nav_block "footer" "$chapter" "$basename" "$expected_footer"; then
			footer_failed=$((footer_failed + 1))
		fi
		
		prev_basename="$basename"
		prev_nav_title="$nav_title"
	done
	
	# Report results outside loop
	if [ $header_failed -eq 0 ]; then
		echo "✓ All NAV_HEADER links match adjacent chapter titles"
	else
		echo "✗ Found $header_failed NAV_HEADER link mismatch(es)"
	fi
	
	if [ $footer_failed -eq 0 ]; then
		echo "✓ All NAV_FOOTER links match adjacent chapter titles"
	else
		echo "✗ Found $footer_failed NAV_FOOTER link mismatch(es)"
	fi
	
	return $((header_failed + footer_failed))
}

case "$COMMAND" in
	title)
		check_nav_title || FAILED=$((FAILED + $?))
		;;
	links)
		check_nav_links || FAILED=$((FAILED + $?))
		;;
	all)
		check_nav_title || FAILED=$((FAILED + $?))
		check_nav_links || FAILED=$((FAILED + $?))
		;;
	*)
		echo "Error: Unknown command '$COMMAND'. Use: title, links, or all" >&2
		exit 1
		;;
esac

exit $FAILED

