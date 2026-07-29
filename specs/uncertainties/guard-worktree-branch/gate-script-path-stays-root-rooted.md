# Uncertain choice — the pin gate's SCRIPT PATH stays ROOT-rooted while its INVOCATION moves to GIT_CTX

**Choice made.** In `scripts/merge-guard.sh`, `decide()` keeps resolving the gate as
`$ROOT/scripts/check-verified-pin.sh` (and keeps its `[ ! -f "$gate" ]` existence probe against
ROOT), but runs it as `(cd "$GIT_CTX" && BASE_REF=… "$gate" "$HEAD_REF_R")`. So the *which script*
question is answered from the project dir; the *which checkout is judged* question is answered from
the resolved git context.

**Viable alternative considered.** Derive the gate path from `GIT_CTX` too —
`$GIT_CTX/scripts/check-verified-pin.sh` — since a linked worktree of the same repo carries the same
`scripts/` tree, so in the ordinary worktree case the two paths are the same file at the same content.

**Why it's uncertain.** The spec's done-condition names only the invocation
("`check-verified-pin.sh` runs from `GIT_CTX`, so it judges the branch state of the checkout the
merge command would run in") and is silent on where the script itself is found. Both readings satisfy
that sentence. The tie was broken on the same principle the milestone applies to markers — a
project-scoped asset is read from the project dir, so a crafted `cwd` can never select *which
executable* the guard runs (only which checkout it judges), keeping the arbitrary-executable surface
exactly where it is today. A reviewer who weights "the worktree's own checked-out gate version should
judge the worktree" more heavily than that containment argument would resolve it the other way; the
two differ observably when the worktree has a different revision of `scripts/check-verified-pin.sh`
than the main checkout.

**Regression-locked either way** by `scripts/merge-guard.test.sh`'s worktree class: the recording gate
lives at `$ROOT/scripts/` and reports its own `$PWD`, so the assertions pin the split explicitly
(`origin/main|wt/milestone|<worktree>`).
