# Change — gate-contract

One milestone, prose-only: the two attended-gate items of the approved slate (group E)
— the **gate-presentation contract** (every attended gate ends in the fixed five-line
summary block) and the **feature lifecycle section** (the per-feature gate list that
`implement-feature`/`land-feature` read and surface, so the user stops being the
checklist). Approved by Michael 2026-07-12; evidence in
`specs/reviews/2026-07-12-skill-mining.md` ("Gate presentation contract … discussed
never shipped"; "Working-style contract") and
`specs/reviews/2026-07-12-transcript-harvest.md` finding 13 ("The user is the
lifecycle checklist — 'did we forget the workbench?', 'weren't there mockups?', 'did
we do feature review?' across 5 sessions").

## Why

Michael supervises glance-and-proceed, often from a phone: "Most of the time… I just
say 'proceed'"; "This is too much to read." Every attended gate that ends in dense
prose forces either a full read or a blind proceed. The five-line block was agreed
verbatim with him on 2026-07-12 and has been in live use since; keel is where it
belongs so every session applies it without being told. Separately, the feature
lifecycle has real gates (composition sign-off, plan PR, per-milestone pins, the
consolidated check, reconciliation, review-feature) whose *sequence* no artifact
records per feature — the transcripts show the user re-deriving it from memory five
times. keel's own doctrine ("derive, don't store") says the fix is an evidence-pointer
list, not a status paragraph.

## Decisions taken

- **The presentation contract is a reference, delivered by the banner.**
  `references/gate-presentation.md` (new) defines the block **verbatim as agreed**:

  > **⎯⎯ Summary ⎯⎯**
  > **Done:** what just happened, one sentence.
  > **Decision:** the one question needing the user — or "none."
  > **Recommend:** the pick + one-line why.
  > **Glance:** the single artifact to check for proof (file, PR, screenshot) — never "see above."
  > **Next:** what happens on approval.

  The **header line is part of the block**; fixed labels, fixed order, one line each
  (the bold markup is presentational — the labels, order, and semantics are the
  contract); **Decision always present even when "none"**; **Glance names one
  artifact, never "see above"**; dense detail stays above the block, optional to read.
  Scope: every attended gate, sign-off ask, and substantive session-ending report in a
  keel-managed project. Delivery is the session-bootstrap banner: one line in both
  copies that **enumerates the five labels itself** (so the contract is carried even
  where the plugin-cache reference path isn't resolvable) and names
  `references/gate-presentation.md` as the definition. Every session in an
  **already-managed** project inherits it — the pre-marker sittings (a greenfield
  kickoff/interview before `specs/` exists, `auto genesis` phase 1) fire before the
  banner can and are an **accepted gap**: those skills end attended anyway, and the
  contract reaches them the first session after the markers exist.
- **The lifecycle list lives in the feature spec, as evidence pointers.**
  `spec-feature`'s Movement 3 authors a **Lifecycle** section in
  `specs/features/<slug>.md`: the gates applicable to *this* feature (the no-UI path
  drops the composition/review gates per Q8.1), each line naming **where its state
  derives from** — the redline sign-off, the plan PR, each milestone's `verified:` pin
  + PR, the post-wave consolidated check, the spec reconciliation, `review-feature` +
  its refinement milestone. It is a gate *list with evidence sources*, never a stored
  current-phase paragraph — spec-foundation's derived-status rule holds unchanged.
- **The readers**: `implement-feature` reads the Lifecycle section at orchestration
  start and reports each gate's derived state in its output/handoff;
  `land-feature`'s reconciliation step updates the section to merged reality and
  surfaces the still-open gates — making "built-verified-merged, not done" mechanical
  instead of a sentence the user must remember; `review-feature`, on a passing gate
  (refinement milestone closed or none needed), records the closure in the same
  section. **The closure commit path is land-feature's existing carve-out**: a
  plan-only commit made directly, exactly like the reconciliation step ("plan-only by
  construction … carries no code and needs no pin") — the never-commit-to-main
  invariant's one recorded exemption extends to this record, stated explicitly in
  review-feature.
- **Entries are pin-shaped, never narrative.** A Lifecycle entry records a fact with
  evidence (a date, a PR number, a SHA, a spec pointer) — the same shape as a
  `verified:` pin; free current-phase prose ("currently building") is the banned
  shape. This is what keeps the section consistent with the derived-status rule.
- **Missing-section rule (retroactivity)**: feature specs authored before this change
  have no Lifecycle section — a reader that finds none **surfaces its absence** and
  backfills it at the next plan-only touch (land-feature's reconciliation is the
  natural moment); never silently skips, never fails.
- **`status` is deliberately not edited**: its sources already include the feature
  specs wholesale, so the Lifecycle section is inside what it reads; its lifecycle
  vocabulary needs no new terminal state (a review-closed feature is simply done and
  drops out of active reporting).
- **No new artifact type, no gate mechanics change**: the section is part of the
  feature spec (plan path); nothing new is linted, and the existing gates themselves
  (pin, review, merge authority) are untouched — this change is presentation and
  recording only.

## Milestone

`specs/milestones/gate-contract.md` — new `references/gate-presentation.md`; one
banner line in `scripts/session-bootstrap.sh` (both copies) + its test; one section
each in `skills/spec-feature/SKILL.md` (Movement 3),
`skills/implement-feature/SKILL.md` (orchestration start + output),
`skills/land-feature/SKILL.md` (reconciliation step), `skills/review-feature/SKILL.md`
(gate closure).
