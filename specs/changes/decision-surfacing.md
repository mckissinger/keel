# Change — decision-surfacing: the builder flags the choices it was unsure about, as a complement to verification

**For:** the human reviewing autonomous/assisted build output, who cannot read every line at scale.
**Enables:** the "audit the *choices*, not the diff" leverage (Taelin/Thariq, 2026) — the builder,
at the build→verify handoff, surfaces the genuine judgment calls it made under ambiguity so a human
can spend review attention where it actually matters, **without** relaxing any code-level check.

## Why this, and the boundary that keeps it honest

The X research that motivated this had a strong dissenting camp (Karpathy, Dario, and many
practitioners): review does not go *away*, it moves *up* — architecture/contract/decision review
always, line-level for sensitive surfaces. So this artifact is deliberately scoped as a **complement
to keel's verification, never a replacement.** It adds a signal for the human; it removes nothing.
The verifier still checks every done-condition; the pin gate is unchanged; correctness-critical
milestones still get their full fine-grained treatment. "Review becomes forensics once the agent's
deliberation is gone by PR time" (repoops, 2026) is exactly the gap this closes — it captures the
deliberation *at build time*, while the builder still has it.

## What it is

At its handoff step, `implement-milestone` writes **zero or more file-per-entry** uncertain-choice
records under `specs/uncertainties/<milestone-slug>/` — one file per choice, riding the milestone
branch (file-per-entry so parallel milestones never collide, same discipline as `decisions/` /
`deferrals/` / `specs/runs/`). Each entry names: **the choice made**, **the viable alternative(s)
considered**, and **why it's uncertain** (what a reasonable reviewer might decide differently).

The `verify-milestone` **skill session** (the orchestrator with Read tools — not the read-only
`verifier` subagent) reads that directory and **includes each entry verbatim alongside** the subagent's
correctness report; it does not adjudicate them. The human adjudicates at keel's **existing** attended
gates, unchanged by this milestone — the `verify-milestone` report, and (for user-facing features) the
`review-feature` sitting: an uncertain choice that should change the spec becomes a `decisions/` or
`deferrals/` entry or a fix through the normal flow; one that's fine is accepted. No wording is added to
`skills/review-feature/` — the entries flow through that gate as it already works. After adjudication the
entries are historical.

## The definition that keeps it from becoming noise (two-readers testable)

A choice is logged **only if all three hold**: (1) the builder selected among **viable alternatives**,
(2) the **spec did not dictate** the selection, and (3) a **reasonable reviewer could have chosen
differently**. A spec-dictated choice, a single-obvious-path choice, or a routine style pick is **not**
logged. The bar is deliberately high — the value is a *short* list of real judgment calls, not a diary.
A milestone with no genuine uncertainty writes **no** entries, and that is a clean handoff, not a gap.

## Integration seam

`implement-milestone` step 8 (handoff) gains the write; `verify-milestone` gains the read + report-
inclusion. The two must agree on the path (`specs/uncertainties/<milestone-slug>/`). No done-condition
of any milestone is weakened, and the verifier's independence and read-only stance are untouched — it
reports the builder's flagged choices, it does not treat them as pre-cleared.

## Not in scope

No change to model routing (that landed in #171), the pin gate, or the verifier's correctness checks.
This adds one build-time signal and one read; nothing else moves.
