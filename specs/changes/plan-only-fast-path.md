# Change — plan-only-fast-path: plan-only PRs stop paying suite-grade CI

Evidence base: `specs/reviews/2026-08-16-harness-efficiency.md` (T1d, on `main`). Keel
generates ≥4 plan-only PRs per feature (plan PR, reviews, reconciliation, closure), and
every one fires the full required-check set. On keel itself that is ~40s of `guards`; in
field projects it is the full suite ladder — 20–24 minutes of e2e shards re-run against
diffs that touch no code. The punch-list intake of 2026-08-16 routed this out as
design-bearing: the plan-path classification lives inside the shipped canonical gate
script, and check-coverage changes touch the compensating-control decision
(`decisions/2026-07-29-security-review-wiring.md`).

Resolved at intake (2026-08-16, attended):

- **Security-review keeps running on every PR, plan-only included.** The fast path
  exempts only suite/build-grade jobs. This dissolves the compensating-control tension —
  the 2026-07-29 decision is untouched — and keeps the marker-file carve-out (auto-merge
  marker edits classify as plan) permanently unable to dodge review. `verified-pin` and
  `plan-lint` likewise always run: they are precisely the plan gates.
- **Scope is both keel and the shipped doctrine.** The canonical script gains the
  classification mode; keel's own CI dogfoods the early-exit; the Q11 CI-topology
  doctrine and `spec-foundation`'s kickoff CI wiring carry it to field projects — where
  the measured waste lives. Existing projects pick the updated script up through the
  existing `scripts/KEEL-SYNC` batch-sync mechanism; no new propagation machinery.
- **The mechanism is a job-level early-exit, never a workflow `paths:` filter.** A
  required check that never reports wedges the merge (branch protection waits forever);
  an early-exited job reports success with a "plan-only" note. The classification is one
  source of truth: `scripts/check-verified-pin.sh`'s own `is_plan_path`, exposed as a
  mode flag — no duplicated path lists in CI yaml, ever.

Fans into **one milestone**: `specs/milestones/plan-only-fast-path.md`. No UI (keel is
no-UI — movement 2 skipped).
