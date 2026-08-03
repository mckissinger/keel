---
name: implement-feature
description: Orchestrate building a whole feature's milestones — connective tissue over implement-milestone + verify-milestone, in dependency order, enforcing the branch/PR/stack rules and stopping at the user's merge — UNLESS a committed auto-merge marker (or an active keel:auto mode) authorizes the run to drive landing itself into a prepared review-feature. Spawns fresh-context verifier subagents ([auto] parallel; [runtime] serial unless the profile's isolation contract is proven). Defaults to interleaved cadence but ALWAYS asks. Never merges on its own initiative.
when_to_use: After spec-feature has authored a whole feature's milestone specs, to build and verify them end-to-end. NOT for a single milestone (that's implement-milestone), NOT for checking one completed milestone (that's verify-milestone), and — by default — NOT for merging the reviewed PRs (that's land-feature, under the user's per-merge approval); the one exception is a repo with a valid committed auto-merge marker (or an active mode), where the run drives the land-feature choreography itself and ends at a prepared review-feature.
effort: high
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "\"${CLAUDE_PLUGIN_ROOT}\"/scripts/guard-branch-rules.sh"
---

# Implement Feature

Build a feature's milestones end-to-end. This skill is **connective tissue**: it sequences `implement-milestone` and `verify-milestone` in dependency order and enforces the GitHub process, but **re-implements neither** and — **by default** — **stops at the user's merge** (agents never merge on their own initiative). The one standing exception is a repo the human has armed for committed auto-merge (or an active `keel:auto` mode): there the run continues through landing into a **prepared** `review-feature` (see [Where the run ends](#where-the-run-ends--three-authorization-branches-totally-ordered)).

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

1. **Build** — dispatch `implement-milestone` on its own branch: off `main` if independent, off the parent if it genuinely stacks, off the diamond's **integration branch** if multi-parent. **The build subagent always runs `claude-opus-4-8`; route only its *effort* by the milestone's `Routing:` tag (§4):** set an explicit **`effort` arg on the dispatch (Agent/Task) call** — `reasoning-heavy` → `xhigh`, `mechanical` → `high`. The build model no longer varies by grain — `implement-milestone`'s frontmatter default is already `claude-opus-4-8` — so the per-invocation arg that matters at dispatch is effort, not model (`${CLAUDE_PLUGIN_ROOT}/references/model-routing.md`).
2. **Verify in a fresh context** — dispatch verification as a **subagent with its own context window**. Prompt it from the **spec's done-conditions + the checkout**, never from the builder's claims. **Dispatch the `verifier` at effort ≥ the builder's effort for this milestone** — `reasoning-heavy` → `xhigh`, `mechanical` → `high`, never below the build it audits (`${CLAUDE_PLUGIN_ROOT}/references/model-routing.md`; the reason is `decisions/2026-07-01-model-capability-ledger.md` — an independent check weaker than the builder defeats the self-justification guard). The fresh-context verifier's proof run is the **full** committed suite — its dispatch **forbids** a spec/milestone filter, never scoped to this milestone's own tests (`${CLAUDE_PLUGIN_ROOT}/references/milestones-and-verification.md` §9.1).
   - **`[auto]` conditions** → verifier subagents run in **parallel** (worktrees).
   - **`[runtime]` conditions** → run **serially** — the runtime-proof needs sole access to the shared local services — **unless** the profile carries a **proven Q13 isolation contract** (`specs/stack-profile.md`), in which case each subagent claims its own instance and `[runtime]` milestones verify in **parallel**.
3. **Pin bottom-up** — on a clean verdict, the orchestrator writes the `verified:` pin (the verifier subagent is read-only) and runs the mechanical postcondition checks (`HEAD^` == verified SHA, working tree clean). For a stack, write pins in stack order via clean rebases onto the plan-only pin commits.
4. **Open the PR** — base `main` for an independent milestone, the parent branch for a stacked one. Quote the done-conditions + verification evidence in the body.

Keep the orchestrator's retained state thin (a ledger: slug → branch → PR → verdict → SHA); build and verify detail lives in the subagents.

## Two hard boundaries

- **Verification is independent.** The orchestrator dispatches verification but does not *judge* it; build and remediation are different subagents from verification.
- **Stops at merge — by default.** With **no** committed auto-merge marker and **no** active mode, `implement-feature` ends at *all milestones built, verified, pinned, PRs open with correct bases, stack minimal and bottom-up* — and **the user merges**, exactly as written. The merge-time choreography is `land-feature`'s, under the user's per-merge approval. The one standing exception — a repo armed for committed auto-merge, or an active mode — is the next section; there the run continues through landing, but even then it stops at a **prepared** `review-feature`, never passing it.

## Where the run ends — three authorization branches, totally ordered

Which of three end-states the run reaches is decided in **one fixed order** — the first that applies wins, and they are **mutually exclusive**:

1. **Active `keel:auto` mode** → the **autonomy branch**.
2. **Else a valid committed auto-merge marker** (`.claude/keel-auto-merge.json`, `scope: "project"`, present on the default branch, armed by `keel:arm-auto-merge`) → the **run-through branch**.
3. **Else** → the **"stops at merge" default** above (the user merges).

This order matches the guards' precedence `mode > committed` (the per-session **attended** marker is *not* an `implement-feature` concern — that marker governs an interactive per-merge flow, not this orchestration). **No branch claims an unobservable outcome** — each reports what `gh` and the checks actually returned, never "merged without a prompt" (a queued `--auto` is reported as *queued behind the required checks*, not as *merged*).

### The run-through branch (reached by a committed marker)

The run **continues through landing** instead of stopping at open PRs. It drives the `land-feature` choreography itself — a **bare, un-chained** `gh pr merge <pr> --auto` on each **pinned, gate-passing** PR (the `merge-guard.sh` committed-project row **emits `allow`**; the build-session `guard-branch-rules.sh` row does not emit allow — it **`exit 0` defers** to `merge-guard.sh`) — then runs the **post-wave consolidated check** on `main`, and then **prepares** `review-feature`. This mirrors the autonomy branch's landing step, but is reached by the **committed marker, not a mode** — and the run **states which authorization it is acting under**. The merge mechanics themselves (bottom-up, retarget-before-delete, close+reopen, re-pin, consolidated check, reconciliation) are `land-feature`'s and unchanged; only *who fires the merge command* differs from the default.

### The autonomy branch (reached by an active mode)

Under an active `keel:auto` mode (per `decisions/2026-07-05-autonomy-modes-v2.md` + `decisions/2026-07-genesis-envelope.md`), two gates change: the cadence ask becomes a **ledgered default** (per `keel:auto`'s ledger contract under `specs/runs/<run-id>/`), and "stops at merge" becomes **enable `gh pr merge --auto` on each pinned, gate-passing PR — per the `land-feature` choreography — and proceed**. Everything else (fresh-context verification, pin discipline, the branch guard) is unchanged.

### Both continuing branches PREPARE `review-feature` — neither passes it

The run **prepares** the human's review and **ends there**; it never renders a verdict on it.

- **UI feature:** render the surfaces and **stage the review inputs** (the activation driver, screenshots, and the workbench composition to diff against, per `review-feature`'s pass), then **halt at the human aesthetic/completeness judgment** — reporting the feature **built-verified-merged, review prepared, not done**.
- **No-UI feature:** `review-feature` is **skipped** (as its own skill states), and the run reports the feature **done at the consolidated check**.

Either way the **taste gate, the feature-spec sign-off, and the never-auto list are untouched** — the run does not pass, waive, or pre-judge any of them.

### Stop-points vs notify-and-continue

The run asks mid-flight **only at true stop-points**; everything else is recorded and the run proceeds.

- **A stop-point halts the run attended** — surfaced with the five-line gate block (`references/gate-presentation.md`), and the run **ends on it, never silently deferred**. The stop-point set is exactly the un-pre-authorizable set the framework already names: **live/paid/irreversible spend, a missing credential, a red substrate** (routed to the profile's Q12 remedy, never absorbed), **a required `/security-review` finding, a `verify-milestone` `blocked` verdict** (or a `discrepancy` a remediation pass does not clear — a single `discrepancy` is normal build iteration, not a stop-point), **a `merge-guard` `deny`, and a genuine scope change**. This set is the written rule — not a per-run judgment. (The verdict tokens are `verify-milestone`'s own — `clean` / `discrepancy` / `blocked` — there is no `fail` verdict; `blocked` is the state that cannot self-resolve.)
- **Everything else is notify-and-continue:** recorded as a **run-note** (in-transcript, and appended to the run's ledger when one exists under `specs/runs/<run-id>/`), and the run **proceeds to the next independent milestone**. All run-notes are **surfaced together in the final handoff**, so nothing recorded is lost.
- **No new notification infrastructure is invented.** The mechanism is run-notes plus the existing five-line halt; keel has no push channel today, and the required-checks floor means a missed notification never lands unreviewed code. If the harness exposes a push affordance the run *may* additionally use it, but nothing in the flow depends on one.

## Output

The handoff depends on which authorization branch the run took, and always reports **each lifecycle gate's derived state** — the pins and PRs this run produced, and the gates still open — plus **every run-note gathered along the way, surfaced together**:

- **Default (no marker, no mode):** a feature whose milestones are all built, independently verified, and pinned, PRs open and correctly based — handed to the user for merge (`land-feature`), then `review-feature`. Gates still open: the user's merges, `land-feature`'s reconciliation + consolidated check, `review-feature`.
- **Run-through (committed marker) or autonomy (mode):** the milestones are additionally **landed** (each via a gate-passing `--auto`) and the consolidated check has run on `main`; the run ends at a **prepared** `review-feature`. For a UI feature the handoff reports it **built-verified-merged, review prepared, not done**, with the review inputs staged; for a no-UI feature it reports the feature **done at the consolidated check**. The taste gate, the feature-spec sign-off, and the never-auto list remain the human's — the run never rendered a verdict on them.
