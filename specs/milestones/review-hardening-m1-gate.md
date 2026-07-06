# Milestone — review-hardening-m1-gate: the pin gate fails closed everywhere; the guards agree on fail direction

**Goal:** `check-verified-pin.sh` fails closed when no merge base exists (the reproduced
shallow-clone/orphan-history pass-open); runtime-affecting spec files stop riding the
plan-only exemption; `guard-branch-rules.sh` treats missing JSON readers the way
`merge-guard.sh` does (closed, not open); and the known classifier bypasses become asserted
test cases instead of folklore.

**Feature:** `specs/features/review-hardening.md`. **No-UI** → two-dimension
done-conditions. **Parallelizable:** no (m2 → m3 follow).

## The contract changes

- **Merge-base presence is a step-0-class precondition.** Before the three-dot diff, the
  gate verifies a merge base exists between `BASE_REF` and `HEAD_REF` (e.g.
  `git merge-base` succeeds); absence → FAIL with a message naming the two refs and the
  likely cause (shallow clone / unrelated histories) and the fix (`fetch-depth: 0` /
  full fetch). The diff's own failure must never be readable as "no changes".
- **Runtime-affecting spec files are code, not plan.** `specs/stack-profile.md` and
  `specs/run-command-inventory.txt` are excluded from `is_plan_path`: a PR touching either
  is not plan-only (it needs a pinned milestone or chore-batch spec — the punch-list chore
  lane covers small config changes), and a post-pin edit to either counts as drift. All
  other `specs/**` paths keep today's plan classification.
- **The branch guard degrades closed.** Today `guard-branch-rules.sh` exits 0 (open) at
  hook-input parsing when neither `jq` nor `python3` is available — before any
  classification or marker read. After this milestone a reader-less environment cannot
  silently allow a merge-shaped or commit-shaped command: the guard falls back to a raw
  scan of the hook input (the `merge-guard.sh` degrade precedent at its own reader-less
  branch) and blocks (exit 2) when the raw text carries a merge/commit shape, allowing
  only inputs the scan finds benign. Marker files are unreadable without a JSON reader and
  are therefore treated as absent, as they already are. `merge-guard.sh`'s own degrade
  direction (ask, never allow) is unchanged.
- **Accepted bypasses are asserted, not closed.** `sh -c '…'` / `eval "…"` / piped-`xargs`
  merge shapes are out of classification reach by design (the guards are text classifiers;
  branch protection + required checks are the authority). The self-test asserts today's
  behavior on those shapes so a future edit that silently changes it fails the suite. No
  new classification is added; the header-prose documentation of these limits is **m2's**
  (m2 owns all header comment blocks this feature touches).

## Done-conditions

### Logic / invariants

- [auto] `scripts/check-verified-pin.sh`: with `BASE_REF` and `HEAD_REF` both resolvable
  but sharing no merge base, the gate exits non-zero with a FAIL message naming both refs
  and the shallow-clone/unrelated-histories cause — never "no changes — pass". With a merge
  base present, all currently-passing fixtures still pass byte-for-byte on verdict.
- [auto] `scripts/check-verified-pin.sh`: a PR whose only change is
  `specs/stack-profile.md` or `specs/run-command-inventory.txt` is NOT exempt as plan-only
  (the gate proceeds to the pin requirement); a post-pin edit to either file lands in the
  drift set and fails the pin check; a PR touching only other `specs/**`/`design/**`/
  `decisions/**`/`deferrals/**` paths remains exempt exactly as today.
- [auto] `scripts/guard-branch-rules.sh`: with both `jq` and `python3` absent from PATH,
  the guard no longer exits 0 at input parsing — a hook input whose raw text carries a
  merge shape or a commit shape is blocked (exit 2) by the fallback raw scan, and a
  clearly benign input (e.g. `ls`) still exits 0; with either reader present, every
  existing fixture's exit code is unchanged. The fallback never parses JSON and never
  `eval`s the input.
- [auto] `scripts/merge-guard.sh` is byte-identical to its pre-milestone state — this
  milestone adds assertions about it (in its test suite) and changes to
  `guard-branch-rules.sh` only; all header-prose updates are m2's.
- [auto] All changed scripts stay safe under `set -euo pipefail` with quoted expansions;
  `scripts/check-neutral.sh` passes on all changed scripts; no `eval`, no interpolated
  command text.

### Behavioral completeness

- [auto] `scripts/check-verified-pin.test.sh` extended: a fixture reproducing the review's
  live repro — orphan-history branch carrying code + an unpinned milestone spec — now FAILS
  (was: passed open); a resolvable-refs-no-merge-base fixture FAILS with the naming
  message; a stack-profile-only PR fixture requires a pin; a run-command-inventory-only PR
  fixture requires a pin; a decisions-only PR fixture stays exempt; every pre-existing
  fixture keeps its verdict.
- [auto] `scripts/guard-branch-rules.test.sh` extended: a PATH stripped of both `jq` and
  `python3` + a hook input carrying `git commit` on the default branch → exit 2 (raw-scan
  fallback); same PATH + a merge-shaped hook input → exit 2; same PATH + a benign hook
  input → exit 0; jq-present and python3-present equivalents keep today's exits, including
  the fresh-marker rows.
- [auto] `scripts/merge-guard.test.sh` extended with accepted-bypass assertions:
  `sh -c 'gh pr merge 5'`, `bash -lc 'gh pr merge 5'`, `eval "gh pr merge 5"`, and
  `echo 5 | xargs gh pr merge` each produce today's unclassified outcome (documented in
  the test as the accepted limit, not a target to close) — so any future classification
  change on these shapes is a conscious suite edit, never silent.
- [auto] Every pre-existing self-test suite still passes
  (`check-verified-pin`, `merge-guard`, `guard-branch-rules`, `attended-marker-parity`,
  `session-bootstrap`, `check-auto-preflight`, `check-plan`, `check-neutral`,
  `check-skill-frontmatter`, `check-skill-anchors`) and
  `claude plugin validate --strict .` passes.
- [runtime] In a throwaway fixture repo whose local history holds two **disconnected**
  shallow tips (base and PR head each fetched with `--depth 1` from a remote where they
  have diverged by more than one commit — so no merge base exists locally; a plain
  `git clone --depth 1` + local branch does NOT produce this state, since the shallow tip
  is then its own merge base), a live `BASE_REF=… scripts/check-verified-pin.sh` invocation
  FAILS closed naming both refs and the shallow-clone/unrelated-histories cause; after a
  full fetch of the same refs (`git fetch --unshallow` or equivalent), the same invocation
  proceeds past the merge-base precondition, its verdict then governed by the ordinary pin
  rules. Deterministic core covered by the committed `scripts/check-verified-pin.test.sh`
  (named committed test).

## verification

verifier subagent against this file — the no-merge-base fail-closed path (exercised via the
committed self-tests, including the reproduced orphan-history fixture, never re-derived),
the plan-exemption carve-out's three-way behavior (exempt / pin-required / drift), the
branch guard's reader-less fail-closed parity, the merge-guard byte-identity claim, and a
no-eval / quoted-data review of every changed line — **+ `/security-review` pre-pin**
(hard-invariant surface: this is the merge gate itself. Adversarial questions: can any ref
pair reach the "no changes — pass" exit without a verified merge base; can a crafted path
smuggle `stack-profile.md` back into the plan class (case, nesting, rename); can any
merge- or commit-shaped hook input slip past the reader-less raw-scan fallback with exit
0; do the bypass assertions
actually pin today's behavior or just echo it?).
