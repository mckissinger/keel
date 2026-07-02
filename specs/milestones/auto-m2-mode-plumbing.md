# Milestone — auto-m2-mode-plumbing: the mode signal and the guard's --auto path

**Goal:** the autonomy mode exists as mechanism — a run-scoped mode file with a defined
contract, a merge guard that maps gate-PASS + `--auto` to `allow` under an active mode (and
nothing else), and a session bootstrap whose injected invariants match the active mode
instead of contradicting it.

**Feature:** `specs/features/autonomy-modes.md`. **No-UI** → two-dimension done-conditions.
**Depends on:** `auto-m1-doctrine`. **Parallelizable:** with m3 (disjoint files).

## Done-conditions

### Logic / invariants
- [auto] The **mode-file contract** is documented in one place (a comment header in
  `scripts/merge-guard.sh`, the reading owner): path `.claude/keel-autonomy.json`; fields
  `level` (`feature`|`run`), `scope`, `created`, `invoker`; untracked (never committed);
  written only by the human-triggered `keel:auto` skill; cleared at run end. A malformed or
  unreadable mode file is treated as **no mode** (fail closed to today's behavior).
- [auto] `scripts/merge-guard.sh`: with a valid mode file present, a merge-shaped command that
  is `gh pr merge` **with `--auto`** and whose `check-verified-pin.sh` gate PASSES maps to
  `permissionDecision: "allow"`. Everything else is byte-for-byte today's decision table:
  plain `gh pr merge` (no `--auto`) → `ask` even under a mode; gate FAIL → `deny` with the
  gate's stderr; no mode file → the existing ask-floor; unresolvable context → `ask`.
  Covered by new cases in `scripts/merge-guard.test.sh`.
- [auto] `scripts/session-bootstrap.sh`: with a valid mode file present, the injected
  orientation replaces the "Never merge; the user reviews and merges" line with the
  mode framing (merge authority delegated to required checks via `--auto` per the decisions
  entry; ledger every would-be ask to `specs/runs/<run-id>/`; stop-points still halt) and
  names the active level + scope. No mode file → today's text unchanged. Covered by new
  cases in `scripts/session-bootstrap.test.sh`.
- [auto] `scripts/guard-branch-rules.sh` is untouched vs `main` — build sessions hard-block
  merges regardless of mode.

### Behavioral completeness
- [auto] Fail-closed matrix in `merge-guard.test.sh`: mode file missing / malformed JSON /
  unknown `level` / `--auto` absent / gate FAIL — each yields the pre-mode behavior (ask or
  deny), never `allow`.
- [auto] All existing self-test cases in both touched suites still pass unmodified (no-mode
  regression: today's behavior is the default path).
- [auto] `scripts/check-neutral.sh` exits 0 (both scripts are scanned corpus).

## verification
verifier subagent against this file + `scripts/merge-guard.test.sh` +
`scripts/session-bootstrap.test.sh` (new and existing cases) + `scripts/check-neutral.sh` +
`scripts/check-plan.sh`. **`/security-review` pre-pin** — this milestone touches the merge
gate (a hard invariant): the review attacks the `allow` path (mode-file spoofing, `--auto`
string evasion, gate-bypass composition); confirmed findings become test cases +
done-conditions before the pin. No UI surface → no runtime walk (the live composition proof
is m5's).
