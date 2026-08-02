# Milestone — committed-auto-merge-marker: a committable per-project marker the guards honor

**Goal:** a keel repo can carry a **committed** `.claude/keel-auto-merge.json` that arms
`gh pr merge --auto` for every session — and (a) it can *land under the full protection contract*
(the pin gate treats it as a plan path, so arming is a plan-only PR), and (b) both merge guards
**honor it** with a new committed-project row whose precedence is `mode > attended > committed`. This
is the primitive the whole feature stands on; nothing else in the feature is committable or honored
until it lands.

**Feature:** `specs/features/per-project-auto-merge.md`. **No-UI** → two-dimension done-conditions
(logic/invariants + behavioral completeness). **Depends on:** nothing (foundational). **Parallelizable:**
no (M2/M3/M4 all depend on it). **Routing:** reasoning-heavy — it edits **two** hard-invariant gates
(`check-verified-pin.sh` and `merge-guard.sh`/`guard-branch-rules.sh`); wrong wording here either lets
code land unpinned or lets an agent self-arn a merge. Dispatch the verifier at `xhigh`.

## The marker-shape decision (author it first, this milestone)

Write **`decisions/2026-08-02-committed-auto-merge-marker.md`** (new, append-only) recording the
resolved fork: the committed marker is **`.claude/keel-auto-merge.json`** and
`check-verified-pin.sh`'s `is_plan_path()` gains it as a **plan-path carve-out** (so arming is a
plan-only PR that lands under protection with no pin), with the rationale — a `verified:` pin proves
*unwatched* verification, arming is human-attended by construction, so the arming skill's live
protection-assertion is the right proof and the required-checks floor guards every subsequent merge —
and the two rejected alternatives (chore-lane pin; relocate to `specs/`). This entry is the reviewed
record for the pin-gate carve-out below; the carve-out and the entry land together.

## Done-conditions

### Logic / invariants

