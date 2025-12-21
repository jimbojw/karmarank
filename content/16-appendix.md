# Appendix

## Glossary

### Core Concepts

**The Firm Ledger**

The organization's accounting of value. It does not track code quality, effort, or moral virtue. It tracks **Status-Weighted Stories**. If an action is not recorded here, it is chemically indistinguishable from doing nothing.

**The Private Ledger**

Your internal accounting of value, based on craft, ethics, and logic. (e.g., "clean code," "robust architecture"). Useful for mental health, but useless for promotion. Do not expect the Firm Ledger to replicate data from this table.

**Status ($S_i$)**

The contextual importance of a _person_ ($i$). Someone who sits in the calibration court has high Status. Someone who testifies has Status transitively according to how the evaluators in that room view them.

**karma ($k_i$)**

A synonym for "affect" or "care". How much good or bad feeling _this person_ ($i$) has about the subject and is willing to testify to.

**Karma ($K$)**

The sum of Status-weighted karma. ($K = \sum S_i \cdot k_i$).

**Status-Weighted Story**

The atomic unit of corporate currency. A narrative unit featuring you, as told by someone with Status. Stories yield karma and are weighted by the Status of the teller.

**The Uncanny Valley of Alignment**

The non-linear relationship between System Awareness and Organizational Alignment.

* **Idealists** align because they believe the nobel lie.
* **Burnouts** rebel because they reject the nobel lie.
* **Optimizers** align because they subvert the nobel lie.

**Full-Stack Human**

The result of an engineer applying their system-design skills to social dynamics. An individual who can both build value (Technical CPU) and sell value (Social GPU emulation), giving them an asymmetric advantage over pure politicians.

**KarmaRank**

The implied iterative algorithm by which Karma ($K$) and Status ($S$) converge. That is, the outcome of calibration confers title and accolades, which are components of Status. Status is the realized effect of Karma validated by calibration.

### Topology

**The Calibration Cylinder**

The local network graph that determines your rating. It consists of three layers:

1.  **The Defendant:** You.
2.  **The Counsel/Jury:** Your Manager and their Peers.
3.  **The Judge:** Your Skip-Level (Director/VP).

Anyone outside this cylinder is irrelevant to your immediate survival.

**Frustum Culling**

A graphics rendering technique applied to social attention. The practice of aggressively ignoring input, requests, or feedback from individuals who do not have influence on your Calibration Cylinder.

**The Witness**

A High-Status individual ($S_i$) who has agreed to testify on your behalf during the calibration trial. Without a Witness, your work is hearsay.

### Tactics & Workflows

**Karma-Driven Development (KDD)**

A development methodology where the "Test" (the promotion bullet point) is written and validated _before_ any code is written.

- _Protocol:_ Groom Backlog → Write Test → Compiler Check → Code (Green State) → Refactor Story.

**The Compiler Check**

The step in KDD where you validate a proposed "Status-Weighted Story" with your Manager. If the Manager rejects the premise ($k_i \approx 0$), the code fails to compile and must not be written.

**The Brief**

The final artifact of your work. A document formatted for the "Numerophiles" in the calibration room. It must follow the structure: **Villain** (Context) → **Hero** (Action) → **Witness** (Validation) → **Visual** (Chart).

**Political Echolocation**

The process of pinging High-Status nodes with strategic questions ("What is your mental model of X?") to populate your backlog with high-demand stories and warm the cache for your identity.

### Economics

**Arbitrage**

The act of changing jobs to correct a market pricing error. If your Private Ledger valuation (Senior Engineer) is higher than your Firm Ledger valuation (Level 3), you execute a trade (change companies) to capture the spread.

**The Loyalty Discount**

The economic penalty for remaining at a firm longer than two years. Caused by the spread between the **Retention Budget** (Cost of Living adjustments) and the **Acquisition Budget** (Market Rate).

**Legacy Cache**

The accumulation of negative or neutral stories ("bugs," "awkward interactions") that inevitably build up in your "Permanent Record" over time. A primary driver for the necessity of **Server Migration** (Job Hopping).

## Further Reading

This manifesto is a synthesis of engineering pragmatism and social science. If you want to inspect the source code for these ideas, start here:

### Pierre Bourdieu

_The Logic of Practice_ / _Distinction_

The source of **Field**, **Capital**, and **Habitus**. Bourdieu explains why some people "just get it" (Habitus) and how social games are played for specific types of Capital within a bounded Field.

### Jonathan Haidt

_The Righteous Mind_

The source of **Moral Foundations Theory**. Essential for debugging **Protocol Mismatches**. It explains why your "rational" argument for refactoring code (Sanctity/Order) sounds like nonsense to a manager optimizing for quarterly revenue (Authority/Outcome).

### James C. Scott

_Seeing Like a State_

The definitive text on **Legibility**. It explains why the Firm (like the State) must flatten complex reality into simple metrics (Ratings), even if that simplification destroys local knowledge and value.

### Chris Voss

_Never Split the Difference_

The manual for **Tactical Empathy** and **Conversational Reconnaissance**. Voss frames empathy not as "niceness," but as a way to extract information and influence behavior using Calibrated Questions. This is the engine behind **Political Echolocation**.

### Goodhart's Law

Marilyn Strathern

_"When a measure becomes a target, it ceases to be a good measure."_ The fundamental reason why **Strategic Ambiguity** is a feature, not a bug, of performance review systems.
