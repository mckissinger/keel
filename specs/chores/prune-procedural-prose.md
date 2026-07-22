# Chore batch — prune-procedural-prose

Punch-list batch: prose-only pruning of three orchestration skill docs (`implement-feature`, `spec-feature`, `auto`), cutting procedural throat-clearing, restated rationale, and parenthetical asides while preserving every load-bearing invariant, gate, and cross-reference. No behavior or contract changes; the prose-anchor lint confirms every load-bearing sentence survives.

## Applied items

- **prune-implement-feature** — `skills/implement-feature/SKILL.md` pruned: the connective-tissue intro, cadence bullets, orchestration steps, two-boundaries section, autonomy-mode carve-out, and output paragraph tightened without dropping any gate (fresh-context verification, pin discipline, diamond/integration-branch rule, stops-at-merge).
  - Done-condition: the file is materially shorter with all load-bearing rules intact; `check-skill-anchors.sh` still finds every anchor for this file.

- **prune-spec-feature** — `skills/spec-feature/SKILL.md` pruned: preconditions, the three movements (interview / compose-the-workbench / author-milestones), output-and-handoff, autonomy-mode, and cadence sections tightened; every invariant retained (the confirm-before-author gate, reference-pull gating, pure-recomposition-at-content-grain rule, Lifecycle-section shape, three-dimension done-conditions, plan-only PR).
  - Done-condition: the file is materially shorter with all load-bearing rules intact; `check-skill-anchors.sh` still finds every anchor for this file.

- **prune-auto** — `skills/auto/SKILL.md` pruned: the seven numbered steps, the Genesis posture (Phase 1 / Phase 2 / ledger+debrief deltas), and the Boundaries list tightened; every invariant retained (mode-file single-writer + 24h TTL, preflight gate, ledger contract, debrief mandate, stop-point semantics, delegation-to-required-checks, genesis-never-self-escalates, no-sandbox-key-values).
  - Done-condition: the file is materially shorter with all load-bearing rules intact; `check-skill-anchors.sh` still finds every anchor for this file.

## Combined checks

Repo-facing lints — `check-skill-anchors.sh` (62 anchors across 10 feature files), `check-skill-frontmatter.sh` (29 skill files), `check-neutral.sh`, `check-plan.sh` — all PASS. Guard self-tests — `check-verified-pin.test.sh`, `merge-guard.test.sh`, `session-bootstrap.test.sh`, `guard-branch-rules.test.sh`, `attended-marker-parity.test.sh`, `check-auto-preflight.test.sh`, `check-plan.test.sh`, `check-skill-frontmatter.test.sh`, `check-neutral.test.sh`, `check-skill-anchors.test.sh` — all rc=0. `claude plugin validate --strict .` — Validation passed. All green on the combined branch.

verified: clean at 447d7a4, 2026-07-22, via punch-list (evidence in PR #173)
