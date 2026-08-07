# Chore batch — release 1.24.0

Minor release surfacing the 2026-08-05 harvest slate implementation to the installed runtime.
The changes are fully merged on `main` (PRs #212–#215, each chore batch carrying its own
verified pin) but installed plugins report `1.23.0`; the version must move before
`claude plugin update` can pick them up. The `v1.24.0` release tag is cut on merge.

## Applied items

- **plugin-version-1.24.0** — `.claude-plugin/plugin.json` `version` bumped `1.23.0` → `1.24.0`
  (minor: new capabilities and process-rule changes, no removals, no breaking changes; skill
  count stays 31; one new reference file). Since v1.23.0:
  - **verification-economy** (#213): CI-green re-pin rule, plan-path discrepancy fast lane,
    builder terminal-suite cut, 3-iteration adversarial-plan-pass cap, `scripts/KEEL-SYNC`
    version manifest + status drift reporting, observed-execution rule for env-gated tests.
  - **guards-routing-monitoring** (#214): shape-aware guard deny/ask messages (decisions
    unchanged; guard/merge-guard self-tests extended), verifier at flat `high` under the
    capability-based verifier-strength invariant, Agent-dispatch effort-arg reality in
    model-routing, branch-from-fetched-origin rule + worktree untracked-state note, new
    `references/dispatch-and-monitoring.md` (dispatch report contract + settle-only monitoring).
  - **stack-hygiene-preflight** (#215): Q12 machine-wide stack-hygiene check (foreign-stack
    enumeration, report-never-teardown, Q13-sibling carve-out, 502-row ownership routing),
    authored at provision, run by both entry preflights.
  - **harvest digest** (#212): specs/reviews/2026-08-05-harvest.md + cursor update (plan-only).
  - Guard/hook semantics deltas since `1.23.0`, for the record: guard-branch-rules.sh and
    merge-guard.sh message text only (all decisions, exit codes, and allow/ask/deny rows
    unchanged, asserted by their extended self-tests); implement-milestone's allowed-tools adds
    `Bash(git fetch origin*)` for the branch-from-origin rule.
  `.claude-plugin/marketplace.json` carries no `version` field, so it is unchanged.

## Combined checks

`claude plugin validate --strict .`, `bash scripts/check-neutral.sh`, `bash scripts/check-plan.sh`,
`bash scripts/check-skill-frontmatter.sh`, `bash scripts/check-skill-anchors.sh`, plus all 13
script self-tests. The released content itself landed verified with #213/#214/#215 (their batch
pins) and is unaffected by a version-string change.
