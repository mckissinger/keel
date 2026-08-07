# Chore batch — guards-routing-monitoring

Compressed implementation of the 2026-08-05 harvest slate's mechanical Tier-2 items
(digest: `specs/reviews/2026-08-05-harvest.md`, F4/F6/F7/F8/F10) plus the verifier-effort
change from the 2026-08-06 Anthropic model/effort review, authorized by the owner 2026-08-06 as
direct implementation with a fresh-context verifier pass in place of per-item ceremony.

## Applied items

- **shape-aware-guard-denies (F4)** — `scripts/guard-branch-rules.sh`: when a merge command fails
  the closed-set whitelist while an authorization exists (mode/attended/committed), the exit-2
  message names the canonical bare shape instead of the generic policy line; every path still
  exits 2. `scripts/merge-guard.sh`: the gate-passed ask carries the same shape hint when an
  authorization exists and the shape failed; the decision stays ask.
  - Done-condition: `bash scripts/guard-branch-rules.test.sh` passes with the wrong-shape-under-
    marker cases asserting the shape-hint text (attended: "canonical bare shape"; committed:
    "committed auto-merge marker is armed") including a piped `--auto` case; `bash
    scripts/merge-guard.test.sh` passes with the mode+no-`--auto` case asserting "not the
    canonical bare shape"; no decision (allow/ask/deny/exit code) changed in either script.
- **verifier-effort-high (model/effort review)** — `references/model-routing.md`: the verifier row
  pins `high` for every milestone; the escalation section is reframed as the model-pair-relative
  **verifier-strength invariant** (capability decorrelation carries never-weaker under the
  Fable-5/Opus-5 pair; effort-escalation reactivates on any same-model pairing).
  `skills/verify-milestone/SKILL.md` step 2, `skills/implement-feature/SKILL.md` step 2, and
  `references/milestones-and-verification.md` §4 cite the invariant instead of the per-dispatch
  escalation.
  - Done-condition: no live surface still prescribes dispatching the verifier above `high` under
    the current model pair, and the invariant's reactivation condition is stated in
    model-routing.md.
- **effort-arg-reality (F7)** — `references/model-routing.md` resolution order gains the harness
  reality check (Agent/Task dispatch carries `model` only; Workflow `agent()` carries
  `model`+`effort`); the build-dispatch table row and the notes bullet are corrected;
  `skills/implement-feature/SKILL.md` step 1 routes `reasoning-heavy` → `xhigh` via an
  effort-carrying mechanism and records the gap as a once-per-run note otherwise.
  - Done-condition: no keel surface prescribes an `effort` arg on an Agent/Task dispatch call.
- **branch-from-origin (F10)** — `skills/implement-milestone/SKILL.md` step 2 branches
  `git fetch origin && git checkout -b <slug> origin/main` (frontmatter allowlists
  `git fetch origin*`); `skills/implement-feature/SKILL.md` step 1 says freshly-fetched
  `origin/main`, never local `main`; implement-milestone step 1 gains the worktree
  untracked-state note (`.env.local`/markers absent by construction — re-derive, never treat as
  project-missing, never propose sibling-worktree deletion).
  - Done-condition: both build surfaces prescribe the fetched-origin base with the stale-base
    scar, and the worktree note names the two file classes.
- **dispatch-report-contract (F6) + settle-only-monitoring (F8)** — new
  `references/dispatch-and-monitoring.md` (named report sections; one protocol resume then
  treat-as-not-run; empty-section-is-complete; all-settled-or-first-failure watching;
  empty-output-is-a-failed-read; observed-duration windows), cited from
  `skills/implement-feature/SKILL.md` step 2, `skills/verify-milestone/SKILL.md` dispatch, and
  `skills/land-feature/SKILL.md`'s wave-scripting contract.
  - Done-condition: the reference exists with both contracts and all three skills cite it; the
    verifier-report rule states that a still-missing report after the one resume counts as
    not-run, never a pass.

## Combined checks

Recorded at build time, re-run by the verifier: `bash scripts/check-neutral.sh`,
`bash scripts/check-plan.sh`, `bash scripts/check-skill-frontmatter.sh`,
`bash scripts/check-skill-anchors.sh`, plus all 13 script self-tests
(`guard-branch-rules.test.sh` and `merge-guard.test.sh` carry the new/updated cases).

verified: clean at 989119a, 2026-08-06, via fresh-context verifier subagent — four seam findings at 5bcc46b remediated, all four re-checked clean (evidence in PR #214) — carried forward from 00def02: CI-green rule: update-branch absorbed verification-economy (#213), own content unchanged; evidence = PR #214 re-fired required checks
