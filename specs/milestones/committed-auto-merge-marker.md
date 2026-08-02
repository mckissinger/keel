# Milestone — committed-auto-merge-marker: a committable per-project marker the guards honor

**Goal:** a keel repo can carry a **committed** `.claude/keel-auto-merge.json` that arms
`gh pr merge --auto` for every session — and (a) it can *land under the full protection contract*
(the pin gate treats it as a plan path, so arming is a plan-only PR), and (b) both merge guards
**honor it** with a new committed-project row whose precedence is `mode > attended > committed`. This
is the primitive the whole feature stands on; nothing else in the feature is committable or honored
until it lands.

**The root of trust that makes "committed" real (closes the two adversarial-pass blockers).** The
guards honor the marker **only when it is present on the default branch (`main`)**, read via git
(`git show <default-branch-ref>:.claude/keel-auto-merge.json` as data) — never from the working tree.
`main` advances **only** by a human-merged PR (the standing never-commit-to-`main` invariant + branch
protection), so presence-on-`main` *is* the authorization trail: an agent that merely `Write`s the
file locally (or commits it on a branch) has an untracked / not-on-`main` file the guards **ignore**.
And a merge-shaped command whose target PR **touches `.claude/keel-auto-merge.json`** is **never
auto-merged** — it forces the per-merge human tap regardless of any active marker or mode — so no
*temporary* authority (an 8h attended marker, a 24h mode) can auto-land the *permanent* marker's own
PR. Together these move "the agent never self-arms" from a prose promise to a **mechanical control** —
raising the bar from a plain-file `Write` (which these ignore) to forging the local default-branch ref
itself (`git update-ref` / `git branch -f`, which are not merge/push/commit-shaped and so pass both
guards' classifiers). That ref-forgery residual is **named, not hidden**: it is the same threat model
the existing untracked markers already carry, and the **required-checks floor on the protected branch
remains the real backstop** — nothing lands that the three checks did not pass, self-armed or not.
This is what the plan-pass flagged prose alone as missing.

**Feature:** `specs/features/per-project-auto-merge.md`. **No-UI** → two-dimension done-conditions
(logic/invariants + behavioral completeness). **Depends on:** nothing (foundational). **Parallelizable:**
no (M2/M3/M4 all depend on it). **Routing:** reasoning-heavy — it edits **two** hard-invariant gates
(`check-verified-pin.sh` and `merge-guard.sh`/`guard-branch-rules.sh`); wrong wording here either lets
code land unpinned or lets an agent self-arm a merge. Dispatch the verifier at `xhigh`.

## The marker-shape decision (author it first, this milestone)

Write **`decisions/2026-08-02-committed-auto-merge-marker.md`** (new, append-only) recording the
resolved fork: the committed marker is **`.claude/keel-auto-merge.json`** and
`check-verified-pin.sh`'s `is_plan_path()` gains it as a **plan-path carve-out** (so arming is a
plan-only PR that lands under protection with no pin), with the rationale — a `verified:` pin proves
*unwatched* verification, arming is human-attended by construction, so the arming skill's live
protection-assertion is the right proof and the required-checks floor guards every subsequent merge —
and the two rejected alternatives (chore-lane pin; relocate to `specs/`). The entry must **confront
the pin gate's own stated classification principle** it appears to violate:
`check-verified-pin.sh:50-51`'s existing carve-out comments "runtime-affecting spec files are code,
not plan," yet this marker is runtime-affecting (both guards decide on it) and is nonetheless treated
as *plan*. Record why that is coherent, not a contradiction: the marker carries **no code**, so a
`verified:` pin (a code-verification instrument) has nothing to verify; its *authority* is gated
elsewhere and more strongly — by the human-merge-tap rule on any marker-touching PR (below) plus the
required-checks floor — so exempting it from the pin gate removes a useless instrument, not a control.
**Explicitly accept the drift-window consequence:** because plan paths are skipped by the post-pin
drift check, a marker file riding inside a pinned *code* PR's window would be invisible to that check
— the human-tap rule closes it (that same PR touches the marker, so it is never auto-merged and a
human sees it), and the entry states this. This entry is the reviewed record for the pin-gate
carve-out below; the carve-out and the entry land together.

