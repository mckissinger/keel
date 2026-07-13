# Milestone — gate-contract

Change context: `specs/changes/gate-contract.md`. One milestone, prose-only; adds
`references/gate-presentation.md` and edits `scripts/session-bootstrap.sh` (both
banner copies) + `scripts/session-bootstrap.test.sh`, `skills/spec-feature/SKILL.md`,
`skills/implement-feature/SKILL.md`, `skills/land-feature/SKILL.md`,
`skills/review-feature/SKILL.md`. No gate or guard *semantics* change — the banner
gains one line, nothing else about any script's behavior moves. Integration seams: the bootstrap banner is covered by its self-test (stays
green, gains an assertion); land-feature's reconciliation step ("Reconcile the specs
to merged reality") is the single home for the lifecycle update — the new sentence
extends it, not a new step; review-feature's "Relationship to the other gates" section
already states the not-done-until rule — the closure recording points at the feature
spec, it does not restate the rule; spec-foundation's derived-status rule ("never add
a current-phase paragraph") must stay true of the Lifecycle section — it records gates
and evidence sources, never narrative status.

## Done-conditions

- [auto] **The presentation reference exists, block verbatim.**
  `references/gate-presentation.md` defines the summary block as **the "⎯⎯ Summary ⎯⎯"
  header line plus the five labeled lines** with exactly the agreed labels in the
  agreed order — **Done / Decision / Recommend / Glance / Next** — and the agreed
  semantics per line: Done = what just happened, one sentence; Decision = the one
  question needing the user, **always present even when "none"**; Recommend = the pick
  + one-line why; Glance = **the single artifact to check for proof (file, PR,
  screenshot), never "see above"**; Next = what happens on approval. It states that
  the labels, order, and semantics are the contract (the bold markup is
  presentational, per the output medium), the scope (every attended gate, sign-off
  ask, and substantive session-ending report in a keel-managed project), the placement
  rule (dense detail stays above the block, optional to read; the block is last), and
  the rationale (glance-and-proceed supervision, often mobile).
- [auto] **Banner delivery, labels carried inline.** Both orientation-banner copies in
  `scripts/session-bootstrap.sh` carry one line that **enumerates the five labels
  itself** (`Done / Decision / Recommend / Glance / Next` — so the contract travels
  even where the plugin-cache reference path doesn't resolve; both heredocs are
  literal, no interpolation needed) and names `references/gate-presentation.md` as the
  definition; `scripts/session-bootstrap.test.sh` gains an assertion that the emitted
  banner contains the five-label string, with the full suite still passing and the
  banner staying under the test's existing word bound.
- [auto] **spec-feature authors the Lifecycle section.** `skills/spec-feature/SKILL.md`
  Movement 3 states: the feature spec (`specs/features/<slug>.md`) gains a
  **Lifecycle** section enumerating the gates applicable to this feature — the
  composition/redline sign-off and `review-feature` entries present only for a UI
  feature (Q8.1) — where each entry names the gate **and where its state derives
  from** (the sign-off in this spec, the plan PR, each milestone's `verified:` pin +
  code PR, the post-wave consolidated check, the spec reconciliation commit,
  `review-feature` + its refinement milestone). The prose states the section is
  evidence pointers for derivation, never stored status — consistent with the
  derived-status rule — **and the skill's enumeration of the feature spec's contents
  (its "the feature spec (`specs/features/<slug>.md`) contains…" list) gains the
  Lifecycle section**, so that enumeration stays complete.
- [auto] **implement-feature reads and surfaces it.**
  `skills/implement-feature/SKILL.md` states: at orchestration start, read the feature
  spec's Lifecycle section (alongside the milestone specs it already reads); the
  skill's output/handoff reports each lifecycle gate's derived state — including the
  gates that remain open after the build (the user's merges, `land-feature`,
  `review-feature`).
- [auto] **land-feature updates and surfaces it.** `skills/land-feature/SKILL.md`'s
  reconciliation step ("Reconcile the specs to merged reality") states: the feature
  spec's Lifecycle section is updated to merged reality in the same plan-only commit,
  and the still-open gates are surfaced to the user — a landed feature with
  `review-feature` open is reported as **built-verified-merged, not done**.
- [auto] **The missing-section rule appears in both readers.** The
  implement-feature and land-feature passages each state: a feature spec with no
  Lifecycle section (authored before this change) has its **absence surfaced, never
  silently skipped**, and land-feature's reconciliation is named as the backfill
  moment (the section is added there, derived from the evidence that exists).
- [auto] **review-feature records the closure, commit path stated.**
  `skills/review-feature/SKILL.md` states: when the gate passes (no findings, or the
  refinement milestone closed and re-reviewed), the closure is recorded in the feature
  spec's Lifecycle section as a **plan-only commit made directly, under the same
  recorded carve-out as land-feature's reconciliation step** (plan-only by
  construction, carries no code, needs no pin) — the durable answer to "did we do
  feature review?".
- [auto] **Entries are pin-shaped — the checkable no-stored-status line.** At least
  one of the edited passages (spec-feature's authoring bullet is the natural home)
  states the entry shape: a Lifecycle entry records a fact with evidence — a date, a
  PR number, a SHA, a spec pointer — the same shape as a `verified:` pin; free
  current-phase prose ("currently building") is the banned shape. No edit instructs
  writing narrative status into a spec.
- [auto] **Repo checks green.** `claude plugin validate --strict .`,
  `scripts/check-neutral.sh`, `scripts/check-plan.sh`,
  `scripts/check-skill-frontmatter.sh`, `scripts/check-skill-anchors.sh`, and every
  `scripts/*.test.sh` pass on the branch.

## verification

verifier subagent against this file's done-conditions (all `[auto]`; prose-only —
closable by reading the named files and running the named checks).
