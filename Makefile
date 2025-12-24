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

# Build artifacts for markdown output
TITLE_PAGE := $(BUILD_DIR)/title-page.md
FILTERED_METADATA := $(BUILD_DIR)/metadata-filtered.yaml
IMAGE_LIST := $(BUILD_DIR)/image-list.txt

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

.PHONY: all clean html pdf epub md images release directories prepare-metadata-filtered prepare-title-page build-transform-filter check check-links check-images check-images-refs check-unused-images check-chapter-order verify-pandoc-deps verify-pdf-deps nav check-nav check-nav-title check-nav-header check-nav-footer fix

# Main targets
# Build deployable artifacts (index page + all formats).
# Each format builds both short-named and long-named versions.
all: images index html pdf epub md

# Build infrastructure
directories:
	@mkdir -p $(OUTPUT_DIR)
	@mkdir -p $(BUILD_DIR)

# Build combined transform filter (map + transform logic)
# See scripts/build-transform-filter.sh for ID extraction implementation details
build-transform-filter: $(BUILD_DIR)/transform-chapters.lua
$(BUILD_DIR)/transform-chapters.lua: $(CHAPTERS) filters/transform-chapters.lua | directories
	@scripts/build-transform-filter.sh $(BUILD_DIR) $@ filters/transform-chapters.lua $(sort $(CHAPTERS))

# Pattern rule to build transformed chapters
$(TRANSFORMED_DIR)/%.md: $(CONTENT_DIR)/%.md $(BUILD_DIR)/transform-chapters.lua filters/remove-nav.lua | directories build-transform-filter verify-pandoc-deps
	@mkdir -p $(TRANSFORMED_DIR)
	$(PANDOC) \
		$< \
		--from=commonmark_x \
		--to=commonmark_x \
		--lua-filter=filters/remove-nav.lua \
		--lua-filter=$(BUILD_DIR)/transform-chapters.lua \
		--output=$@

# Prepare filtered metadata (excludes styling fields)
prepare-metadata-filtered: $(FILTERED_METADATA)
$(FILTERED_METADATA): $(METADATA) | directories
	@echo "Preparing filtered metadata..."
	@scripts/prepare-metadata-filtered.sh $(METADATA) $@ $(DATE) $(VERSION) $(HASH) $(RELEASE_MODE)

# Prepare title page markdown
prepare-title-page: $(TITLE_PAGE)
$(TITLE_PAGE): $(METADATA) | directories
	@echo "Preparing title page..."
	@scripts/prepare-title-page.sh $(METADATA) $@ $(DATE) $(VERSION) $(HASH) $(RELEASE_MODE)

# Extract image list from transformed chapters
$(IMAGE_LIST): $(TRANSFORMED_CHAPTERS) filters/extract-images.lua | directories verify-pandoc-deps
	@echo "Extracting image references..."
	@mkdir -p $(BUILD_DIR)
	$(PANDOC) \
		$(TRANSFORMED_CHAPTERS) \
		--from=commonmark_x \
		--lua-filter=filters/extract-images.lua \
		--to=commonmark_x \
		--output=$@ || (rm -f $@ && exit 1)

# Copy referenced images to output
images: $(IMAGE_LIST) | directories
	@echo "Copying images to output..."
	@scripts/copy-images.sh $(IMAGE_LIST) $(IMAGES_DIR) $(OUTPUT_DIR)/images

# Dependency checks
verify-pandoc-deps:
	@if [ "$(USE_DOCKER)" = "true" ]; then \
		docker info >/dev/null 2>&1 || (echo "✗ Error: Docker not available. Install Docker or use: USE_DOCKER=false make <target>" && exit 1); \
	else \
		command -v pandoc >/dev/null || (echo "✗ Error: pandoc not found. Install pandoc or use: USE_DOCKER=true make <target>" && exit 1); \
	fi

verify-pdf-deps: verify-pandoc-deps
	@if [ "$(USE_DOCKER)" != "true" ]; then \
		command -v pdflatex >/dev/null || (echo "✗ Error: pdflatex not found. Install LaTeX or use: USE_DOCKER=true make pdf" && exit 1); \
	fi

# Output format targets
# Index Page (Landing Page)
index: $(INDEX_FILE)
$(INDEX_FILE): templates/index.template.md $(METADATA) $(TEMPLATE_DIR)/book.html | directories verify-pandoc-deps
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

