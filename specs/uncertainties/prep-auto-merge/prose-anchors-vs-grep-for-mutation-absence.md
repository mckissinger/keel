# Uncertainty — locked the print-never-run boundary with prose anchors, not a grep-for-absence

**The choice made.** The skill's load-bearing boundary invariants (Prints — never runs, Reminds — never
sets, never sets the `ANTHROPIC_API_KEY` secret, points at `keel:arm-auto-merge`, the wedge gate, reuse the
assertion) are locked by **positive prose anchors** in `scripts/skill-anchors/prep-auto-merge.txt` (enforced
by `check-skill-anchors.sh`). `scripts/check-prep-auto-merge.test.sh` tests only the **artifacts** (the
template passes (b2), pins a SHA, tracks keel's SHA; a generated contract is accepted).

**The viable alternative.** The milestone's `[auto]` done-conditions (lines 100-101) suggested "a grep that
the skill body contains **no** protection/secret mutation call" — i.e. a negative grep proving absence of
`gh api -X PUT/PATCH` / `gh secret set` in the SKILL.md.

**Why it's uncertain.** I departed from the spec's literal grep-for-absence because it is **unsound for this
skill**: the skill's whole job is to *print* the exact `gh api -X PUT/PATCH` protection and `allow_auto_merge`
commands for the human to run, so those strings **must** appear in the file (in the print-templates, lines
75/90) — a grep asserting their absence would either false-positive on the legitimate templates or, if
scoped to dodge them, become a brittle context-sensitive matcher. Positive prose anchors invert the test:
they assert the *boundary sentences that make the intent print-only* are present, which a cold edit removing
"never runs" would break, while the print-templates stay. A reviewer could reasonably want a stricter
mechanical guarantee than "the disclaimer sentence is still there" — e.g. a structured check that every
mutating `gh api` in the skill sits inside a fenced print-template block, not in an imperative step. That
stronger check wasn't built; the anchors + the human-reviewed skill prose are the current guarantee. Related:
[[keep-vs-trim-arm-manual-check-contract-walkthrough]].
