# The stack-profile interface — how keel stays stack-neutral

keel's methodology is stack-agnostic; the *mechanics* of proving a build actually runs are
not. This file is the contract between the two: the questions every project answers about
its own stack so the neutral skills (`verify-milestone`, `provision`, `spec-feature`,
`review-feature`) can dispatch verification, provisioning, and design-token install
**without naming a framework**.

## What a profile is, and where it lives

A **stack profile** is a project-local artifact — **`specs/stack-profile.md`** — that answers
the questions below for *this project's* stack. keel ships **no** profile and **no library to
pick from**; each project **derives its own**. The only stack anyone has hardened is the one
they actually ran, so a curated library of recipes for stacks we've never built would be
confident guesses dressed as authority — which is exactly what this design avoids.

## How a profile is derived

`spec-foundation` (greenfield) or `adopt` (brownfield) fills `specs/stack-profile.md` by:

1. **Reading the project** — dependency manifest, framework/build config, test setup. What's
   installed beats any assumption.
2. **Web research, bounded by the questions below** — for anything the project doesn't already
   answer ("how do you drive an authenticated render in <framework>", "how do you run a
   simulator test for <mobile stack>", "what does <stack>'s production build do that dev
   doesn't"). The questions are what make the research finite — without them, "research how to
   test this stack" is unbounded. Web research only (no MCP dependency, so it works for anyone).
3. **Proposed in the interview's synthesis** — the stack proposal is part of the understanding
   the user confirms at the confirm-before-author gate. Nothing is derived behind their back.

A derived profile is a **strong starting point, not a hardened one.** Research captures the
*documented* mechanics; the tacit gotchas no doc lists surface in use and accrete back via
`lessons/` and profile updates — exactly how keel's own mechanics were earned. Expect ~80% from
derivation and the last 20% from running it.

---

## The questions (the profile verbs)

Answer each in `specs/stack-profile.md` concretely enough that a fresh build/verify session can
execute it without re-deciding. The ⚠ notes are the **generalized scars** — gotchas keel
learned the hard way on its first stack, restated as questions every stack must face.

**Q1 — Source roots.** Where do the units of work live (route dir, screen modules, API
handlers, command files, package entrypoints)? This is how verification knows what's *new or
changed* in a milestone.

**Q2 — Surface.** What counts as a verifiable *surface* here — a rendered route, a mobile
screen, an HTTP endpoint, a CLI subcommand, an exported function?

**Q3 — Activate + assert healthy.** How do you run/open one surface and assert it activated
**without error**? (render authenticated + no error boundary/console; OR request + 2xx +
schema-valid; OR invoke + exit 0 + expected stdout, no stderr.)
> ⚠ **Test-runtime ≠ production-runtime.** Where does your unit-test environment render or
> transform differently from production (server/client split, islands, a native bridge, a
> transpiler that elides types)? The runtime-proof must exercise that boundary **in the real
> runtime** — never infer "it runs" from a green unit suite. (This is the RSC-boundary / jsdom
> scar: a Server Component passing a function as `children` to a Client Component, and an
> `export type` in a server file, both reached green pins and were invisible until a real
> render.)

**Q4 — Drive action + assert effect.** How do you trigger a state-changing action and confirm
its **effect** (a DB row, a written file, a response body, a state transition)?

**Q5 — Seed test state.** How do you obtain known-good, **authenticated/seeded state with no
human and no email** (an admin-API-minted user + session captured once, a fixture loader, a
seed script)?

**Q6 — Dev build vs production build.** What are the fast/dev build and the
production-equivalent build, how do you run each, and **what does each catch that the other
doesn't**? The runtime-proof runs against **both**.
> ⚠ **Build divergence is real.** The production build/transform routinely catches breakage the
> dev/test transform can't (and vice-versa). Prove against both fidelities, never just one.

**Q7 — Live/external proof.** If a milestone calls a paid/external/AI service, how do you run a
**capped real call** within a pre-authorized spend envelope, asserting invariants over
nondeterministic output (never exact text)? (Or "n/a — no external calls.")

**Q8 — Has UI? + design-token install.** Does this deliverable render a user interface? If
**yes**, where/how do design tokens install (CSS variables, a theme file, native style
tokens)? If **no**, the design track and the fidelity done-condition are skipped entirely (see
below).

**Q9 — Schema/state versioning.** How are schema/data/state changes versioned, and is the scheme
**collision-free under parallel branches**? (Or "n/a — no persistent schema.")
> ⚠ **No hand-incremented counters.** A global next-number forces parallel branches to
> coordinate and collide at merge. Use a content/timestamp scheme, and make shared-object
> creation **idempotent** (create-if-not-exists) so the earliest migration wins and the rest
> no-op.

**Q10 — Deployed verification surface.** What is the deployed/preview surface to smoke (a
preview URL, a release build, a container), and does probing it need an **auth/bypass header**?
(Or "local-only — no deployed surface.")
> ⚠ **Deployment protection can block a naïve smoke.** If the preview is auth-gated, the smoke
> must pass the documented bypass; otherwise a healthy deploy reads as a failed one.

---

## What stays in the methodology (not the profile)

These rules are already stack-neutral and live in the spine. The profile only feeds them inputs:

- **Runtime-proof runs serially** against shared local singletons (a DB/emulator, dev-server
  ports) — the profile names *which* singletons (informs Q3–Q6); the serialization rule is the
  spine's.
- **A route/asset the build needs must be git-*tracked*,** not just present on disk — git-level,
  not stack-level.
- **Flaky-by-construction tests** (async propagation: cache reloads, eventual consistency, races)
  run to convergence (≥5×) before a record is written.
- **Every `[runtime]`/live condition needs a pre-authorized spend envelope** — drained at
  provision, never gated mid-run.

## Has UI? — what Q8 gates

Q8's answer is load-bearing across the methodology. **No UI** →
- the **design-system gate** (`app-design-directions`) and **per-feature mockups** (`spec-feature`
  Movement 2) are skipped;
- done-conditions cover **two** dimensions (logic + UX/behavioral completeness), not three — the
  **fidelity** dimension only exists when there's something to render.

**Has UI** → the full design track and the three-dimension done-conditions apply, as written.
