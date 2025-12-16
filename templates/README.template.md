# The KarmaRank Manifesto  
> Optimizing the Unspoken Corporate Objective Function

You are good at games. You understand systems.  
So why does your performance review feel like gaslighting?

**KarmaRank** is a framework for understanding how you are _actually_ evaluated in modern corporations. Not the HR story, but the real objective function.

## Start Reading

- [**Read Online (HTML)**](https://jimbojw.github.io/karmarank/karmarank-manifesto.html)
- **Download Latest**: [PDF](https://jimbojw.github.io/karmarank/karmarank-manifesto.pdf) | [ePub](https://jimbojw.github.io/karmarank/karmarank-manifesto.epub) | [Plain Text](https://jimbojw.github.io/karmarank/karmarank-manifesto.txt)
- _Looking for stable versions? View [Releases](https://github.com/jimbojw/karmarank/releases)._

## TL;DR

Corporate performance evaluation is not a function of work quality; it is a function of **Status-Weighted Stories**.

This document patches the "Default Engineering Worldview" (which assumes meritocracy) with **KarmaRank**, a transitive, narrative-aggregating algorithm over the corporate social graph.

![Net Status-Weighted Karma formula](./content/images/net-status-weighted-karma.png)

It explains how to decouple your self-worth from your rating, optimize your output for the **Firm Ledger**, and maximize your karmic ROI within your local **Calibration Cylinder**.

## Table of Contents

<!-- TOC_PLACEHOLDER -->

## Repository Structure

- `content/` - Markdown chapter files
- `content/images/` - Image assets (diagrams, figures)
- `templates/` - Pandoc HTML templates
- `output/` - Generated files (gitignored)
- `metadata.yaml` - Book metadata
- `Makefile` - Build configuration

## Local Development

### Prerequisites

Install Pandoc and LaTeX:

```bash
sudo apt update
sudo apt install pandoc texlive-latex-base texlive-latex-extra
```

### Building

This project uses `make`. To build all formats (HTML, PDF, TXT, Markdown):

```bash
make all
```

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
![Alt text](images/diagram.png)
```

**Note:** We use PNG format for diagrams to ensure consistent rendering across HTML and PDF output.

## License

This work is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-nc-sa/4.0/).

See the [LICENSE](LICENSE) file for the full legal text.
