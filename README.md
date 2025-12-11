# KarmaRank Book

A minimal book setup using Pandoc for generating HTML and PDF from Markdown sources.

## Structure

- `content/` - Your Markdown chapter files
- `images/` - Image assets
- `templates/` - Pandoc HTML templates
- `output/` - Generated files (gitignored)
- `metadata.yaml` - Book metadata

## Local Development

### Prerequisites

Install Pandoc and LaTeX:

```bash
sudo apt update
sudo apt install pandoc texlive-latex-base texlive-latex-extra
```

### Building

Run the build script:

```bash
./build.sh
```

This will generate:

- `output/book.html` - Combined HTML with MathJax
- `output/book.pdf` - PDF (if LaTeX is installed)

Open `output/book.html` in your browser to preview.

## LaTeX Math Support

The setup supports LaTeX math notation:

- **Inline math**: `$x = y$` (recommended for PDF compatibility)
- **Block math**: `$$x = y$$` (recommended for PDF compatibility)

**Note**: While Pandoc supports `\(...\)` and `\[...\]` syntax, these may not work reliably for PDF generation. For best compatibility across HTML and PDF formats, use `$...$` for inline math and `$$...$$` for block math.

## GitHub Actions

On push to `main` or `master`, GitHub Actions will:

1. Build HTML and PDF
2. Upload artifacts
3. Deploy HTML to GitHub Pages (if enabled)

## Adding Images

You can include images (including SVG diagrams) using standard Markdown syntax:

```markdown
![Alt text](images/diagram.svg)
```

For sizing control, use Pandoc's extended syntax:

```markdown
![Alt text](images/diagram.svg){width=400px}
```

**SVG Support:**

- **HTML**: SVG renders natively
- **PDF**: Requires `librsvg2-bin` (rsvg-convert) or `inkscape` for conversion

Install SVG converter for PDF:

```bash
sudo apt install librsvg2-bin
```

## Adding Chapters

1. Add new `.md` files to `content/`
2. Files are processed in alphabetical order
3. Use `01-chapter.md`, `02-chapter.md` naming for explicit ordering
