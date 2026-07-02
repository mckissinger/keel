# Milestone — hooks-m2-guards: merge + branch guards

**Goal:** merge-shaped commands become harness decisions (ask by default, deny with reason
when the project's pin gate fails), and build-skill sessions cannot commit to main or merge —
mechanically, including in local-only projects with no branch protection.

**Feature:** `specs/features/enforcement-hooks.md`. **No-UI** → two-dimension
done-conditions. **Depends on:** `hooks-m1-bootstrap`. **Parallelizable:** no.

## Done-conditions

### Logic / invariants
- [auto] `hooks/hooks.json` gains a PreToolUse hook on Bash invoking
  `scripts/merge-guard.sh`. The guard classifies the command: merge-shaped (`gh pr merge`,
  `git merge` targeting the default branch, `git push` to the default branch) → decision;
  everything else → allow (no output, exit 0). Decision logic: if the project carries the
  gate (`scripts/check-verified-pin.sh` present) and the PR context is resolvable (`gh pr
  view --json baseRefName,headRefName` for `gh pr merge`; local refs otherwise), run the gate
  — **pass → `ask`** (per-merge human approval, stating the gate passed), **fail → `deny`**
  with the gate's reason verbatim. Gate or context missing → plain `ask` naming what was
  unresolvable. The guard never auto-allows a merge and never re-implements gate logic.
- [auto] Command classification is robust to the obvious evasions the self-test enumerates:
  flags before subcommands, `--repo` args, default-branch detection via
  `origin/HEAD`→fallback, and it does **not** false-positive on `git merge-base`,
  `git merge --abort`, branch-to-branch merges, or pushes to non-default branches.
- [auto] `skills/implement-milestone/SKILL.md` and `skills/implement-feature/SKILL.md` gain
  skill-scoped `hooks:` running `scripts/guard-branch-rules.sh`: `git commit` while on the
  default branch → exit 2 with the branch-first rule; merge-shaped commands → exit 2 (build
  sessions never merge). Everything else exits 0 silently.
- [auto] Both scripts: executable, `dirname`-relative, no denylisted stack language
  (check-neutral now scans them, per m1), and safe under `set -euo pipefail` with quoted
  expansions — command text is **parsed, never eval'd or re-executed**.

### Behavioral completeness
- [auto] `scripts/merge-guard.test.sh` + `scripts/guard-branch-rules.test.sh` (house idiom)
  cover minimum: merge-shaped detection matrix (positives + the non-triggers above), deny on
  failing gate with reason passthrough, ask on passing gate, ask on missing gate/context,
  branch-guard commit-on-main exit 2 vs commit-on-branch exit 0.
- [auto] `claude plugin validate --strict .` passes; both pre-existing self-tests pass.
- [runtime] Live-session probe (may close in m3's composition walk): a `gh pr merge` attempt
  in a fixture repo surfaces the harness ask/deny (deterministic core: the decision matrix,
  covered by `merge-guard.test.sh`).

## verification
verifier subagent against this file (decision matrix exercised via the committed self-tests,
not re-derived; skill-frontmatter greps; no-eval/quoting review of both scripts) +
**`/security-review` pre-pin** — the guard interpolates `gh pr view` output and command text
into shell decisions (hard-invariant surface; adversarial questions: can a crafted PR
title/branch name or command string flip a deny into allow, inject into the gate invocation,
or smuggle a merge past classification?).

verified: clean at d1fd4cd, 2026-07-01, via fresh-context verifier subagent; /security-review PROCEED (no blocking findings) — merge-guard.test.sh 29/29 + guard-branch-rules.test.sh 16/16 (+ check-neutral 17/17, check-verified-pin 17/17, session-bootstrap 11/11, plugin validate --strict pass, check-neutral corpus scan pass); decision floor is ask (no code path emits allow), gate invoked as the project's scripts/check-verified-pin.sh (never re-implemented), gh pr view output handled as quoted data; d1fd4cd's delta vs security-reviewed 6c0f352 is comment-only (5 classifier-comment lines in merge-guard.sh, tests unchanged); [runtime] live-session probe deferred to m3's composition walk per spec (deterministic core covered by merge-guard.test.sh) (evidence: verifier + security reports in PR)
