# Feature — Skill-trigger evals: keel measures whether its own skills fire right

**Grain:** one feature → two milestones (`spec-feature`). **No-UI** (committed scripts +
fixtures + docs). Signed off 2026-07-03.

## Definition

keel routes work by auto-triggering the right verb on the user's prompt — the whole grain
ladder depends on the *right* skill firing (spec-change vs spec-feature; implement-milestone vs
implement-feature) and the wrong one staying silent. Nothing asserts that today: the skill
descriptions were restructured in the packaging chore **without measurement** — un-pinned claims
by keel's own philosophy (the parked `skill-trigger-evals` deferral). This feature ships a
committed, self-runnable eval harness that measures it in two layers: a cheap deterministic
**frontmatter lint** that gates every skill-touching PR in CI, and an LLM-judged
**trigger-accuracy eval** — committed should-trigger / should-not-trigger fixtures for the
confusable grain boundaries, run in fresh `claude -p` sessions keel-enabled vs disabled — that
produces a baseline and carries, as its first case, the measured superpowers finding that a
workflow-summarizing description pulls the agent toward the description instead of the skill
body. The harness produces *evidence*; acting on it (rewriting descriptions) is downstream, not
this feature.

## Interview outcome (resolved decisions)

- **Runner: bespoke self-contained** (user decision). A committed keel script — bash
  orchestration + a small node judge, matching the existing `scripts/` + `workflows/` idiom —
  spawns fresh headless `claude -p` sessions with the plugin enabled vs disabled per fixture and
  judges activation by rubric. No dependency on an external eval repo: superpowers-evals' `drill`
  and skill-creator's `evals.json` were both considered and declined — keel ships its own
  canonical scripts and must clear its own neutrality bar, and cross-skill grain-boundary routing
  needs real multi-skill sessions a single-skill `evals.json` can't express.
- **Re-run policy: lint in CI, session evals on-demand + pre-release** (user decision). The
  deterministic frontmatter lint gates every skill-touching PR in CI (beside `check-neutral.sh` /
  `check-plan.sh`); the token-heavy session evals run on demand, before a release tag, and on a
  description change or model bump — never blocking a PR on real-session spend.
- **Lint is field-presence only.** It checks that each `skills/*/SKILL.md` frontmatter carries a
  non-empty `name` (equal to the skill's directory — the grain is inherent in keel's verb names),
  `description`, and `when_to_use` (the trigger field keel skills actually use — all 16 current
  skills have it, so the gate is CI-green with **zero skill edits**). It does **not** judge
  whether a description disambiguates from a sibling verb or summarizes its workflow — a token
  grep for "NOT" is a weak proxy; the **boundary evals (M2) measure that directly**, which is the
  honest home for the deferral's "grain named / NOT-this scoping" intent. The lint's job is to
  keep the *structure* every trigger and every eval depends on from silently regressing.
- **The live baseline run is a planned stop point.** Producing a real baseline spawns fresh
  `claude -p` sessions and burns tokens — un-pre-authorizable spend, so `/verify-milestone` halts
  for human authorization (rules §4), runs it, and the baseline report is the evidence. Its
  deterministic core (activation detection + judge scoring) is covered by committed tests on
  canned transcripts, so the harness itself pins on `[auto]`.
- **Out of scope (defaults confirmed):** model-tiering for mechanical subagents (a separate
  change if ever wanted); rewriting the workflow-summarizing descriptions (downstream of the
  eval's finding — prose-audit territory); any fidelity dimension (no-UI).

## Milestones (build order)

| # | Milestone | What |
|---|---|---|
| 1 | `skill-evals-m1-lint` | `scripts/check-skill-frontmatter.sh` + `.test.sh`; structural frontmatter checks over every `skills/*/SKILL.md`; wired into `.github/workflows/ci.yml`; green on the current skill set |
| 2 | `skill-evals-m2-harness` | `scripts/skill-eval/` runner (`claude -p` keel-on/off), file-per-entry boundary fixtures + barrel, node judge, description-variant A/B mode + the superpowers case, baseline report, re-run-policy doc, deferral → `_closed.md` |

Milestone 2 depends on 1 for CI ordering only (the lint lands first as the cheap gate; the
harness does not import the lint). Built sequentially; not worth parallelizing — two milestones,
M2 is the bulk.

## Surface ownership (the no-UI route map, rules §6)

- `scripts/check-skill-frontmatter.sh` + `scripts/check-skill-frontmatter.test.sh` — **M1**.
- `.github/workflows/ci.yml` (one lint step added) — **M1**.
- `scripts/skill-eval/**` (runner, judge, fixtures, barrel, README, baseline report) — **M2**.
- `specs/deferrals/skill-trigger-evals.md` → `specs/deferrals/_closed.md` — **M2**.

## Seams

- **`.github/workflows/ci.yml`** — M1 adds one lint step; it is the shared CI file, but M1 owns
  the edit and M2 does not touch it (no collision).
- **`specs/deferrals/`** — M2 removes this feature's open entry (`skill-trigger-evals.md`, which
  *is* file-per-entry) and appends its resolution to the **shared** `specs/deferrals/_closed.md`.
  Only M2 touches `_closed.md` in this feature, so no collision here — but note `_closed.md` is a
  single shared file (per the deferrals README), so a *future* feature closing a deferral
  concurrently would need append-discipline; the file-per-entry property is the open ledger's, not
  the closed one's.
- **Fixtures are test data, not methodology prose** — the eval fixtures deliberately carry
  app-stack names as prompt payloads (a should-fire prompt is literally "kickoff a Next.js app").
  That is why the harness lives under `scripts/skill-eval/**`, inside the `scripts/` zone
  `check-neutral.sh` **excludes by design** (the same reason keel's `*.test.sh` are excluded — they
  hold denylisted strings as test data). The neutrality bar is unaffected: it bans stack language
  in keel's *scanned methodology corpus*, and no scanned file gains any.
