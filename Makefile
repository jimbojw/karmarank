# Variables
METADATA := metadata.yaml
CONTENT_DIR := content
OUTPUT_DIR := output
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

# Output files
HTML_FILE := $(OUTPUT_DIR)/$(FILENAME_BASE).html
PDF_FILE := $(OUTPUT_DIR)/$(FILENAME_BASE).pdf
EPUB_FILE := $(OUTPUT_DIR)/$(FILENAME_BASE).epub
TXT_FILE := $(OUTPUT_DIR)/$(FILENAME_BASE).txt
MD_FILE := $(OUTPUT_DIR)/$(FILENAME_BASE).md
INDEX_FILE := $(OUTPUT_DIR)/index.html

# Tools
PANDOC := pandoc

README_FILE := README.md

.PHONY: all clean html pdf epub txt md release directories prepare-images readme latest

all: directories prepare-images html pdf epub txt md index latest readme

directories:
	@mkdir -p $(OUTPUT_DIR)

# Copy images to output directory for HTML
prepare-images: directories
	@if [ -d "$(IMAGES_DIR)" ]; then \
		mkdir -p $(OUTPUT_DIR)/images; \
		cp -r $(IMAGES_DIR)/* $(OUTPUT_DIR)/images/; \
	fi

# HTML Build
html: $(HTML_FILE)
$(HTML_FILE): $(CHAPTERS) $(METADATA) $(TEMPLATE_DIR)/book.html | directories
	@echo "Building HTML..."
	$(PANDOC) \
		$(CHAPTERS) \
		--resource-path=$(CONTENT_DIR) \
		--metadata-file=$(METADATA) \
		--template=$(TEMPLATE_DIR)/book.html \
		--standalone \
		--self-contained \
		--toc \
		--toc-depth=2 \
		--mathjax \
		--metadata date="$(VERSION) ($(DATE)-$(HASH))" \
		--output=$@
	@echo "✓ HTML: $@"

# PDF Build
pdf: $(PDF_FILE)
$(PDF_FILE): $(CHAPTERS) $(METADATA) | directories
	@echo "Building PDF..."
	@if command -v pdflatex >/dev/null; then \
		$(PANDOC) \
			$(CHAPTERS) \
			--resource-path=$(CONTENT_DIR) \
			--metadata-file=$(METADATA) \
			--from=markdown+tex_math_dollars+tex_math_double_backslash \
			--pdf-engine=pdflatex \
			--toc \
			--toc-depth=2 \
			--variable=geometry:margin=1.5in \
			--metadata date="$(VERSION) ($(DATE)-$(HASH))" \
			--output=$@; \
		echo "✓ PDF: $@"; \
	else \
		echo "⚠ Skipping PDF (pdflatex not found)"; \
	fi

# ePub Build
epub: $(EPUB_FILE)
$(EPUB_FILE): $(CHAPTERS) $(METADATA) | directories
	@echo "Building ePub..."
	$(PANDOC) \
		$(CHAPTERS) \
		--resource-path=$(CONTENT_DIR) \
		--metadata-file=$(METADATA) \
		--toc \
		--toc-depth=2 \
		--mathml \
		--css=templates/epub.css \
		--metadata date="$(VERSION) ($(DATE)-$(HASH))" \
		--output=$@
	@echo "✓ ePub: $@"

# Plain Text Build
txt: $(TXT_FILE)
$(TXT_FILE): $(CHAPTERS) $(METADATA) | directories
	@echo "Building Plain Text..."
	$(PANDOC) \
		$(CHAPTERS) \
		--resource-path=$(CONTENT_DIR) \
		--metadata-file=$(METADATA) \
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
index: $(INDEX_FILE)
$(INDEX_FILE): templates/index.template.md $(METADATA) $(TEMPLATE_DIR)/book.html | directories
	@echo "Building Landing Page..."
	$(PANDOC) \
		templates/index.template.md \
		--metadata-file=$(METADATA) \
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
readme: $(README_FILE)
$(README_FILE): $(TEMPLATE_DIR)/README.template.md $(CHAPTERS) content/01-tldr.md
	@echo "Generating README.md..."
	@cp $(TEMPLATE_DIR)/README.template.md $@
	@# Inject TL;DR (skip first 2 lines: header and blank)
	@{ \
		TMP=$$(mktemp); \
		tail -n +3 content/01-tldr.md > $$TMP; \
		sed -i "/<!-- TLDR_PLACEHOLDER -->/r $$TMP" $@; \
		rm $$TMP; \
	}
	@# Generate TOC (using grep and sed to format links)
	@{ \
		TMP=$$(mktemp); \
		echo "" > $$TMP; \
		for f in $(CHAPTERS); do \
			TITLE=$$(grep "^# " $$f | head -n 1 | sed 's/^# //'); \
			echo "- [$$TITLE]($$f)" >> $$TMP; \
		done; \
		sed -i "/<!-- TOC_PLACEHOLDER -->/r $$TMP" $@; \
		rm $$TMP; \
	}
	@echo "✓ README.md updated"

clean:
	rm -rf $(OUTPUT_DIR)
