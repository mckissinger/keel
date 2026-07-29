# Milestone — guard-worktree-branch: the branch guards judge the checkout the command runs in

**Goal:** `guard-branch-rules.sh` and `merge-guard.sh` resolve branch state from the hook input's `cwd`
(the directory the Bash call actually executes in), falling back to `CLAUDE_PROJECT_DIR:-$PWD` when
`cwd` is absent or unusable — so a worktree session's commit on its milestone branch is judged against
the worktree's HEAD, not the main checkout's. Marker reads stay project-rooted. Every non-worktree
behavior is byte-for-byte today's.

**Change:** `specs/changes/guard-worktree-branch.md`. **No-UI** → two-dimension done-conditions (logic +
behavioral completeness). **Depends on:** nothing. **Parallelizable:** no (two scripts kept in
deliberate parity plus their tests — one coherent edit). **Routing:** reasoning-heavy — this edits the
merge/commit gating machinery itself; a wrong fallback direction here either blocks every worktree build
or silently opens a commit-on-main hole.

## Done-conditions

### Logic / invariants

- [auto] `read_hook_command` in **both** scripts extracts `cwd` from the hook input JSON alongside
  `tool_input.command`, on both reader paths (jq and python3), into a variable parsed as data — never
  eval'd. `file:line` evidence in each script.
- [auto] **One resolved git context, used everywhere git is read.** Both scripts derive a single
  `GIT_CTX` — the first usable of hook-input `cwd`, `CLAUDE_PROJECT_DIR`, `PWD`, where *usable* means
  the value is a directory inside a git work tree (`git -C <dir> rev-parse --is-inside-work-tree`
  true) — and **every** git read runs against it: `detect_default_branch`, the `REMOTES` list, and the
  HEAD reads in classification (`classify_git_push`, the `GIT_COMMIT` rule) in both scripts, **plus**,
  in `merge-guard.sh`, `resolve_gh_context`'s ref-existence probes, `decide()`'s `BASE_REF_R`/
  `HEAD_REF_R` resolution, and the pin-gate invocation (`check-verified-pin.sh` runs from `GIT_CTX`, so
  it judges the branch state of the checkout the merge command would run in). No git read is left
  resolving from `ROOT` when `GIT_CTX` differs — the split is exactly: git state from `GIT_CTX`,
  marker files from `ROOT`. `file:line` evidence for the `GIT_CTX` derivation and each converted
  call site in both scripts.
- [auto] **Marker reads stay project-rooted:** `read_mode_file` and `read_attended_marker` in both
  scripts still read `$ROOT/.claude/keel-autonomy.json` / `$ROOT/.claude/keel-attended-merge.json` —
  never a path derived from `cwd`. `file:line` evidence; `scripts/attended-marker-parity.test.sh` green.
- [auto] **Reader-less degrade unchanged:** with neither jq nor python3 on PATH, neither script parses
  `cwd` (there is no JSON reader to do it with); the raw fail-closed substring scan and its message are
  unchanged — the existing reader-less test cases pass without edits.
- [auto] **Headers document the contract:** both script headers state the `cwd`-first resolution, the
  fallback order, why markers stay project-rooted, and that `git -C <elsewhere>` remains an accepted
  classification limit (branch protection + required checks stay the authority). The duplication note
  ("keep the two in sync") now covers the `cwd` reader too.
- [auto] **Gates otherwise untouched:** the milestone's diff touches only `scripts/guard-branch-rules.sh`,
  `scripts/merge-guard.sh`, and their two test files — `scripts/check-verified-pin.sh`, `scripts/repin.sh`,
  `scripts/check-auto-preflight.sh`, `hooks/hooks.json`, and the never-auto list are unchanged (empty
  diffs).

### Behavioral completeness

- [auto] **The structurally-missing test class exists in `scripts/guard-branch-rules.test.sh`** — a
  linked-worktree fixture (`git worktree add` on a feature branch off a main-checkout repo sitting on
  `main`) covering at minimum: (i) `CLAUDE_PROJECT_DIR`=main checkout, hook `cwd`=worktree on the
  feature branch → `git commit` **exits 0** (the Relay misfire, now a regression); (ii) hook
  `cwd`=main checkout on `main` → `git commit` **exits 2** (the rule still bites where it should);
  (iii) hook input carrying **no** `cwd` field → today's matrix byte-for-byte (commit on `main` via
  `CLAUDE_PROJECT_DIR` → exit 2); (iv) `cwd` naming a non-git or nonexistent directory → fallback to
  `ROOT` resolution, matrix unchanged.
- [auto] **The same four-class coverage exists in `scripts/merge-guard.test.sh`**, asserted at the
  observable seams: (i) a `git push` (implicit current-branch) case whose **classification** resolves
  the worktree's HEAD when `cwd` is the worktree (push from a feature-branch worktree is not
  push-to-default; the same command with `cwd` absent falls back to `ROOT` and classifies as today);
  (ii) a merge-shaped case from a worktree `cwd` whose **decision path** demonstrates `GIT_CTX`
  resolution — `decide()`'s resolved `HEAD_REF_R` / the pin-gate invocation reflect the worktree's
  branch, asserted via the guard's decision output or the gate's reported refs, not via
  classification (merge-shape classification is HEAD-independent by design).
- [auto] **No existing expectation weakened:** every pre-existing case in both test files passes
  unchanged, except any case that pinned the buggy ROOT-resolution semantics itself — each such edit (if
  any) is named in the PR body with the reason.
- [auto] All script self-test suites pass (`guard-branch-rules`, `merge-guard`,
  `attended-marker-parity`, `session-bootstrap`, `check-verified-pin`, `check-auto-preflight`,
  `check-plan`, `check-skill-frontmatter`, `check-skill-anchors`, `check-neutral`, `repin`), and
  `claude plugin validate --strict .` passes.

## verification

verifier subagent against this file — every `[auto]` condition checked against source with `file:line`
evidence; the suites run, not re-derived. **Dispatch the verifier at `xhigh`** (reasoning-heavy).
**`/security-review` of the milestone's diff is a pre-pin precondition** — this milestone edits the
commit/merge gating machinery (a hard-invariant surface): confirmed findings are remediated and
regression-locked before the `verified:` record is written. Adversarial focus for both passes: the
fallback direction (an unusable `cwd` must degrade to today's behavior, never to silence), and whether
any crafted `cwd` value could be eval'd or could point branch-state reads at an attacker-chosen repo
while markers still read project-local.