## Done-conditions

### Logic / invariants

- [auto] **The committed-marker contract is documented as a header block in
  `scripts/merge-guard.sh`** (the reading owner, mirroring the existing attended-merge-marker
  contract at ~L113-155): path `.claude/keel-auto-merge.json` under `CLAUDE_PROJECT_DIR`; required
  fields — `scope` MUST equal `"project"` (any other value → invalid → treated as NO marker, fail
  closed), `created` (ISO-8601 UTC, parsed **as data**, never eval'd), `invoker` (who armed it); all
  required, non-empty strings; **any defect → treated as absent, fail closed**. **The root of trust is
  presence on the default branch, not the working tree:** the marker is honored **only** as read from
  the **default-branch ref proper** — `origin/$DEFAULT_BRANCH` (the `detect_default_branch` result,
  the same ref `check-verified-pin.sh` treats as `main`), via
  `git show "origin/$DEFAULT_BRANCH:.claude/keel-auto-merge.json"` parsed as data. **It is emphatically
  NOT `BASE_REF_R`** — that variable is the *target PR's base branch* (resolved from
  `gh pr view --json baseRefName`), which under the stacked-PR choreography is a **sibling milestone
  branch**, not `main`; reading from it would honor a marker an agent planted on a lower stack branch
  (the very forgery this root of trust exists to block). A working-tree copy, a branch-only commit, or
  an untracked file that is **not on the default branch** is **ignored**. Mirror
  `check-verified-pin.sh`'s step-`-1` **best-effort refresh** of the default-branch remote ref before
  the read (a failed fetch warns and proceeds with the local image — never a hard failure), so a
  human's disarm on real `main` is seen without an indefinite stale-clone honor window; the residual
  (a clone that never fetches at all) is named, not silently assumed away. This **inverts** the
  untracked-markers' rule deliberately and the header states the difference and why: the untracked
  attended/mode markers are spoofable-if-tracked, so they are honored only untracked; this marker is
  the opposite — its authorization *is* the git history of the default branch (which advances only by
  a human-merged PR), so it is honored only when committed there. **No TTL** — a committed setting does
  not expire (contrast the attended marker's 8h and the mode file's 24h); this is safe **because** the
  read-from-default-branch root of trust means the marker got there through a human-merged PR, not
  because an unexpiring local file is trusted. The header states that the marker's only writer/remover
  is the M2 arming skill and that any PR touching the marker is never auto-merged (the human-tap rule
  below).
- [auto] **`scripts/check-verified-pin.sh` `is_plan_path()` treats `.claude/keel-auto-merge.json` as
  a plan path** — a `case` arm returning 0 for exactly that path (not a `.claude/*` wildcard: only
  this one file), placed and commented as the mirror of the existing
  `specs/stack-profile.md|specs/run-command-inventory.txt` code-not-plan carve-out. Consequence,
  asserted by a test: a PR whose diff is only `.claude/keel-auto-merge.json` is **plan-only → exempt
  → pass**; a PR mixing it with a real code file is still a code PR and still needs a pinned spec (the
  carve-out widens the plan set by exactly one file, nothing more).
- [auto] **`scripts/merge-guard.sh` `decide()` gains a committed-project row** below the mode row and
  the attended row (~L664-680), reached **only when** `MODE_ACTIVE=0` **and** `ATTENDED_ACTIVE=0`
  **and** `COMMITTED_ACTIVE=1` (a valid marker present on `main`) **and** the PR does **not** touch the
  marker file (the human-tap rule above) **and** `AUTO_MERGE=1` **and** `SHAPE="gh-pr-merge"` **and**
  the gate passed: it emits `allow` for the canonical bare `gh pr merge <pr> --auto` shape,
  with a message naming the committed per-project marker and the required-checks delegation. The
  precedence is **mode > attended > committed** — a valid mode file or a valid attended marker makes
  the committed row unreached (guarded by `MODE_ACTIVE=0 && ATTENDED_ACTIVE=0`). **Everything else is
  byte-for-byte today's table**: plain `gh pr merge` without `--auto` stays `ask`; gate FAIL stays
  `deny`; `git merge`/`git push` to the default branch stay `ask`; unresolvable context stays `ask`.
  The **same closed-set `detect_strict_auto` shape whitelist and the bare/un-chained emission
  discipline** as the mode/attended rows apply — a bundled/chained `--auto` forfeits the allow back to
  `ask`.
