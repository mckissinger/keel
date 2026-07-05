# Milestone — auto-genesis-m3-guards: the guards recognize level "genesis"

**Goal:** both merge guards accept `level: "genesis"` in the autonomy mode file with exactly the
decision rows `level: "run"` gets today — and reject everything else exactly as today.

**Feature:** `specs/features/auto-genesis.md`. **No-UI** → two-dimension done-conditions.
**Depends on:** `auto-genesis-m2-posture` (implements the level its prose names) **and the
landed `auto-hardening-m1-guards`** (builds on the TTL-bearing readers; same files — build only
after that milestone is on `main`). **Parallelizable:** no.

## Done-conditions

### Logic / invariants
- [auto] `scripts/merge-guard.sh`: `read_mode_file` accepts `level` values `"feature"`,
  `"run"`, and `"genesis"` (any other value → invalid file → treated absent, unchanged);
  a valid genesis-level mode file yields the **same decision word** as a run-level one across
  the full matrix (bare `--auto` + gate pass → allow; plain merge → ask; gate fail → deny),
  including under the 24h TTL. The emitted reason **names the active level** (`level: genesis`
  vs `level: run`) via the existing `$MODE_LEVEL` interpolation on the allow row — so the
  decision is identical and only the level token in the reason differs; today's run/feature
  emission is unchanged. The header contract's field documentation adds `"genesis"`.
- [auto] `scripts/guard-branch-rules.sh`: its duplicated reader accepts the same three values
  with the same fail-closed defects; genesis-level yields the same exit code as run-level across
  its matrix. Header contract updated identically.
- [auto] Both scripts remain safe under `set -euo pipefail` with quoted expansions; the level
  value is handled as data (never eval'd or interpolated into decision JSON);
  `scripts/check-neutral.sh` passes on both.

### Behavioral completeness
- [auto] `scripts/merge-guard.test.sh` extended: genesis-level fixture → the run-level decision
  word on each row (allow/ask/deny), with the emitted reason asserted to contain
  `level: genesis`; a bogus level (`"genesis "` with whitespace, `"Genesis"`, `"total"`) →
  treated absent; genesis + expired (>24h, fixture 25h) `created` → treated absent; the
  attended-marker precedence rows unchanged (mode active → marker ignored) with a genesis-level
  mode.
- [auto] `scripts/guard-branch-rules.test.sh` extended: genesis-level + bare `--auto` in build
  scope → today's run-level exit behavior; bogus/expired genesis fixtures → exit 2.
- [auto] `claude plugin validate --strict .` passes; every pre-existing self-test suite still
  passes.
- [runtime] In a fixture repo, a live guard invocation with a fresh genesis-level mode file and
  a gate-passing bare `gh pr merge <n> --auto` emits `allow`; the identical call with
  `level: "total"` emits `ask`. Deterministic core covered by the committed
  `scripts/merge-guard.test.sh` (named committed test).

## verification
verifier subagent against this file — the three-value whitelist and reject-everything-else in
both readers (exercised via the committed self-tests, never re-derived), genesis≡run decision
parity, TTL composition, and a no-eval / quoted-data review — **+ `/security-review` pre-pin**
(hard-invariant surface: a new accepted value on the field that unlocks merges. Adversarial
questions: can any non-whitelisted level, casing variant, or padded string reach the allow
row; does genesis parity hold under gate-fail and plain-merge shapes; do the TTL and
tracked-spoof rejections apply to genesis files identically across both scripts and both field
readers?).

verified: clean at 49b23ce, 2026-07-05, via two fresh-context verifier subagents (initial at 10af880 + a re-verify of the final SHA) — the three-value whitelist (feature|run|genesis, exact-match globs) and reject-everything-else in both merge-guard.sh (read_mode_file) and guard-branch-rules.sh (its duplicated reader); genesis≡run decision parity across the full matrix (bare --auto + gate pass → allow with the reason naming `level: genesis` via the UNCHANGED $MODE_LEVEL interpolation; plain merge → ask; gate fail → deny; guard-branch build-scope exit codes), under the 24h TTL; bogus levels ("genesis " whitespace, "Genesis" casing, "total") and expired (25h) genesis fixtures treated absent; attended-marker precedence with a genesis mode (marker ignored). No-eval / quoted-data review: the level flows json_str → exact-match case → MODE_LEVEL, never eval'd, never interpolated raw into decision JSON (emitted via jq --arg / json.dumps). Committed self-tests: merge-guard 97, guard-branch-rules 39, all 10 suites + check-neutral + attended-marker-parity (12) + `claude plugin validate --strict` green. **[runtime]** live-guard walk's deterministic core = the committed merge-guard.test.sh genesis allow/ask/deny rows (per this section; no live gh invocation required). **Pre-pin /security-review: NO findings** (>80% confidence) — a pure one-token widening of an exact-match whitelist, genesis handled byte-identically to run/feature, level provably one of three safe literals before emission, authenticity model (untracked-only / all-fields / 24h TTL / tracked-spoof) unchanged; the forged-mode-file residual is the pre-existing accepted one in specs/deferrals/mode-file-binding-ttl.md, not new. The review surfaced a three-reader parity gap (session-bootstrap.sh, the orientation reader, still on the feature|run whitelist) which was FOLDED INTO this branch at the user's decision — genesis added to its whitelist + a session-bootstrap.test.sh row (suite now 34), so all three mode-file readers stay in lockstep. (evidence: verifier + security reports in PR)
