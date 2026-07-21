# The stack-profile interface — how keel stays stack-neutral

keel's methodology is stack-agnostic; the *mechanics* of proving a build actually runs are
not. This file is the contract between the two: the questions every project answers about
its own stack so the neutral skills (`verify-milestone`, `provision`, `app-design-directions`,
`spec-feature`, `review-feature`) can dispatch verification, provisioning, and the whole
**design surface** (tokens, workbench, motion, platform feel) **without naming a framework**.

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
> render.) What a unit suite *can* cover is set by the tier ladder — see Q11.

**Q4 — Drive action + assert effect.** How do you trigger a state-changing action and confirm
its **effect** (a DB row, a written file, a response body, a state transition)? The
*deterministic core* of each such action should be asserted by a **committed test** in a Q11
tier; the agent-driven walk proves the divergence/live remainder, not every enumerated action.

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

**Q8 — Design surface (the verb cluster).** This is a *cluster*, not one question: it opens
with the has-UI? gate and — when the answer is yes — continues through five design-surface
verbs the neutral design skills (`app-design-directions`, `spec-feature`, `review-feature`)
dispatch through, exactly as verification dispatches through Q1–Q7. Answer each concretely in
`specs/stack-profile.md`. The web reference answers below are the **hardened** ones (keel's
proven stack); the mobile answers are **derived-when-needed** against this interface the first
time a real mobile project appears — neutral seams now, web hardened, no mobile toolchain built
on spec. Expect the same ~80%-from-derivation, last-20%-from-running-it as every other verb.

**Q8.1 — Has UI? (the gate).** Does this deliverable render a user interface? If **no**, the
entire design track and the fidelity done-condition are skipped, Q8.2–Q8.6 answer "n/a — no
UI," and done-conditions cover two dimensions, not three (see "Has UI? — what Q8 gates" below).
If **yes**, answer the rest of the cluster.

**Q8.2 — Token source + install.** Where do design tokens live, in what structure, and how do
they install onto the surface? The rule is **native-vs-portable**: a **single-platform**
deliverable installs **native tokens** (e.g. CSS custom properties / a theme file the framework
already consumes); a **multi-platform** deliverable (web + mobile) authors **one portable
source** (e.g. a DTCG token file compiled per platform by e.g. Style Dictionary) so the values
port and each platform gets its native form. Tokens are **two-tier — primitive → semantic** (raw
scale values, then role-named aliases the components read), and **interaction-states and motion
are token-level, not per-component** (hover/pressed/focus/disabled deltas and easing/duration are
named tokens every component inherits, never re-decided per widget).
> ⚠ **A token the components don't actually read is decorative.** Declaring a token layer but
> hardcoding raw values in the markup (a stray hex, a one-off duration) defeats the whole spine —
> the redline can't retheme what isn't wired. The install answer must name the mechanism that
> makes components **read** the semantic tier, and the fidelity check (has-UI milestones) asserts
> no raw values bypass it. (The generalized form of the tokens-declared-but-not-read scar: a
> token layer present in the sheet yet bypassed by raw values in the markup reaches green and
> looks themed — until a retheme moves nothing.)
- *Web reference:* CSS custom properties (primitive `--color-blue-600` → semantic `--color-accent`),
  installed via the framework's theme layer; state + motion tokens declared in the same sheet.
- *Mobile (derived-when-needed):* one portable DTCG source compiled to a native theme per platform.

**Q8.3 — Workbench mechanism.** How does this stack render a **reviewable gallery of the real,
themed primitives in every state** — the durable fidelity source of truth, not a throwaway
mockup? Name the mechanism that mounts real components (themed, in default / hover / pressed /
focus / disabled / loading / empty / error) on one reviewable surface.
- *Web reference:* a `/styleguide` route (or e.g. Storybook) that imports the real primitives and
  lays them out in every state.
- *Mobile (derived-when-needed):* the platform's native preview harness — e.g. SwiftUI `#Preview`;
  e.g. Jetpack Compose `@Preview` + a `@PreviewParameterProvider` to fan the states; e.g. Flutter
  Widgetbook; e.g. React Native's Storybook.

**Q8.4 — Design screenshot / review driver.** How is a themed surface **captured** as an image
for the redline / vision diff — the mechanism that turns a rendered surface into the screenshot
an agent or human diffs against the mockup?
- *Web reference:* a headless-browser screenshot (e.g. Playwright; or e.g. Chromatic over the
  gallery).
