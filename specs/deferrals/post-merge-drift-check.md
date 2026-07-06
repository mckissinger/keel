# Mechanical post-merge drift re-check on main

**Parked 2026-07-05** (review-hardening m2; the reframing it complements is
`decisions/2026-07-05-pin-gate-honesty.md`).

**The idea.** After a milestone PR merges, mechanically re-diff the merged result on
`main` against the pinned tree (the `verified:` SHA's content) and alert on divergence —
a post-merge audit that would catch any way a merge could land content differing from
what the fresh session verified (moved base absorbed at merge time, a squash that
resolved conflicts, server-side surprises).

**Why deferred, not built.** The practical gap is already closed PR-side: required
checks + the **require-branches-up-to-date** protection mean a moved base forces the
branch to absorb it *before* merge, where the pin gate demands re-verification of the
combined state; squash-merge then preserves content. What a post-merge checker adds under
that regime is **auditability** (an after-the-fact record that the guarantee held), not
**correctness** (nothing it catches would have been mergeable). Auditability alone does
not justify a new CI surface on `main` plus an alerting path that someone must own.

**Revisit trigger.** Build it as its own `spec-change` if either happens: (a) evidence of
a real post-merge divergence — any case where `main`'s content after a milestone merge is
not the verified content; or (b) an autonomy-mode project where the PR-side controls
prove insufficient in practice (e.g. a host where require-branches-up-to-date cannot be
enforced, or merge modes outside keel's prescription are in use).
