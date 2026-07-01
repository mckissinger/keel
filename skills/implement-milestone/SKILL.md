---
name: implement-milestone
description: Build ONE milestone to its done-conditions — the atomic build verb. Branch first, build to the spec's done-conditions (honoring the [auto]/[runtime]/[attended] tags and the stack profile's runtime-proof), halt at stop-points, then hand off to verify-milestone. Never self-verifies, never commits to main, never merges. Used directly for a spec-change's single milestone, or invoked per-milestone by implement-feature.
---

# Implement Milestone

Build **one milestone** — the atomic build/verify unit (one branch, one PR, one `verified:` pin). This is the workflow's build verb. It does **not** verify its own work (that's `verify-milestone`, in a separate fresh context) and it does **not** merge (the user does). Its job ends at *built to the done-conditions, handed off to verification*.

The milestone-authoring + verification rules it builds against live in `${CLAUDE_PLUGIN_ROOT}/references/milestones-and-verification.md`; the project's stack mechanics live in `specs/stack-profile.md` (derived against `${CLAUDE_PLUGIN_ROOT}/references/profile-interface.md`). Read both — this skill *applies* them.

## Preconditions

- The milestone's spec exists on `main` with its **done-conditions** (tagged `[auto]`/`[runtime]`/`[attended]`) and its `verification:` line — written by `spec-feature` or `spec-change` and landed in the plan PR. If there's no milestone spec, you're not ready to build; go author it first.
- The feature's mockups (`design/mockups/<feature>/`) and `specs/design.md` exist for a UI milestone (skip for a no-UI milestone, per the profile's Q8).

## The pass

1. **Branch first — before any code.** `git checkout -b <slug>` as the *first* step (off `main`, or off the parent milestone's branch when this one genuinely stacks). Writing code on the wrong branch is the most common recoverable mistake; branching first prevents it.

2. **Read the milestone into context.** Its done-conditions (verbatim) + `verification:` line; the feature spec + its **route→milestone map**; for a UI milestone, **this feature's workbench composition** (the fidelity reference — the real themed primitives per the profile's workbench verb, Q8.3, and the `design.md` design tokens, not generic defaults); the stack profile (how to build/run on this stack).

3. **Build to the done-conditions — all three dimensions.** Logic/invariants, UX completeness (the enumerated states + interactions), and — for a UI milestone — fidelity (design tokens per the profile, themed components, the `design.md` icon / chart / motion libraries, and a layout matching this feature's workbench composition, not platform defaults). The done-conditions are the contract; build to *them*, not to your own idea of "done."

4. **Self-check the `[auto]` conditions as you go** — typecheck, lint, unit/integration tests green before you hand off. This is your own sanity loop, **not** the formal verification: you do not run the `[runtime]` walk to completion as proof here, and you **never write the `verified:` pin** — that is `verify-milestone`'s job, in a fresh context, so no claim is taken on trust.

5. **Halt at stop-points — never silently defer.** If a done-condition needs an action that isn't pre-authorized in the run's envelope (live spend, a paid/irreversible action, a missing credential), **stop and surface it**. Deferring an acceptance gate while later milestones build on top stacks work on unverified code — the failure the framework exists to prevent.

6. **Run-discovered spec drift rides this branch.** If building surfaces a needed change to the spec / `decisions/` / `deferrals/`, make it on *this* milestone's branch (file-per-entry, so parallel branches don't collide) — it's part of this milestone's diff.

7. **Hand off — don't verify, don't merge.** Commit the milestone's code on its branch. Then hand to **`verify-milestone`** (a fresh session/subagent renders the surfaces, drives the actions, and — only on a clean verdict — writes the pin). You never write the pin, never commit to `main`, never merge.

## Boundaries

- **Build and verify never share a context.** You build; an independent `verify-milestone` checks. That separation is what keeps verification honest — don't collapse it by "verifying" your own work here.
- **One milestone, one branch.** Don't build two milestones on one branch. For a feature's worth of milestones in dependency order, that orchestration is `implement-feature`.
- **Never merge, never commit to `main`.** Open work lives on branches; the user merges.

## Where this sits

```
spec-change   → implement-milestone → verify-milestone                 (single milestone)
spec-feature  → implement-feature (orchestrates implement-milestone + verify-milestone per milestone)
```
