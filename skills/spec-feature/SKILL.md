---
name: spec-feature
description: Deeply spec ONE feature before building it — a single attended session that interviews the feature (every screen, state, interaction, edge), composes its screens from the already-decided design system's real workbench components, and authors its milestones with logic + UX-completeness + fidelity done-conditions.
when_to_use: Once per feature, after the kickoff foundation + design system exist, right before that feature is built (or in a batch of per-feature sessions before a build run). NOT for the app-level skeleton (that's spec-foundation), NOT for exploring a design direction (that's app-design-directions, done once).
---

# Feature Spec

Plan **one feature** to a depth that survives a fresh build session. The app foundation and design system were decided once at kickoff (`spec-foundation`, `app-design-directions`); here you go *deep* on one feature so the build produces what you pictured, not a generic default.

One feature = one attended session, ending on your sign-off. The build runs in a **fresh session** afterward (the spec must be self-contained enough to build from cold), then `/verify-milestone`, then `review-feature`.

## Preconditions

The three movements assume four kickoff outputs exist: `specs/00-product.md` (the feature backlog), `specs/01-architecture.md` (data model + environment contract), `specs/design.md` + the built component gallery, and a green `provision`. When they do, pick the feature from `00-product.md`'s backlog + build order — spine-journey features first (a usable walking skeleton) — and run the movements below.

When some are **missing**, triage:

- **A genuinely fresh, multi-feature greenfield app** → run the kickoff sequence first (`kickoff` / `spec-foundation`).
- **One feature against an existing codebase, or a small/contained product that consumes an existing engine / app / platform** → don't run the full kickoff. Follow **`references/no-foundation.md`**: it satisfies each missing precondition by *discovering it from the existing code*, establishes the design referent Movement 2 needs, and seeds a minimal foundation, then returns you to the movements below.

The milestone-authoring + verification rules are in **`${CLAUDE_PLUGIN_ROOT}/references/milestones-and-verification.md`** — read it; this skill *applies* those rules per feature and adds the per-feature design step. Do not restate them.

## The three movements (one session, in order)

### 1. Interview the feature (deep)

Apply the `interview` discipline but at **feature depth**. Resolve:

- **Every screen/surface** this feature adds or touches, and what each shows.
- **Every state** per surface: empty/first-run (most-skipped), loading, error, partial, and the populated happy path.
- **Every interaction**: sort, filter, search, inline-edit, bulk action, keyboard, drag. Name them; don't leave them to builder defaults.
- **The exact data** each surface shows (fields, formats, derived values) — from the real data model in `01-architecture.md`.
- **The edges**: permissions/role differences, validation, conflicts, the worst-case screen.
- **Cross-feature seams**: what existing surface this feature mounts into or links to — name the integration seam now, per the shared rules, or it's discovered at merge.

