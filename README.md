# The KarmaRank Manifesto  
> Optimizing the Unspoken Corporate Objective Function

You are good at games. You understand systems.  
So why does your performance review feel like gaslighting?

**KarmaRank** is a framework for understanding how you are _actually_ evaluated in modern corporations. Not the HR story, but the real objective function.

## Start Reading

**Latest builds:**

[![Read The KarmaRank Manifesto Online (HTML)](https://img.shields.io/badge/Read_Online-HTML-2ea44f?style=for-the-badge&logo=html5&logoColor=white)](https://jimbojw.github.io/karmarank/karmarank-manifesto.html) [![Download The KarmaRank Manifesto (PDF)](https://img.shields.io/badge/Download-PDF-b31b1b?style=for-the-badge&logo=adobeacrobatreader&logoColor=white)](https://jimbojw.github.io/karmarank/karmarank-manifesto.pdf) [![Download The KarmaRank Manifesto (ePub)](https://img.shields.io/badge/Download-ePub-orange?style=for-the-badge&logo=epub&logoColor=white)](https://jimbojw.github.io/karmarank/karmarank-manifesto.epub)

**Stream in terminal:**

```
curl -sL https://jimbojw.github.io/karmarank/karmarank-manifesto.md | less
```

(Looks great in [glow](https://github.com/charmbracelet/glow) or [bat](https://github.com/sharkdp/bat))

_See [Releases](https://github.com/jimbojw/karmarank/releases) for stable versions._

## TL;DR

Corporate performance evaluation is not a function of work quality; it is a function of **Status-Weighted Stories**.

This document patches the [Default Engineering Worldview](content/04-security-advisory.md) (which assumes meritocracy) with **KarmaRank**, a transitive, narrative-aggregating algorithm over the corporate social graph.

> **KarmaRank:** Time-Decayed, Capital-Constrained, Adversarial Eigenvector-Sponsorship.

While this full KarmaRank definition describes the actual appraisal process, for the day-to-day practitioner, it suffices to optimize for **Net Status-Weighted Karma**:

[![Net Status-Weighted Karma Equation](content/images/net-status-weighted-karma.light.png#gh-light-mode-only)![Net Status-Weighted Karma Equation](content/images/net-status-weighted-karma.dark.png#gh-dark-mode-only)](content/03-origin-story.md)

$$
K = \sum_{i} S_i \cdot k_i
$$

Where:

* **$K$ — Net Status-Weighted Karma**  
  In a given field: a company, a team, a subculture, a community.
* **$i$ — The Index**  
  Ranging over the people whose opinions about you actually _travel_—your manager, your manager's peers, the Staff engineer everyone listens to, the PM who won't shut up in calibration meetings.
* **$S_i$ — Status**  
  Intentionally capitalized, because it's the most important term. It's not just the witness's job title, but their actual ability to move decisions and narratives as it pertains _to you_.
* **$k_i$ — Karmic Appraisal**  
  The signed "emotional value" person $i$ gets from telling a story about you and your work.

The KarmaRank Manifesto proceeds from this observation, explaining how to decouple your self-worth from your rating ([Law #1](content/05-law-1.md)), optimize your output for the **Firm Ledger**, and maximize your karmic ROI within your local [Calibration Cylinder](content/09-calibration-cylinder.md).

[![Calibration Cylinder showing You (Defendant), your Manager (Counsel), your Manager's Peers (Prosecution/Jury) and your Skip Manager (Judge).](content/images/calibration-cylinder.light.png#gh-light-mode-only)![Calibration Cylinder showing You (Defendant), your Manager (Counsel), your Manager's Peers (Prosecution/Jury) and your Skip Manager (Judge).](content/images/calibration-cylinder.dark.png#gh-dark-mode-only)](content/09-calibration-cylinder.md)
*Figure: Calibration Cylinder showing You (Defendant), your Manager (Counsel), your Manager's Peers (Prosecution/Jury) and your Skip Manager (Judge).*

## Table of Contents

<!-- TOC_START -->

- [License: CC-BY-NC-SA-4.0](content/00-license.md)
- [TL;DR](content/01-tldr.md)
- [Introduction: The Frame of the Game](content/02-introduction.md)
- [KarmaRank Origin Story (with Math)](content/03-origin-story.md)
- [SECURITY ADVISORY: Five Vulnerabilities in the Default Engineering Worldview](content/04-security-advisory.md)
- [Law #1: Conative Dissonance](content/05-law-1.md)
- [Law #2: The Rating Is The Job](content/06-law-2.md)
- [Law #3: Who Cares?](content/07-law-3.md)
- [Meta-Law: You Do Not Talk About KarmaRank](content/08-meta-law.md)
- [The Calibration Cylinder: Topology of the Trial](content/09-calibration-cylinder.md)
- [Know Your Counsel: Technician, Politician, Peacemaker](content/10-kyc.md)
- [Tactics I: Karma-Driven Development (KDD)](content/11-kdd.md)
- [Tactics II: Manufacturing Evidence (The Brief)](content/12-brief.md)
- [The Exit: The Market Check](content/13-exit.md)
- [Conclusion: You Are Not Cynical Enough](content/14-conclusion.md)
- [Epilogue: The Meta-Game](content/15-epilogue.md)
- [Appendix](content/16-appendix.md)

<!-- TOC_END -->

## Contributing

Contributions welcomed:

* 💬 GitHub [Discussions](https://github.com/jimbojw/karmarank/discussions) for: Questions, Stories, Ideas, Debate.
* 🐛 GitHub [Issues](https://github.com/jimbojw/karmarank/issues) for **actionable tasks** only: Typos & Grammatical Errors, Rendering Bugs, Specific Content Requests.

See [CONTRIBUTING.md](CONTRIBUTING.md) for PR process details.

## Build From Source

Requires Docker:

```
make -j$(nproc) all 
```

Artifacts will be written to `output/`. See [DEVELOPING.md](DEVELOPING.md) for details.

## License

This work is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-nc-sa/4.0/).

See the [LICENSE](LICENSE) file for the full legal text.
