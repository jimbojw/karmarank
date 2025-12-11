# The KarmaRank Manifesto

**Subtitle:** Optimizing the Unspoken Corporate Objective Function

This repository contains the source code for _The KarmaRank Manifesto_, a book about understanding and optimizing corporate performance evaluation systems.

## Repository Structure

- `content/` - Markdown chapter files
- `images/` - Image assets
- `templates/` - Pandoc HTML templates
- `output/` - Generated files (gitignored)
- `metadata.yaml` - Book metadata

## Local Development

### Prerequisites

Install Pandoc and LaTeX:

```bash
sudo apt update
sudo apt install pandoc texlive-latex-base texlive-latex-extra librsvg2-bin
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

The book uses LaTeX math notation throughout. The setup supports:

- **Inline math**: `$x = y$` (recommended for PDF compatibility)
- **Block math**: `$$x = y$$` (recommended for PDF compatibility)

**Note**: While Pandoc supports `\(...\)` and `\[...\]` syntax, these may not work reliably for PDF generation. For best compatibility across HTML and PDF formats, use `$...$` for inline math and `$$...$$` for block math.

## GitHub Actions

On push to `main` or `master`, GitHub Actions will:

1. Build HTML and PDF
2. Upload artifacts
3. Deploy HTML to GitHub Pages (if enabled)

After the first workflow run, configure GitHub Pages in your repo settings to deploy from the `gh-pages` branch.

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

## Editing Chapters

Chapters are numbered for explicit ordering:

- `00-introduction.md`
- `01-origin-story.md`
- `02-readme.md`
- etc.

Files are processed in alphabetical order, so the numbering ensures correct sequence.

## License

This work is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-nc-sa/4.0/).

See the [LICENSE](LICENSE) file for the full legal text.
