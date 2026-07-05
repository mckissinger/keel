---
name: auto
description: Enter one of keel's three human-triggered autonomy postures — `keel:auto feature <slug>` (unattended build-verify-pin-land of one feature), `keel:auto run [scope]` (from any project state, spec + build + land continuously, ledgering every would-be ask), or `keel:auto genesis "<idea>"` (a raw idea → an attended research + approval gate → an unattended bootstrap-and-build to a preview-deployed product) — audit the entry state, pass the preflight, write the mode file, orchestrate the existing verbs, and end at the mandatory per-feature debrief.
when_to_use: Human-triggered only, when the user explicitly starts an autonomy run. Args — `feature <slug>` / `run [scope]` / `genesis "<idea>"`. NOT for an attended feature build (that's implement-feature) or a single milestone (implement-milestone). The agent never invokes this skill to escalate its own autonomy — the human invocation IS the authorization.
disable-model-invocation: true
---

# Auto

Run keel unattended, inside the one carve-out the doctrine grants. `decisions/2026-07-autonomy-modes.md` is the authority this skill executes: per-merge human approval is delegated to **GitHub's server-side required checks — never to agent judgment** — *only* under an active mode entered by an explicit human invocation. This skill is that invocation's runbook. It is **connective tissue**, like `kickoff`: it sequences the existing verbs (`spec-feature`, `implement-feature`, the `land-feature` choreography, `review-feature`) under the mode's contract and re-implements none of them.

Three postures, one skill:

- **`auto:feature <slug>`** — one feature, already specced attended; build, verify, pin, and land it unattended; debrief at feature end.
- **`auto:run [scope]`** — a **posture, not a phase**: invocable at any project state, half-built included. It takes recorded defaults silently, ledgers every would-be ask, lands continuously, and debriefs per feature, batched at run end.
- **`auto:genesis "<idea>"`** — a raw product idea, no repo yet. An **attended Phase 1** (research fan-out → one rejectable approval artifact) crosses a **single human approval gate** into an **unattended Phase 2** that bootstraps a repo against the template contract and drives the existing verbs to a preview-deployed product. Its full contract is the **Genesis posture** section below; steps 1–7 are its Phase 2 spine once the mode file is written.

`auto:feature` and `auto:run` run the seven steps below **in order** — each a gate for the next. `auto:genesis` runs its own Phase 1 first (the Genesis posture section), then enters these same steps at Phase 2.

## 1. Entry-state audit — the run's definition of done

Before anything is written, establish where the project sits on the **grain ladder** from `specs/` + git state: what `specs/00-product.md`'s backlog lists, which features have deep specs (`specs/features/`), which milestones exist / are pinned / are merged (`specs/milestones/`, `_landed/`, open PRs, branch state). From that position, write down **the run's definition of done for the given scope** — the concrete list of features/milestones this run will take from their current state to landed-and-debrief-pending.

**First input when present: the most recent `specs/runs/*/charter.md`.** An immediately-preceding `kickoff` sitting writes its synthesis there — backlog, build order, resolved decisions, definition of done — so read it as the audit's starting point instead of re-deriving that state from cold; reconcile it against current `specs/` + git state (a charter can be stale if work landed since). With **no** charter present, the audit proceeds from `specs/` + git state exactly as above, unchanged. A charter is a *seed*, never the authorization — this human `keel:auto` invocation is what enters the posture.

Any entry point is valid — that is what "posture, not phase" means. A feature specced attended **just builds**. An unspecced feature in scope gets `spec-feature` in **default-taking mode** with the synthesis ledgered (step 5). A half-built feature resumes from its open branches/PRs. The audit's output is the run's charter; commit it as the run ledger's first entry.

## 2. Preflight gate — before the mode file exists

`scripts/check-auto-preflight.sh` must **pass before the mode file is written**. It is the hard entry gate (canonical in keel's `scripts/`, contract prose in `skills/provision/SKILL.md`'s auto-provision envelope): command inventory vs the committed allowlist, the required checks actually *required* in branch protection, every contracted env-var name resolving. A headless run aborts after repeated classifier blocks, so an undrained gap kills the run rather than pausing it — which is why this is checked mechanically up front.

**A preflight failure ends the sitting attended.** Fix the gaps with the user at the keyboard (or via provision's envelope), re-run the preflight, and only then proceed. Never fix a preflight failure by widening permissions mid-run.

## 3. The mode file — this skill is the only writer

On a green preflight, write `.claude/keel-autonomy.json` **exactly per the m2 contract in `scripts/merge-guard.sh`'s header** (the reading owner): fields `level` (`"feature"` / `"run"`), `scope`, `created` (a real ISO-8601 UTC timestamp — `date -u +%Y-%m-%dT%H:%M:%SZ`), `invoker`; **untracked, never committed** (a git-tracked copy is treated as a spoof). The write path is the authorization trail — this skill, human-triggered, is the **only** writer; no other skill, agent, or session creates, edits, or extends that file. **Remove it at run end**, on every exit path: run complete, stop-point halt, or abort. A stale mode file left behind is a standing escalation — clearing it is part of the run, not housekeeping. **TTL: 24h.** The guards honor the mode file only while `created` is within 24 hours of now; past that it is treated as absent (a backstop against a crashed run's leftover file arming a later session — clearing it is still your job, not the TTL's). There is no refresh path: only a fresh human `keel:auto` invocation renews it.

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

## Genesis posture — `auto:genesis "<idea>"`

The third posture starts from a raw idea with no repo. It has **two phases split by one human approval gate**; everything the doctrine authorizes for the unattended phase is granted by that single approval, per `decisions/2026-07-genesis-envelope.md` (the envelope this section executes) against the contract in `references/template-contract.md`. This section is the Phase 1 + bootstrap contract; once the mode file is written it hands to steps 1–7 above as its Phase 2 spine.

### Phase 1 (attended) — research → one rejectable approval artifact

Before any repo, branch, or mode file exists, run a **research fan-out** that produces exactly **ONE approval artifact** carrying three named parts:

- **(1) a validation assessment** — prior art, demand and feasibility, and an explicit *should-this-exist* recommendation the user can **reject**. This part alone can end the flow.
- **(2) a product skeleton** — a feature backlog, the spine journey, high-level data shapes, and a **service inventory drawn from the sandbox key set by name** (names only, never values).
- **(3) 2–3 throwaway design-direction boards** — cheap, disposable, **direction-picking only**, per the diverge-cheap/converge-real rule. They are not the workbench: the real themed workbench is built later by `app-design-directions`, taking the approved board as its ledgered input.

**The approval gate has exactly three outcomes: approve (naming a direction), revise (iterate Phase 1), or reject (end the flow, nothing created).** The gate is attended under every circumstance — it is the mode's *entry*, not a ledgerable default — and a rejected assessment **creates nothing**: no repo, no resources, no mode file.

### Phase 2 (unattended) — bootstrap, then the existing verbs

On approval (and only on approval), Phase 2 runs unattended:

1. **Bootstrap the repo** per `references/template-contract.md`, inside the envelope `decisions/2026-07-genesis-envelope.md` grants: **generate-from-scratch (v1)**, tier-1 gates wired and required, the tier-2 stack pruned to the approved service inventory (the prune rule applied). Every credential is wired **by name only** from `~/.config/keel/sandbox.env` — **no genesis session ever reads or prints a sandbox key value**.
2. **Run `scripts/check-auto-preflight.sh`.** **A red preflight is a stop-point that ends the run attended** — never routed around, never patched by widening permissions mid-run. Only a green preflight proceeds.
3. **Write the mode file with `level: "genesis"`** — exactly per the mode-file contract in `scripts/merge-guard.sh`'s header (the reading owner), under the same **24h TTL** the guards enforce, this skill its only writer and clearer (steps 3 and 7 above).
4. **Drive the existing verbs by reference**, re-deriving none of their rules:
   - **`spec-foundation`** in its **Under an active autonomy mode** carve-out (added by this milestone), seeded by the approved skeleton.
   - **`app-design-directions`** in its existing ledgered-pick carve-out, seeded by the approved board.
   - then the **`auto:run` loop** — `spec-feature` → `implement-feature` → the `--auto` land path (step 4 above) — feature by feature.
5. **End at a preview deploy and the debrief.** The **never-auto list is `decisions/2026-07-autonomy-modes.md` §(d)'s** — referenced, never restated — and **genesis ends at preview, never live**.

### Ledger + debrief deltas

Phase 1's approval artifact is committed as the **new repo's first run-ledger entries** (the run ledger contract of step 5 above is otherwise unchanged — by reference, not restated). At the debrief (step 6 above), genesis adds one item: **the Phase 1 validation assessment is revisited against the built reality** at the `review-feature` sitting, alongside the standard adjudication.

## Boundaries

- **Delegation is to the required checks, never to agent judgment** (the decisions entry §(e)): only the canonical `gh pr merge --auto` shape on a gate-passing PR is allowed under a mode — **emit it bare and un-chained** (its own Bash call, nothing bundled), per the emission contract in `scripts/merge-guard.sh`'s header, or the allow forfeits and the run stalls; plain `gh pr merge` stays ask; a gate failure stays deny. No session ever decides a PR is good enough — it hands the PR to the checks that decide.
- **The build-session branch guard is untouched** — build sessions still never merge; landing runs from the orchestrating session.
- **This skill never widens the harness's permission posture** and never treats a blocked call as something to work around: the mode changes which gates exist via the m2 guard path, nothing else.
- **One writer, one clearer**: the mode file exists only between this skill's step 3 and the run's end.
- **Genesis never self-escalates**: the agent never invokes `auto:genesis` to escalate its own autonomy — the human invocation IS the authorization, exactly as for the other two postures.
- **The genesis approval gate is attended under every circumstance** — it is the mode's entry, not a ledgerable default; nothing about `auto:run`'s ledger-the-ask contract lets a session take the approval decision on the user's behalf.
- **No session reads or prints sandbox key values** — genesis wires credentials by name only; a rejected validation assessment creates nothing.
