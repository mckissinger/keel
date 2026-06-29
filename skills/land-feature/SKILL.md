---
name: land-feature
description: Drive the merge of a feature's reviewed PRs — the stacked-PR choreography (merge bottom-up, retarget before delete, close+reopen to re-fire CI, recreate closed children, re-pin after a forced rebase) plus the post-wave consolidated check on main. Human-triggered, per-merge approval preserved — agents never merge without the user's explicit instruction.
---

# Land Feature

Merge a feature's verified PRs into `main` correctly. The GitHub mechanics of a stacked series are fragile and have repeatedly drawn blood; this skill encodes the sequence that works so it isn't re-derived each time. It runs **under the user's control** — agents merge only on the user's explicit per-merge instruction; this skill executes the mechanics around each approved merge, it does not grant itself merge authority.

Run it after the feature's milestones are built, verified, pinned, and **reviewed by the user** (`implement-feature` opened the PRs; the user has approved merging).

## Independent milestones (the common, easy case)

A milestone branched off `main` with no descendant depending on it: **squash-merge, delete branch.** No cascade. Prefer this — `implement-feature` keeps stacks shallow precisely so most merges are this.

## A stacked series (m1 ← m2 ← m3) — the careful path

GitHub's defaults fight the naïve "merge + delete each" loop. The sequence that holds:

1. **Merge bottom-up, with merge commits — never squash a stacked PR.** Squashing rewrites the SHA the descendants' `verified:` pins point at, orphaning them. Merge the bottom PR (base `main`) with `--merge`.
2. **Do NOT `--delete-branch` while an open descendant is based on that branch.** Deleting a merged base **CLOSES** the child PR — and a closed PR whose base is gone **cannot be reopened** (`gh pr reopen` fails); you'd have to recreate it. Instead: merge without deleting, **retarget the descendant to `main` while it's still open** (`gh pr edit <child> --base main`), *then* delete the now-unreferenced parent branch.
3. **After retargeting, close+reopen the descendant to re-fire CI.** Retargeting does **not** re-run `on: pull_request` workflows (its activity type is `edited`, not `reopened`), so the `verified-pin` + quality jobs never fire against the new base. `gh pr close <n> && gh pr reopen <n>` emits `reopened` and runs them. (A new push also works.)
4. **The verified-pin gate passes per stacked PR only once its ancestors are on `main`** — so its diff vs `main` touches only its own milestone file. That's exactly the state after merging bottom-up. Confirm green before merging the next.
5. **If a descendant was closed by a base-deletion, recreate it** (`gh pr create --base main --head <branch>`) — the head branch still exists.

## When a review fix forces a rebase (the cascade)

A behavioral fix to a mid-stack milestone changes its code SHA, so every descendant rebased on top must be re-pinned (the pin is self-invalidating):

- **Conflict-only rebase** (no behavioral diff): re-run the suite green, **re-pin to the new `HEAD^`** with a carry-forward note. Not a full re-verification.
- **Behavioral rebase**: it's a new state — **re-verify** (fresh `verify-milestone`), then re-pin.
- Write each descendant's pin **after** rebasing that branch (the rebase moves the code tip; the pin must reference the post-rebase SHA). The pin commit itself is plan-only, so the gate sees no code drift after it.

## The post-wave consolidated check (mandatory, last)

A wave isn't done until it's green on `main` **together**. Nothing on a branch proves the merged result. After the feature's PRs are all on `main`, run one consolidated check: **fresh state → all migrations in order → full suite** (+ the consolidated first-run walk for a UI feature). This is the only gate that catches cross-sibling integration bugs (a shared layout double-wrapped, two migrations that conflict only when combined).

## Boundaries

- **The user merges.** This skill runs the mechanics around each merge the user has approved; it never merges on its own initiative.
- **Never merge with checks pending or red.** Confirm each PR's base is `main` and its checks are green first.
- Then the feature goes to **`review-feature`** (the human aesthetic/completeness gate) before it counts as done.
