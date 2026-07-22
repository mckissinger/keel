---
name: implement-milestone
description: Build ONE milestone to its done-conditions — the atomic build verb. Branch first, build to the spec's done-conditions (honoring the [auto]/[runtime]/[attended] tags and the stack profile's runtime-proof), author the committed tests the conditions name, halt at stop-points, then hand off to verify-milestone. Never self-verifies, never commits to main, never merges.
when_to_use: Use when exactly one milestone needs building and its spec (done-conditions + verification line) already exists on main — directly for a spec-change's single milestone, or invoked per-milestone by implement-feature. Not for a whole feature (that's implement-feature), not for checking completed work (that's verify-milestone), and not before the milestone spec exists (author it first).
model: sonnet
effort: high
allowed-tools: Bash(git checkout -b *), Bash(git branch *), Bash(git add *), Bash(git commit *)
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "\"${CLAUDE_PLUGIN_ROOT}\"/scripts/guard-branch-rules.sh"
---

# Implement Milestone

## Git ground truth (this session, injected at invocation)

- Current branch: !`git branch --show-current`
- Working tree: !`git status --porcelain`

This is the session's actual state for step 2 (**Branch first**): if the branch above is `main` — or any branch that isn't this milestone's — branch before touching any code. If the injected values are missing or stale, fall back to the prose rule in step 2 and run the commands yourself.

Build **one milestone** — the atomic build/verify unit (one branch, one PR, one `verified:` pin). This is the workflow's build verb. It does **not** verify its own work (that's `verify-milestone`, in a separate fresh context) and it does **not** merge (the user does). Its job ends at *built to the done-conditions, handed off to verification*.

The milestone-authoring + verification rules it builds against live in `${CLAUDE_PLUGIN_ROOT}/references/milestones-and-verification.md`; the project's stack mechanics live in `specs/stack-profile.md` (derived against `${CLAUDE_PLUGIN_ROOT}/references/profile-interface.md`). Read both — this skill *applies* them.

## Preconditions

- The milestone's spec exists on `main` with its **done-conditions** (tagged `[auto]`/`[runtime]`/`[attended]`) and its `verification:` line — written by `spec-feature` or `spec-change` and landed in the plan PR. If there's no milestone spec, you're not ready to build; go author it first.
- For a UI milestone: `specs/design.md` + the built workbench/gallery exist, and the feature spec names this feature's **workbench composition** (the fidelity reference the milestone's done-conditions point at). A divergence sketch under `design/mockups/<feature>/` is optional — used when present, never required; a missing `design/mockups/` directory does not block a UI milestone whose spec names its workbench components. (Skip all of this for a no-UI milestone, per the profile's Q8.)

## The pass

1. **Orient first — before branching.** Derive the current state, don't assume it: read the `verified:` pins in `specs/milestones/`, `gh pr list`, and the recent `git log`; re-read *this* milestone's spec + `specs/stack-profile.md` from `main` (not a stale branch copy). The canonical state sweep is owned by the `status` skill — its derivation (pins, PRs, branches, worktrees) is the one to run here rather than an ad-hoc variant. **Entry preflight: run the profile's Q12 substrate health check first** (seconds — daemon responsive, ports owned by *this* project's stack, toolchain resolves, env file present or re-derived via the recorded command, env-var names asserted via the profile's recorded name-check command — never by reading the env file directly); a red substrate is a **stop-point routed to the Q12 signature table's remedy** — never absorbed into the milestone, never debugged ad hoc mid-build. Then run the profile's **cheapest committed rung once** (the Q11 static/lint tier — a few seconds) to confirm a green baseline before you write a line. **A pre-existing red is a stop-point, not something to absorb** — surface it and route to `debug`; building on top of a broken baseline hides which failure your change caused. (Under batched/by-wave cadence the plan on `main` may have moved since it was authored — orienting is how you catch that.)

2. **Branch first — before any code.** `git checkout -b <slug>` as the *first code step* (off `main`, or off the parent milestone's branch when this one genuinely stacks). Writing code on the wrong branch is the most common recoverable mistake; branching first prevents it.

3. **Read the milestone into context.** Its done-conditions (verbatim) + `verification:` line; the feature spec + its **route→milestone map**; for a UI milestone, **this feature's workbench composition** (the fidelity reference — the real themed primitives per the profile's workbench verb, Q8.3, and the `design.md` design tokens, not generic defaults); the stack profile (how to build/run on this stack).

4. **Build to the done-conditions — all three dimensions.** Logic/invariants, UX completeness (the enumerated states + interactions), and — for a UI milestone — fidelity (design tokens per the profile, themed components, the `design.md` icon / chart / motion libraries, and a layout matching this feature's workbench composition, not platform defaults). The done-conditions are the contract; build to *them*, not to your own idea of "done."

5. **Author the committed tests the done-conditions name — tests are part of the build, not of verification.** Every `[auto]` condition's test, and the committed test each `[runtime]` condition names for its deterministic core, in the tiers the stack profile provides (Q11: unit, component-render, end-to-end) — a deterministic interaction (an open/close, a focus order, an edit that commits) gets a component-render or e2e test, never a hope that the walk catches it. Missing coverage blocks the pin at `verify-milestone`, so shipping without the tests just bounces the milestone back. Author every one of them under the shared rules' **§8 test-authoring doctrine** (`${CLAUDE_PLUGIN_ROOT}/references/milestones-and-verification.md` §8 — the cross-stack rules live there, not here). Then **self-check the `[auto]` conditions as you go — run the ladder bottom-up** (static → unit → wiring → e2e, per the profile's Q11 ordering), **single-test-first** (the affected tests, not the whole suite, in the inner loop), all committed suites green before you hand off — every suite run bounded per the profile's **Q12 timeout rule** (the budgets and the bound live there, not here). This is your own sanity loop, **not** the formal verification: you do not run the `[runtime]` walk to completion as proof here, and you **never write the `verified:` pin** — that is `verify-milestone`'s job, in a fresh context, so no claim is taken on trust.

6. **Halt at stop-points — never silently defer.** If a done-condition needs an action that isn't pre-authorized in the run's envelope (live spend, a paid/irreversible action, a missing credential), **stop and surface it**. Deferring an acceptance gate while later milestones build on top stacks work on unverified code — the failure the framework exists to prevent.

7. **Run-discovered spec drift rides this branch.** If building surfaces a needed change to the spec / `decisions/` / `deferrals/` — including **living docs my change made stale** (a feature spec, `00-product.md`, or `01-architecture.md` this milestone invalidates), not just drift I introduced in my own files — make it on *this* milestone's branch (file-per-entry, so parallel branches don't collide) — it's part of this milestone's diff. (This is the per-milestone half of the spec-authority rule; the wave-level half is `land-feature`'s reconciliation step.)

8. **Hand off — don't verify, don't merge.** Commit the milestone's code on its branch. Then hand to **`verify-milestone`** (a fresh session/subagent renders the surfaces, drives the actions, and — only on a clean verdict — writes the pin). You never write the pin, never commit to `main`, never merge.

## Boundaries

- **Build and verify never share a context.** You build; an independent `verify-milestone` checks. That separation is what keeps verification honest — don't collapse it by "verifying" your own work here.
- **One milestone, one branch.** Don't build two milestones on one branch. For a feature's worth of milestones in dependency order, that orchestration is `implement-feature`.
- **Never merge, never commit to `main`.** Open work lives on branches; the user merges.

## Where this sits

```
spec-change   → implement-milestone → verify-milestone                 (single milestone)
spec-feature  → implement-feature (orchestrates implement-milestone + verify-milestone per milestone)
```
