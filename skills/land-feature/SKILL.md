---
name: land-feature
description: Drive the merge of a feature's reviewed PRs into main — the stacked-PR choreography (merge bottom-up, retarget before delete, close+reopen to re-fire CI, recreate closed children, re-pin after a forced rebase) plus the post-wave consolidated check on main.
when_to_use: Human-triggered only, after the feature's milestones are built, verified, pinned, and reviewed by the user — per-merge approval is preserved, and agents never merge without the user's explicit instruction. NOT for building or verifying milestones (that's implement-feature / verify-milestone), and NOT the aesthetic/completeness gate (review-feature runs after landing).
disable-model-invocation: true
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

- **Conflict-only rebase** (no behavioral diff): re-run the suite green, then **re-pin with `scripts/repin.sh <milestone-spec> [note]`** — it rewrites the pin to the new code tip with a carry-forward clause, commits it plan-only, and asserts the postconditions. The green suite re-run stays your job (the script runs no tests). Not a full re-verification.
- **Behavioral rebase**: it's a new state — **re-verify** (fresh `verify-milestone`), then re-pin.
- Write each descendant's pin **after** rebasing that branch (the rebase moves the code tip; the pin must reference the post-rebase SHA). The pin commit itself is plan-only, so the gate sees no code drift after it.

## A diamond milestone (multi-parent) — rebase before landing

Not a linear stack: a milestone that genuinely depends on **all** its siblings **and** carries an "after all land" whole-repo done-condition (a terminal guard/cleanup that locks an invariant over the fully-assembled corpus). `implement-feature` built + verified it on a conflict-free **integration branch** (a merge of its parents), PR based on that branch, kept last. Landing it:

1. **Land it only after all its parents are on `main`.** It's the last thing merged in the wave.
2. **Rebase the diamond branch onto `main`** (dropping the integration parentage) so its multiple merge bases collapse to a single base — a clean own-files-only diff. **Why:** the integration merge leaves the branch with more than one merge base vs `main`, so the three-dot `git diff main...HEAD` that `check-verified-pin.sh` uses picks an older base and **falsely reports drift** on the already-verified sibling files. The rebase is what makes the pin gate verify cleanly.
3. It's a **conflict-only rebase** — content is identical (disjoint file ownership made the integration tree the same as `main`). Apply the cascade rule above unchanged: **re-run the guard/suite green, then re-pin with `scripts/repin.sh`** (carry-forward clause, plan-only commit — the green re-run stays yours, the script runs no tests). Not a re-verification.
4. **Then merge, and delete the integration scaffolding branch** once the diamond is on `main`.

The post-wave consolidated check below still runs last.

## The post-wave consolidated check (mandatory, last)

A wave isn't done until it's green on `main` **together**. Nothing on a branch proves the merged result. After the feature's PRs are all on `main`, run one consolidated check: **fresh state → all migrations in order → full suite** (+ the consolidated first-run walk for a UI feature). This is the only gate that catches cross-sibling integration bugs (a shared layout double-wrapped, two migrations that conflict only when combined).

## Reconcile the specs to merged reality (last, after the consolidated check is green)

Once the wave is green on `main` together, the specs still describe the *plan*; `main` now describes what was *built*. Close that gap in **one plan-only commit** so the next `spec-feature` session reads reality, not intent:

- **Update the living docs to merged reality** — `specs/features/<feature>.md` (the route→milestone map, any decisions the build changed), and `specs/00-product.md` / `specs/01-architecture.md` **only if the build changed a data shape or environment fact**. Per the spec-authority rule (`${CLAUDE_PLUGIN_ROOT}/references/milestones-and-verification.md` §5), don't rewrite correct merged code to match a stale spec — update the doc to match the code.
- **Archive the wave's completed milestone specs** to `specs/milestones/_landed/` (mirroring the `deferrals/_closed.md` archive precedent). A landed milestone's pin is history; moving it out of `specs/milestones/` keeps the active-plan surface honest without losing the record.
- **This commit is plan-only by construction** — it touches only `specs/**` (feature/product/architecture edits + `_landed/` moves), so the verified-pin gate exempts it under the same plan-only exemption that covers a plan PR (§5), and `check-plan.sh` does not lint `_landed/` (its glob is non-recursive, `specs/milestones/*.md` only — the archive path is not an active milestone spec). Commit it directly as the reconciliation step; it carries no code and needs no pin.

## Boundaries

- **The user merges.** This skill runs the mechanics around each merge the user has approved; it never merges on its own initiative. The PreToolUse merge guard makes this same per-merge approval harness-shaped — its `ask` on an approved, gate-passing merge — as a local backstop that never replaces branch protection + CI.
- **External repos:** upstream repos actively trap undisclosed agent PRs, so any keel-driven contribution to an external repo must disclose agent authorship and keep the human-review step honest.
- **Never merge with checks pending or red.** Confirm each PR's base is `main` and its checks are green first.
- Then the feature goes to **`review-feature`** (the human aesthetic/completeness gate) before it counts as done.

## Under an active autonomy mode

Under an active `keel:auto` mode (per `decisions/2026-07-autonomy-modes.md`), this choreography is invoked by the `keel:auto` orchestration with `gh pr merge --auto` on each gate-passing PR — GitHub's required checks decide each merge, never agent judgment. Every rule above (bottom-up ordering, retarget-before-delete, close+reopen, re-pin after a rebase, the consolidated check, the reconciliation) is unchanged; only who fires the merge command changes. **Emit each such merge bare and un-chained** — its own `gh pr merge <pr> --auto` call, nothing bundled with it — per the emission contract in `scripts/merge-guard.sh`'s header; a bundled merge forfeits the strict-auto allow and stalls the run. Outside a mode, the attended per-merge flow above holds exactly as written.
