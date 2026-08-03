# Milestone — committed-auto-merge-marker: a committable per-project marker the guards honor

**Goal:** a keel repo can carry a **committed** `.claude/keel-auto-merge.json` that arms
`gh pr merge --auto` for every session — and (a) it can *land under the full protection contract*
(the pin gate treats it as a plan path, so arming is a plan-only PR), and (b) both merge guards
**honor it** with a new committed-project row whose precedence is `mode > attended > committed`. This
is the primitive the whole feature stands on; nothing else in the feature is committable or honored
until it lands.

**The root of trust that makes "committed" real (closes the two adversarial-pass blockers, then
hardened by the pre-pin security review — see the "Security-review hardening" section below).** The
guards honor the marker **only when it is present on the repo's SERVER default branch**, read via git
after a mandatory fetch (`git show refs/remotes/origin/<db>:.claude/keel-auto-merge.json` as data,
where `<db>` is the server default branch from `gh repo view`, **not** the locally-rewritable
`origin/HEAD` symref) — never from the working tree, never from a locally-forgeable tracking ref. The
server default branch advances **only** by a human-merged PR (the standing never-commit-to-`main`
invariant + branch protection), so presence there *is* the authorization trail: an agent that merely
`Write`s the file locally, commits it on a branch, or even forges a local `refs/remotes/origin/<db>`
has nothing the guards honor — the mandatory fetch overwrites a forged tracking ref with real origin
content, and if it can't fetch, the marker is **not honored** (no fallback). And a merge-shaped
command whose target PR **touches `.claude/keel-auto-merge.json`** is **never auto-merged** — it forces
the per-merge human tap regardless of any active marker or mode (with a mandatory fresh fetch of the PR
head, so a stale local ref can't hide a just-pushed marker) — so no *temporary* authority (an 8h
attended marker, a 24h mode) can auto-land the *permanent* marker's own PR. Together these move "the
agent never self-arms" from a prose promise to a **mechanical control**. The residual is now only
forging the **server** default branch (needs repo write + settings — an admin action out of an agent's
reach), and the **required-checks floor on the protected branch remains the real backstop** — nothing
lands that the three checks did not pass, self-armed or not.

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
  presence on the SERVER default branch, not the working tree and not any locally-forgeable ref**
  (this clause was **hardened by the pre-pin security review** — see the "Security-review hardening"
  section below; the three fail-closed steps): **(1)** the authorization branch is the repo's
  **server** default branch, from `gh repo view --json defaultBranchRef` run in `GIT_CTX` — **NOT**
  the local `refs/remotes/origin/HEAD` symref that `detect_default_branch` reads (an agent repoints it
  with `git remote set-head`, which is not a merge/push/commit shape, to a branch it pushed carrying a
  marker). gh resolves the **same repo `gh pr merge` targets**, so the marker authorizes exactly the
  repo the merge acts on — which is also why the read stays at `GIT_CTX`, not `ROOT` (reading at `ROOT`
  would let a marker in one repo authorize a merge gh performs in another). **It is emphatically NOT
  `BASE_REF_R`** — the *target PR's base branch* (from `gh pr view --json baseRefName`), a **sibling
  milestone branch** under a stack. **(2)** A **MANDATORY, fail-closed** fetch of that branch from
  origin precedes the read — **never best-effort**: a forged local `refs/remotes/origin/<db>` (planted
  with `git update-ref`, or committed in a throwaway `GIT_CTX` whose origin is unreachable) is
  overwritten by real origin content, and a fetch that cannot run means the marker is **not honored**,
  rather than falling back to the local ref. **(3)** The content is read from the just-fetched
  `refs/remotes/origin/<db>` via `git show`, parsed as data. A working-tree copy, a branch-only commit,
  or an untracked file **not on the server default branch** is **ignored**. This **inverts** the
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
  wrong-typed field reads as absent), the marker text — **read from the server default branch via a
  MANDATORY fetch then `git show refs/remotes/origin/<db>` (see the hardened root of trust above),
  never the working-tree file and never `BASE_REF_R`** — parsed **as data** (`json_str`, never
  eval'd), `scope != "project"` or any missing/empty field or a marker absent from the server default
  branch → `COMMITTED_ACTIVE=0` (fail closed). It sets a `COMMITTED_ACTIVE` flag consumed by each
  script's decision path. **The two readers are NOT identical, deliberately:** `merge-guard.sh`'s is
  the **security-authoritative** read (server default branch via `gh repo view` + mandatory fetch);
  `guard-branch-rules.sh`'s only decides whether to **defer** the build-session `--auto` to
  `merge-guard.sh` on the same call, so a fooled read there can at worst over-relax to a defer
  `merge-guard.sh` re-checks (or fail closed to a safe exit-2 block) — it therefore keeps
  `detect_default_branch` for the name but mirrors the **mandatory fail-closed fetch**, and both state
  that `merge-guard.sh` is the backstop. **Repo context (the milestone-#187 split):** the *file path*
  `.claude/keel-auto-merge.json` stays ROOT-rooted (markers are project assets), but the marker read
  runs against **`GIT_CTX`** — the repo `gh pr merge` targets — so the marker authorizes exactly that
  repo (never `ROOT`, which could authorize a different repo). State this ROOT-path / GIT_CTX split
  explicitly in both readers so a builder does not read from the wrong repo.
- [auto] **Any merge-shaped command whose target PR touches the marker file is never auto-merged** —
  the human-tap rule that blocks a *temporary* authority from auto-landing the *permanent* marker.
  **This check lives only in `merge-guard.sh` `decide()`** (which already resolves the PR's base/head
  refs): compute the PR's changed files with the **non-truncating** `git diff --name-only
  "$BASE_REF_R"..."$HEAD_REF_R"` (NOT `gh pr view --json files`, which truncates on large PRs and
  would let a padded marker-touching PR evade the control); if that list **includes**
  `.claude/keel-auto-merge.json`, or if the file list **cannot be determined** (diff error), the
  decision is **`ask`** — before and regardless of the mode/attended/committed allow rows, fail closed.
  So arming or disarming always takes a human merge tap. **Hardened by the pre-pin security review**
  (see the section below): a **MANDATORY fresh fetch** of base+head precedes the diff (so a stale
  local head cannot omit a just-pushed marker), **`diff.relative` is pinned OFF** (so a subdirectory
  `GIT_CTX` cannot drop the out-of-prefix marker), and every failure path fails closed to `ask`. **`guard-branch-rules.sh` needs no file-list
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
    tripwire still green with the third row present. **Security-review regressions** (each proven to
    return `allow` on the pre-fix code and `ask` now): finding 1 — `refs/remotes/origin/HEAD` repointed
    at a marker branch, gh still reports the real default → `ask`; finding 2a — a forged
    `refs/remotes/origin/<db>` overwritten by the mandatory fetch → `ask`; finding 2b — forged ref +
    unreachable origin → fetch fails, no local fallback → `ask`; finding 3 — a stale local PR-head ref
    hiding a just-pushed marker, revealed by the mandatory head fetch → human-tap `ask`; finding 4 —
    `diff.relative=true` + a subdirectory `GIT_CTX`, still detected via the pinned-off diff → human-tap
    `ask`.
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
  `specs/uncertainties/committed-auto-merge-marker/`, and this milestone spec (its pin + the
  security-review amendments below). `session-bootstrap.sh`, `template-contract.md`, the deferral, the
  arming skill, and `implement-feature` are **out of scope** here (M2/M3/M4 own them) and have empty
  diffs.

## Security-review hardening (2026-08-02, supersedes the earlier clauses it names)

The pre-pin `/security-review` (a hard-invariant precondition for this milestone) found **four**
concretely-exploitable self-arm / tap-evasion paths in the first build, each defeating the milestone's
central guarantee via ordinary agent-available commands (no server-side control). All four were
confirmed to return `allow` on the pre-fix code and are now closed and regression-tested. This section
is the reviewed record; where it conflicts with the earlier done-condition prose, **this governs**.

- **Finding 1 — `origin/HEAD` was the root of trust, and it is agent-repointable.** The read resolved
  the default branch via `detect_default_branch`, whose first source is the local
  `refs/remotes/origin/HEAD` symref; `git remote set-head origin <branch>` (not a merge/push/commit
  shape, so the guards permit it) repoints it at a branch the agent pushed carrying a marker. **Fix:**
  resolve the authorization branch from the **server** — `gh repo view --json defaultBranchRef` in
  `GIT_CTX` — never the symref; no gh / no default branch → fail closed.
- **Finding 2 — the marker read went through `GIT_CTX` with a best-effort fetch, so a forged local
  ref (or a crafted `cwd` whose origin is unreachable) was honored.** **Fix:** the refresh fetch is
  **mandatory and fail-closed** — a forged `refs/remotes/origin/<db>` is overwritten by real origin
  content, and a fetch that cannot run means the marker is not honored (no fallback). The read stays at
  `GIT_CTX` (the repo `gh pr merge` targets) rather than moving to `ROOT`: reading at `ROOT` while gh
  merges the `GIT_CTX` repo would let a marker in one repo authorize a merge in another — a worse hole.
- **Finding 3 — `pr_touches_marker` diffed a stale local PR-head ref, so a marker pushed onto the PR
  after the last fetch was invisible, letting a temporary authority auto-land the arming PR.** **Fix:**
  a **mandatory fresh fetch of base+head** precedes the diff; fetch failure → `ask`.
- **Finding 4 — `pr_touches_marker` honored `diff.relative` and failed open on an empty list.** With
  `diff.relative=true` and a subdirectory `GIT_CTX`, the out-of-prefix marker was dropped. **Fix:**
  the diff is pinned with `-c diff.relative=false --no-renames`, so full repo-root-relative paths are
  always emitted (a genuinely empty list then correctly means "no changes", not a dropped marker).

The net effect: the residual is no longer "forge a local ref" (an agent can do that) but "forge the
**server** default branch" (repo write + settings — an admin action out of an agent's reach), with the
required-checks floor as the standing backstop.

**Named residual (git-transport desync, backstopped, below the remediation bar).** The mandatory
fetches trust that `git fetch origin` and `gh` resolve the *same* content. A non-merge-shaped git-config
rewrite (`git config url.<evil>.insteadOf …`, `git remote set-url`) could in principle point `git
fetch origin` at attacker content while `gh` still hits real GitHub — forging `COMMITTED_ACTIVE=1` and
dropping the *local* human tap. Confidence is low (gh most likely honors `insteadOf` during remote
resolution, which fails the read closed) and the impact is bounded: it drops only the local tap, never
the **server-side required checks** (verified-pin, plan-lint, security-review, guards), which remain
the real merge gate — exactly the model `decisions/2026-08-01-required-checks-protection.md` sets. A
belt-and-suspenders close (resolve and fetch the concrete `gh`-reported clone URL rather than the
config-rewritable `origin` alias) is possible but not taken here; the residual is named, consistent
with the guard header already scoping git remote config out of reach and naming required-checks as the
floor.

## verification

verifier subagent against this file — every `[auto]` condition checked with `file:line` evidence: the
marker contract header field-by-field (tracked-not-untracked difference stated, no-TTL stated,
fail-closed on every defect), the `is_plan_path` carve-out is exactly one file (not a wildcard) with
its plan-only/mixed-PR test pair, the `decide()` committed row's five-way guard + precedence + the
whitelist forfeit, the `d_auto` tripwire covering three rows, the `read_committed_marker` fail-closed
typing, the guard-branch-rules defer row + precedence, and the confined diff. Suites run, not
re-derived. Confirm specifically that the **root of trust is the SERVER default branch** (`gh repo
view`, not `origin/HEAD`; a working-tree-only or forged-local-ref marker is ignored) and that the
**human-tap rule** fires before any auto-allow on a marker-touching PR. **Dispatch the verifier at
`xhigh`** (two hard-invariant gates). **`/security-review` of the milestone's diff is a pre-pin
precondition — it has already run once and its four findings are remediated and regression-tested
(the "Security-review hardening" section); a re-review of the remediated diff confirms the fixes
hold before the pin.** The adversarial questions, each now answerable by a mechanical control the spec
names (not prose): (1) does the plan-path carve-out open any path for a *code* file to land unpinned —
it must widen the plan set by exactly one named file; (2) can an agent **self-arm** — it must not: the
marker is honored only from the server default branch (via `gh`, with a mandatory fail-closed fetch),
and any marker-touching PR forces a human tap (with a fresh head fetch), so neither a local `Write`, a
repointed `origin/HEAD`, a forged tracking ref, nor a temporary-authority auto-merge of the marker's
PR arms it; (3) does the committed row let a non-canonical/bundled `--auto` land — it must not.
Confirmed findings remediated before the pin.
