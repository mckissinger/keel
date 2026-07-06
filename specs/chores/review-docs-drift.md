# Chore batch — review-docs-drift

Punch-list batch: reconcile docs that drifted behind the shipped surface — the README's plugin inventory and autonomy story, the session-bootstrap grain ladder, and M1/M2 prose leakage in the shared rules and spec skills.

## Applied items

- **readme-skill-count** — README "What's in the plugin" says **17 skills** and the grain list carries the **Autonomy** row (`auto` posture switch + `auto-merge` attended toggle, both human-triggered only).
- **readme-autonomy-modes** — README describes three autonomy postures (`auto:feature`, `auto:run`, `auto:genesis`) plus the attended auto-merge toggle, and points at `decisions/2026-07-05-autonomy-modes-v2.md` + `decisions/2026-07-genesis-envelope.md` as superseding the original `decisions/2026-07-autonomy-modes.md`.
- **readme-hooks-sentence** — README hooks-layer sentence distinguishes the globally wired `merge-guard.sh` PreToolUse hook (in `hooks/hooks.json`) from the skill-scoped `guard-branch-rules.sh` (wired by the build skills' frontmatter).
- **banner-genesis** — both grain-ladder banners in `scripts/session-bootstrap.sh` list `keel:auto genesis "<idea>"` alongside `feature`/`run` on the Autonomy row.
- **m1-m2-prose-leakage** — the milestone-numbered anchors ("per the M1 workbench verb", "per M2's neutral fidelity") are gone from `references/milestones-and-verification.md`, `skills/spec-feature/SKILL.md`, and `skills/spec-change/SKILL.md`; the prose anchors on the stable references (Q8.3, §6) instead.

## Combined checks

`bash scripts/check-verified-pin.test.sh` (PASS), `bash scripts/check-neutral.test.sh` (PASS), `bash scripts/check-neutral.sh` (PASS), `bash scripts/session-bootstrap.test.sh` (PASS), `bash scripts/merge-guard.test.sh` (PASS), `bash scripts/guard-branch-rules.test.sh` (PASS), `bash scripts/attended-marker-parity.test.sh` (PASS), `bash scripts/check-auto-preflight.test.sh` (PASS), `bash scripts/check-plan.test.sh` (PASS), `bash scripts/check-plan.sh` (PASS), `bash scripts/check-skill-frontmatter.test.sh` (PASS), `bash scripts/check-skill-frontmatter.sh` (PASS), `bash scripts/check-skill-anchors.test.sh` (PASS), `bash scripts/check-skill-anchors.sh` (PASS), `claude plugin validate --strict .` (validation passed) — all green on the combined branch.

verified: clean at b70faa5, 2026-07-05, via punch-list (evidence in PR #89)
