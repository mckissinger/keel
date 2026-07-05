# Milestone — auto-hardening-m1-guards: marker TTLs + the auto-merge repo assertion

**Goal:** a stale autonomy mode file or attended-merge marker is treated as absent by both merge
guards (fail closed, no new writer path), and the auto preflight fails before launch when the
repo cannot honor `gh pr merge --auto`.

**Feature:** `specs/features/auto-hardening.md`. **No-UI** → two-dimension done-conditions.
**Parallelizable:** no (m2 follows; the auto-genesis feature's guard milestone builds after this
lands).

## The TTL contract (guards are the enforcement point)

- **Autonomy mode file** (`.claude/keel-autonomy.json`): valid only while `created` is within
  **24 hours** of now. **Attended marker** (`.claude/keel-attended-merge.json`): within
  **8 hours**.
- Age is computed from the `created` field parsed **as data** (same jq/python3 field-reader
  discipline as the existing contract); a `created` value that cannot be parsed as a timestamp →
  the file is invalid → treated absent (fail closed), same as any other field defect today.
- An expired file changes **no other row** of either decision matrix: expired ≡ absent,
  byte-for-byte.
- **No refresh path.** The writing skill (`keel:auto` / `keel:auto-merge`) stays each file's only
  writer; nothing extends a marker's life except a fresh human invocation. The run-binding half
  of `specs/deferrals/mode-file-binding-ttl.md` stays deferred.

## Done-conditions

### Logic / invariants
- [auto] `scripts/merge-guard.sh`: both readers (`read_mode_file`, `read_attended_marker`)
  reject a file whose `created` is older than its TTL (24h mode / 8h marker) or unparseable —
  the file is then treated exactly as absent (existing ask/deny/allow matrix unchanged). TTL
  math never shells out to `eval`; `created` stays data. Both script header contracts document
  the TTL and the expired≡absent rule.
- [auto] `scripts/guard-branch-rules.sh`: its duplicated readers enforce the same TTLs with the
  same fail-closed defects (per the self-contained-hook idiom), and an expired marker/mode file
  leaves the exit-2 matrix byte-for-byte at today's no-marker behavior.
- [auto] `scripts/check-auto-preflight.sh` gains check (d): `gh api` on the repo asserts
  `allow_auto_merge` is `true`; `false`/missing/API-error → FAIL with a fix line naming the
  attended remedy (repo settings or `gh api -X PATCH`). Runs after the existing (a)–(c); the
  script stays fail-closed when `gh`/`jq` are missing.
- [auto] Both guard scripts and the preflight stay safe under `set -euo pipefail` with quoted
  expansions; `scripts/check-neutral.sh` passes on all changed scripts.
- [auto] `skills/auto/SKILL.md` and `skills/auto-merge/SKILL.md` state their file's TTL (24h /
  8h) in the marker-writing step, and `scripts/check-skill-frontmatter.sh` still passes.
- [auto] `specs/deferrals/mode-file-binding-ttl.md` is updated in place: the TTL half is marked
  resolved by this milestone (with the two TTL values), the run-binding half explicitly remains
  deferred with its original rationale.

### Behavioral completeness
- [auto] `scripts/merge-guard.test.sh` extended: fresh-marker fixtures still produce today's
  allow/ask/deny outcomes; a mode file aged past 24h and an attended marker aged past 8h each →
  treated absent (the no-marker matrix governs); a marker just inside its TTL → still active; an
  unparseable `created` → treated absent; the header-doc tripwire asserts the TTL is documented.
- [auto] `scripts/guard-branch-rules.test.sh` extended: expired mode file + bare `--auto` in
  build scope → exit 2; expired attended marker + bare `--auto` → exit 2; fresh equivalents
  preserve today's exit-0 defer rows.
- [auto] `scripts/attended-marker-parity.test.sh` extended with an expired-marker fixture: both
  scripts reach the same conclusion (gate) across the jq and python3 readers.
- [auto] The preflight self-test covers check (d): a stubbed `gh` reporting
  `allow_auto_merge: true` → PASS; `false` → FAIL naming the fix; API error → FAIL (fail
  closed).
- [auto] `claude plugin validate --strict .` passes and every pre-existing self-test suite still
  passes.
- [runtime] In a fixture repo, a mode file written with `created` backdated 25h is refused by a
  live `gh pr merge <n> --auto` guard invocation (decision `ask`, not `allow`); the identical
  file with a fresh `created` produces `allow`. Deterministic core covered by the committed
  `scripts/merge-guard.test.sh` (named committed test).

## verification
verifier subagent against this file — TTL enforcement and expired≡absent in both scripts'
readers (exercised via the committed self-tests, never re-derived), the preflight (d) check and
its fail-closed posture, the no-new-writer invariant (no refresh path added anywhere), and a
no-eval / quoted-data review of the TTL math — **+ `/security-review` pre-pin** (hard-invariant
surface: marker lifetime bounds a merge unlock. Adversarial questions: can a crafted `created`
— future-dated, non-ISO, huge, negative — extend a marker's life or crash a reader open; does
expiry hold across both scripts and both field readers; is today's fresh-marker behavior
byte-identical?).