- *Mobile (derived-when-needed):* a simulator + snapshot test (iOS); an emulator + e.g. a Compose
  screenshot test (Android); e.g. Widgetbook goldens (Flutter).
- *Optional — recording capability:* the driver may also declare how a rendered **interaction**
  is captured as video or a frame sequence (*web:* e.g. a headless-browser video/trace recording;
  *mobile:* e.g. a simulator screen recording). `review-feature`'s frame-by-frame motion review
  consumes it when present and degrades to a slowed live replay when absent — still capture
  remains the required contract.

**Q8.5 — Motion + interaction mechanism.** What is the stack's **motion library**, how are the
**motion tokens (easing / duration)** and the **interaction-state tokens** expressed, and what is
the **reduce-motion signal**? Motion and states are behavioral — they live only in real code and
are reviewed executably, never as a static image.
> ⚠ **Reduce-motion is read once, at the token layer — not per-animation.** Wiring the
> reduce-motion check into each component invites the one place that forgets it; a surface then
> honors it everywhere but the one screen that ships motion-sick. Express it as a token/global the
> motion layer consults, so honoring it is structural, not per-widget diligence.
- *Web reference:* CSS transitions / a JS motion library (e.g. Framer Motion) driven by the
  easing/duration tokens from Q8.2; interaction-state tokens applied on `:hover` / `:focus-visible`
  / `[data-pressed]`; reduce-motion read from the `prefers-reduced-motion` media query at the token
  layer.
- *Mobile (derived-when-needed):* the platform's native animation API + its accessibility
  reduce-motion flag, read once at the token layer.

**Q8.6 — Platform-convention set (native feel).** Which platform's **interaction conventions**
must this surface obey to feel native — web, iOS Human-Interface-Guidelines, or Android Material?
Name what must be **native** (navigation patterns, gestures, system controls like
pickers / date-pickers / share sheets) versus what is **brand-universal** (the token palette, type
scale, iconography, information architecture). Define once, implement per platform: the brand
ports, the native feel does not.
- *Web reference:* web conventions — pointer + keyboard, browser-native focus order, standard form
  controls themed through the tokens.
- *Mobile (derived-when-needed):* the platform HIG / Material control set for navigation, gestures,
  and system pickers.

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

**Q11 — Test tiers (the committed-test ladder).** For each tier, the **concrete, runnable
command** on this stack — or **"n/a + why"** (a recorded reason, not an assumed gap) — answered
**cheapest → dearest**, with a rough speed per rung and what it *uniquely* catches (the canonical
split: **static catches shape, unit catches logic, component-scope catches wiring, end-to-end
catches environment**):
- **Static** — typecheck / lint / format-check (usually sub-seconds, amortized).
- **Unit** — pure logic, no rendering (e.g. a test runner over exported functions; ~ms/test).
- **Component-render** — mount a **real component/screen tree** in a fast headless harness and
  drive interactions (e.g. a DOM-emulation environment with a component testing library on web;
  a native preview/snapshot harness on mobile; ~10–1000ms/test). This is the tier that catches
  deterministic *interaction* bugs — render loops, focus ordering, an edit that doesn't commit —
  that pure units structurally cannot see.
