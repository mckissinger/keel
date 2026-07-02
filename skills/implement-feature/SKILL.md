---
name: implement-feature
description: Orchestrate building a whole feature's milestones — connective tissue over implement-milestone + verify-milestone, in dependency order, enforcing the branch/PR/stack rules and stopping at the user's merge. Spawns fresh-context verifier subagents ([auto] parallel, [runtime] serial). Defaults to interleaved cadence but ALWAYS asks. Never merges.
when_to_use: After spec-feature has authored a whole feature's milestone specs, to build and verify them end-to-end. NOT for a single milestone (that's implement-milestone), NOT for checking one completed milestone (that's verify-milestone), and NOT for merging the reviewed PRs (that's land-feature, under the user's per-merge approval).
---

# Implement Feature

Build a feature's milestones end-to-end. This skill is **connective tissue** — like `kickoff` for the foundation phase: it sequences `implement-milestone` and `verify-milestone` across a feature's milestones and enforces the GitHub process, but it does **not** re-implement either, and it **stops at the user's merge** (agents never merge).

It completes the feature tier: `spec-feature` → **`implement-feature`** → [user merges] → `land-feature` → `review-feature`.

## First: ask the cadence

The milestones of a feature relate in one of three ways, and the choice changes everything downstream — so **always ask, defaulting to interleaved:**

- **Interleaved (default, safest)** — build M1 → user merges M1 → M2 builds off updated `main`. **No stack ever forms**, so no rebase/re-pin cascade. Costs a user merge between milestones.
- **Stacked** — build all milestones in dependency order, open stacked PRs, user merges bottom-up. Max autonomy; concentrates the merge-time cascade risk (handled by `land-feature`).
- **By wave** — build the independent milestones concurrently off `main`, the dependent chain stacked; review, then the next wave.

Read the feature's milestone specs for `parallelizable` markings (§4 of the rules) and **keep any stack as shallow as the genuine dependency chain requires** — prefer independent milestones off `main` (they merge independently, no cascade).

The one exception a real dependency forces is a **diamond milestone (multi-parent)** — one that genuinely depends on *all* its siblings **and** carries an "after all land" whole-repo check (a terminal guard/cleanup over the assembled corpus). It can't be a single-parent stacked PR, so build + verify it on a conflict-free **integration branch** (a merge of its parent milestones — safe because disjoint file ownership makes the integration tree the same as the eventual `main`), base its PR on that branch, and keep it **last**. This is the exception, not license for deep stacks. The finish — rebasing it onto `main` and re-pinning — is `land-feature`'s.

## The orchestration

For each milestone, in dependency order (bottom-up for a stack):

1. **Build** — dispatch `implement-milestone` (its own branch; off `main` if independent, off the parent if it genuinely stacks, off a conflict-free **integration branch** — merge of all its parents — if it's a multi-parent diamond).
2. **Verify in a fresh context** — dispatch verification as a **subagent with its own context window** (this is the proven pattern — `verify-all-milestones` already spawns fresh-context `verifier` agents in worktrees; a worktree-isolated verifier *is* the "fresh session" the rule protects). Prompt it from the **spec's done-conditions + the checkout**, never from the builder's claims.
   - **`[auto]` conditions** → verifier subagents can run in **parallel** (worktrees).
   - **`[runtime]` conditions** → run **serially**, one at a time, because the runtime-proof needs sole access to the shared local services (the single backend stack, dev-server ports). Parallel runtime walks collide — this is exactly why the parallel sweep can't close `[runtime]`.
3. **Pin bottom-up** — on a clean verdict, the orchestrator writes the `verified:` pin (the verifier subagent is read-only) and runs the mechanical postcondition checks (`HEAD^` == verified SHA, working tree clean). For a stack, write pins in stack order via clean rebases onto the plan-only pin commits.
4. **Open the PR** — base `main` for an independent milestone; base the parent branch for a stacked one. Quote the done-conditions + verification evidence in the body.

Keep the orchestrator's own retained state thin (a ledger: slug → branch → PR → verdict → SHA) so it scales across a multi-milestone feature without its context filling — the build and verify detail lives in the subagents, discarded after.

## Two hard boundaries

- **Verification is independent.** It runs in a context that never saw the build narrative, prompted from the spec — so the orchestrator dispatches verification, it does not *judge* it. Build and remediation are different subagents from verification.
- **Stops at merge.** `implement-feature` ends at *all milestones built, verified, pinned, PRs open with correct bases, stack minimal and bottom-up*. **The user merges.** The merge-time choreography (retarget-before-delete, close+reopen for CI, recreate closed children, re-pin after a forced rebase, the post-wave consolidated check) is `land-feature`, run under the user's per-merge approval.

## Output

A feature whose milestones are all built, independently verified, and pinned, with PRs open and correctly based — handed to the user for merge (`land-feature`), then `review-feature`.
