# Milestone — skill-evals-m2-harness: session-eval harness + baseline

**Goal:** keel ships a self-runnable, LLM-judged eval that measures whether the right skill fires
(and the wrong one stays silent) on the confusable grain boundaries — in fresh `claude -p`
sessions keel-enabled vs disabled, with a description-variant A/B mode carrying the superpowers
finding — and produces a human-reviewed baseline.

**Feature:** `specs/features/skill-trigger-evals.md`. **No-UI** → two-dimension done-conditions.
**Depends on:** `skill-evals-m1-lint` (CI ordering only — the harness does not import the lint).
**Parallelizable:** no.

## Done-conditions

### Logic / invariants
- [auto] `scripts/skill-eval/` ships a runner (bash) + a judge (node, stdlib-only per keel's
  no-dependency bar) + fixtures. Given a fixture, the runner spawns a fresh headless `claude -p`
  session with the keel plugin enabled and one with it disabled, captures each session's
  skill-activation trace, and passes both traces to the judge.
- [auto] **Activation detection** (the deterministic core) is covered by
  `scripts/skill-eval/detect.test.sh` over committed **canned transcript fixtures** — one where
  `implement-feature` fired, one where nothing fired, one where the wrong verb
  (`implement-milestone`) fired — asserting the detected skill matches the transcript.
- [auto] **Judge scoring** is covered by `scripts/skill-eval/judge.test.sh` over canned detection
  inputs: a should-trigger case (intended skill detected → pass), a should-not-trigger case (no
  skill or a different skill → pass), and a mismatch (→ fail) each score correctly.
- [auto] **Boundary fixtures exist file-per-entry with a barrel** (rules §4): one
  `scripts/skill-eval/fixtures/<name>.json` per prompt, each declaring `{prompt, expected:
  <verb>|none, boundary}` across the four confusable groups (spec-foundation/spec-feature/
  spec-change; kickoff/adopt/interview; implement-feature/implement-milestone; punch-list vs
  spec-change); a glob/index assembles them, so registering a fixture is a new file, never an edit
  to a shared registry.
- [auto] **Description-variant A/B mode:** given a skill and two description variants (current vs a
  when-to-use-only variant), the runner runs each and the judge emits a comparative
  trigger-accuracy result; verified over canned session outputs by `judge.test.sh`, and the
  specific superpowers case (a workflow-summarizing description vs its trimmed variant on one
  confusable pair) ships as a committed fixture.

### Behavioral completeness
- [runtime] **Live baseline run — planned stop point (token spend).** For at least one boundary
  group, the runner spawns real `claude -p` sessions keel-on/off and writes
  `scripts/skill-eval/BASELINE.md`; `/verify-milestone` **halts for human spend authorization**
  (rules §4) before running it, then attaches the baseline report as the PR evidence. Its
  deterministic core is covered by the committed `detect.test.sh` + `judge.test.sh` suites named
  above (missing/failing coverage blocks the pin, rules §3/§5).
- [auto] **Re-run policy documented:** `scripts/skill-eval/README.md` states the lint gates every
  PR in CI, the session evals run on-demand + pre-release + on description-change/model-bump, and
  how to invoke each; it does **not** wire the session evals into CI (deliberately — cost).
- [auto] **Deferral closed:** `specs/deferrals/skill-trigger-evals.md` is removed and its
  resolution recorded in `specs/deferrals/_closed.md` (per the deferrals README convention),
  naming this feature's PR.
- [auto] The harness lives under `scripts/skill-eval/**`, inside the `scripts/` zone that
  `check-neutral.sh` **deliberately does not scan** — because eval fixtures are **test data** that
  legitimately carry app-stack names as prompt payloads (a should-fire fixture is a prompt like
  "kickoff a Next.js app"), exactly as keel's own `scripts/*.test.sh` carry denylisted strings as
  test data. So the neutrality bar does not apply to the fixtures; the condition is that
  `check-neutral.sh` stays green (it does) **and** this milestone adds no stack language to any
  file in the scanned corpus (`skills`/`references`/`agents`/`workflows`/`hooks`/`README.md`/the
  four named scripts) — verifiable from the diff.

## verification
verifier subagent against this file for the `[auto]` conditions: in the verify worktree run
`scripts/skill-eval/detect.test.sh`, `scripts/skill-eval/judge.test.sh`, and the A/B-mode assertions
over their canned fixtures; confirm the four boundary groups have file-per-entry fixtures + a
working barrel; confirm `scripts/skill-eval/README.md` states the re-run policy; confirm the
deferral moved to `_closed.md`; confirm `check-neutral.sh` is green and that this milestone's diff
adds no stack language to any scanned-corpus file (the harness itself is in the unscanned
`scripts/` zone by design).
The `[runtime]` live baseline run is the planned stop point — `/verify-milestone` authorizes the
spend, runs it, and attaches the baseline report; its deterministic core is covered by the
committed `detect.test.sh` + `judge.test.sh` suites named above. No hard invariant touched → no
`/security-review`.
