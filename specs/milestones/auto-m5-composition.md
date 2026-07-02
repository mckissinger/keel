# Milestone — auto-m5-composition: the modes proven live, and no-mode proven unchanged

**Goal:** the shipped whole composes — a live walk in a fixture keel project proves the mode
file, the guard's `--auto` path, the preflight, the ledger, and the debrief contract work
together, and that a session with no mode file behaves exactly as before this feature.

**Feature:** `specs/features/autonomy-modes.md`. **No-UI** → two-dimension done-conditions.
**Depends on:** `auto-m2-mode-plumbing`, `auto-m3-envelope-preflight`, `auto-m4-skills`.
**Parallelizable:** no (tests the shipped whole).

## Done-conditions

### Logic / invariants
- [auto] All self-test suites green on the branch: merge-guard (incl. m2's mode + fail-closed
  cases), session-bootstrap (incl. mode-text cases), guard-branch-rules (unchanged),
  check-verified-pin (unchanged), check-auto-preflight, check-neutral, check-plan; plus
  `claude plugin validate --strict .`.

### Behavioral completeness — the composition walk
- [runtime] **Live composition walk** in a fixture keel project (scripted where possible;
  each assertion's deterministic core lives in the m2/m3 committed self-tests): (a) the mode
  file is written only via the human-invoked `keel:auto` skill and removed at run end; (b)
  with the mode active, a pinned gate-PASSING `gh pr merge --auto` is **allowed** and the PR
  lands when the required checks pass; (c) plain `gh pr merge` under the same mode still
  reaches the harness **ask**; (d) a gate-FAILING merge attempt is still **denied** with the
  gate's reason; (e) a session with no mode file shows today's behavior end-to-end (bootstrap
  text, ask-floor) — the no-mode regression; (f) `check-auto-preflight.sh` fails closed in
  the fixture when a required check is present-but-not-required, and passes after it is made
  required; (g) a would-be attended gate under the mode writes a ledger entry
  (file-per-entry under `specs/runs/<run-id>/`) instead of asking; (h) a build-session merge
  attempt still hard-blocks (guard-branch-rules composes with the mode).
- [attended] Walk transcript attached to the PR; any composition failure discovered here is
  a stop-point (fix rides this branch or bounces to the owning milestone) — never waved
  through.

## verification
verifier subagent against this file (suite runs + validate) + the [runtime]/[attended]
composition walk above, run serially in the verify session (it gates the pin — the walk's
transcript is the evidence). **`/security-review` pre-pin** — the walk exercises the full
allow path end-to-end; the review attacks the composed system (mode-file forgery from a
build session, `--auto` on an unpinned PR, ledger-as-cover-for-silent-deferral) before the
pin is written.

verified: clean at 6c2ca30, 2026-07-02, via fresh-context verifier subagent that RE-EXECUTED the [runtime] walk serially in its own fixture (not a transcript audit) — all eight assertions (a mode-file lifecycle, b --auto allow, c plain-merge ask, d gate-FAIL deny, e no-mode regression, f preflight fail-closed→pass, g committed ledger entry, h build-guard hard-block composes with the mode) reproduced byte-identical to the committed transcript against the real shipped scripts; all suites green (merge-guard 62, session-bootstrap 29, guard-branch-rules 16, check-verified-pin 17, check-auto-preflight 13, check-neutral 17, check-plan 18) + plugin validate --strict; diff vs main is specs/walks/** only; every stub disclosed. /security-review of the composed allow path PROCEED-with-follow-up: vectors (2) local-drift and (3) ledger-as-cover cleared (server-side required checks backstop drift; the ledger is in no decision path); one finding in m2's already-merged merge-guard (mode file trusted on existence + field-validity alone — no human-trigger binding, no expiry) is accepted here as consistent with the delegation doctrine (decisions/2026-07-autonomy-modes.md §(e): the mode unlocks only the --auto handoff; server-side required checks are the merge gate, not the mode file) and m2's prior clearance; the no-expiry/stale-file residual (already named at skills/auto/SKILL.md:33) is logged as a follow-up spec-change against merge-guard.sh, NOT a blocker for this prose+walk milestone. [attended] transcript attached to this PR. (evidence: walk transcript + verifier + security reports in PR)