# HTML Build (builds both short and long versions)
html: $(HTML_FILE_LONG)
$(HTML_FILE): $(TRANSFORMED_CHAPTERS) $(METADATA) $(TEMPLATE_DIR)/book.html | directories verify-pandoc-deps
	@echo "Building HTML..."
	$(PANDOC) \
		$(TRANSFORMED_CHAPTERS) \
		--resource-path=$(CONTENT_DIR) \
		--metadata-file=$(METADATA) \
		--from=commonmark_x \
		--template=$(TEMPLATE_DIR)/book.html \
		--standalone \
		--toc \
		--toc-depth=2 \
		--mathjax \
		--metadata date="$(DATE)" \
		--metadata build-info="$(VERSION) ($(DATE)-$(HASH))" \
		--output=$@
	@echo "✓ HTML: $@"
$(HTML_FILE_LONG): $(HTML_FILE)
	@cp $< $@

# PDF Build (builds both short and long versions)
pdf: $(PDF_FILE_LONG)
$(PDF_FILE): $(TRANSFORMED_CHAPTERS) $(METADATA) | directories verify-pdf-deps
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
$(PDF_FILE_LONG): $(PDF_FILE)
	@cp $< $@

# ePub Build (builds both short and long versions)
epub: $(EPUB_FILE_LONG)
$(EPUB_FILE): $(TRANSFORMED_CHAPTERS) $(METADATA) | directories verify-pandoc-deps
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
$(EPUB_FILE_LONG): $(EPUB_FILE)
	@cp $< $@

# Combined Markdown Build (builds both short and long versions)
md: $(MD_FILE_LONG)
$(MD_FILE): $(TRANSFORMED_CHAPTERS) $(TITLE_PAGE) $(FILTERED_METADATA) filters/convert-images-to-gh-pages.lua | directories verify-pandoc-deps
	@echo "Building Markdown..."
	$(PANDOC) \
		$(TITLE_PAGE) \
		$(TRANSFORMED_CHAPTERS) \
		--resource-path=$(CONTENT_DIR) \
		--metadata-file=$(FILTERED_METADATA) \
		--from=commonmark_x \
		--to=commonmark_x \
		--standalone \
		$(if $(RELEASE_MODE),,--lua-filter=filters/convert-images-to-gh-pages.lua) \
		--output=$@
	@echo "✓ Markdown: $@"
$(MD_FILE_LONG): $(MD_FILE)
	@cp $< $@

# Check targets
check: check-links check-images check-images-refs check-unused-images check-chapter-order check-nav

# Navigation check targets
check-nav: check-nav-title check-nav-header check-nav-footer

check-nav-title: | directories
	@echo "Checking NAV_TITLE comments..."
	@scripts/check-nav-title.sh $(sort $(CHAPTERS))

check-nav-header: | directories
	@echo "Checking NAV_HEADER format..."
	@scripts/check-nav-header.sh $(sort $(CHAPTERS))

check-nav-footer: | directories
	@echo "Checking NAV_FOOTER format..."
	@scripts/check-nav-footer.sh $(sort $(CHAPTERS))

check-links: | directories
	@echo "Checking inter-document links..."
	@scripts/check-links.sh $(sort $(CHAPTERS))

check-images: | directories
	@echo "Checking image files..."
	@scripts/check-images.sh $(IMAGES_DIR)

check-images-refs: | directories
	@echo "Checking image references in markdown..."
	@scripts/check-images-refs.sh $(IMAGES_DIR) $(ALL_MD)

check-unused-images: | directories
	@echo "Checking for unused images..."
	@scripts/check-unused-images.sh $(IMAGES_DIR) $(ALL_MD)

check-chapter-order: | directories
	@echo "Checking chapter numbering..."
	@scripts/check-chapter-order.sh $(sort $(CHAPTERS))

# Utility targets
clean:
	rm -rf $(OUTPUT_DIR)
	rm -rf $(BUILD_DIR)

fix: readme nav

readme: README.md
README.md: $(CHAPTERS) | directories
	@echo "Updating README.md TOC..."
	@scripts/update-readme-toc.sh $(BUILD_DIR) README.md $(sort $(CHAPTERS))

nav: | directories
	@echo "Ensuring NAV_TITLE comments..."
	@scripts/nav-title.sh $(BUILD_DIR) $(sort $(CHAPTERS))
	@echo "Updating navigation headers..."
	@scripts/nav-header.sh $(BUILD_DIR) $(sort $(CHAPTERS))
	@echo "Updating navigation footers..."
	@scripts/nav-footer.sh $(BUILD_DIR) $(sort $(CHAPTERS))