**Scoped reference research — flows, not looks.** When a design-reference MCP is connected and the feature has user-facing flows, the **flow-level pull runs by default** (Mobbin's `search_flows`) for **interaction patterns**. Run it per `visual-reference.md`'s **delegation mechanics only** (a subagent that hands back compact text, never raw volume into this session), with the extraction **flow-shaped** and explicitly **not** that file's looks deconstruction pass (palette/type/density/depth), which stays **banned in this movement**. **With no design-reference MCP connected, proceed text-only and record that mode.** Findings land as **UX-completeness done-conditions**, never as tokens or visual choices; reference pulls for *looks* stay gated at Movement 2's two cases and nowhere else.

End with a one-paragraph feature definition and the resolved decision list. If you can't write that paragraph, you're not done interviewing. Then **synthesize that understanding (plus any stack-profile delta) and get the user's explicit sign-off before Movement 2 — the confirm-before-author gate.** Don't compose or author until the interview is confirmed.

### 2. Design the feature's screens (compose the real workbench)

**No mockups are produced here** — no standalone artifact to approve *as the design*. You are shown the **real workbench composition** — this feature's screens assembled from the already-themed gallery components — and the **named workbench components are the fidelity reference** the build matches and the verifier diffs against. The one exception is the optional **divergence sketch** for a genuinely novel archetype (below) — not the spec, not a deliverable.

**Skip this movement for a no-UI feature** (the profile's has-UI? verb, Q8.1): go to Movement 3 with two-dimension done-conditions (logic + behavioral completeness, no fidelity). Otherwise compose **this feature's** screens from the real workbench components:

- **Compose from the locked system, don't re-explore.** `specs/design.md` and the built gallery — the **real workbench** (Q8.3), the durable fidelity source of truth — own the palette, type, density, material palette (icons, motion, charts, primitives), and the signature element. Assemble the feature's screens from those real themed primitives; for the craft the system leaves open (motion, micro-interactions) apply `${CLAUDE_PLUGIN_ROOT}/references/interaction-craft.md` and turn its principles into **fidelity done-conditions** (motion as tokens). **Do not run `app-design-directions`** — the direction is locked.
- **Compose the screens into a feature story / preview.** Assemble this feature's distinct screens/states from the real workbench components (Q8.3): real themed primitives in this feature's layout, carrying its real states with real domain data. This composition is the fidelity reference a verifier diffs against (§6 — not a static HTML file). **At spec time the reference is *named*, not built as code** (realized as real components at **build** time), so the plan PR stays plan-only (`specs/**` + `design/**`): point each pure-composition screen's fidelity done-condition at the **named workbench/gallery components** it composes — never at nothing — and if a real composed preview route is wanted early, it is **design-gate infrastructure committed on `main`**, never code in the plan PR. A bespoke mockup is **optional and only for a genuinely novel layout archetype** — a **divergence sketch** (`design/mockups/<feature>/<screen>.html`, diverge-cheap / converge-real) that is **never the re-implemented spec**. In the two looks-pull cases — this novel-archetype case and the gallery-absent content type below, **and only those two** — **when a design-reference MCP is connected the reference pull per `visual-reference.md`'s mechanics runs by default** (source ladder, subagent delegation, deconstruction before use), with **lineage (reference URLs + extraction notes) recorded in the feature spec**. Lineage may cite **only pulls that preceded the divergence point** — before the sketch (novel-archetype) or before the **primitive's design** (content-grain, no sketch); a citation stapled on afterward is banned. **Pure recomposition (content grain, next bullet) stays reference-free — it triggers no reference pull:** the chosen archetype converges into the real composed workbench story at build time.
- **Pure recomposition is content-grain — and a gallery-absent content type becomes a new workbench primitive.** A screen is pure recomposition **only when every content type it renders already exists in the gallery**. A content type the gallery lacks — an email/message view, a timeline, rich text, an activity feed — is novel at *content* grain even when its screen archetype is standard, and **triggers the reference pull per `visual-reference.md`'s mechanics for that content type** (delegation, lineage, pull-timing per the previous bullet). It becomes a **new themed workbench primitive**, added to the gallery in every state (Q8.3) exactly as controls are — **never improvised inline**; the milestone adding the surface owns adding the primitive, and the screen's fidelity done-condition **names that primitive**. The scar: an email panel's sender/subject/body rendered as identical body text — the composition named the containers, the content had no primitive and no condition.
- **You redline it.** **Capture the composed feature story / preview** (per the profile's screenshot / review driver, Q8.4 — `open` on macOS / `xdg-open` for the web reference) and present it for sign-off. The direction was redlined once at kickoff; each feature's *screens* are redlined here — clean compositions you may trust-and-proceed. The feature isn't ready to spec until the screens are signed off (or explicitly waved through).

### 3. Author the feature's milestones

Decompose the feature into 1–5 milestones (the build/verify unit) per `${CLAUDE_PLUGIN_ROOT}/references/milestones-and-verification.md`. For this feature:

- **Done-conditions span all three dimensions** (§2): logic/invariants, **UX completeness** (the enumerated states + interactions from movement 1), and **fidelity** — tokens/fonts/themed-components/icon-set/charts, **layout matches this feature's own workbench composition from movement 2** (by reference — the real themed gallery per Q8.3, **not a static HTML file**), and **motion + interaction-states specced as tokens** (§6 + the profile's motion verb, Q8.5 — named easing/duration and hover/pressed/focus/disabled deltas, plus reduce-motion).
- **Tag each done-condition `[auto]` / `[runtime]` / `[attended]`** (§2, §7). **Route the deterministic core of every interaction to a committed test tier** (Q11 — component-render or e2e), tagged `[auto]`: an open/close, a focus order, an edit that commits, a filter that re-derives are committed-test material, not walk material. Reserve `[runtime]` for what only a live runtime proves — the surface activates on dev + prod builds, the live call works, the system was visually applied — and have each `[runtime]` condition **name the committed test** covering its deterministic core (missing coverage blocks the pin, §3/§5). Nothing is inferred from a passing *unit* test alone.
- **Check every done-condition against §1's three authoring anti-patterns** (owned by the shared rules, not restated).
- **Every screen/route of the feature is owned by exactly one milestone** (§6), including detail/utility ones. Carry the route→milestone map in the feature spec.
- **Author the feature spec's Lifecycle section** in `specs/features/<slug>.md`, enumerating the gates applicable to *this* feature (the composition/redline sign-off and `review-feature` entries present only for a UI feature, Q8.1), each entry naming the gate **and where its state derives from**: the sign-off in this spec, the plan PR, each milestone's `verified:` pin + code PR, the post-wave consolidated check, the spec reconciliation commit, `review-feature` + its refinement milestone. Each entry records a **fact with evidence** (date, PR number, SHA, spec pointer), not free current-phase prose ("currently building"); the section is evidence pointers, never stored status — spec-foundation's derived-status rule holds unchanged.
- **Name the verification method** per milestone (§3): verifier subagent / dynamic workflow + the committed suites for `[auto]`, **plus the narrowed runtime walk for any milestone that adds/changes a surface or a state-changing action** (activation on dev + prod build, the vision/fidelity diff, capped-key live variant for AI milestones, and the exploratory pass — the action→effect assertions live in the committed tests), plus `/security-review` pre-pin for any milestone touching a hard invariant. The runtime walk gates the pin and runs from `/verify-milestone`, not the parallel sweep.
- **Size + mark parallelizable** (§4); design any shared collector as file-per-entry; name the integration seams.
- **Flag stop points** — any done-condition needing un-pre-authorizable spend/action halts the run attended; never silently defer.

Write the feature spec to **`specs/features/<feature>.md`** (the interview outcome; a mandatory one-line **`flow research:`** entry — the mode that ran + the findings that became UX-completeness done-conditions, or `skipped: <reason>` for a feature with no user-facing flow; the workbench composition + any divergence sketches + redline notes, plus any sketch's **reference lineage** (URLs + extraction notes); the route→milestone map; the **Lifecycle** section) and the per-milestone files to **`specs/milestones/<slug>.md`** (self-contained: goal, done-conditions, verification). Commit on the spec branch.

Then, still in-session, **run the adversarial plan pass** (§5): dispatch the read-only verifier with the six plan-shaped questions against the drafted specs and fix its findings before the plan PR opens.

## Output + handoff

The session ends **attended**, on your sign-off of the composed feature story / preview + the milestone list. Then:
- **Open the plan PR** — a **plan-only** PR (only `specs/**` + `design/**`, no code) carrying the feature spec, any divergence sketches, the milestone *specs* (done-conditions + `verification:`, **no** `verified:` pin yet), and any new `decisions/`/`deferrals/`. The workbench composition is the fidelity *reference* (named by Q8.3 in each milestone's done-conditions), converged into real components at build time. The verified-pin gate exempts a plan-only PR, so the milestone specs land without pins (each pin is appended later in its code PR). Merging makes the plan canonical on `main` so the build reads it from there. You open it; the human reviews + merges.
- **Build in a fresh session** (`implement-feature` over the milestones — it runs `implement-milestone` + `verify-milestone` per milestone) — the spec + workbench composition reference carry it cold from `main`.
- **`/verify-milestone`** (fresh) per the pinned-record gate — appends each milestone's `verified:` pin in its own code PR.
- **`review-feature`** — the human aesthetic/completeness gate, rendered-vs-workbench-composition, before the feature counts as done.

## Under an active autonomy mode

Under `keel:auto run` (per `decisions/2026-07-autonomy-modes.md`), the confirm-before-author gate and the redline become a **ledgered synthesis**: take the recorded defaults, write the synthesis and the composed reference to the run ledger per `keel:auto`'s ledger contract, and proceed; the user adjudicates at the debrief. The feature spec's `flow research:` line and any sketch lineage double as the run-ledger record for those steps — no new gate. The done-condition standard, the plan pass, and the plan PR are unchanged. Outside a mode, the attended gates above hold exactly.

## Cadence — interleaved or batched, both valid

- **Interleaved (recommended):** spec one feature → build → review → spec the next, each spec informed by the prior ones' rendered reality.
- **Batched / up-front:** run several spec-feature sessions first, then build in one autonomous stretch — preserves per-feature depth, gives up cross-feature learning. If you batch, **re-check the not-yet-built feature specs whenever a build surfaces something structural** (a data-model or design-system change).
- **By wave:** spec a wave of independent features together, build concurrently, review, then spec the next wave informed by the review.

Pick the cadence per project; the skill works the same.
