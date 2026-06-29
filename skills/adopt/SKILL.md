---
name: adopt
description: Brownfield kickoff — point keel at an EXISTING project that never ran a greenfield kickoff. A one-time retrofit that discovers the foundation from the code (stack, data model, design language, seams, invariants), derives the stack profile, seeds thin foundation specs, and wires the verified-pin gate + branch protection once — then hands off to the per-feature loop. Use instead of kickoff when there's already code.
---

# Adopt

Stand up keel's **durable foundation on an existing project** — the brownfield analog of `kickoff`. Where `kickoff` *authors* the foundation from an interview, `adopt` mostly *discovers* it from code already on disk, seeds the minimum that's missing, and wires the process once. It runs **once** on a project, attended, then the normal per-feature loop takes over.

## Triage — adopt vs kickoff

- **Use `adopt`** when there's already code: a feature against an existing codebase, or a small/contained product that consumes an existing engine/host-app/platform whose stack and design language are already real.
- **Use `kickoff`** instead when it's a genuinely fresh, multi-feature greenfield app with nothing to discover — a global plan over many features is cheaper to decide once, up front, than to back-fill.

## Movement 0 — Ground in the existing codebase (mandatory, first)

A reconnaissance pass (lean on `Explore`/`Plan` agents) that discovers what a kickoff would have authored:

- **Stack + conventions** — framework, language, styling, state, data-fetching, auth, test runner, CI, and the repo's existing **branch/PR/merge process** (you defer to it).
- **The data model** — real entities/fields, read from migrations/schema/types, not invented.
- **Integration seams** — the existing routes, nav, layout, auth the work mounts into — concrete (name the surface *and the file*).
- **Reusable components + the design language** — existing themed primitives, tokens, fonts, icon set, motion, charts. This is your design referent.
- **Invariants** — tenancy/permission/precision rules the work must not violate.

## Satisfy each missing precondition the cheapest correct way

For each thing a kickoff would have produced: **detect** → **discover from code** → **author the minimum** only if absent.

1. **Stack profile (`specs/stack-profile.md`)** — derive it from the recon + the project's config against `${CLAUDE_PLUGIN_ROOT}/references/profile-interface.md` (how to activate a surface, drive an action, seed test state, dev-vs-prod build, versioning, **has-UI?**, deployed surface). Confirm it at the sign-off gate. This is the one artifact you always produce — verification can't run without it.

2. **Product framing (`00-product.md`)** — you may already know the work; a one-paragraph framing suffices. Seed a **stub** backlog if the product will grow.

3. **Architecture (`01-architecture.md`)** — write a **thin, feature-scoped** note: only the stack/data-model/seams/invariants the work touches, plus the minimum *new* decisions it forces (a new table, service, env var — names only). Don't author the whole app's architecture.

4. **Design system — the hard floor (UI work only).** Movement-2 mockups and fidelity done-conditions need a committed referent, or the build fills it with generic defaults. Source it in priority order: (a) **discover-and-document** the existing design language into a thin `design.md` (the common case — the existing components *are* the gallery, no skill invoked); (b) **adopt a host/sibling app's system** by reference; (c) only if there's genuinely nothing to adopt (net-new UI, no host), run `app-design-directions`. Do **not** substitute craft helpers for the *system*.

5. **Process + CI.** Reuse the repo's existing process. Bootstrap only what the rules depend on **and only if absent**: copy keel's shipped `${CLAUDE_PLUGIN_ROOT}/scripts/check-verified-pin.sh` + wire it as a CI job, branch protection, and file-per-entry `decisions/` + `deferrals/`. The CI-gate bootstrap is **code**, so land it as a small **one-time setup PR first** (it would break a later plan PR's plan-only status). If you're inside an existing host app, you inherit all of this.

## Confirm, then hand off

End the sitting **attended**, on the user's sign-off of the discovered foundation (the stack profile especially). Then the project runs the normal loop:
- `spec-feature` (or `spec-change` for a small one) → `implement-feature` → `land-feature` → `review-feature`.
- The foundation you seeded **accretes** — the *next* feature here may find the preconditions already met and skip this entirely.

(For speccing a single feature against existing code *without* doing the full retrofit, `spec-feature`'s `references/no-foundation.md` path discovers just what that one feature needs.)
