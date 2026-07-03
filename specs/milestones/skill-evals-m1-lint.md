# Milestone — skill-evals-m1-lint: structural frontmatter lint, CI-gated

**Goal:** keel ships a deterministic lint that keeps every skill's frontmatter structurally
sound — the fields the router and every eval depend on are present and non-empty — and gates it
in CI, so that structure cannot silently regress.

**Feature:** `specs/features/skill-trigger-evals.md`. **No-UI** → two-dimension done-conditions.
**Depends on:** nothing. **Parallelizable:** no (single cheap milestone; M2 lands after).

## Done-conditions

### Logic / invariants
- [auto] `scripts/check-skill-frontmatter.sh` exists, is executable (100755 in git), and is
  `dirname`-relative (survives plugin-cache path churn); it reads every `skills/*/SKILL.md` and
  exits 0 on a clean set, non-zero (naming the offending file + the missing field on stderr) on a
  violation.
- [auto] For each skill file it asserts the following, failing when any is absent: (a) frontmatter
  parses; (b) `name` present and equal to the skill's directory name;
  (c) `description` present and non-empty; (d) `when_to_use` present and non-empty — this is the
  **trigger** field keel skills actually carry (verified at spec time: all 16 current skills have
  it). **Grain** is inherent in the skill's name (keel skill names are the grain verbs), so the
  `name`-equals-directory check is the grain check; there is no separate grain-token grep.
- [auto] The lint is **field-presence only** — it never inspects whether a `description` or
  `when_to_use` clause disambiguates from a sibling verb or summarizes the workflow. Those are
  semantic questions M2's eval measures empirically (a token-grep for "NOT" is a weak proxy for
  real disambiguation; the boundary evals measure the real thing). So M1 mandates no wording
  change and **edits no skill file**.

### Behavioral completeness
- [auto] `scripts/check-skill-frontmatter.test.sh` (house idiom: throwaway fixture dirs, assert
  exit code + stderr): a well-formed fixture passes; a fixture missing each of {name, description,
  when_to_use} fails with that field named; a fixture whose `name` mismatches its directory fails;
  and a fixture whose description **summarizes a workflow but carries all three fields PASSES** —
  proving the lint does not overreach into M2's semantic territory.
- [auto] Running `scripts/check-skill-frontmatter.sh` over the current `skills/*/SKILL.md` set
  exits 0 **with no skill-file edits** — all 16 skills already carry `name` + `description` +
  `when_to_use`, so the gate is green by construction, not by editing skills.
- [auto] `.github/workflows/ci.yml` runs `scripts/check-skill-frontmatter.test.sh` then
  `scripts/check-skill-frontmatter.sh`, mirroring the existing check-neutral / check-plan wiring.
  (The lint lives under `scripts/`, which `check-neutral.sh` deliberately does not scan; it
  carries no methodology prose, so no neutrality coverage is claimed or needed.)

## verification
verifier subagent against this file: in the verify worktree run `check-skill-frontmatter.test.sh`
(all cases, including the workflow-summary-passes case) and `check-skill-frontmatter.sh` over the
repo (expect exit 0 and no skill files modified); grep `.github/workflows/ci.yml` for both new
steps. No surface added and no live runtime → no runtime walk. No hard invariant touched → no
`/security-review`.
