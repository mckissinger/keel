---
name: spec-feature
description: Deeply spec ONE feature before building it — a single attended session that interviews the feature (every screen, state, interaction, edge), mocks its screens from the already-decided design system, and authors its milestones with logic + UX-completeness + fidelity done-conditions. Use per feature, after the kickoff foundation + design system exist, right before that feature is built (or in a batch of per-feature sessions before a build run). NOT for the app-level skeleton (that's spec-foundation), NOT for exploring a design direction (that's app-design-directions, done once).
---

# Feature Spec

Plan **one feature** to a depth that survives a fresh build session. This is the per-feature unit the redesign adds between the app skeleton and the milestones: the app foundation and design system were decided once at kickoff (`spec-foundation`, `app-design-directions`); here you go *deep* on a single feature — interview it, design its screens from the locked system, and author its milestones — so the build produces what you pictured, not a generic default.

One feature = one attended session, ending on your sign-off. The build runs in a **fresh session** afterward (the spec must be self-contained enough to build from cold — that's the forcing function for spec quality). Then `/verify-milestone`, then `review-feature`.

## Preconditions

This skill's three movements assume four kickoff outputs already exist: `specs/00-product.md` (the feature backlog), `specs/01-architecture.md` (data model + environment contract), `specs/design.md` + the built component gallery, and a green `provision`. When they do, pick the feature from `00-product.md`'s backlog + build order — spine-journey features first, so early work is a usable walking skeleton — and run the three movements below.

When some or all are **missing**, triage before bailing to kickoff:

- **A genuinely fresh, multi-feature greenfield app** → you're not ready to spec a feature; run the kickoff sequence first (`kickoff` / `spec-foundation`). A global plan over many features is cheaper to decide once, up front, than to back-fill one feature at a time.
- **One feature against an existing codebase, or a small/contained product that consumes an existing engine / app / platform** → don't run the full kickoff. Follow **`references/no-foundation.md`**: it satisfies each missing precondition by *discovering it from the existing code* (what kickoff would have authored), establishes the design referent Movement 2 needs, and seeds a minimal foundation as it goes — then returns you to the three movements below.

The milestone-authoring + verification rules are in **`${CLAUDE_PLUGIN_ROOT}/references/milestones-and-verification.md`** — read it; this skill *applies* those rules per feature and adds the per-feature design step. Do not restate them.

## The three movements (one session, in order)

### 1. Interview the feature (deep)

Apply the `interview` discipline — restate the goal, surface open decisions, default what's defaultable, ask only what can't be defaulted, batch into one round — but at **feature depth**, not app-skeleton breadth. For relentlessness on a fuzzy feature, lean on `grill-me`. Resolve:

- **Every screen/surface** this feature adds or touches, and what each shows.
- **Every state** per surface: the empty/first-run (no-data) state, loading, error, partial, and the populated happy path. The empty state is the one most often skipped and most often what makes a feature feel half-built.
- **Every interaction**: sort, filter, search, inline-edit, bulk action, keyboard, drag — whatever this feature needs. Name them; don't leave them to the builder's defaults.
- **The exact data** each surface shows (fields, formats, derived values) — pulled from the real data model in `01-architecture.md`.
- **The edges**: permissions/role differences, validation, conflicts, the worst-case screen.
- **Cross-feature seams**: what existing surface this feature mounts into or links to (the integration seam — name it now, per the shared rules, or it's discovered at merge).

End the interview with a one-paragraph feature definition and the resolved decision list. If you couldn't write that paragraph, you're not done interviewing.

### 2. Design the feature's screens (from the locked system)

Mock **this feature's** screens — not generic archetypes — composing from the already-decided design system:

- **Compose from the system, don't re-explore.** `specs/design.md` and the built component gallery own the palette, type, density, material palette (icons, motion, charts, primitives), and the signature element. Assemble the feature's screens from those primitives; for craft defaults the system leaves open, lean on `taste-skill` / `emil-design-eng`. **Do not run `app-design-directions`** — the direction is locked; re-exploring it per feature is wrong.
- **One mockup per distinct screen/state of this feature**, self-contained HTML with real domain data and real states (not just the happy path), under `design/mockups/<feature>/<screen>.html`. These carry *this feature's* intent — which is exactly what a shared app-wide archetype could not, and the reason past builds drifted generic.
- **You redline them.** Present the feature's mockup set for the user's sign-off. The direction was redlined once at kickoff; each feature's *screens* are redlined here. The feature isn't ready to spec until the screens are signed off.

### 3. Author the feature's milestones

Decompose the feature into 1–5 milestones (the build/verify unit) per `${CLAUDE_PLUGIN_ROOT}/references/milestones-and-verification.md`. For this feature:

- **Done-conditions span all three dimensions** (§2 of the rules): logic/invariants, **UX completeness** (the enumerated states + interactions from movement 1), and **fidelity** (tokens/fonts/themed-components/icon-set/charts + **layout matches this feature's own mockup from movement 2**, by reference, not prose).
- **Tag each done-condition `[auto]` / `[runtime]` / `[attended]`** (§2, §7) so every later session knows what it can close and what gates the pin. Anything that's "a route renders," "an action runs," "the live call works," or "the system was applied" is `[runtime]` — it does not get inferred from a passing unit test.
- **Every screen/route of the feature is owned by exactly one milestone** (§6) — including the obvious detail/utility ones. Carry the route→milestone map in the feature spec.
- **Name the verification method** per milestone (§3): verifier subagent / dynamic workflow for `[auto]`, **plus the runtime walk for any milestone that adds/changes a route or server action** (render + action-through-the-real-runtime, dev + prod build; capped-key live variant for AI milestones), plus `/security-review` pre-pin for any milestone touching a hard invariant. The runtime walk gates the pin and runs from `/verify-milestone`, not the parallel sweep.
- **Size + mark parallelizable** (§4); design any shared collector as file-per-entry; name the integration seams.
- **Flag stop points** — any done-condition needing un-pre-authorizable spend/action halts the run attended; never silently defer.

Write the deep feature spec to **`specs/features/<feature>.md`** (the interview outcome, the mockup set + redline notes, the route→milestone map) and the per-milestone files to **`specs/milestones/<slug>.md`** (self-contained: goal, done-conditions, verification). Commit on the feature's spec branch.

## Output + handoff

The session ends **attended**, on your sign-off of the mockups + the milestone list. Then:
- **Open the plan PR** — a **plan-only** PR (only `specs/**` + `design/**`, no code) carrying the feature spec, the mockups, the milestone *specs* (done-conditions + `verification:`, **no** `verified:` pin yet), and any new `decisions/`/`deferrals/`. The verified-pin gate exempts a plan-only PR, so the milestone specs land without pins (each pin is appended later in its milestone's code PR). Merging it makes the plan canonical on `main` so the build reads it from there, not a floating branch — this matters most under batched / by-wave cadence. You open it; per the project's rules the human reviews + merges.
- **Build in a fresh session** (`/goal` over the feature's milestones) — the spec + mockups carry it cold from `main`.
- **`/verify-milestone`** (fresh) per the pinned-record gate — appends each milestone's `verified:` pin in its own code PR.
- **`review-feature`** — the human aesthetic/completeness gate, rendered-vs-mockup, before the feature counts as done.

## Cadence — interleaved or batched, both valid

- **Interleaved (recommended):** spec one feature → build → review → spec the next, so each feature's spec is informed by the rendered reality of the prior ones. This is where the feedback loop the redesign restores actually lives.
- **Batched / up-front:** run several spec-feature sessions first, then build them in one autonomous stretch. This preserves per-feature depth (the main fix) and suits a clean uninterrupted build run; it only gives up cross-feature learning. If you batch, **re-check the not-yet-built feature specs whenever a build surfaces something structural** (a data-model or design-system change), since they were written against the old assumption.
- **By wave:** spec a wave of independent features together, build them concurrently, review, then spec the next wave informed by the review — the middle ground that keeps build parallelism and a feedback checkpoint.

Pick the cadence per project; the skill works the same either way.
