# Milestone — testing-doctrine

Change context: `specs/changes/testing-doctrine.md`. One milestone, prose-only; edits
`references/milestones-and-verification.md` (new §8),
`skills/implement-milestone/SKILL.md`, `skills/spec-foundation/SKILL.md`. No scripts,
gates, hooks, or templates move. Integration seams: the shared rules file ends at §7
today and other files cite its sections by number — the new section appends as §8 and
must not renumber or contradict §1–§7 or §7's tag semantics; the run-to-convergence
flake rule that §8 rule 2 defers to is owned by **`skills/verify-milestone/SKILL.md`'s
hard rules** (it is *not* in §3 — cite it by that home, never as a §-number);
implement-milestone step 5 already cites Q11 and the single-test-first loop — the
pointer lands inside it without disturbing those; spec-foundation's Stack-profile
paragraph was just edited by substrate-contract (Q12) — the smell-check pointer lands
in that paragraph **after its existing final sentence (the derived-profile/lessons
sentence), leaving the Q12 and scaffold-gap sentences untouched**; rule 1 must stay
consistent with `references/feedback-ladders.md`'s Node API "serialize or isolate"
prior (the smell is contamination-driven serialization, not a deliberate
serialized/isolated tier); the evidence base for the eight rules is
`specs/reviews/2026-07-12-skill-mining.md` §"Testing realizations to encode" (the
ninth realization is Q12's, already landed, and is deliberately excluded).

## Done-conditions

- [auto] **§8 exists with exactly the eight rules.**
  `references/milestones-and-verification.md` gains a section headed **"## 8.
  Test-authoring doctrine (cross-stack)"** after §7, containing the eight rules of the
  change context in that order — per-suite data ownership (with the five-incident scar
  and the contamination-driven-serialization smell, scoped to not contradict the
  ladder priors' deliberate serialize-or-isolate), run-unique fixture identity (with
  builder-side run-twice), privileged-path seeding or round-trip assertion,
  cross-surface assertion parity (tied to Q2), capped-key live test per AI module
  (env-gated, invariants never text), server-mode naming with both-columns for
  straddling classes + the production column building under the stack's env (tied to
  Q6), deferred-rung risk notes + no optional-flagged load-bearing steps, CI-only
  retry budgets + explicit waits. Each rule states its doctrine and the scar that
  earned it (faithful multi-sentence rules are fine; the change context's drafts are
  the source text).
- [auto] **Stack-neutral phrasing.** §8 names no framework/tool as required — hedged
  examples at most — and `scripts/check-neutral.sh` passes.
- [auto] **No duplication of existing owners.** §8 rule 2 defers verification-side
  flake handling to its actual owner — `verify-milestone`'s run-to-convergence hard
  rule, cited by name and home, never as a §-number of the shared rules file (no such
  section exists there); rule 7 names the deferrals ledger as the deferral's home
  (cites, doesn't restate its format); nothing in §8 restates Q12's
  failure-signature table — at most one pointer to it.
- [auto] **No renumbering, no stale references.** §1–§7 keep their numbers and
  content (beyond §7 nothing above the new section changes); repo-wide grep finds no
  pre-existing citation of "§8" that the new section's meaning would break, and every
  §-citation across skills/ references/ workflows/ still resolves to the section it
  meant.
- [auto] **implement-milestone points at §8.** `skills/implement-milestone/SKILL.md`
  step 5 (the author-the-committed-tests step) carries one sentence pointing at the
  shared rules' §8 test-authoring doctrine — no rule restated — with the step's
  existing Q11/single-test-first prose unchanged.
- [auto] **spec-foundation surfaces the smell at derivation.**
  `skills/spec-foundation/SKILL.md`'s Stack-profile paragraph carries one sentence,
  **placed after the paragraph's existing final sentence (the
  derived-profile/lessons sentence), with the Q12 and scaffold-gap sentences
  untouched**: the Q11 derivation checks any existing test config for §8 rule 1's
  smell — a suite serialized to paper over cross-test contamination — and surfaces it
  at derivation time rather than absorbing it (a deliberate serialize-or-isolate
  tier per the stack's ladder prior is not the smell).
- [auto] **Repo checks green.** `claude plugin validate --strict .`,
  `scripts/check-neutral.sh`, `scripts/check-plan.sh`,
  `scripts/check-skill-frontmatter.sh`, `scripts/check-skill-anchors.sh`, and every
  `scripts/*.test.sh` pass on the branch.

## verification

verifier subagent against this file's done-conditions (all `[auto]`; prose-only —
closable by reading the named files and running the named checks).

verified: clean at a9e0e34, 2026-07-13, via verifier subagent against this spec's done-conditions — all 7 conditions evidenced with file:line, 5 repo checks + 11 script self-tests green (evidence in PR #117)
