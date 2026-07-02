---
name: auto
description: Enter one of keel's two human-triggered autonomy postures — `keel:auto feature <slug>` (unattended build-verify-pin-land of one feature) or `keel:auto run [scope]` (from any project state, spec + build + land continuously, ledgering every would-be ask) — audit the entry state, pass the preflight, write the mode file, orchestrate the existing verbs, and end at the mandatory per-feature debrief.
when_to_use: Human-triggered only, when the user explicitly starts an autonomy run. Args — `feature <slug>` / `run [scope]`. NOT for an attended feature build (that's implement-feature) or a single milestone (implement-milestone). The agent never invokes this skill to escalate its own autonomy — the human invocation IS the authorization.
disable-model-invocation: true
---

# Auto

Run keel unattended, inside the one carve-out the doctrine grants. `decisions/2026-07-autonomy-modes.md` is the authority this skill executes: per-merge human approval is delegated to **GitHub's server-side required checks — never to agent judgment** — *only* under an active mode entered by an explicit human invocation. This skill is that invocation's runbook. It is **connective tissue**, like `kickoff`: it sequences the existing verbs (`spec-feature`, `implement-feature`, the `land-feature` choreography, `review-feature`) under the mode's contract and re-implements none of them.

Two postures, one skill:

- **`auto:feature <slug>`** — one feature, already specced attended; build, verify, pin, and land it unattended; debrief at feature end.
- **`auto:run [scope]`** — a **posture, not a phase**: invocable at any project state, half-built included. It takes recorded defaults silently, ledgers every would-be ask, lands continuously, and debriefs per feature, batched at run end.

Run the seven steps below **in order** — each is a gate for the next.

## 1. Entry-state audit — the run's definition of done

Before anything is written, establish where the project sits on the **grain ladder** from `specs/` + git state: what `specs/00-product.md`'s backlog lists, which features have deep specs (`specs/features/`), which milestones exist / are pinned / are merged (`specs/milestones/`, `_landed/`, open PRs, branch state). From that position, write down **the run's definition of done for the given scope** — the concrete list of features/milestones this run will take from their current state to landed-and-debrief-pending.

Any entry point is valid — that is what "posture, not phase" means. A feature specced attended **just builds**. An unspecced feature in scope gets `spec-feature` in **default-taking mode** with the synthesis ledgered (step 5). A half-built feature resumes from its open branches/PRs. The audit's output is the run's charter; commit it as the run ledger's first entry.

## 2. Preflight gate — before the mode file exists

`scripts/check-auto-preflight.sh` must **pass before the mode file is written**. It is the hard entry gate (canonical in keel's `scripts/`, contract prose in `skills/provision/SKILL.md`'s auto-provision envelope): command inventory vs the committed allowlist, the required checks actually *required* in branch protection, every contracted env-var name resolving. A headless run aborts after repeated classifier blocks, so an undrained gap kills the run rather than pausing it — which is why this is checked mechanically up front.

**A preflight failure ends the sitting attended.** Fix the gaps with the user at the keyboard (or via provision's envelope), re-run the preflight, and only then proceed. Never fix a preflight failure by widening permissions mid-run.

## 3. The mode file — this skill is the only writer

On a green preflight, write `.claude/keel-autonomy.json` **exactly per the m2 contract in `scripts/merge-guard.sh`'s header** (the reading owner): fields `level` (`"feature"` / `"run"`), `scope`, `created`, `invoker`; **untracked, never committed** (a git-tracked copy is treated as a spoof). The write path is the authorization trail — this skill, human-triggered, is the **only** writer; no other skill, agent, or session creates, edits, or extends that file. **Remove it at run end**, on every exit path: run complete, stop-point halt, or abort. A stale mode file left behind is a standing escalation — clearing it is part of the run, not housekeeping.

## 4. Orchestration

Both postures drive the existing verbs; the mode changes *which gates exist* (the m2 guard's one changed decision-table row), never how the work is done.

- **`auto:feature`** — drive **`implement-feature`** over the one feature's milestones (build via `implement-milestone`, fresh-context `verify-milestone`, pin, PR — all its rules unchanged), and land each pinned, gate-passing PR via **`gh pr merge --auto`, per the `land-feature` choreography** — bottom-up ordering, retarget-before-delete, close+reopen to re-fire CI, re-pin after a forced rebase, the post-wave consolidated check, the spec reconciliation. That choreography is **`land-feature`'s to specify; follow it there, never re-derive it here**. `--auto` hands the merge to the required checks: GitHub merges when and only when they pass.

- **`auto:run`** — iterate over the scope, feature by feature from the audit's charter: **`spec-feature` (default-taking, synthesis ledgered, for an unspecced feature) → build (`implement-feature`, as above) → land (the `--auto` path, as above)** — then the next feature. Plan PRs land by the same `--auto` path with plan-lint as their required check. The run ends when the charter's definition of done is met or a stop-point halts it.

## 5. The ledger contract (owned here)

**Every would-be ask becomes a recorded deferral.** Each gate that would have stopped for the user — a cadence question, a confirm-before-author synthesis, a redline, a design pick, a punch-list confirmation — writes a **file-per-entry** record under **`specs/runs/<run-id>/`** (per the shared rules' no-shared-file discipline, so parallel work never collides) carrying three things: the **decision** taken, the **rationale**, and **the artifact it would have shown** (the synthesis paragraph, the composed screens' capture, the comparison gallery — by path or inline). Each entry is **committed with the work it explains**, on that work's branch, so the merged history carries its own justification. Silent deferral stays banned; *recorded* deferral is the mode's contract. The eight mode-aware skills reference this contract — it is specified here, once.

## 6. The debrief mandate (owned here)

**The run is not complete until the debrief happens.** Adjudication is batched per feature into a **`review-feature` sitting** — `auto:feature` debriefs its one feature at feature end; `auto:run` debriefs each feature in scope, batched at run end. At that sitting the user judges the rendered features against their references **and adjudicates the run's ledger entries**. Until then, a feature is *built-verified-merged* — **never *feature-done***. Flagged gaps become refinement milestones (a candidate next auto run). This mandate is specified here, once; `review-feature` schedules against it.

## 7. Stop-points — semantics unchanged

A stop-point under a mode is what it always was: **halt and surface, never route around, never widen permissions mid-run.** A genuine block (an unenveloped action, a missing credential, un-pre-authorized spend) ends the run's forward motion at that point; remove the mode file, report the halt, and wait attended. The **never-auto list is `decisions/2026-07-autonomy-modes.md` §(d)'s** — it lives there alone and is not restated here or anywhere else; what it names stays attended under every posture, including these.

## Boundaries

- **Delegation is to the required checks, never to agent judgment** (the decisions entry §(e)): only the canonical `gh pr merge --auto` shape on a gate-passing PR is allowed under a mode; plain `gh pr merge` stays ask; a gate failure stays deny. No session ever decides a PR is good enough — it hands the PR to the checks that decide.
- **The build-session branch guard is untouched** — build sessions still never merge; landing runs from the orchestrating session.
- **This skill never widens the harness's permission posture** and never treats a blocked call as something to work around: the mode changes which gates exist via the m2 guard path, nothing else.
- **One writer, one clearer**: the mode file exists only between this skill's step 3 and the run's end.
