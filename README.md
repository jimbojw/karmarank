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

This document patches the [Default Engineering Worldview](content/04-security-advisory.md) (which assumes meritocracy) with **KarmaRank**, a transitive, narrative-aggregating algorithm over the corporate social graph.

> **KarmaRank:** Time-Decayed, Capital-Constrained, Adversarial Eigenvector-Sponsorship.

While this full KarmaRank definition describes the actual appraisal process, for the day-to-day practitioner, it suffices to optimize for **Net Status-Weighted Karma**:

![Net Status-Weighted Karma Equation, $K = \sum_{i} S_i \cdot k_i$](content/images/net-status-weighted-karma.png)

$$
K = \sum_{i} S_i \cdot k_i
$$

Where:

* **$K$ — Net Status-Weighted Karma**  
  In a given field: a company, a team, a subculture, a community.
* **$i$ — The Index**  
  Ranging over the people whose opinions about you actually _travel_—your manager, your manager's peers, the Staff engineer everyone listens to, the PM who won't shut up in calibration meetings.
* **$S_i$ — Status**  
  The witness's **Status** in this field—intentionally capitalized, because it's the most important term. It's not just job title, but their actual ability to move decisions and narratives as it pertains _to you_.
* **$k_i$ — Karma**  
  Your **karma with person** $i$: the signed "emotional value" they get from telling a story about you and your work.

The KarmaRank Manifesto expands on this, explaining how to decouple your self-worth from your rating ([Law #1](content/05-law-1-two-ledgers.md)), optimize your output for the **Firm Ledger**, and maximize your karmic ROI within your local [Calibration Cylinder](content/09-calibration-cylinder.md).

## Table of Contents

<!-- TOC_START -->

- [License: CC-BY-NC-SA-4.0](content/00-license.md)
- [TL;DR](content/01-tldr.md)
- [Introduction: The Frame of the Game](content/02-introduction.md)
- [KarmaRank: Origin Story (with Math)](content/03-origin-story.md)
- [SECURITY ADVISORY: Five Vulnerabilities in the Default Engineering Worldview](content/04-security-advisory.md)
- [Law #1: Separation of Private & Firm Ledgers](content/05-law-1-two-ledgers.md)
- [Law #2: The Rating Is The Job](content/06-law-2-rating-is-job.md)
- [Law #3: Impact = Who Cares?](content/07-law-3-impact.md)
- [Meta-Law: You Do Not Talk About KarmaRank](content/08-meta-law.md)
- [The Calibration Cylinder: Topology of the Trial](content/09-calibration-cylinder.md)
- [Tactics I: Karma-Driven Development (KDD)](content/10-tactics-1-kdd.md)
- [Tactics II: Manufacturing Evidence (The Brief)](content/11-tactics-2-brief.md)
- [The Exit: The Market Check](content/12-exit.md)
- [Conclusion: You Are Not Cynical Enough](content/13-conclusion.md)
- [Appendix](content/14-appendix.md)

<!-- TOC_END -->

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

## Contributing

We welcome stories, questions, and corrections! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to report issues or submit pull requests.

## License

This work is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-nc-sa/4.0/).

See the [LICENSE](LICENSE) file for the full legal text.
