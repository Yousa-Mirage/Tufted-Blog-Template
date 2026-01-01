# Find all .typ files in content/ that don't start with an underscore in their path
TYP_FILES := $(shell find content -name '*.typ' -not -path '*/_*')

# Identify PDF files: .typ files whose name contains "PDF" (case-insensitive)
PDF_TYP_FILES := $(shell find content -name '*.typ' -not -path '*/_*' | grep -i "PDF")

# Filter out PDF files from TYP_FILES to get HTML-only files
HTML_TYP_FILES := $(filter-out $(PDF_TYP_FILES),$(TYP_FILES))

# Generate corresponding HTML file paths in _site/ (excluding PDF files)
HTML_FILES := $(patsubst content/%.typ,_site/%.html,$(HTML_TYP_FILES))

# Generate corresponding PDF file paths in _site/
PDF_FILES := $(patsubst content/%.typ,_site/%.pdf,$(PDF_TYP_FILES))

# ============================================================================
# Main Targets
# ============================================================================

# Default target
default: build

# Full build (HTML + PDF + assets)
build: html pdf assets

# Build HTML files only
html: $(HTML_FILES)
	@echo "✓ HTML 构建完成。"

# Build PDF files only
pdf: $(PDF_FILES)
	@echo "✓ PDF 构建完成。"

# Copy assets to _site only
assets:
	@mkdir -p _site/assets
	@cp -r assets/* _site/assets/

# Clean all generated files
clean:
	@echo "清理生成的文件..."
	rm -rf _site/*
	@echo "✓ 清理完成。"

.PHONY: build html pdf clean default assets

# ============================================================================
# Build Rules
# ============================================================================

# Pattern rule to compile .typ files to .html files
_site/%.html: content/%.typ
	@mkdir -p $(@D)
	typst compile --root .. --font-path assets --features html --format html $< $@
	@sed -i 's|</head>|<link rel="icon" href="/assets/favicon.ico"><script src="/assets/copy-code.js"></script><script src="/assets/line-numbers.js"></script><script src="/assets/format-headings.js"></script></head>|' $@

# Pattern rule to compile .typ files to .pdf files
_site/%.pdf: content/%.typ
	@mkdir -p $(@D)
	typst compile --root .. --font-path assets $< $@
