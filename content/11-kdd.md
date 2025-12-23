<!-- NAV_HEADER_START -->
[← Know Your Counsel: Technician, Politician, Peacemaker](./10-kyc.md) | [Index](../README.md#table-of-contents) | [Tactics II: Manufacturing Evidence (The Brief) →](./12-brief.md)
---
<!-- NAV_HEADER_END -->
# Tactics I: Karma-Driven Development (KDD)
<!-- NAV_TITLE: @inherit -->

In software engineering, the most disciplined teams practice **Test-Driven Development (TDD)**. The rule is simple: **Red, Green, Refactor.**

1.  **Red:** Write a test that fails (because the feature doesn't exist yet).
2.  **Green:** Write just enough code to make the test pass.
3.  **Refactor:** Clean up the code.

Despite this, most _careers_ run on **Waterfall**. You do months of work, ship it, and then hope that the calibration court validates your work. This is madness. You are building features without a spec.

To fix this, adopt **Karma-Driven Development (KDD)**. In this framework, you never write a line of code until you have written the performance review bullet point that rewards it.

![Karma Driven Development (KDD) Flowchart.](images/kdd-flowchart.png)
*Figure: Karma Driven Development (KDD) Flowchart.*

Remember [Law #2](./06-law-2.md): the rating is the job.

## Phase 1: Echolocation (Witness Selection & The IKEA Hook)

Before you can write a test, you need requirements.

Right now, your mental backlog is likely full of "Technical Debt" and "Cool Ideas." You cannot sort this list by **Technical Merit** (Private Ledger). You must sort it by **Market Demand** (Firm Ledger).

Scan your local area of the corporate social network, including (but not limited to) your [Calibration Cylinder](./09-calibration-cylinder.md) . Find a high-status Witness ($S_i$) who needs a problem solved. But do not just ask them what to do.

If you ask *"What should I work on?"*, you are an execution-bot. You are a commodity.
Instead, you goal is to trigger the **IKEA Effect**.

> **The IKEA Effect:** A cognitive bias in which consumers place a disproportionately high value on products they partially created.

You want your Witness to feel like they had a hand in steering your project. If they design the box, they will love the box. To do this, you must use **Political Echolocation**—pinging the network with a calibrated question to see what signal returns.

### The Archetypal Pings

Schedule a 15-minute sync with a High-Status Node—a Staff Engineer, a Principal PM, or your Skip-Level. Use the specific "Hook" that matches their Archetype.

**Target: The Technician Witness**
* **The Hook (Accusation Audit):** "I'm looking at the [Project X] design. **I know you hated how we handled the concurrency in the last version.** Before I draft the RFC, can I get your mental model on how *you* would structure the lock-free queue?"
* **The IKEA Payoff:** They give you a technical constraint. When you implement it, they see their own genius in your code.

**Target: The Politician Witness**
* **The Hook (Strategic Alignment):** "I'm scoping [Project Y]. I know this overlaps with the VP’s 'Efficiency' pillar. How would you frame this so it lands best with the Director during the Q3 review?"
* **The IKEA Payoff:** They give you the *narrative*. When you present it, they see their own strategy in your Brief.

**Target: The Peacemaker Witness**
* **The Hook (Diplomacy):** "I'm worried [Project Z] might step on Team Alpha's toes. Since you have such good rapport with them, how would you approach the handoff so we don't cause friction?"
* **The IKEA Payoff:** They give you the *diplomacy*. They feel ownership over the team harmony.

## Phase 2: Write The Test (The Spec)

Now that you have validated the demand and secured a Witness, you enter the **Red State**.

Open a blank document. Write the bullet point exactly as you want it to appear in your promotion packet six months from now.

> **The Test:** "Reduced AWS infrastructure spend by 20% ($150k/annually) by optimizing hot-path caching patterns, validated by Staff Engineer [Witness Name]."

Currently, this test fails. The cost of telling it is high because the story is false. But you now have a target.

## Phase 3: The IKEA Cross-Compiler (Counselor Co-Authoring)

Do not start coding yet.

You must run this test against your **Counsel** (Your Manager). In the previous worldview, you would ask for approval. In KDD, you ask for **Co-Authorship**.

You want your manager to edit the bullet point. If they change the wording, they become psychologically committed to defending it in court. They are no longer defending *your* work; they are defending *their* words.

Bring the draft to your 1:1 and apply the **Archetypal Cross-Compiler**:

### Scenario A: Your Manager is a Technician
* **The Pitch:** "I drafted this goal for the [Project X] work. I feel like the 'impact' part is fuzzy. I put 'reduced latency,' but knowing how you care about precision, is there a specific metric you think would look bulletproof to the Staff Engineers?"
* **The Edit:** They will say, *"Don't just say 'reduced latency.' Say 'reduced P99 latency by 50ms during peak load'."*
* **The Contract:** They have defined the success criteria. If you hit 50ms, they *must* endorse you, or they are invalidating their own technical judgment.

### Scenario B: Your Manager is a Politician
* **The Pitch:** "I wrote down this bullet for [Project Y]. It feels a bit too 'in the weeds.' Since you have a better sense of the Director's Q3 narrative, how would you tweak this so it pops during the calibration reading?"
* **The Edit:** They will grab the keyboard. *"Change 'refactored database' to 'Enabled Multi-Region Strategy via Data Layer Modernization'."*
* **The Contract:** They have handed you the script. You are now the actor in their play.

### Scenario C: Your Manager is a Peacemaker
* **The Pitch:** "I'm worried this bullet point sounds too aggressive. I know you value team collaboration. How can we rephrase this so it highlights how I supported the Junior Devs, while still getting credit for the architecture?"
* **The Edit:** They will soften the language but likely add a "force multiplier" clause.
* **The Contract:** You have given them a weapon they are actually willing to use—a "nice" bullet point that still counts.

## Phase 4: Green State (Implementation)

Now—and only now—do you do the work.
And crucially, **you do only the work required to pass the test.**

Your goal is to turn the test from Red to Green with the minimum possible calorie expenditure.

The "Puritan" inside you will want to rewrite the entire system to be "elegant."

**Suppress the Puritan.**

The Firm did not buy "Elegance." They bought "20% Cost Reduction." Any effort spent beyond the Green State is **Gold Plating**—uncompensated labor that introduces risk without adding status.

**Caveat:** If your Manager is a **Technician**, "Clean Code" *is part of the spec*.
* For a Politician, the work is finished when the chart shows “up and to the right”.
* For a Technician, the work is finished when the graph goes up *and* the diff looks elegant, _to them_.

But here again, only provide the minimum viable aesthetics to satisfy your specific audience. Your own Private Ledger taste is irrelevant.

## Phase 5: Refactoring The Narrative

The work is done. The test passes. Now you engage in "Refactoring"—but not of the code. You refactor the **Story**.

You have the raw materials:
1.  **The Villain:** (The problem defined by the Witness in Phase 1).
2.  **The Hero:** (The solution co-signed by the Manager in Phase 3).
3.  **The Result:** (The Green State from Phase 4).

The naive engineer builds the software, then tries to write a marketing brochure for it. The KDD practitioner writes the brochure, pre-sells it to the market via the IKEA Effect, and *then* manufactures the product to spec.

Code is a liability. The Status-Weighted Story is the asset. Never generate the liability without securing the asset first.

Next up: packaging the Story for deployment. It’s time to manufacture some evidence (the Brief).

<!-- NAV_FOOTER_START -->
---
[← Know Your Counsel: Technician, Politician, Peacemaker](./10-kyc.md) | [Index](../README.md#table-of-contents) | [Tactics II: Manufacturing Evidence (The Brief) →](./12-brief.md)
<!-- NAV_FOOTER_END -->
