---
name: adopt
description: Brownfield kickoff — stand up keel's durable foundation on an EXISTING codebase. A one-time attended retrofit that discovers the foundation from the code (stack, data model, design language, seams, invariants), derives the stack profile, seeds thin foundation specs, and wires the verified-pin gate + branch protection once — then hands off to the per-feature loop.
when_to_use: Use instead of kickoff when there's already code — an existing project that never ran a greenfield kickoff, a feature against an existing codebase, or a small/contained product consuming an existing engine/host-app/platform whose stack and design language are already real. NOT for a genuinely fresh, multi-feature greenfield app with nothing to discover — use kickoff for that.
disable-model-invocation: true
---

# Adopt

Stand up keel's **durable foundation on an existing project** — the brownfield analog of `kickoff`. Where `kickoff` *authors* the foundation from an interview, `adopt` mostly *discovers* it from code already on disk, seeds the minimum that's missing, and wires the process once. It runs **once** on a project, attended, then the normal per-feature loop takes over.

## Triage — adopt vs kickoff

- **Use `adopt`** when there's already code: a feature against an existing codebase, or a small/contained product that consumes an existing engine/host-app/platform whose stack and design language are already real.
- **Adopt vs no-foundation — one boundary:** **adopt** when the project will take ongoing keel-managed development (retrofit the foundation once); **no-foundation** (`spec-feature`'s `references/no-foundation.md`) when one feature is being built against code that won't otherwise be keel-managed (discover just what the feature needs).
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

1. **Stack profile (`specs/stack-profile.md`)** — derive it from the recon + the project's config against `${CLAUDE_PLUGIN_ROOT}/references/profile-interface.md` (how to activate a surface, drive an action, seed test state, dev-vs-prod build, versioning, **has-UI?**, deployed surface, and the **local substrate contract (Q12)** — its structural parts (shared singletons, canonical invocation path) discovered from the code; its provision-finalized parts (ports/identity, env re-derivation command, env name-check command, signature-table seeding, duration budgets) recorded as "finalized at provision", never invented). The **parallel-session isolation contract (Q13)** is recorded alongside, finalized-at-provision like Q12's provision-owned parts — the recorded default is "not provided — runtime-proof stays serial"; opting in is `provision`'s question, never discovery's invention. Confirm it at the sign-off gate. This is the one artifact you always produce — verification can't run without it.

2. **Product framing (`00-product.md`)** — you may already know the work; a one-paragraph framing suffices. Seed a **stub** backlog if the product will grow.

3. **Architecture (`01-architecture.md`)** — write a **thin, feature-scoped** note: only the stack/data-model/seams/invariants the work touches, plus the minimum *new* decisions it forces (a new table, service, env var — names only). Don't author the whole app's architecture.

4. **Design system — the hard floor (UI work only).** Movement-2 workbench compositions and fidelity done-conditions need a committed referent, or the build fills it with generic defaults. Source it in priority order: (a) **discover-and-document** the existing design language into a thin `design.md` (the common case — the existing components *are* the gallery, no skill invoked); (b) **adopt a host/sibling app's system** by reference; (c) only if there's genuinely nothing to adopt (net-new UI, no host), run `app-design-directions`. Do **not** substitute craft helpers for the *system*.

5. **Process + CI.** Reuse the repo's existing process. Bootstrap only what the rules depend on **and only if absent**: copy keel's shipped `${CLAUDE_PLUGIN_ROOT}/scripts/check-verified-pin.sh` + wire it as a CI job (and copy `${CLAUDE_PLUGIN_ROOT}/scripts/repin.sh` alongside it — the canonical re-pin mechanizer the rebase re-pin rule invokes, copied not wired), branch protection (required status checks with **require-branches-up-to-date** — a moved base must re-enter the drift window before merge), and file-per-entry `decisions/` + `deferrals/`. The CI-gate bootstrap is **code**, so land it as a small **one-time setup PR first** (it would break a later plan PR's plan-only status). If you're inside an existing host app, you inherit all of this.

   **Also seed keel into the committed `.claude/settings.json`** (unlike a greenfield `provision`, adopt inherits the repo's allowlist/process, so this write is **scoped to keel's own seeding — never the per-service commands provision generates**): add `extraKnownMarketplaces` (keel's GitHub source, repo `mckissinger/keel`) + `enabledPlugins` (`keel@keel`) so every collaborator's session in this project has keel's skills and hooks without a manual install, **and merge the `.permissions.allow` array of `${CLAUDE_PLUGIN_ROOT}/references/allowlist-baseline.json`** — keel's own git + gh process verbs, so keel's plumbing doesn't prompt every feature (it carries no stack command, so it imposes no stack choice on the inherited repo; the merge-guard still gates push-to-default and every merge). Merge into an existing `settings.json` rather than clobbering it.

## Confirm, then hand off

End the sitting **attended**, on the user's sign-off of the discovered foundation (the stack profile especially). Then the project runs the normal loop:
- `spec-feature` (or `spec-change` for a small one) → `implement-feature` → `land-feature` → `review-feature`.
- The foundation you seeded **accretes** — the *next* feature here may find the preconditions already met and skip this entirely.

(For speccing a single feature against existing code *without* doing the full retrofit, `spec-feature`'s `references/no-foundation.md` path discovers just what that one feature needs.)
