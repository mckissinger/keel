---
name: kickoff
description: Orchestrate a greenfield project kickoff in the one correct order — app-skeleton interview → spec-foundation (product skeleton + architecture) → design-system gate → provision — pausing at each attended gate, and ending at a green foundation + a feature backlog (NOT a milestone list). The one attended sitting that stands up a brand-new project's durable foundation.
when_to_use: Use at the very start of a brand-new project to stand up the durable foundation. Per-feature specs and builds run AFTER, one feature at a time, via spec-feature → build → verify → review-feature. NOT for a mid-project feature (invoke spec-feature) or a redesign (that's app-design-directions).
disable-model-invocation: true
---

# Kickoff

Stand up a new project's **durable foundation** in the one correct order, then hand off to the per-feature loop. This skill is **connective tissue**: it dispatches the kickoff skills in sequence and enforces the pauses between them — it does **not** re-implement any of them. Every kickoff step is attended; run them in one sitting.

## Why this exists, and what changed

Two failure modes shaped this ordering:

1. **Authoring UI work before the design direction exists** builds the wrong *structure* (a paginated card list when the direction wants one dense table), and no token layer fixes a structural mismatch. So design is a gate, decided before any feature is built.
2. **Authoring the whole app's milestones in one up-front pass** caps per-feature depth and ships thin features + generic design. So the kickoff now stops at the **foundation + a feature backlog** — it does **not** author the milestone list. Milestones are authored **per feature, one at a time, informed by what's already built**, by `spec-feature` in the loop below.

Plan *globally* what is expensive to change (architecture, data model, design system, invariants, process); decide *locally and per feature* what you can only judge by seeing (a feature's screens, states, done-conditions). The kickoff is the global half.

## The kickoff sequence (one attended sitting)

1. **Interview** (`interview` skill) — drain the app-level decisions only the human can make: goal, users, scope, the **feature backlog**, the spine journey, high-level data shapes, external services, and **design direction** (purpose, audience, aesthetic tone, references). Breadth, not per-feature depth. End when these are resolved enough to write the foundation.

2. **Spec — foundation** (`spec-foundation` skill). Write `00-product.md` (the **feature backlog + build order + spine journey**, not milestones), `01-architecture.md` (stack + data model + environment contract + hard invariants), and the `decisions/` + `deferrals/` conventions with their kickoff entries. **Do not author feature milestones here.** Commit `specs/` as the first PR.

3. **Design-system gate** (`app-design-directions` skill) — attended. **Runs only if the deliverable has a UI** (the profile's Q8); for a no-UI deliverable (CLI, backend, library) this gate is skipped entirely. Otherwise: explore directions → human picks → **build the design system as a reviewable component gallery** (a `/styleguide` route with the real themed primitives + states + charts) and write `specs/design.md` (decision + full material palette). Redline the gallery + the archetype spread. Committed to **main**. This is a gate, not a numbered build milestone — and its deliverable is *code every feature composes from*, not just a doc.

4. **Provision** (`provision` skill) — attended. CLI logins, dev resources, allowlist seeding, spend-capped key, branch-protection + `verified-pin` CI verified live. The sitting ends on a **green preflight**.

5. **Charter seed** (post-preflight) — write the kickoff synthesis to **`specs/runs/<date>-<slug>-kickoff/charter.md`**: the resolved backlog + build order, the architecture/design decisions, and the run's definition of done — everything a subsequent `keel:auto run` would otherwise re-derive from cold. Then **offer** the continuation — the exact `keel:auto run [scope]` invocation the user could type next — but **never issue it**: the human invocation is the authorization for an autonomy posture, and kickoff only hands over the charter it seeded. (`keel:auto`'s entry audit reads the most recent `specs/runs/*/charter.md` as its first input.)

**Kickoff ends here** — on a whole foundation (product backlog, architecture, design system, conventions, project CLAUDE.md), green provision, a seeded charter, and **no milestone list yet**.

## After kickoff: the per-feature loop (not part of this skill)

The build runs as a repeated per-feature loop, each feature taken from the `00-product.md` backlog (spine-journey features first, so early work is a usable walking skeleton):

```
spec-feature   → deep interview + mock the feature's screens from the design system + author its milestones        (attended, one session, ends on your sign-off)
build          → implement-feature  (implement-milestone + verify-milestone per milestone)                          (fresh session, autonomous)
verify         → verify-milestone per milestone, + the consolidated wave check on main                             (fresh session, autonomous)
review-feature → render vs the feature's workbench composition, judge completeness + fidelity, refinement milestone (attended)
```

- **Build/verify in fresh sessions, separate from spec-feature** — the spec must be self-contained enough to build from cold; separating enforces that.
- **Cadence is the user's call** — interleaved (spec→build→review→next, so each spec is informed by the prior feature's reality), batched up-front (several spec-feature sessions, then one long build run — re-check unbuilt specs when a build surfaces something structural), or by wave (spec a wave of independent features, build concurrently, review, then the next wave). All work; the loop is the same.
- The agent never merges and never commits to main; the user reviews and merges.

## Local-only projects

If the project is local-only (no cloud, no external services, no auth/payments), the kickoff is the same **except step 4**: `provision` is a no-op and the deploy/preview/go-live machinery doesn't apply. End on a **local green** instead (build + typecheck + lint + test + a route smoke over the styleguide + any foundation routes). Verification swaps the preview-deploy smoke for a dev-mode route smoke throughout, and `review-feature` runs against the local build. Record the subtraction in `decisions/` so it reads as deliberate.
