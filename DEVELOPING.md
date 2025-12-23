# Developing The KarmaRank Manifesto  

## Repository Structure

- `CONTRIBUTING.md` - Contribution guidelines
- `Makefile` - Build configuration
- `content/` - Markdown chapter files
- `content/images/` - Image assets (diagrams, figures)
- `metadata.yaml` - Book metadata
- `output/` - Generated files (gitignored)
- `templates/` - Pandoc HTML templates

## Local Development

### Prerequisites

**Recommended: Docker** (default, cross-platform)

This project uses Docker for hermetic, reproducible builds. Install Docker by following the [official Docker installation guide](https://docs.docker.com/get-docker/) for your platform.

**Alternative: Native Installation**

If you prefer not to use Docker, install Pandoc and LaTeX natively:

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install pandoc texlive-latex-base texlive-latex-extra texlive-fonts-recommended

# macOS (Homebrew)
brew install pandoc basictex

# Other platforms: See https://pandoc.org/installing.html
```

### Building

This project uses `make`. To build all formats (HTML, PDF, ePub, Markdown):

```bash
# Docker build (default, recommended)
make all

# Native build (if you have pandoc/LaTeX installed locally)
USE_DOCKER=false make all

# Parallel build (faster, uses all CPU cores)
make -j$(nproc) all
```

**Note:** The Makefile supports parallel builds. Use `make -j$(nproc)` to build multiple chapters simultaneously, which significantly speeds up builds on multi-core systems.

This will generate files in `output/` with detailed filenames (e.g., `karmarank-manifesto-0.1.0-2025-12-14-abc1234.pdf`) useful for debugging.

To clean the output directory:

```bash
make clean
```

### Release Mode

To simulate a release build (which generates clean filenames like `karmarank-manifesto-0.1.0.pdf`):

```bash
export RELEASE_MODE=true
make all
```

## GitHub Actions & Releases

This project uses **File-Driven Releases**.

1.  **Continuous Integration**: On every push to `main`, the book is built and artifacts are uploaded to the action run.
2.  **Automated Releases**: To cut a new public release:
    - Edit `metadata.yaml` and bump the `version` (e.g., `0.1.0` -> `0.1.1`).
    - Commit and push to `main`.
    - GitHub Actions will detect the version bump and automatically create a GitHub Release with the tag `v0.1.1` and attach the built artifacts.

## LaTeX Math Support

The book uses LaTeX math notation throughout. The setup supports:

- **Inline math**: `$x = y$` (recommended for PDF compatibility)
- **Block math**: `$$x = y$$` (recommended for PDF compatibility)

## Adding Images

Images should be placed in `content/images/`. Reference them in Markdown relative to the `content/` directory:

```markdown
![Descriptive caption text.](images/diagram.png)
*Figure: Descriptive caption text.*
```

**Note:** We use PNG format for diagrams to ensure consistent rendering across HTML and PDF output.
