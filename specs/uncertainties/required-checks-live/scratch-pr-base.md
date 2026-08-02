# Uncertain choice — the scratch plan-only PR is based on the milestone branch, not main

**Choice made:** the done-condition's scratch plan-only PR (proving all four contexts go green on a
docs-only diff) is opened with **base = `required-checks-live`** (this milestone's branch) and head =
a throwaway docs-tweak branch off it.

**Viable alternative:** base = `main`. Rejected because a PR's checks run from the merge ref: to get
the four new contexts, the head must contain the split workflow, and against `main` that puts
`.github/workflows/ci.yml` in the PR diff — no longer a plan-only/docs-only diff, defeating the
condition's purpose. Basing on the milestone branch keeps the diff docs-only while the merge ref
carries the split workflow.

**Why it's uncertain:** the spec says "a scratch plan-only PR" without naming the base; a reviewer
could read it as base-`main` and judge the evidence weaker (the contexts prove out against a branch
base, not `main`). The check-runs evidence is identical either way — the same four jobs execute on
the same merge-ref workflow — but the reading differs enough to record.
