# Uncertain choice — GIT_CTX is not constrained to the SAME repository as ROOT

**Choice made.** `resolve_git_ctx` (both guards) accepts the hook input's `cwd` on one test only, the
spec's definition of *usable*: it is an existing directory and
`git -C <dir> rev-parse --is-inside-work-tree` prints `true`. Any work tree qualifies — including one
belonging to a repository unrelated to `CLAUDE_PROJECT_DIR`.

**Viable alternative considered.** Additionally require that the candidate share the project's
repository — e.g. compare `git -C <dir> rev-parse --git-common-dir` against the same read at `ROOT`,
and fall back to ROOT when they differ. That would confine the cwd-first resolution to the main
checkout plus its own linked worktrees, which is the case the milestone exists to fix.

**Why it's uncertain.** The spec fixes the usability test verbatim and says nothing about repository
identity, so adding the check would be a tightening the spec did not ask for (and one that costs an
extra git read on every Bash call). The reasoning for accepting it as specified: the guarded command
*executes in* `cwd`, so a commit made there lands in that checkout's branch — judging that checkout is
the correct answer, not a hole; and markers plus the gate script path stay ROOT-rooted, so a crafted
`cwd` cannot unlock autonomy state or select an executable. The residual asymmetry a reviewer could
object to is that the *default-branch name* is then also learned from the foreign repo, so a `git
commit` while `cwd` is a work tree whose default branch is named differently would not be judged
against the project's default-branch name. Since the commit would not touch the project's default
branch either, that reads as consistent rather than as a bypass — but a reviewer holding the guard to
"never let an out-of-project directory influence the decision" would add the common-dir check.