- [auto] **The `d_auto` variable-binding tripwire is preserved:** the committed row binds its decision
  word through the same `d_auto="allow"` variable (never a bare `emit allow` literal), so
  `scripts/merge-guard.test.sh`'s existing **negative** static scan (no bare unconditional `allow`
  literal in `decide()`) stays green with the third row added — the scan is unchanged; the new row
  must simply keep using the variable binding so the scan still finds no bare literal.
- [auto] **A committed-marker reader is added to BOTH guard scripts** (`read_committed_marker` in
  `scripts/merge-guard.sh` and its sibling copy in `scripts/guard-branch-rules.sh` — the same
  two-copy pattern the scripts already use for `read_attended_marker`), mirroring
  `read_attended_marker`: STRING-TYPED field reads (jq `select(type)` / python3 `isinstance`, so a
  wrong-typed field reads as absent), the marker text — **read from `origin/$DEFAULT_BRANCH` via
  `git show`, never the working-tree file and never `BASE_REF_R`** — parsed **as data** (`json_str`,
  never eval'd), `scope != "project"` or any missing/empty field or a marker absent from the default
  branch → `COMMITTED_ACTIVE=0` (fail closed). It sets a `COMMITTED_ACTIVE` flag consumed by each
  script's decision path. (`guard-branch-rules.sh` already carries `detect_default_branch`; it needs
  no `gh` machinery for this read.) **Repo context (the milestone-#187 split):** the *file path*
  `.claude/keel-auto-merge.json` stays ROOT-rooted (markers are project assets, like the attended
  marker), but the `git show "origin/$DEFAULT_BRANCH:<path>"` read runs against **`GIT_CTX`** — the
  same checkout `decide()` judges and where `DEFAULT_BRANCH` is detected — so the honor decision
  reflects the git state of the repo the merge command runs in. State this ROOT-path / GIT_CTX-git-
  state split explicitly in both readers so a builder does not read from the wrong repo.
- [auto] **Any merge-shaped command whose target PR touches the marker file is never auto-merged** —
  the human-tap rule that blocks a *temporary* authority from auto-landing the *permanent* marker.
  **This check lives only in `merge-guard.sh` `decide()`** (which already resolves the PR's base/head
  refs): compute the PR's changed files with the **non-truncating** `git diff --name-only
  "$BASE_REF_R"..."$HEAD_REF_R"` (NOT `gh pr view --json files`, which truncates on large PRs and
  would let a padded marker-touching PR evade the control); if that list **includes**
  `.claude/keel-auto-merge.json`, or if the file list **cannot be determined** (diff error), the
  decision is **`ask`** — before and regardless of the mode/attended/committed allow rows, fail closed.
  So arming or disarming always takes a human merge tap. **`guard-branch-rules.sh` needs no file-list
  check of its own:** on a valid committed marker + bare `--auto` it `exit 0`-defers (below), and
  `merge-guard.sh` — firing on the same Bash call — applies this human-tap rule and emits `ask` for a
  marker-touching PR. This keeps the `gh`-dependent file-list logic in the one guard that already has
  PR-context resolution.
- [auto] **`scripts/guard-branch-rules.sh` gains the committed-project defer row** mirroring its
  existing attended exception (~L510-525): when a build session emits the canonical bare
  `gh pr merge <pr> --auto` **and** no active mode **and** no attended marker **and** a valid
  committed marker (present on `origin/$DEFAULT_BRANCH`) → `exit 0` (defer the gate decision to
  `merge-guard.sh`, which fires on the same Bash call and owns both the gate-pass check and the
  human-tap rule), same precedence `mode > attended > committed`. It does **not** itself inspect the
  PR's files — deferral hands that to `merge-guard.sh`, so a marker-touching PR still resolves to
  `ask` there. Every other build-session merge/commit path is unchanged (still `exit 2` — build
  sessions never merge on their own).

### Behavioral completeness

- [auto] **Every affected self-test suite passes with new cases proving the new behavior, and every
  existing expectation still holds:**
  - `scripts/check-verified-pin.test.sh` — a case where the sole changed file is
    `.claude/keel-auto-merge.json` → exempt/pass; a case mixing it with a code file → still fails for
    the unpinned code file (the carve-out did not widen to the code file).
  - `scripts/merge-guard.test.sh` — committed marker **on `main`** + bare `--auto` + gate pass →
    `allow`; committed + gate FAIL → `deny`; committed + plain `gh pr merge` (no `--auto`) → `ask`;
    committed + **bundled/chained** `--auto` → `ask` (whitelist forfeit); **precedence**:
    mode+committed → mode message, attended+committed → attended message, committed-only → committed
    message; invalid committed marker (wrong `scope`, missing field, malformed JSON) → treated as
    absent (`ask` floor); **root-of-trust**: a marker present only in the **working tree / not on the
    default branch** → treated as absent (`ask` floor); **human-tap rule**: a PR whose diff touches
    `.claude/keel-auto-merge.json` → `ask` even with a valid committed marker and a passing gate — and
    **the escalation case the rule exists for**: a marker-touching PR under an active **mode** or a
    valid **attended** marker → still `ask` (the tap fires *before and regardless of* every allow row),
    and an **indeterminate file list** (diff error) → `ask` (fail closed); the `d_auto` negative static
    tripwire still green with the third row present.
  - `scripts/guard-branch-rules.test.sh` — committed marker on the default branch + bare `--auto` +
    no mode + no attended → `exit 0` (defer, regardless of whether the PR touches the marker — the tap
    is merge-guard's job on the same call); committed + any non-`--auto` merge → `exit 2`;
    working-tree-only / not-on-default-branch marker → `exit 2` (root of trust — no valid committed
    marker to defer on); precedence cases mirror merge-guard's.
  - The committed marker is a **valid, real** fixture **committed to the fixture repo's `main`**
    (`scope: "project"`, all fields), distinct from the attended fixture, so the read-from-`main`
    path is exercised, not stubbed.
  - **Reader parity:** the committed reader's dual jq / python3 paths get a parity check in the tests'
    existing parity vehicle (the pattern that already proves `read_attended_marker`'s two readers
    agree) — the same marker JSON read under jq and under the python3 fallback yields the same
    `COMMITTED_ACTIVE` verdict, including the fail-closed cases.
- [auto] **All other script self-test suites, and every repo lint, pass unchanged:**
  `check-neutral.sh`, `check-skill-frontmatter.sh`, `check-skill-anchors.sh`, `check-plan.sh`,
  `check-auto-preflight.test.sh`, and `claude plugin validate --strict .` all green. Note: any suite
  that **executes** the two guard scripts (e.g. `scripts/attended-marker-parity.test.sh`, which runs
  both `merge-guard.sh` and `guard-branch-rules.sh`) is **expected to still pass** — the committed row
  is additive and does not alter the attended/mode/no-marker paths it exercises — but it is **not**
  claimed untouched-by-input; confirm it green rather than asserting an empty relationship.
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
re-derived. Confirm specifically that the **root of trust is read from `main`** (a working-tree-only
marker is ignored) and that the **human-tap rule** fires before any auto-allow on a marker-touching
PR. **Dispatch the verifier at `xhigh`** (two hard-invariant gates). **`/security-review` of the
milestone's diff is a pre-pin precondition** — the adversarial questions, each now answerable by a
mechanical control the spec names (not prose): (1) does the plan-path carve-out open any path for a
*code* file to land unpinned — it must widen the plan set by exactly one named file; (2) can an agent
**self-arm** — it must not: the marker is honored only from `main`, and any marker-touching PR forces
a human tap, so neither a local `Write` nor a temporary-authority auto-merge of the marker's PR arms
it; (3) does the committed row let a non-canonical/bundled `--auto` land — it must not. Confirmed
findings remediated before the pin.