- [auto] **The committed-marker contract is documented as a header block in
  `scripts/merge-guard.sh`** (the reading owner, mirroring the existing attended-merge-marker
  contract at ~L113-155): path `.claude/keel-auto-merge.json` under `CLAUDE_PROJECT_DIR`; required
  fields — `scope` MUST equal `"project"` (any other value → invalid → treated as NO marker, fail
  closed), `created` (ISO-8601 UTC, parsed **as data**, never eval'd), `invoker` (who armed it); all
  required, non-empty strings; **any defect → treated as absent, fail closed**. Unlike the attended
  marker the file is **git-tracked** (that is the whole point — it is the committed, per-project
  variant), so the tracked-copy-is-a-spoof rule that the untracked markers carry is **explicitly
  inverted here and the difference is stated**: for this marker the tracked file *is* the
  authorization, written only by the M2 arming skill. **No TTL** — a committed setting does not expire
  (contrast the attended marker's 8h and the mode file's 24h); the header states this and states that
  the marker's only writer/remover is the arming skill.
- [auto] **`scripts/check-verified-pin.sh` `is_plan_path()` treats `.claude/keel-auto-merge.json` as
  a plan path** — a `case` arm returning 0 for exactly that path (not a `.claude/*` wildcard: only
  this one file), placed and commented as the mirror of the existing
  `specs/stack-profile.md|specs/run-command-inventory.txt` code-not-plan carve-out. Consequence,
  asserted by a test: a PR whose diff is only `.claude/keel-auto-merge.json` is **plan-only → exempt
  → pass**; a PR mixing it with a real code file is still a code PR and still needs a pinned spec (the
  carve-out widens the plan set by exactly one file, nothing more).
- [auto] **`scripts/merge-guard.sh` `decide()` gains a committed-project row** below the mode row and
  the attended row (~L664-680), reached **only when** `MODE_ACTIVE=0` **and** `ATTENDED_ACTIVE=0`
  **and** a valid committed marker is present **and** `AUTO_MERGE=1` **and** `SHAPE="gh-pr-merge"`
  **and** the gate passed: it emits `allow` for the canonical bare `gh pr merge <pr> --auto` shape,
  with a message naming the committed per-project marker and the required-checks delegation. The
  precedence is **mode > attended > committed** — a valid mode file or a valid attended marker makes
  the committed row unreached (guarded by `MODE_ACTIVE=0 && ATTENDED_ACTIVE=0`). **Everything else is
  byte-for-byte today's table**: plain `gh pr merge` without `--auto` stays `ask`; gate FAIL stays
  `deny`; `git merge`/`git push` to the default branch stay `ask`; unresolvable context stays `ask`.
  The **same closed-set `detect_strict_auto` shape whitelist and the bare/un-chained emission
  discipline** as the mode/attended rows apply — a bundled/chained `--auto` forfeits the allow back to
  `ask`.
- [auto] **The `d_auto` variable-binding tripwire is preserved and extended:** the committed row binds
  its decision word through the same `d_auto="allow"` variable (never a bare `emit allow` literal), so
  `scripts/merge-guard.test.sh`'s static scan against an unconditional allow literal stays live and
  now covers three rows.
- [auto] **A committed-marker reader is added** (`read_committed_marker`, mirroring
  `read_attended_marker`): STRING-TYPED field reads (jq `select(type)` / python3 `isinstance`, so a
  wrong-typed field reads as absent), the marker text parsed **as data** (`json_str`, never eval'd),
  `scope != "project"` or any missing/empty field → `COMMITTED_ACTIVE=0` (fail closed). It sets a
  `COMMITTED_ACTIVE` flag consumed by `decide()`.
- [auto] **`scripts/guard-branch-rules.sh` gains the committed-project defer row** mirroring its
  existing attended exception (~L510-525): when a build session emits the canonical bare
  `gh pr merge <pr> --auto` **and** no active mode **and** no attended marker **and** a valid
  committed marker → `exit 0` (defer the gate decision to `merge-guard.sh`, which fires on the same
  Bash call), same precedence `mode > attended > committed`. Every other build-session merge/commit
  path is unchanged (still `exit 2` — build sessions never merge on their own).

### Behavioral completeness

- [auto] **Every affected self-test suite passes with new cases proving the new behavior, and every
  existing expectation still holds:**
  - `scripts/check-verified-pin.test.sh` — a case where the sole changed file is
    `.claude/keel-auto-merge.json` → exempt/pass; a case mixing it with a code file → still fails for
    the unpinned code file (the carve-out did not widen to the code file).
  - `scripts/merge-guard.test.sh` — committed marker present + bare `--auto` + gate pass → `allow`;
    committed + gate FAIL → `deny`; committed + plain `gh pr merge` (no `--auto`) → `ask`; committed +
    **bundled/chained** `--auto` → `ask` (whitelist forfeit); **precedence**: mode+committed → mode
    message, attended+committed → attended message, committed-only → committed message; invalid
    committed marker (wrong `scope`, missing field, malformed JSON) → treated as absent (`ask` floor);
    the `d_auto` static tripwire updated to expect three variable-bound rows.
  - `scripts/guard-branch-rules.test.sh` — committed marker + bare `--auto` + no mode + no attended →
    `exit 0` (defer); committed + any non-`--auto` merge → `exit 2`; precedence cases mirror
    merge-guard's.
  - The committed marker is a **valid, real** fixture in these tests (`scope: "project"`, all fields),
    distinct from the attended fixture.
- [auto] **All other script self-test suites, and every repo lint, pass unchanged:**
  `check-neutral.sh`, `check-skill-frontmatter.sh`, `check-skill-anchors.sh`, `check-plan.sh`,
  `check-auto-preflight.test.sh`, and `claude plugin validate --strict .` all green (this milestone
  touches none of their inputs).
- [auto] **No unowned surface moved:** `git diff --stat` for this milestone is confined to
  `scripts/check-verified-pin.sh`(+`.test.sh`), `scripts/merge-guard.sh`(+`.test.sh`),
  `scripts/guard-branch-rules.sh`(+`.test.sh`), `decisions/2026-08-02-committed-auto-merge-marker.md`,
  and this milestone spec (its pin). `session-bootstrap.sh`, `template-contract.md`, the deferral, the
  arming skill, and `implement-feature` are **out of scope** here (M2/M3/M4 own them) and have empty
  diffs.

## verification

verifier subagent against this file — every `[auto]` condition checked with `file:line` evidence: the
marker contract header field-by-field (tracked-not-untracked difference stated, no-TTL stated,
fail-closed on every defect), the `is_plan_path` carve-out is exactly one file (not a wildcard) with
its plan-only/mixed-PR test pair, the `decide()` committed row's five-way guard + precedence + the
whitelist forfeit, the `d_auto` tripwire covering three rows, the `read_committed_marker` fail-closed
typing, the guard-branch-rules defer row + precedence, and the confined diff. Suites run, not
re-derived. **Dispatch the verifier at `xhigh`** (two hard-invariant gates). **`/security-review` of
the milestone's diff is a pre-pin precondition** — the adversarial question: does the plan-path
carve-out open any path for a *code* file to land unpinned (it must widen the plan set by exactly one
named file), and does the committed row let an agent self-arm or let a non-canonical/bundled `--auto`
land (it must not); confirmed findings remediated before the pin.
