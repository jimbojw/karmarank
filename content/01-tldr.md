# TL;DR

Corporate performance evaluation is not a function of work quality; it is a function of **Status-Weighted Stories**.

This document patches the [Default Engineering Worldview](./04-security-advisory.md#security-advisory-five-vulnerabilities-in-the-default-engineering-worldview) (which assumes meritocracy) with **KarmaRank**, a transitive, narrative-aggregating algorithm over the corporate social graph.

A complete KarmaRank algorithm would model _time-decayed_, _capital-constrained_, _adversarial eigenvector-sponsorship_. But for the day-to-day practitioner, it suffices to optimize for **Net Status-Weighted Karma**:

![Net Status-Weighted Karma Equation](images/net-status-weighted-karma.png)

$$
K = \sum_{i} S_i \cdot k_i
$$

Where:

* $K$ is your Net Status-Weighted Karma in a given field: a company, a team, a subculture, a community.
* $i$ is the index, ranging over the people whose opinions about you actually _travel_—your manager, your manager's peers, the Staff engineer everyone listens to, the PM who won't shut up in calibration meetings.
* $S_i$ is the witness's **Status** in this field—intentionally capitalized, because it's the most important term. It's not just job title, but their actual ability to move decisions and narratives as it pertains _to you_.
Here, 
* $k_i$ is your **karma with person** $i$: the signed "emotional value" they get from telling a story about you and your work.

The full document explains how to decouple your self-worth from your rating ([Law #1](./05-law-1-two-ledgers.md#law-1-separation-of-private-firm-ledgers)),
optimize your output for the **Firm Ledger**, and maximize your karmic ROI within your local [Calibration Cylinder](./09-calibration-cylinder.md#the-calibration-cylinder-topology-of-the-trial).