- **End-to-end** — committed, scripted checks against the real runtime (e.g. a checked-in
  browser-automation spec), runnable headlessly in CI (~seconds/test + server boot; measurably
  the flakiest rung — reserve it for what lower rungs can't see).

Also answer the stack's **escalation holes**: the failure classes that *structurally cannot be
seen below the runtime walk* on this stack (e.g. an async server-rendered boundary that no
headless harness can mount, a native bridge everything below the device mocks away, an
SSR/client compile split). Naming them makes escalating to the walk a **routed decision**, not
a habit. Derivation priors for common stacks — dated, honesty-marked, and read only at
derivation time — live in `references/feedback-ladders.md`; they seed this answer, the bounded
research step verifies their currency.

These commands are what `[auto]` done-conditions bind to and what `verify-milestone` runs before
its walk; deriving a profile with only a unit tier **must** record why the other tiers are n/a.
> ⚠ **The inner loop reproduces at the cheapest layer that can see the failure class; the walk
> is the gate, not the debugger.** On an earlier run an agent hand-drove a browser to debug
> failures a typecheck or unit test shows in a second — the e2e-class rung runs ~100× slower and
> measurably flakier than the component rung, and browser-automation-via-MCP-snapshotting costs
> ~4× the tokens of the same task driven via CLI/scripts (so when browser automation *is* the
> right layer, prefer a scripted/CLI driver over snapshot-per-step). Escalate past a rung only
> when the failure class is in its escalation holes — and when a defect *does* escape to a
> higher rung, that's missing coverage one rung down (backfill it there).
> ⚠ **A missing middle tier turns the agent walk into the regression harness.** On an earlier
> run, two deterministic interaction bugs — an external-store snapshot-stability violation that
> crashed a route on open, and an open-on-keypress that self-closed because keyboard activation
> landed on the just-focused close control — passed every `[auto]` check (a green pure-logic
> unit suite, typecheck, lint, a clean production build) because nothing below the walk ever
> mounted a component. Both were caught only by agent-driven browser walks: expensive,
> non-repeatable, and one could not deterministically isolate an intermittent recurrence. A
> ~30-line component-render test would have caught both in under a second, on every future run.
> The walk is an *acceptance* layer; the committed tiers are the *regression* harness — never
> let the first substitute for the second.

**Q12 — Local substrate contract.** The recorded, checkable description of the **healthy local
substrate** — the daemons, ports, env files, and toolchain that everything above the unit tier
rests on and that no milestone owns. The build/verify verbs assert this contract at entry
(seconds, not minutes), so drift is caught at session start instead of mid-run. Record:

- **Shared local singletons + a one-line health check each.** Which shared local singletons the
  runtime ladder assumes running (a local database/emulator stack, a dev server, a background
  daemon), and for each the **one-line command** that asserts it healthy — up, responsive, and
  answering on *this* project's ports.
- **Unique port block / project identity.** The port block or project-identity assignment this
  project's local stack owns, **collision-free against the user's other projects** — recorded so
  "are these ports mine?" is checkable, never assumed.
- **Canonical invocation path.** The path from which local-stack commands must run for the
  stack's **config discovery to actually work** (e.g. the subdirectory holding the stack's
  config, when that isn't the repo root).
- **Env re-derivation command.** The one command that regenerates the local env file from the
  host env store — the recipe the environment contract records at provisioning is the source;
  this answer names where that line lives, so a fresh checkout, worktree, or session re-derives
  mechanically instead of improvising.
- **Env name-check command.** The one **committed** command that asserts every contracted
  env-var **name** resolves — host env store or local env file — reporting names/status only,
  **values never appearing in its output**. The implementation is stack-appropriate (a package
  script, the stack's own env-schema validation, a small committed script); the command is
  recorded, the implementation never mandated. And the direct-read ban lives here: sessions
  never **read** `.env*` files directly — a permission denial on such a read is the posture
  *working*, not an obstacle to route around, and this recorded command is the sanctioned path.
- **Known-failure-signature table.** Signature → classified remedy (e.g. "gateway 502 → a second
  **unisolated** stack is running; stop it", "auth failure on seed → stale env file; re-derive it",
  "a permission denial on a `.env*` read → working as intended; run the recorded env name-check
  command instead"), consulted before any diagnosis and **accreting like the ⚠ scars**: every
  newly diagnosed substrate failure adds a row.
- **Per-suite duration budgets — and the timeout rule, owned here.** A rough expected duration
  for each Q11 tier's suite and for the runtime walk. The rule every suite-running verb points
  at: **any suite/walk command runs bounded — exceeding roughly 2× its recorded budget means
  kill it and classify as environment (signature table first), never an open-ended wait** — and
  long suites run backgrounded with periodic progress checks where the harness supports it.

**Authorship splits.** The structural answers — the singletons, the invocation path — are
*derived* at spec time like every other question. The ports/identity assignment, the env
re-derivation command, the env name-check command, the signature-table seeding, the duration
budgets, and the proven-green health check are **finalized at provision** — a derived profile
carrying "finalized at provision" placeholders for those is well-formed, not incomplete. Which singletons exist here feeds the
spine's serialization rule (see "What stays in the methodology" below), and the flake
*mitigations* stay baked at provisioning (provision's step 6) — this question records the
**contract**, not the mitigations. How a *second, simultaneous* session derives its own
instance from this contract's base is Q13's question, below.

> ⚠ **Config discovery can silently fall back to another project's ports.** A stack invoked from
> the wrong directory can miss its config, fall back to defaults, and talk to *another project's*
> database while every command appears to succeed — an earlier run lost days to exactly this.
> The canonical invocation path + the ports-are-mine check turn it into a one-second assertion.
> ⚠ **A stalled daemon reads as a hung run.** A background daemon blocked on an interactive
> prompt (a sign-in, a first-run consent) produces the same silence as a long-running suite; the
> singleton health checks distinguish the two in seconds — never diagnose a "hung" run before
> asserting the singletons are actually up.
> ⚠ **Never wait open-endedly on a status or suite command.** An unbounded wait on a slow status
> command once burned hours of wall-clock on an earlier run. The duration budgets make "too
> long" a measurable fact; apply the timeout rule above instead of waiting on hope.
- *Web reference:* the local backend stack's CLI status command as each singleton's health check
  (exit 0 + this project's ports in its output); the stack config's project-id / port
  assignments as the identity; the host-env pull command (e.g. `vercel env pull .env.local`) as
  the env re-derivation.

**Q13 — Parallel-session (worktree) isolation contract.** The recorded recipe for standing up
**instance N of the local stack, isolated** — how a second simultaneous session (a parallel
worktree, a sweep's verifier) gets its own substrate instead of colliding with the primary's.
This question is **opt-in**: a stack that can't isolate cheaply (a single-socket daemon, a
licensed simulator) answers **"not provided — runtime-proof stays serial"** and everything
behaves exactly as today — the serial rule is the permanent safe default, not a legacy mode.
When provided, record:

- **Instance identity.** How instance N derives its own port block / project identity from
  Q12's base assignment (e.g. base + a per-instance offset), collision-free against sibling
  instances *and* the user's other projects.
- **Datastore isolation recipe.** How an instance gets its own datastore state — a
  branch/namespace/schema/container per instance, seeded per Q5 — such that writes in one
  instance are invisible to the others.
- **Per-instance env derivation.** Q12's env re-derivation command, parameterized by instance
  identity, producing the worktree's own env file.
- **Teardown.** The one command that returns instance N's resources (ports, datastore,
  processes) — run on **every** exit path, a crashed or failed session included. A leaked
  instance is a named failure signature: Q12's signature table gains a leaked-instance row
  (e.g. "ports busy at claim → a prior session leaked its instance; run its teardown").
- **Allocation.** Instance identity is **ephemeral, claimed per session** — never a recorded
  assignment: workflows assign it by dispatch index; an attended session probes before
  claiming.
- **The proven flag.** The contract is *unproven* until a sitting has run **two simultaneous
  instances green** — both health checks green at once, one instance's writes invisible to the
  other — recorded in the profile as `proven at <date>`. An unproven or absent contract changes
  nothing anywhere. And the flag proves the *recipe class* only: **every per-instance run opens
  with an instance-scoped substrate assertion** — health green + these-ports-are-instance-N's,
  the Q12 preflight parameterized by identity — and a failed assertion is classified
  environment/blocked, never walked against (a rotted recipe that silently falls back to the
  shared primary is Q12's config-discovery scar in per-instance form — re-checked per run,
  never inferred from the flag).

**Authorship split.** Like Q12's provision-owned parts, this answer is **finalized at
provision** — derivation records the question with its default ("not provided — runtime-proof
stays serial") or a "finalized at provision" placeholder; `provision` asks it, authors the
recipe when the user opts in, and runs the two-instances proof (its step 6). What a proven
contract relaxes is the spine's serialization rule (see "What stays in the methodology" below)
— nothing else consumes the flag.

> ⚠ **Teardown that only runs on clean exits is teardown that leaks.** A crashed or killed
> session never reaches its cleanup line; its instance's ports stay claimed and its datastore
> branch stays live, and the *next* session's claim then fails in ways that read as fresh
> mysteries. Wire teardown into every exit path, and when a claim does fail, consult the
> leaked-instance signature row before diagnosing anything else.
- *Web reference:* a datastore whose hosting offers cheap branching (e.g. a branch-per-instance
  feature on a hosted database) or a container-per-instance of the local backend stack as the
  datastore recipe; ports derived as Q12's base plus a fixed per-instance offset; Q12's env
  pull re-run with the instance's identity into the worktree's own env file; teardown via the
  stack CLI's stop/delete for that one instance.

**Q14 — Verification-integrity contract (the poisoned-environment guard).** The recorded answer
that lets the spine gate a `[runtime]`/environment-dependent **negative** verdict on proof the
running environment reflects committed code. keel's spine mandates the requirement (see
`references/milestones-and-verification.md` §3 and `agents/verifier.md`); this question supplies
the two project-specific specifics that mandate consumes — it does **not** restate the mandate as
a profile-owned rule. Declare both:

- **Service-config paths.** The tracked paths whose uncommitted working-tree state makes the
  running services reflect something other than committed code — the local-stack config, the
  env-derivation source. A dirty tree at these paths is the environment poisoned, classified
  environment, never a code defect.
- **Positive-control probe.** The independent signal **and** the restart/probe recipe that prove
  the environment reflects committed state: restart the service, probe the **gate** (hit the
  endpoint, expect a real response) rather than trusting a CLI start banner, and require an
  **independent signal to change** — never a repetition to recur. Only once that control has gone
  from absent/stale to present may a negative `[runtime]` finding stand.

A [runtime]/environment-dependent **negative** finding is gated on both the clean tree and the positive control — the requirement is the spine's; these two declarations are what it reads.
The carve-out rides with the requirement: it gates a **negative** runtime finding **only** — never
an `[auto]`/static finding, and **never a clean pass** (a passing walk already exercised the
environment).

> ⚠ **Reproduction count is not confidence (the B2 scar).** A verifier reported a probe returning
> "no code found," reproduced it 4× across dev+prod and new+existing users, and concluded users had
> no code — all inside one poisoned, un-restarted environment. After a restart on committed config
> the same probe returned real results immediately; the tell of the genuine reload was an
> **independent signal change** (an email subject changed), **not** the repetition. N poisoned reads
> are one poisoned read.

**Authorship split.** Like Q12/Q13's provision-owned parts, this answer is **derived at spec time**
(which paths count as service-config, which independent signal proves a genuine reload) with the
exact restart/probe **commands finalized at provision** — a derived profile carrying a "finalized at
provision" placeholder for those commands is well-formed, not incomplete.

---

## What stays in the methodology (not the profile)

These rules are already stack-neutral and live in the spine. The profile only feeds them inputs:

- **Runtime-proof runs serially** against shared local singletons (a DB/emulator, dev-server
  ports) — the profile names *which* singletons (Q12; informs Q3–Q6); the serialization rule is
  the spine's. One condition relaxes it: a profile carrying a Q13 contract **marked proven**
  lets each parallel session stand up its own instance per that contract — serial remains the
  default for every other case (no Q13, an unproven Q13, or a stack that answered "not
  provided").
- **A route/asset the build needs must be git-*tracked*,** not just present on disk — git-level,
  not stack-level.
- **Flaky-by-construction tests** (async propagation: cache reloads, eventual consistency, races)
  run to convergence (≥5×) before a record is written.
- **Every `[runtime]`/live condition needs a pre-authorized spend envelope** — drained at
  provision, never gated mid-run.

## Has UI? — what Q8 gates

Q8.1's has-UI? answer is load-bearing across the methodology, and it gates the rest of the
cluster. **No UI** →
- the **design-system gate** (`app-design-directions`) and **per-feature mockups** (`spec-feature`
  Movement 2) are skipped, and Q8.2–Q8.6 all answer "n/a — no UI";
- done-conditions cover **two** dimensions (logic + UX/behavioral completeness), not three — the
  **fidelity** dimension only exists when there's something to render.

**Has UI** → the full design track and the three-dimension done-conditions apply, and the rest of
the cluster becomes load-bearing input to the design skills:
- **Q8.2 (token source)** is the neutral spine the whole design system compiles from;
- **Q8.3 (workbench)** is the reviewable component gallery `app-design-directions` installs as the
  durable fidelity source of truth, and that `spec-feature` / `review-feature` compose and diff
  against;
- **Q8.4 (screenshot driver)** is how the vision diff / redline captures a surface;
- **Q8.5 (motion + interaction)** and **Q8.6 (platform conventions)** are the behavioral +
  native-feel contract those same skills build and review to.

So the **design track and the fidelity dimension gate off has-UI? (Q8.1)**; the **workbench,
screenshot, and motion verbs (Q8.3–Q8.5) feed `app-design-directions`, `spec-feature`, and
`review-feature`** directly — the design track is dispatched through the profile exactly as
verification is.
