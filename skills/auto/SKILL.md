---
name: auto
description: Enter one of keel's three human-triggered autonomy postures — `keel:auto feature <slug>` (unattended build-verify-pin-land of one feature), `keel:auto run [scope]` (from any project state, spec + build + land continuously, ledgering every would-be ask), or `keel:auto genesis "<idea>"` (a raw idea → an attended research + approval gate → an unattended bootstrap-and-build to a preview-deployed product) — audit the entry state, pass the preflight, write the mode file, orchestrate the existing verbs, and end at the mandatory per-feature debrief.
when_to_use: Human-triggered only, when the user explicitly starts an autonomy run. Args — `feature <slug>` / `run [scope]` / `genesis "<idea>"`. NOT for an attended feature build (that's implement-feature) or a single milestone (implement-milestone). The agent never invokes this skill to escalate its own autonomy — the human invocation IS the authorization.
disable-model-invocation: true
---

# Auto

Run keel unattended, inside the one carve-out the doctrine grants. `decisions/2026-07-autonomy-modes.md` is the authority this skill executes: per-merge human approval is delegated to **GitHub's server-side required checks — never to agent judgment** — *only* under an active mode entered by an explicit human invocation. Like `kickoff`, this skill is **connective tissue**: it sequences the existing verbs (`spec-feature`, `implement-feature`, `land-feature`, `review-feature`) and re-implements none of them.

Three postures, one skill:

- **`auto:feature <slug>`** — one already-specced feature; build, verify, pin, and land it unattended; debrief at feature end.
- **`auto:run [scope]`** — a **posture, not a phase**: invocable at any project state, half-built included. Takes recorded defaults silently, ledgers every would-be ask, lands continuously, debriefs per feature (batched at run end).
- **`auto:genesis "<idea>"`** — a raw idea, no repo yet. An **attended Phase 1** (research → one rejectable approval artifact) crosses a **single human approval gate** into an **unattended Phase 2** that bootstraps a repo and drives the existing verbs to a preview-deployed product. Full contract in the **Genesis posture** section; steps 1–7 are its Phase 2 spine once the mode file is written.

`auto:feature` and `auto:run` run the seven steps below **in order**, each a gate for the next. `auto:genesis` runs Phase 1 first, then enters at Phase 2.

## 1. Entry-state audit — the run's definition of done

Before anything is written, derive the project's position on the **grain ladder** (backlog, deep specs, milestone pin/merge state) from `specs/` + git. That canonical sweep is the `status` skill's; run its derivation, not ad-hoc. Then write **the run's definition of done for the scope**: the features/milestones this run takes to landed-and-debrief-pending. **First input when present: the most recent `specs/runs/*/charter.md`** — a preceding `kickoff`'s synthesis, read as the starting point and reconciled against current `specs/` + git (it can be stale); with **no** charter it proceeds from those alone. A charter is a *seed*, never the authorization — this human `keel:auto` invocation enters the posture.

Any entry point is valid; an unspecced feature in scope gets `spec-feature` in **default-taking mode**, synthesis ledgered (step 5). Commit the audit's charter as the run ledger's first entry.

## 2. Preflight gate — before the mode file exists

`scripts/check-auto-preflight.sh` must **pass before the mode file is written** — the hard entry gate (canonical in keel's `scripts/`, contract prose in `skills/provision/SKILL.md`'s auto-provision envelope): the command allowlist, the required checks actually *required*, every contracted env-var resolving.

**A preflight failure ends the sitting attended.** Fix the gaps with the user (or via provision's envelope), re-run, then proceed — never by widening permissions mid-run.

## 3. The mode file — this skill is the only writer

On a green preflight, write `.claude/keel-autonomy.json` **exactly per the m2 contract in `scripts/merge-guard.sh`'s header** (the reading owner): `level` (`"feature"` / `"run"`), `scope`, `created` (a real ISO-8601 UTC timestamp — `date -u +%Y-%m-%dT%H:%M:%SZ`), `invoker`; **untracked, never committed** (a git-tracked copy is a spoof). This skill, human-triggered, is the file's **only** writer and clearer — no other skill, agent, or session touches it — so **remove it at run end** on every exit path (complete, halt, or abort); a stale mode file left behind is a standing escalation. **TTL: 24h** — the guards honor the file only while `created` is within 24 hours of now, else treat it as absent; even so, clearing it is your job, not the TTL's. No refresh path: only a fresh human `keel:auto` invocation renews it.

## 4. Orchestration

Both postures drive the existing verbs; the mode changes *which gates exist* (the m2 guard's one changed decision-table row), never how the work is done.

- **`auto:feature`** — drive **`implement-feature`** over the feature's milestones (fresh-context `verify-milestone`, pin, PR — rules unchanged), and land each pinned, gate-passing PR via **`gh pr merge --auto`, per the `land-feature` choreography** — **`land-feature`'s to specify; follow it there, never re-derive it here**. `--auto` hands the merge to the required checks: GitHub merges when and only when they pass.
- **`auto:run`** — iterate the scope feature by feature from the charter: **`spec-feature` (default-taking, synthesis ledgered) → `implement-feature` → the `--auto` land path**, then the next. Plan PRs land by the same `--auto` path with plan-lint as their required check. The run ends when the charter's definition of done is met or a stop-point halts it.

## 5. The ledger contract (owned here)

**Every would-be ask becomes a recorded deferral.** Each gate that would have stopped for the user writes a **file-per-entry** record under **`specs/runs/<run-id>/`** (no-shared-file discipline) carrying the **decision**, the **rationale**, and **the artifact it would have shown** (by path or inline). Each entry is **committed with the work it explains**, on that work's branch. Silent deferral stays banned; *recorded* deferral is the mode's contract. The eight mode-aware skills reference this — specified here, once.

## 6. The debrief mandate (owned here)

**The run is not complete until the debrief happens.** Adjudication is batched per feature into a **`review-feature` sitting** — `auto:feature` at feature end; `auto:run` per feature, batched at run end. There the user judges the rendered features against their references **and adjudicates the run's ledger entries**. Until then a feature is *built-verified-merged* — **never *feature-done***; flagged gaps become refinement milestones. Specified here, once; `review-feature` schedules against it.

## 7. Stop-points — semantics unchanged

A stop-point under a mode is what it always was: **halt and surface, never route around, never widen permissions mid-run.** A genuine block (an unenveloped action, a missing credential, un-pre-authorized spend) ends forward motion — remove the mode file, report the halt, wait attended. The **never-auto list is `decisions/2026-07-autonomy-modes.md` §(d)'s** — it lives there alone, not restated here or anywhere else; what it names stays attended under every posture.

## Genesis posture — `auto:genesis "<idea>"`

This posture starts from a raw idea, in **two phases split by one human approval gate**; everything the doctrine authorizes for the unattended phase is granted by that single approval, per `decisions/2026-07-genesis-envelope.md` against `references/template-contract.md`.

### Phase 1 (attended) — research → one rejectable approval artifact

Before any repo, branch, or mode file exists, a **research fan-out** produces exactly **ONE approval artifact** with three parts:

- **(1) a validation assessment** — prior art, demand, feasibility, and an explicit *should-this-exist* recommendation the user can **reject**; this part alone can end the flow.
- **(2) a product skeleton** — a feature backlog, the spine journey, high-level data shapes, and a **service inventory drawn from the sandbox key set by name** (names only, never values).
- **(3) 2–3 throwaway design-direction boards** — disposable, **direction-picking only**, per diverge-cheap/converge-real. Not the workbench: that is `app-design-directions` later, taking the approved board as its ledgered input.

**The approval gate has exactly three outcomes: approve (naming a direction), revise (iterate Phase 1), or reject (end the flow, nothing created).** The gate is attended under every circumstance — the mode's *entry*, not a ledgerable default; nothing about `auto:run`'s ledger-the-ask contract lets a session take it on the user's behalf. A rejected assessment **creates nothing**: no repo, no resources, no mode file.

### Phase 2 (unattended) — bootstrap, then the existing verbs

On approval (and only on approval), Phase 2 runs unattended:

1. **Bootstrap the repo** per `references/template-contract.md`, inside the envelope `decisions/2026-07-genesis-envelope.md` grants (generate-from-scratch v1, tier-1 gates required, tier-2 pruned to the approved service inventory). Every credential is wired **by name only** from `~/.config/keel/sandbox.env` — **no genesis session ever reads or prints a sandbox key value**.
2. **Run `scripts/check-auto-preflight.sh`.** **A red preflight is a stop-point that ends the run attended** (step 7 semantics). Only a green preflight proceeds.
3. **Write the mode file with `level: "genesis"`** — exactly per the mode-file contract in `scripts/merge-guard.sh`'s header, under the same **24h TTL** the guards enforce, this skill its only writer and clearer (steps 3 and 7 above).
4. **Drive the existing verbs by reference** (no rule re-derived): **`spec-foundation`** in its **Under an active autonomy mode** carve-out (seeded by the approved skeleton), **`app-design-directions`** in its ledgered-pick carve-out (seeded by the approved board), then the **`auto:run` loop** — `spec-feature` → `implement-feature` → the `--auto` land path — feature by feature.
5. **End at a preview deploy and the debrief.** The **never-auto list is `decisions/2026-07-autonomy-modes.md` §(d)'s** — referenced, never restated — and **genesis ends at preview, never live**.

### Ledger + debrief deltas

Phase 1's approval artifact is committed as the **new repo's first run-ledger entries** (the step-5 ledger contract otherwise unchanged, by reference). At the debrief (step 6), genesis adds one item: **the Phase 1 validation assessment is revisited against the built reality**, alongside the standard adjudication.

## Boundaries

- **Delegation is to the required checks, never to agent judgment** (decisions §(e)): only the canonical `gh pr merge --auto` shape on a gate-passing PR is allowed under a mode — **emit it bare and un-chained** (its own Bash call, nothing bundled), per the emission contract in `scripts/merge-guard.sh`'s header, or the allow forfeits and the run stalls; plain `gh pr merge` stays ask, a gate failure stays deny.
- **The build-session branch guard is untouched** — build sessions never merge; landing runs from the orchestrating session. This skill never widens the harness's permission posture and never routes around a blocked call: the mode changes which gates exist via the m2 guard path, nothing else.
- **Genesis never self-escalates** — the agent never invokes `auto:genesis` (or any posture) to escalate its own autonomy; the human invocation IS the authorization. No session reads or prints sandbox key values, and a rejected validation assessment creates nothing.
