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
# Short names (built first)
SHORT_BASE := karmarank-manifesto
# Long names (copied from short names)
ifdef RELEASE_MODE
    LONG_BASE := karmarank-manifesto-$(VERSION)
else
    LONG_BASE := karmarank-manifesto-$(VERSION)-$(DATE)-$(HASH)
endif

# Source files (sorted)
CHAPTERS := $(sort $(wildcard $(CONTENT_DIR)/*.md))
TOP_LEVEL_MD := $(wildcard *.md)
ALL_MD := $(CHAPTERS) $(TOP_LEVEL_MD)

# Transformed chapters directory (for pandoc builds)
TRANSFORMED_DIR := $(BUILD_DIR)/chapters
TRANSFORMED_CHAPTERS := $(patsubst $(CONTENT_DIR)/%,$(TRANSFORMED_DIR)/%,$(CHAPTERS))

# Chapter ID extraction directory
CHAPTER_IDS_DIR := $(BUILD_DIR)/chapter-ids
CHAPTER_ID_FILES := $(patsubst $(CONTENT_DIR)/%.md,$(CHAPTER_IDS_DIR)/%.md,$(CHAPTERS))

# Build artifacts for markdown output
TITLE_PAGE := $(BUILD_DIR)/title-page.md
FILTERED_METADATA := $(BUILD_DIR)/metadata-filtered.yaml

# Output files (short names - built first)
HTML_FILE := $(OUTPUT_DIR)/$(SHORT_BASE).html
PDF_FILE := $(OUTPUT_DIR)/$(SHORT_BASE).pdf
EPUB_FILE := $(OUTPUT_DIR)/$(SHORT_BASE).epub
MD_FILE := $(OUTPUT_DIR)/$(SHORT_BASE).md
INDEX_FILE := $(OUTPUT_DIR)/index.html

# Long name files (copied from short names)
HTML_FILE_LONG := $(OUTPUT_DIR)/$(LONG_BASE).html
PDF_FILE_LONG := $(OUTPUT_DIR)/$(LONG_BASE).pdf
EPUB_FILE_LONG := $(OUTPUT_DIR)/$(LONG_BASE).epub
MD_FILE_LONG := $(OUTPUT_DIR)/$(LONG_BASE).md

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

.PHONY: all clean html pdf epub md release directories prepare-metadata-filtered prepare-title-page prepare-chapter-ids build-transform-filter latest check check-links check-images check-images-refs check-unused-images check-chapter-order check-pandoc-deps check-pdf-deps

all: prepare-chapter-ids build-transform-filter html pdf epub md index latest readme

directories:
	@mkdir -p $(OUTPUT_DIR)
	@mkdir -p $(BUILD_DIR)

# Extract H1 IDs from chapters (Step 1: discover pandoc's auto-generated IDs)
prepare-chapter-ids: $(CHAPTER_ID_FILES)
$(CHAPTER_IDS_DIR)/%.md: $(CONTENT_DIR)/%.md filters/extract-h1-id.lua | directories
	@mkdir -p $(CHAPTER_IDS_DIR)
	@$(PANDOC) $< \
		--from=commonmark_x \
		--to=commonmark_x \
		--lua-filter=filters/extract-h1-id.lua \
		--output=$@.tmp 2>/dev/null || true
	@if ! grep -qE '{#[^}]+}' $@.tmp 2>/dev/null; then \
		echo "Error: Failed to find ID in output from $<. Expected {#id} format." >&2; \
		echo "Output was:" >&2; \
		cat $@.tmp >&2; \
		rm -f $@.tmp; \
		exit 1; \
	fi; \
	mv $@.tmp $@

# Build combined transform filter (map + transform logic)
build-transform-filter: $(BUILD_DIR)/transform-chapters.lua
$(BUILD_DIR)/transform-chapters.lua: $(CHAPTER_ID_FILES) filters/transform-chapters.lua | directories prepare-chapter-ids
	@echo "-- Auto-generated chapter ID map" > $@
	@echo "chapter_id_map = {" >> $@
	@for f in $(CHAPTERS); do \
		basename=$$(basename $$f); \
		id_file=$(CHAPTER_IDS_DIR)/$$basename; \
		if [ -f $$id_file ]; then \
			id=$$(sed 's%.*{#\([^}]\+\).*%\1%' $$id_file); \
			if [ -z "$$id" ]; then \
				echo "Error: Failed to extract ID from $$id_file" >&2; \
				exit 1; \
			fi; \
			echo "  [\"$$basename\"] = \"$$id\"," >> $@; \
		fi; \
	done
	@echo "}" >> $@
	@echo "" >> $@
	@echo "-- Transform logic" >> $@
	@cat filters/transform-chapters.lua >> $@
	@echo "✓ Transform filter created"

# Pattern rule to build transformed chapters
$(TRANSFORMED_DIR)/%.md: $(CONTENT_DIR)/%.md $(BUILD_DIR)/transform-chapters.lua | directories prepare-chapter-ids build-transform-filter check-pandoc-deps
	@mkdir -p $(TRANSFORMED_DIR)
	$(PANDOC) \
		$< \
		--from=commonmark_x \
		--to=commonmark_x \
		--lua-filter=$(BUILD_DIR)/transform-chapters.lua \
		--output=$@

# Prepare filtered metadata (excludes styling fields)
prepare-metadata-filtered: $(FILTERED_METADATA)
$(FILTERED_METADATA): $(METADATA) | directories
	@echo "Preparing filtered metadata..."
	@echo "---" > $@
	@grep -E "^(title|subtitle|author|lang|license|rights|version):" $(METADATA) >> $@
	@echo "date: $(DATE)" >> $@
	@if [ -z "$(RELEASE_MODE)" ]; then \
		echo "build: $(VERSION) ($(DATE)-$(HASH))" >> $@; \
	fi
	@echo "---" >> $@
	@echo "✓ Metadata filtered"

# Prepare title page markdown
prepare-title-page: $(TITLE_PAGE)
$(TITLE_PAGE): $(METADATA) | directories
	@echo "Preparing title page..."
	@{ \
		TITLE=$$(grep "^title:" $(METADATA) | cut -d'"' -f2); \
		SUBTITLE=$$(grep "^subtitle:" $(METADATA) | cut -d'"' -f2); \
		AUTHOR=$$(grep "^author:" $(METADATA) | cut -d'"' -f2); \
		echo "# $$TITLE" > $@; \
		echo "" >> $@; \
		echo "*$$SUBTITLE*" >> $@; \
		echo "" >> $@; \
		echo "By $$AUTHOR" >> $@; \
		echo "" >> $@; \
		if [ -z "$(RELEASE_MODE)" ]; then \
			echo "Build: $(VERSION) ($(DATE)-$(HASH))" >> $@; \
		else \
			echo "Version: $(VERSION)" >> $@; \
		fi; \
		echo "" >> $@; \
	}
	@echo "✓ Title page prepared"

# HTML Build
html: $(HTML_FILE)
$(HTML_FILE): $(TRANSFORMED_CHAPTERS) $(METADATA) $(TEMPLATE_DIR)/book.html | directories check-pandoc-deps
	@echo "Building HTML..."
	$(PANDOC) \
		$(TRANSFORMED_CHAPTERS) \
		--resource-path=$(CONTENT_DIR) \
		--metadata-file=$(METADATA) \
		--from=commonmark_x \
		--template=$(TEMPLATE_DIR)/book.html \
		--standalone \
		--self-contained \
		--toc \
		--toc-depth=2 \
		--mathjax \
		--metadata date="$(DATE)" \
		--metadata build-info="$(VERSION) ($(DATE)-$(HASH))" \
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
pdf: $(PDF_FILE)
$(PDF_FILE): $(TRANSFORMED_CHAPTERS) $(METADATA) | directories check-pdf-deps
	@echo "Building PDF..."
	$(PANDOC) \
		$(TRANSFORMED_CHAPTERS) \
		--resource-path=$(CONTENT_DIR) \
		--metadata-file=$(METADATA) \
		--from=commonmark_x+implicit_figures+tex_math_dollars \
		--pdf-engine=pdflatex \
		--toc \
		--toc-depth=2 \
		--variable=geometry:margin=1.5in \
		--metadata date="$(DATE)" \
		--metadata build-info="$(VERSION) ($(DATE)-$(HASH))" \
		--output=$@
	@echo "✓ PDF: $@"

# ePub Build
epub: $(EPUB_FILE)
$(EPUB_FILE): $(TRANSFORMED_CHAPTERS) $(METADATA) | directories check-pandoc-deps
	@echo "Building ePub..."
	$(PANDOC) \
		$(TRANSFORMED_CHAPTERS) \
		--resource-path=$(CONTENT_DIR) \
		--metadata-file=$(METADATA) \
		--from=commonmark_x \
		--toc \
		--toc-depth=2 \
		--mathml \
		--css=templates/epub.css \
		--metadata date="$(DATE)" \
		--metadata build-info="$(VERSION) ($(DATE)-$(HASH))" \
		--output=$@
	@echo "✓ ePub: $@"

# Combined Markdown Build
md: $(MD_FILE)
$(MD_FILE): $(TRANSFORMED_CHAPTERS) $(TITLE_PAGE) $(FILTERED_METADATA) | directories check-pandoc-deps
	@echo "Building Markdown..."
	$(PANDOC) \
		$(TITLE_PAGE) \
		$(TRANSFORMED_CHAPTERS) \
		--resource-path=$(CONTENT_DIR) \
		--metadata-file=$(FILTERED_METADATA) \
		--from=commonmark_x \
		--to=commonmark_x \
		--standalone \
		--output=$@
	@echo "✓ Markdown: $@"

# Index Page (Landing Page)
index: $(INDEX_FILE)
$(INDEX_FILE): templates/index.template.md $(METADATA) $(TEMPLATE_DIR)/book.html | directories check-pandoc-deps
	@echo "Building Landing Page..."
	$(PANDOC) \
		templates/index.template.md \
		--metadata-file=$(METADATA) \
		--from=commonmark_x \
		--template=$(TEMPLATE_DIR)/book.html \
		--standalone \
		--metadata date="$(DATE)" \
		--metadata build-info="$(VERSION) ($(DATE)-$(HASH))" \
		--output=$@
	@echo "✓ Landing Page: $@"

# Latest Copies (Permalinks)
# Copy from short names to long names
latest: $(HTML_FILE_LONG) $(PDF_FILE_LONG) $(EPUB_FILE_LONG) $(MD_FILE_LONG)

$(HTML_FILE_LONG): $(HTML_FILE)
	@cp $< $@

$(PDF_FILE_LONG): $(PDF_FILE)
	@cp $< $@

$(EPUB_FILE_LONG): $(EPUB_FILE)
	@cp $< $@

$(MD_FILE_LONG): $(MD_FILE)
	@cp $< $@

# README Build
readme: README.md
README.md: $(CHAPTERS) | directories
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
