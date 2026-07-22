---
name: implement-feature
description: Orchestrate building a whole feature's milestones — connective tissue over implement-milestone + verify-milestone, in dependency order, enforcing the branch/PR/stack rules and stopping at the user's merge. Spawns fresh-context verifier subagents ([auto] parallel; [runtime] serial unless the profile's isolation contract is proven). Defaults to interleaved cadence but ALWAYS asks. Never merges.
when_to_use: After spec-feature has authored a whole feature's milestone specs, to build and verify them end-to-end. NOT for a single milestone (that's implement-milestone), NOT for checking one completed milestone (that's verify-milestone), and NOT for merging the reviewed PRs (that's land-feature, under the user's per-merge approval).
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "\"${CLAUDE_PLUGIN_ROOT}\"/scripts/guard-branch-rules.sh"
---

# Implement Feature

Build a feature's milestones end-to-end. This skill is **connective tissue**: it sequences `implement-milestone` and `verify-milestone` in dependency order and enforces the GitHub process, but **re-implements neither** and **stops at the user's merge** (agents never merge).

## First: ask the cadence

Feature milestones relate in one of three ways, and the choice changes everything downstream — so **always ask, defaulting to interleaved:**

- **Interleaved (default)** — build M1 → user merges M1 → M2 builds off updated `main`. **No stack ever forms.**
- **Stacked** — build all milestones in dependency order, open stacked PRs, user merges bottom-up; concentrates the cascade risk `land-feature` handles.
- **By wave** — independent milestones concurrently off `main`, the dependent chain stacked; review, then the next wave.

Read the milestone specs for `parallelizable` markings (§4 of the rules) and **keep any stack as shallow as the genuine dependency chain requires** — prefer independent milestones off `main`.

The one exception a real dependency forces is a **diamond milestone (multi-parent)** — depends on *all* its siblings **and** carries an "after all land" whole-repo check. Not a single-parent stacked PR, so build + verify it on a conflict-free **integration branch** (a merge of its parents), base its PR there, keep it **last**. The rebase-onto-`main`-and-re-pin finish is `land-feature`'s.

## The orchestration

At orchestration start, read the feature spec's **Lifecycle** section (`specs/features/<feature>.md`) with the milestone specs — it enumerates this feature's gates and their state sources, for the handoff to report. A spec with **no** Lifecycle section has that **absence surfaced in the handoff, never silently skipped**; `land-feature`'s reconciliation backfills it.

For each milestone, in dependency order (bottom-up for a stack):

1. **Build** — dispatch `implement-milestone` on its own branch: off `main` if independent, off the parent if it genuinely stacks, off the diamond's **integration branch** if multi-parent.
2. **Verify in a fresh context** — dispatch verification as a **subagent with its own context window**. Prompt it from the **spec's done-conditions + the checkout**, never from the builder's claims. The fresh-context verifier's proof run is the **full** committed suite — its dispatch **forbids** a spec/milestone filter, never scoped to this milestone's own tests (`${CLAUDE_PLUGIN_ROOT}/references/milestones-and-verification.md` §9.1).
   - **`[auto]` conditions** → verifier subagents run in **parallel** (worktrees).
   - **`[runtime]` conditions** → run **serially** — the runtime-proof needs sole access to the shared local services — **unless** the profile carries a **proven Q13 isolation contract** (`specs/stack-profile.md`), in which case each subagent claims its own instance and `[runtime]` milestones verify in **parallel**.
3. **Pin bottom-up** — on a clean verdict, the orchestrator writes the `verified:` pin (the verifier subagent is read-only) and runs the mechanical postcondition checks (`HEAD^` == verified SHA, working tree clean). For a stack, write pins in stack order via clean rebases onto the plan-only pin commits.
4. **Open the PR** — base `main` for an independent milestone, the parent branch for a stacked one. Quote the done-conditions + verification evidence in the body.

Keep the orchestrator's retained state thin (a ledger: slug → branch → PR → verdict → SHA); build and verify detail lives in the subagents.

## Two hard boundaries

- **Verification is independent.** The orchestrator dispatches verification but does not *judge* it; build and remediation are different subagents from verification.
- **Stops at merge.** `implement-feature` ends at *all milestones built, verified, pinned, PRs open with correct bases, stack minimal and bottom-up*. **The user merges.** The merge-time choreography is `land-feature`'s, under the user's per-merge approval.

## Under an active autonomy mode

Under an active `keel:auto` mode (per `decisions/2026-07-autonomy-modes.md`), two gates change: the cadence ask becomes a **ledgered default** (per `keel:auto`'s ledger contract under `specs/runs/<run-id>/`), and "stops at merge" becomes **enable `gh pr merge --auto` on each pinned, gate-passing PR — per the `land-feature` choreography — and proceed**. Everything else (fresh-context verification, pin discipline, the branch guard) is unchanged. Outside a mode, this section does not apply.

## Output

A feature whose milestones are all built, independently verified, and pinned, PRs open and correctly based — handed to the user for merge (`land-feature`), then `review-feature`. The handoff reports **each lifecycle gate's derived state**: the pins and PRs this run produced, and the gates still **open** — the user's merges, `land-feature`'s reconciliation + consolidated check, `review-feature`.
