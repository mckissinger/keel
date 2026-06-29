# Feature-spec without a kickoff foundation (existing codebase / no foundation docs)

The path for projects where the four kickoff outputs spec-feature consumes — `00-product.md`, `01-architecture.md`, `design.md` + gallery, a green `provision` — **do not exist**, because the project never ran a greenfield kickoff. Two cases trigger it: a feature against an **existing codebase**, and a **small/contained new product** that consumes an existing engine, host app, or platform rather than standing up its own world.

**The core idea.** spec-feature's three movements are foundation-*independent* in spirit; only its *preconditions* assume a greenfield kickoff authored those four artifacts. In a project with code already on disk, most of what kickoff would have **authored**, you can instead **discover from the code**. So the rule is: satisfy each missing precondition the cheapest correct way — discover it where it already exists, author the minimum where it doesn't — and **seed a thin foundation as you go**, so it accretes feature-by-feature instead of all at once. One precondition is a hard floor you cannot fake: the design system (a UI fidelity check needs something to check against).

This path does not change the three movements or the shared `milestones-and-verification.md` rules. It only stands in for the missing foundation, then returns you to them.

## Triage — is this path legitimate, or should you run kickoff?

The test: **can the four preconditions be discovered or decided in a focused recon pass, or do they need an interview-driven global planning session?**

- **Use this path** when: it's one feature on/against an existing codebase; or a new product small enough that its architecture and backlog are obvious or already half-decided; or it consumes an existing engine/host-app/platform whose stack, data, and design language are already real.
- **Run kickoff instead** when: it's a genuinely fresh, multi-feature greenfield app with nothing to discover and many features whose build-order and shared data model are worth planning once, globally. Back-filling that per feature is more expensive than the kickoff sitting.

When in doubt and the project is net-new but not large, prefer this path and let the foundation accrete.

## Movement 0 — Ground in the existing codebase (do this first)

Mandatory, before the feature interview. A reconnaissance pass (lean on `Explore` / `Plan` agents) that discovers and writes down what the missing foundation docs would have told you:

- **Stack + conventions** — framework, language, styling engine, state, data-fetching, auth, test runner, CI, and the repo's existing branch/PR/merge process. (Stands in for `01-architecture.md`'s stack section and tells you which process to defer to.)
- **The data model / shapes this feature touches** — the real entities and fields it will read and write, read from migrations / schema / types, not invented. (This is what Movement 1's "exact data each surface shows" pulls from when there is no `01-architecture.md`.)
- **Integration seams** — the existing route, nav, layout, and auth the feature mounts into or links to. In an existing codebase the seams are with **already-built code**, not sibling milestones, so they are concrete: name the surface *and the file*. These become the cross-feature seams in Movement 1.
- **Reusable components + the design language** — the existing themed primitives, tokens, fonts, icon set, motion, chart library. This is your design-system referent (see the floor below).
- **Invariants the feature must honor** — tenancy/RLS, the permission model, money/precision rules, anything the feature could silently violate.

Output a short **existing-context** section. It grounds the feature spec and seeds the thin foundation docs you write as a byproduct.

## Satisfying each missing precondition

For each kickoff output: **detect** whether it exists → **discover** it from code → author the **minimum** if it must be authored → respect the **floor**.

1. **Feature backlog (`00-product.md`).** You already know the feature; you don't need a backlog to pick it. Substitute a one-paragraph feature framing (the capability, who uses it, why it matters). If the product will grow, seed a **stub `00-product.md`** — vision + this feature + the known-next ones — so a backlog accretes. Do not decompose into milestones here (that's Movement 3).

2. **Architecture + data model (`01-architecture.md`).** Discovered in Movement 0. Write a **thin, feature-scoped** `01-architecture.md` (or extend an existing one) capturing only the stack / data model / seams / invariants this feature touches, **plus the minimum *new* decisions the feature forces** — a new table, a new service, a new external dependency, a new env var (names only). Record genuinely cross-cutting calls in a file-per-entry `decisions/`. Don't author the whole app's architecture; author the slice this feature stands on.

3. **Design system (`design.md` + gallery) — the hard floor.** Movement 2 composes from it and Movement 3's fidelity done-conditions point at it; with no committed referent, "uses the right icon set / tokens / chart library" has no answer and the build fills it with generic defaults — the exact vanilla failure the workflow exists to prevent. **Gate on the artifact — a committed `design.md` plus a referent to compose from — not on running any particular skill.** Source it in priority order:
   1. **Existing design language in the codebase** → *discover-and-document* it into a thin `design.md` (palette, type, density, icon set, motion, chart library, primitives, any signature element). The existing components **are** the gallery; no skill is invoked. This is the common case.
   2. **A host / sibling app owns the system** → adopt it by reference in `design.md` (point at its tokens/primitives/gallery).
   3. **Nothing to adopt** (net-new UI, no host) → *only then* must a direction be decided; use the workflow's own gate `app-design-directions`, scaled to the project. Do **not** substitute the interaction-craft reference (`${CLAUDE_PLUGIN_ROOT}/references/interaction-craft.md`) for the *system* — that's the craft floor for the feel a committed system leaves open, not a replacement for the system itself.

   If the feature has no UI, this floor doesn't apply.

4. **Conventions + CI machinery.** Reuse the repo's existing process — its PR conventions, CI, branch protection, `CLAUDE.md`. Bootstrap only the minimum the milestone rules depend on, **and only if absent**: the `verified-pin` job + the plan-path definition (so the plan-PR exemption works — plan paths are `specs/**` + `design/**`), and file-per-entry `decisions/` + `deferrals/` directories. Don't re-run `provision` or re-establish what the repo already has. If you're building inside an existing host app, you inherit all of this.

## Then run the three movements

With Movement 0 done and the floor satisfied, run Movements 1–3 from `SKILL.md` **unchanged**. Movement 1's "exact data" points at the thin architecture note / discovered model; Movement 2 composes from the discovered-or-adopted design system; Movement 3 and the shared `milestones-and-verification.md` rules are identical. Carry the integration seams from Movement 0 into Movement 1 as the cross-feature seams, and into Movement 3 as named seams between milestones.

## Output + handoff (adjustments)

Same outputs as a normal spec-feature session — the feature spec (`specs/features/<feature>.md`), the mockups (`design/mockups/<feature>/`), the milestone specs (`specs/milestones/<slug>.md`) — **plus** the thin foundation you seeded as a byproduct: the stub `00-product.md`, the feature-scoped `01-architecture.md`, the discovered/adopted `design.md`. All of these are `specs/**` + `design/**`, so they ride the **plan PR** as a plan-only change set.

Two carve-outs:
- **The CI-gate bootstrap is not plan-only.** If the repo lacks the `verified-pin` job, establishing it (`scripts/check-verified-pin.sh` + the CI wiring + branch protection) is *code* and would break the plan-PR's plan-only status. Land it as a small **one-time setup PR first** (mirrors `spec-foundation`'s repo-setup step), before the feature's plan PR — so later code PRs are gated without contaminating the plan PR.
- **Defer to the host repo's rules.** Adopt its branch/PR/merge conventions rather than imposing the kickoff defaults; record any deliberate subtraction in `decisions/`.

Future features on this project now inherit the foundation you seeded — the *next* spec-feature here may find the preconditions already met and skip this path entirely.
