# Skill-trigger evals — session harness

keel routes work by auto-triggering the right grain verb on the user's prompt, and
the whole grain ladder depends on the *right* skill firing and the wrong one staying
silent. This harness measures that on the confusable boundaries: it spawns fresh
headless `claude -p` sessions with the keel plugin **enabled** and one with it
**disabled**, detects which keel skill fired, and judges it against a committed
expectation. It also runs a description-variant **A/B** mode carrying the
superpowers finding.

It is deliberately parked under `scripts/` — the zone `check-neutral.sh` does **not**
scan — because the fixtures carry app-stack names as *prompt payloads* (a should-fire
prompt is literally "kickoff a Next.js app"), exactly like keel's own `*.test.sh`
carry denylisted strings as test data. The neutrality bar is unaffected: it bans
stack language in keel's scanned methodology corpus, and this harness adds none
there.

## Layout

| File | Role |
|------|------|
| `run.sh` | Runner. Orchestrates the keel-on/off boundary sweep, the A/B mode, and the `baseline` stop-point. Isolates the two live assumptions. |
| `detect.sh` → `detect.js` | Activation detector — the deterministic core. Parses a captured `claude -p` trace → the fired verb, or `none`. The trace-format assumption lives only here. |
| `judge.js` | Scorer. `score` (one detection vs a fixture's `expected`) and `ab` (comparative trigger-accuracy across two description variants). Node built-ins only. |
| `index.sh` | The fixture **barrel** — globs `fixtures/*.json`, so registering a fixture is a new file, never a registry edit. |
| `fixtures/*.json` | Boundary fixtures, file-per-entry: `{prompt, expected: <verb>|none, boundary}` across the four confusable groups. |
| `fixtures/transcripts/*.jsonl` | Committed canned `claude -p` traces the detector self-tests against. |
| `fixtures/ab/*.json` | Committed A/B cases (the superpowers case) — two description variants + canned per-variant outcomes. |
| `detect.test.sh`, `judge.test.sh` | The deterministic core's self-tests. Green offline; no network. |

## Invoke

```sh
# Deterministic self-tests (offline, CI-safe):
bash scripts/skill-eval/detect.test.sh
bash scripts/skill-eval/judge.test.sh

# The fixture barrel:
bash scripts/skill-eval/index.sh --count      # how many fixtures are registered
bash scripts/skill-eval/index.sh --json       # the assembled barrel run.sh consumes

# Detector / judge directly:
bash scripts/skill-eval/detect.sh fixtures/transcripts/implement-feature-fired.jsonl
node scripts/skill-eval/judge.js score --expected spec-feature --detected spec-feature
node scripts/skill-eval/judge.js ab   fixtures/ab/superpowers-implement-feature.json

# Runner — offline dry-run (prints the plan + an offline detect→judge smoke):
bash scripts/skill-eval/run.sh boundary --dry-run
bash scripts/skill-eval/run.sh ab fixtures/ab/superpowers-implement-feature.json --dry-run

# Runner — LIVE (paid; spawns real claude -p sessions):
bash scripts/skill-eval/run.sh boundary
bash scripts/skill-eval/run.sh baseline --group "implement-feature/implement-milestone" --confirm-spend
```

## Scoring rule

A fixture's `expected` is the single keel grain verb that **should** fire, or `none`
if no keel verb should. A case passes iff `detected === expected`.

- **should-trigger** → `expected` = the intended verb.
- **should-not-trigger** → `expected` = `none` (nothing should fire) or the correct
  **sibling** verb when the point is that a confusable verb must stay silent while its
  sibling fires. Either way the confusable/wrong verb firing gives
  `detected !== expected` → fail.

The A/B comparative accuracy is just this rule tallied per description variant.

## Re-run policy

- **The frontmatter lint (M1, `scripts/check-skill-frontmatter.sh`) gates every
  skill-touching PR in CI** — beside `check-neutral.sh` / `check-plan.sh`. It is the
  cheap deterministic structural gate.
- **The session evals in this directory are deliberately NOT wired into CI** — they
  spawn real `claude -p` sessions and burn tokens; blocking a PR on live-session spend
  is the wrong economics. They run:
  - **on-demand** (a `run.sh boundary` sweep while iterating),
  - **before a release tag** (pre-release confidence),
  - **on a description change or a model bump** (the two events that can move trigger
    behavior).
- **The deterministic core IS CI-safe.** `detect.test.sh` + `judge.test.sh` run over
  committed canned transcripts/outputs with no network, so the harness's own logic is
  gate-able even though the live evals are not.

## The two live assumptions (validated at the baseline run)

The live path is real and invocable but was **not executed** at build time — a live
`claude -p` session is paid spend, the milestone's `[runtime]` stop-point. Two
mechanisms are assumed, each quarantined into one function so a wrong guess is a
one-function fix, and both are **validated at the first live BASELINE run**:

1. **Keel on/off toggle** — `run.sh:keel_project_dir <on|off>` writes a throwaway
   project whose `.claude/settings.json` includes (on) or omits (off) keel's
   `extraKnownMarketplaces` + `enabledPlugins: {"keel@keel": true}` (the shape
   provision/adopt seed); `claude -p` is run with that dir as cwd. *If the live run
   shows a different toggle, edit `keel_project_dir` only.*
2. **Trace capture + format** — `run.sh:run_claude_p` invokes
   `claude -p "<prompt>" --output-format stream-json --verbose`; the trace **shape**
   (a `Skill` tool_use whose `input.skill` is `keel:<verb>`) is parsed solely by
   `detect.js:skillFromEvent`. *If the live run shows different flags, edit
   `run_claude_p`; if a different event shape, edit `detect.js:skillFromEvent` — nothing
   else.*

## The baseline (`[runtime]`, the spend stop-point)

`run.sh baseline --group <boundary> --confirm-spend` spawns the real sessions and
writes `BASELINE.md`. It refuses to run without `--confirm-spend`. It is **not** run
during a build; `/verify-milestone` authorizes the spend, runs it, and attaches the
report as the PR evidence. `BASELINE.md` is intentionally absent from this commit.
