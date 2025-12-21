# Variables
METADATA := metadata.yaml
CONTENT_DIR := content
OUTPUT_DIR := output
BUILD_DIR := build
TEMPLATE_DIR := templates
IMAGES_DIR := $(CONTENT_DIR)/images

# Version info
VERSION := $(shell grep "version:" $(METADATA) | cut -d'"' -f2)
HASH := $(shell git rev-parse --short HEAD 2>/dev/null || echo "dev")
DATE := $(shell date +%Y-%m-%d)

# Base filename logic
ifdef RELEASE_MODE
    FILENAME_BASE := karmarank-manifesto-$(VERSION)
else
    FILENAME_BASE := karmarank-manifesto-$(VERSION)-$(DATE)-$(HASH)
endif

# Source files (sorted)
CHAPTERS := $(sort $(wildcard $(CONTENT_DIR)/*.md))
TOP_LEVEL_MD := $(wildcard *.md)
ALL_MD := $(CHAPTERS) $(TOP_LEVEL_MD)

# Transformed chapters directory (for pandoc builds)
TRANSFORMED_DIR := $(BUILD_DIR)/chapters
TRANSFORMED_CHAPTERS := $(patsubst $(CONTENT_DIR)/%,$(TRANSFORMED_DIR)/%,$(CHAPTERS))

# Output files
HTML_FILE := $(OUTPUT_DIR)/$(FILENAME_BASE).html
PDF_FILE := $(OUTPUT_DIR)/$(FILENAME_BASE).pdf
EPUB_FILE := $(OUTPUT_DIR)/$(FILENAME_BASE).epub
TXT_FILE := $(OUTPUT_DIR)/$(FILENAME_BASE).txt
MD_FILE := $(OUTPUT_DIR)/$(FILENAME_BASE).md
INDEX_FILE := $(OUTPUT_DIR)/index.html

# Tools
# Docker is the default build method for hermetic, cross-platform builds
# To use native pandoc/LaTeX instead: USE_DOCKER=false make all
USE_DOCKER ?= true
DOCKER_IMAGE := pandoc/latex:latest
ifeq ($(USE_DOCKER),true)
    DOCKER_RUN := docker run --rm \
        --volume "$(CURDIR):/data" \
        --workdir /data \
        --user $(shell id -u):$(shell id -g) \
        $(DOCKER_IMAGE)
    # pandoc/latex image has pandoc as entrypoint, so we don't need to specify it
    PANDOC := $(DOCKER_RUN)
else
    PANDOC := pandoc
endif

.PHONY: all clean html pdf epub txt md release directories prepare-images prepare-chapters readme latest check check-links check-images check-images-refs check-unused-images check-chapter-order check-pandoc-deps check-pdf-deps

all: directories prepare-images prepare-chapters html pdf epub txt md index latest readme

directories:
	@mkdir -p $(OUTPUT_DIR)
	@mkdir -p $(BUILD_DIR)

# Copy images to output directory for HTML
prepare-images: directories
	@if [ -d "$(IMAGES_DIR)" ]; then \
		mkdir -p $(OUTPUT_DIR)/images; \
		cp -r $(IMAGES_DIR)/* $(OUTPUT_DIR)/images/; \
	fi

# Transform chapter markdown before pandoc:
# - Append `{#filename}` custom ids to chapter headings.
# - Convert inter-document links to custom id links.
#   E.g. `[text](./xx-filename.md)` becomes `[text](#xx-filename)`.
# - Strip file paths from anchored inter-document links.
#   E.g. `[text](./xx-filename.md#section)` becomes `[text](#section)`.
prepare-chapters: directories
	@echo "Preparing transformed chapters for pandoc..."
	@mkdir -p $(TRANSFORMED_DIR)
	@for f in $(CHAPTERS); do \
		dest=$$(echo $$f | sed 's|$(CONTENT_DIR)|$(TRANSFORMED_DIR)|'); \
		cat $$f | \
		sed "s%^#[^#].\+%\0 {#$$(basename $$f .md)}%g" | \
		sed "s%\[\(.*\?\)\](\./\([^#)]\+\)\.md)%[\1](#\2)%g" | \
		sed "s%\[\(.*\?\)\]([^#)]\+\.md#\(.\+\?\))%[\1](#\2)%g" > $$dest; \
	done
	@# Copy images to build directory for pandoc resource-path
	@if [ -d "$(IMAGES_DIR)" ]; then \
		mkdir -p $(TRANSFORMED_DIR)/images; \
		cp -r $(IMAGES_DIR)/* $(TRANSFORMED_DIR)/images/; \
	fi
	@echo "✓ Chapters transformed"

# HTML Build
html: check-pandoc-deps $(HTML_FILE)
$(HTML_FILE): $(TRANSFORMED_CHAPTERS) $(METADATA) $(TEMPLATE_DIR)/book.html | directories prepare-chapters
	@echo "Building HTML..."
	$(PANDOC) \
		$(TRANSFORMED_CHAPTERS) \
		--resource-path=$(TRANSFORMED_DIR) \
		--metadata-file=$(METADATA) \
		--from=commonmark_x \
		--template=$(TEMPLATE_DIR)/book.html \
		--standalone \
		--self-contained \
		--toc \
		--toc-depth=2 \
		--mathjax \
		--metadata date="$(VERSION) ($(DATE)-$(HASH))" \
		--output=$@
	@echo "✓ HTML: $@"

# Pandoc Dependencies Check (shared by all pandoc-based targets)
check-pandoc-deps:
	@if [ "$(USE_DOCKER)" = "true" ]; then \
		docker info >/dev/null 2>&1 || (echo "✗ Error: Docker not available. Install Docker or use: USE_DOCKER=false make <target>" && exit 1); \
	else \
		command -v pandoc >/dev/null || (echo "✗ Error: pandoc not found. Install pandoc or use: USE_DOCKER=true make <target>" && exit 1); \
	fi

# PDF Build Dependencies Check (depends on pandoc, also checks pdflatex)
check-pdf-deps: check-pandoc-deps
	@if [ "$(USE_DOCKER)" != "true" ]; then \
		command -v pdflatex >/dev/null || (echo "✗ Error: pdflatex not found. Install LaTeX or use: USE_DOCKER=true make pdf" && exit 1); \
	fi

# PDF Build
pdf: check-pdf-deps $(PDF_FILE)
$(PDF_FILE): $(TRANSFORMED_CHAPTERS) $(METADATA) | directories prepare-chapters
	@echo "Building PDF..."
	$(PANDOC) \
		$(TRANSFORMED_CHAPTERS) \
		--resource-path=$(TRANSFORMED_DIR) \
		--metadata-file=$(METADATA) \
		--from=commonmark_x+implicit_figures+tex_math_dollars \
		--pdf-engine=pdflatex \
		--toc \
		--toc-depth=2 \
		--variable=geometry:margin=1.5in \
		--metadata date="$(VERSION) ($(DATE)-$(HASH))" \
		--output=$@
	@echo "✓ PDF: $@"

# ePub Build
epub: check-pandoc-deps $(EPUB_FILE)
$(EPUB_FILE): $(TRANSFORMED_CHAPTERS) $(METADATA) | directories prepare-chapters
	@echo "Building ePub..."
	$(PANDOC) \
		$(TRANSFORMED_CHAPTERS) \
		--resource-path=$(TRANSFORMED_DIR) \
		--metadata-file=$(METADATA) \
		--from=commonmark_x \
		--toc \
		--toc-depth=2 \
		--mathml \
		--css=templates/epub.css \
		--metadata date="$(VERSION) ($(DATE)-$(HASH))" \
		--output=$@
	@echo "✓ ePub: $@"

# Plain Text Build
txt: check-pandoc-deps $(TXT_FILE)
$(TXT_FILE): $(TRANSFORMED_CHAPTERS) $(METADATA) | directories prepare-chapters
	@echo "Building Plain Text..."
	$(PANDOC) \
		$(TRANSFORMED_CHAPTERS) \
		--resource-path=$(TRANSFORMED_DIR) \
		--metadata-file=$(METADATA) \
		--from=commonmark_x \
		--to plain \
		--standalone \
		--columns=72 \
		--metadata date="$(VERSION) ($(DATE)-$(HASH))" \
		--output=$@
	@echo "✓ Plain Text: $@"

# Combined Markdown Build
md: $(MD_FILE)
$(MD_FILE): $(CHAPTERS) $(METADATA) | directories
	@echo "Building Combined Markdown..."
	@{ \
		cat $(METADATA); \
		echo ""; \
		grep "^title:" $(METADATA) | cut -d'"' -f2 | sed 's/^/# /'; \
		echo ""; \
		grep "^subtitle:" $(METADATA) | cut -d'"' -f2 | sed 's/^/**/;s/$$/**/'; \
		echo ""; \
		grep "^author:" $(METADATA) | cut -d'"' -f2 | sed 's/^/By /'; \
		echo ""; \
		echo "> Version: $(VERSION) ($(DATE)-$(HASH))"; \
		echo ""; \
		awk 'FNR==1{print ""}1' $(CHAPTERS); \
	} > $@
	@echo "✓ Markdown: $@"

# Index Page (Landing Page)
index: check-pandoc-deps $(INDEX_FILE)
$(INDEX_FILE): templates/index.template.md $(METADATA) $(TEMPLATE_DIR)/book.html | directories
	@echo "Building Landing Page..."
	$(PANDOC) \
		templates/index.template.md \
		--metadata-file=$(METADATA) \
		--from=commonmark_x \
		--template=$(TEMPLATE_DIR)/book.html \
		--standalone \
		--metadata date="$(VERSION) ($(DATE)-$(HASH))" \
		--output=$@
	@echo "✓ Landing Page: $@"

# Latest Copies (Permalinks)
latest: $(HTML_FILE) $(PDF_FILE) $(EPUB_FILE) $(TXT_FILE)
	@echo "Creating 'latest' copies..."
	@cp $(HTML_FILE) $(OUTPUT_DIR)/karmarank-manifesto.html
	@cp $(PDF_FILE) $(OUTPUT_DIR)/karmarank-manifesto.pdf
	@cp $(EPUB_FILE) $(OUTPUT_DIR)/karmarank-manifesto.epub
	@cp $(TXT_FILE) $(OUTPUT_DIR)/karmarank-manifesto.txt
	@echo "✓ Latest copies created"

# README Build
readme: | directories
	@echo "Updating README.md TOC..."
	@{ \
		TOC_FILE="$(BUILD_DIR)/readme_toc.tmp"; \
		NEW_README="$(BUILD_DIR)/README.new"; \
		\
		echo "<!-- TOC_START -->" > $$TOC_FILE; \
		echo "" >> $$TOC_FILE; \
		for f in $(CHAPTERS); do \
			TITLE=$$(grep "^# " $$f | head -n 1 | sed 's/^# //'); \
			echo "- [$$TITLE]($$f)" >> $$TOC_FILE; \
		done; \
		echo "" >> $$TOC_FILE; \
		echo "<!-- TOC_END -->" >> $$TOC_FILE; \
		\
		sed '/<!-- TOC_START -->/,$$d' README.md > $$NEW_README; \
		cat $$TOC_FILE >> $$NEW_README; \
		sed '1,/<!-- TOC_END -->/d' README.md >> $$NEW_README; \
		\
		mv $$NEW_README README.md; \
	}
	@echo "✓ README.md updated"

# Check targets: validates inter-document links and image files
check: check-links check-images check-images-refs check-unused-images check-chapter-order

check-links: | directories
	@echo "Checking inter-document links..."
	@FAILED=0; \
	for chapter in $(CHAPTERS); do \
		DIR=$$(dirname $$chapter); \
		LINKS=$$(grep -oE '\]\(\./[^)]+\.md[^)]*\)' $$chapter 2>/dev/null | sed 's/.*(\.\///;s/\.md.*/.md/' | sort -u); \
		for link in $$LINKS; do \
			TARGET=$$DIR/$$link; \
			if [ ! -f "$$TARGET" ]; then \
				echo "✗ Broken link in $$chapter: $$link"; \
				FAILED=$$((FAILED + 1)); \
			fi; \
		done; \
	done; \
	if [ $$FAILED -eq 0 ]; then \
		echo "✓ All inter-document links are valid"; \
		exit 0; \
	else \
		echo "✗ Found $$FAILED broken link(s)"; \
		exit 1; \
	fi

check-images: | directories
	@echo "Checking image files..."
	@FAILED=0; \
	if [ -d "$(IMAGES_DIR)" ]; then \
		for excalidraw in $(IMAGES_DIR)/*.excalidraw; do \
			if [ -f "$$excalidraw" ]; then \
				BASENAME=$$(basename $$excalidraw .excalidraw); \
				PNG_FILE=$(IMAGES_DIR)/$$BASENAME.png; \
				if [ ! -f "$$PNG_FILE" ]; then \
					echo "✗ Missing PNG for $$excalidraw"; \
					FAILED=$$((FAILED + 1)); \
				elif [ ! "$$PNG_FILE" -nt "$$excalidraw" ]; then \
					echo "✗ PNG is out of date: $$PNG_FILE (older than $$excalidraw)"; \
					FAILED=$$((FAILED + 1)); \
				fi; \
			fi; \
		done; \
	fi; \
	if [ $$FAILED -eq 0 ]; then \
		echo "✓ All image files are up to date"; \
		exit 0; \
	else \
		echo "✗ Found $$FAILED image issue(s)"; \
		exit 1; \
	fi

check-images-refs: | directories
	@echo "Checking image references in markdown..."
	@FAILED=0; \
	for md_file in $(ALL_MD); do \
		if [ -f "$$md_file" ]; then \
			DIR=$$(dirname $$md_file); \
			if [ "$$DIR" = "." ]; then \
				DIR=""; \
			fi; \
			IMAGES=$$(grep -oE '!\[.*\]\([^)]+images/[^)]+\)' $$md_file 2>/dev/null | grep -oE '(content/)?images/[^)]+' | sort -u); \
			for img_ref in $$IMAGES; do \
				TARGET=""; \
				if [ -n "$$DIR" ]; then \
					TARGET=$$DIR/$$img_ref; \
				else \
					TARGET=$$img_ref; \
				fi; \
				if [ ! -f "$$TARGET" ]; then \
					TARGET=$(IMAGES_DIR)/$$(basename $$img_ref); \
				fi; \
				if [ ! -f "$$TARGET" ]; then \
					echo "✗ Broken image reference in $$md_file: $$img_ref"; \
					FAILED=$$((FAILED + 1)); \
				fi; \
			done; \
		fi; \
	done; \
	if [ $$FAILED -eq 0 ]; then \
		echo "✓ All image references are valid"; \
		exit 0; \
	else \
		echo "✗ Found $$FAILED broken image reference(s)"; \
		exit 1; \
	fi

check-unused-images: | directories
	@echo "Checking for unused images..."
	@FAILED=0; \
	if [ -d "$(IMAGES_DIR)" ]; then \
		for img_file in $(IMAGES_DIR)/*.png $(IMAGES_DIR)/*.excalidraw; do \
			if [ -f "$$img_file" ]; then \
				BASENAME=$$(basename $$img_file); \
				BASENAME_NO_EXT=$$(basename $$img_file .png | sed 's/\.excalidraw$$//'); \
				FOUND=0; \
				for md_file in $(ALL_MD); do \
					if [ -f "$$md_file" ]; then \
						if grep -qE "(images/|content/images/)$$BASENAME" $$md_file 2>/dev/null || \
						   grep -qE "(images/|content/images/)$$BASENAME_NO_EXT" $$md_file 2>/dev/null; then \
							FOUND=1; \
							break; \
						fi; \
					fi; \
				done; \
				if [ $$FOUND -eq 0 ]; then \
					echo "✗ Unused image: $$img_file"; \
					FAILED=$$((FAILED + 1)); \
				fi; \
			fi; \
		done; \
	fi; \
	if [ $$FAILED -eq 0 ]; then \
		echo "✓ All images are referenced"; \
		exit 0; \
	else \
		echo "✗ Found $$FAILED unused image(s)"; \
		exit 1; \
	fi

check-chapter-order: | directories
	@echo "Checking chapter numbering..."
	@FAILED=0; \
	LAST_NUM=-1; \
	for chapter in $(CHAPTERS); do \
		if [ -f "$$chapter" ]; then \
			BASENAME=$$(basename $$chapter); \
			NUM=$$(echo $$BASENAME | sed -n 's/^\([0-9][0-9]\)-.*/\1/p'); \
			if [ -n "$$NUM" ]; then \
				NUM_INT=$$(echo $$NUM | sed 's/^0*//'); \
				if [ -z "$$NUM_INT" ]; then \
					NUM_INT=0; \
				fi; \
				if [ $$NUM_INT -le $$LAST_NUM ]; then \
					echo "✗ Chapter out of order or duplicate number: $$chapter (number $$NUM)"; \
					FAILED=$$((FAILED + 1)); \
				fi; \
				LAST_NUM=$$NUM_INT; \
			fi; \
		fi; \
	done; \
	if [ $$FAILED -eq 0 ]; then \
		echo "✓ Chapter numbering is valid"; \
		exit 0; \
	else \
		echo "✗ Found $$FAILED chapter ordering issue(s)"; \
		exit 1; \
	fi

clean:
	rm -rf $(OUTPUT_DIR)
	rm -rf $(BUILD_DIR)
