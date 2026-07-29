# Change — guard-worktree-branch: the branch guards resolve state from the wrong checkout in worktree sessions

**Provenance:** the 2026-07-29 corpus review + three-project transcript mining (new-test-proj "Relay",
cre-list "CRELaunch", test-proj-1 "Bidlevel").

## The defect

Both PreToolUse guards root every git read at the project dir:

- `scripts/guard-branch-rules.sh:55-56` — `ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"; cd "$ROOT"` — then the
  commit rule reads `git rev-parse --abbrev-ref HEAD` (line 456) from that dir.
- `scripts/merge-guard.sh` shares the idiom (the classifiers are deliberately duplicated).

In a worktree session the Bash command executes in the **worktree** (on the milestone branch), but
`CLAUDE_PROJECT_DIR` stays the **main checkout** (on `main`). The guard judges the wrong repo:

- Relay: the milestone's final commit was hard-blocked — "the guard says I'm on `main`, but two
  independent checks say `pipeline-board-toolbar-states`" — ending the build on an unresolved stop-point.
- CRELaunch: the same misfire at the m75 pin step, worked around with `git -C <worktree>` (an evasion
  shape the guard exists to make unnecessary).

The test suites never catch it because every existing case sets `CLAUDE_PROJECT_DIR` equal to the
working directory — the mismatch class is structurally untested.

## The fix

The PreToolUse hook input JSON already carries a `cwd` field — the directory the tool call runs in.
Resolve **branch state** (default-branch detection, remotes, the HEAD reads behind the push/commit
rules) from hook-input `cwd` when it is a directory inside a git work tree; fall back to
`CLAUDE_PROJECT_DIR:-$PWD` (today's exact behavior) when the field is absent or unusable. **Marker
files** (`keel-autonomy.json`, `keel-attended-merge.json`) stay rooted at the project dir — they are
project-scoped; worktrees never carry them. The reader-less degrade path is untouched (no JSON parser →
no `cwd` either; the raw fail-closed scan is unchanged). `git -C <elsewhere>` remains an accepted,
documented classifier limit — branch protection stays the authority.

Fans into **one milestone**: `specs/milestones/guard-worktree-branch.md`.
