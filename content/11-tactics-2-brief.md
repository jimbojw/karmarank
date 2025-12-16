# Tactics II: Manufacturing Evidence (The Brief)

In the previous chapter, you learned Karma Driven Development (KDD), a strategy for choosing Status-Weighted Stories _first_ and working backwards to make them true. Now it's time to learn how to optimize that evidence for your manager to bring to calibration court.

Your manager is tired. They have six other cases to litigate. They do not remember that cool bug fix you did in March.

In the lead up to your performance review, if you ask your manager to "look at my commits," you are asking your lawyer to investigate the crime scene ten minutes before the trial starts. You will lose.

Your job is to hand them a fully formed **Legal Brief**. This is a document that requires zero cognitive load to copy-paste into the HR portal.

But how do you write a brief that survives the adversarial environment of the Calibration Cylinder? You have to understand the psychology of the jury.

## 1. Feeding the Numerophiles

Your evaluators (Directors, VPs, Senior Peers) are human beings, but they are a specific subspecies. They are **Numerophiles**.

They are obsessed with quantification. In the absence of trust, they use numbers as a proxy for truth. A paragraph of prose feels like an "opinion." A bar chart feels like "science."

- **Bad:** "I significantly improved the performance of the login page." (Hearsay).
- **Good:** "Reduced P99 login latency by **230ms (-14%)**, reclaiming **45 engineering-hours** per month in wait time." (Fact).

It does not matter that the "45 hours" is a back-of-the-napkin estimate based on shaky assumptions. It is a **Number**. It has significant digits. It triggers the "Truth" receptor in the evaluator's brain.

## 2. Moral Targeting (Know Your Judge)

Before you pick your number, you must pick your narrative. This goes back to **CVE-DEW-03 (The Protocol Mismatch)**. You must frame your achievement in a way that strokes the specific **[Moral Matrix](#jonathan-haidt)** of your evaluators.

Different tribes worship different gods:

- **The Sales/Exec Tribe:** Worships **Authority** and **Revenue**. They care about speed, dollars, and "winning."
- **The Old Guard/Sysadmin Tribe:** Worships **Sanctity** and **Order**. They care about stability, uptime, and "doing it the right way."
- **The Modern SV/HR Tribe:** Worships **Care/Harm** and **Fairness**. They care about "User Delight," "Inclusivity," and "Democratizing Access."

You must estimate the moral composition of your org in general and the Calibration Room in particular, then tailor your evidence accordingly.

### The Case Study: The UI Refresh

Let's say you updated a settings page.

**If the Jury is Sales-Driven:**

- **Narrative:** "Removed friction from the conversion funnel."
- **The Metric:** "Conversion rate increased by 0.5%. Annualized revenue impact: $50k."

**If the Jury is Engineering-Driven:**

- **Narrative:** "Paid down technical debt by migrating to the new design system."
- **The Metric:** "Deleted 4,000 lines of legacy CSS. Reduced build size by 12KB."

**If the Jury is Modern SV (Care/Harm):**

- **Narrative:** "Reduced cognitive load for frustrated users."
- **The Metric:** "Using Likert scales to assess convenience pre- and post-launch, we found the new UI scored **~1.53 points higher** than baseline (n=20)."

Same work. Different story. Different numbers.

If you pitch the "CSS deletion" story to a room full of "User Empathy" managers, you get a pat on the head. If you show them the Likert scale data, you get a promotion.

## 3. The Visual Kill Shot

Humans are visual creatures. A wall of text is a barrier; an image is a bypass tunnel straight to the brain.

Whenever possible, **do not just state the number. Show the delta.**

If you are claiming that your new UI is better, do not just write "1.53 points higher." Deploy a diverging stacked bar chart.

- **Top:** Distribution of sentiment scores _before_ development.
- **Bottom:** Distribution of sentiment scores _after_ implementation.

![Example diverging stacked bar charts for showing quantified sentiment change](images/diverging-stacked-bar-chart.png)

When a tired Director scans your packet at 4:00 PM on a Friday, they will not read your bullet points. They _will_ look at the pretty picture. The picture says "Up and to the Right." The picture says "Competence."
    
If you don't know what data visualizations to make, ask your AI of choice something like "what's the canonical/persuasive way to visualize <your kind of data>?".

## 4. Constructing the Brief

Your final deliverable to your manager—the document you hand them two weeks before calibration—should look like this:

**Headline:** [The Moral Frame] e.g., "Democratizing Data Access for Non-Technical Users"

- **The Context (The Villain):** "Previously, 40% of PM queries required Engineer intervention, causing delay and frustration (Harm)."
- **The Action (The Hero):** "Built a self-serve dashboard using Metabase."
- **The Result (The Evidence):**
  - "Reduced Engineer-assist tickets by **85%**."
  - "Saved **20 hours/week** of engineering time."
  - _Insert Screenshot of Ticket Volume dropping off a cliff._
- **The Witness:** "As [Director Alice] noted, this 'fundamentally changed how we make decisions'."

Your company or team probably keeps a specific internal doc or side template. Use it. Your goal is low cognitive load, not art.

## 5. Is This Lying?

You might feel a twinge of guilt. "I didn't actually measure the 20 hours saved, I just estimated it." "The Likert scale sample size was only 12 people."

Relax. You are not falsifying data. You are **formatting reality**.

The firm demands a number to justify the budget. If you refuse to provide one because you are waiting for "perfect, academically rigorous data," you are not being noble. You are being invisible.

You are estimating. You are deriving. You are translating your labor into the native language of the colony: **Numerology**.

Give them the number so they can give you the money.
