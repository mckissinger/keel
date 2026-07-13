# The gate presentation contract

How an attended gate ends. Every attended gate, sign-off ask, and substantive
session-ending report in a keel-managed project ends on the **summary block** — the
"⎯⎯ Summary ⎯⎯" header line plus the five labeled lines, exactly:

> **⎯⎯ Summary ⎯⎯**
> **Done:** what just happened, one sentence.
> **Decision:** the one question needing the user — or "none."
> **Recommend:** the pick + one-line why.
> **Glance:** the single artifact to check for proof (file, PR, screenshot) — never "see above."
> **Next:** what happens on approval.

The header line is part of the block. The **labels, order, and per-line semantics are
the contract**; the bold markup is presentational, per the output medium. **Decision is
always present**, even when the answer is "none." **Glance names exactly one artifact**
— a file, a PR, a screenshot — never "see above."

**Placement:** dense detail stays above the block, optional to read; the block is last.
**Why:** supervision is glance-and-proceed, often from a phone — five fixed lines answer
"what happened, what do you need from me, what do you recommend, where's the proof,
what happens next" without forcing a full read or a blind proceed.
