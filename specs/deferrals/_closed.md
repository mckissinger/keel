# Closed deferrals

Resolved items moved out of the open, file-per-entry ledger. Each records what
closed it and the PR that carried the resolution.

## Skill trigger evals + budget lint

**Parked 2026-07-01, closed 2026-07-03.** The concern: skill descriptions were
restructured in the packaging chore without measurement — un-pinned claims by
keel's own philosophy. The gate (an eval-runner shape decision + a re-run trigger
policy) is now resolved.

**Resolution.** Shipped as the `skill-trigger-evals` feature, in two milestones:

- **`skill-evals-m1-lint`** — `scripts/check-skill-frontmatter.sh` + `.test.sh`, a
  deterministic field-presence frontmatter lint (name == directory, `description`,
  `when_to_use`) over every `skills/*/SKILL.md`, wired into CI so the structure every
  trigger and eval depends on cannot silently regress.
- **`skill-evals-m2-harness`** — `scripts/skill-eval/`: a bespoke self-contained
  session harness (bash runner + Node stdlib-only judge, no external eval repo) that
  spawns fresh `claude -p` sessions keel-enabled vs disabled, a deterministic
  activation detector + judge covered by committed tests on canned transcripts,
  file-per-entry boundary fixtures + a glob barrel across the four confusable groups,
  a description-variant A/B mode carrying the superpowers case, and a `[runtime]` live
  baseline as the planned spend stop-point.

**Re-run policy (resolves the deferral's open trigger-policy question):** the
frontmatter lint gates every skill-touching PR in CI; the token-heavy session evals
run on-demand + pre-release + on a description change or model bump, and are
deliberately never wired into CI.

Closed by the skill-trigger-evals feature's M2 code PR (`skill-evals-m2-harness`).
