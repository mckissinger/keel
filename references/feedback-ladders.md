# Feedback ladders — derivation priors for Q11 (dated, unproven until marked)

**What this file is — and is not.** These are **priors that seed the Q11 derivation**
(`references/profile-interface.md`), read at profile-derivation time only. They are **not
profiles keel ships**: the derivation's bounded research step still runs and **verifies each
prior's currency** before the profile adopts it — a stale entry here degrades to deriving from
scratch, never to a silently wrong answer. Each entry is **date-stamped** and marked:

- **hardened** — a keel run actually used this ladder; the entry carries earned weight.
- **researched** — a sourced research pass, unproven in a keel run. Trust it as a starting
  hypothesis, not authority.

**Maintenance loop:** when a run discovers an entry is stale or wrong, **update the entry**
(and flip its marker if the run proved it) — the same accretion loop as scars and `lessons/`.
Testing ecosystems churn at known rates (static tier ≈ stable; unit runners ≈ 5-year cycles;
the wiring layer is mid-migration *now*; e2e drivers ≈ 4–5-year cycles) — expect a light
touch 1–2×/year.

Entries lead with what unseeded research reproduces *worst* — the **escalation holes** (what
structurally can't be seen below the runtime walk), **scaffold gaps** (what the stack's
create-command doesn't ship), and **flake traps** — because the tool names are the easy 80%
any search finds. Ladders read cheapest → dearest.

---

## Web app frameworks

### React / Next.js (App Router) — hardened, as of 2026-07
- **Escalation holes:** async React Server Components cannot render below e2e (the framework's
  own docs say to test them end-to-end — keep server components thin, extract logic into
  unit-testable functions). Dev-vs-prod build transforms diverge (the ⚠ Q6 scar).
- **Scaffold gap:** the create-command ships **no test runner at all** — kickoff must add one.
- **Flake traps:** DOM-emulation harnesses diverge from real rendering exactly at
  server/client boundaries (the ⚠ Q3 scar); external-store hooks require referentially stable
  snapshots (a fresh-object selector infinite-loops at runtime while every unit test passes —
  a keel run hit this live).
- **Ladder:** typecheck (`tsc --noEmit`, incremental ~1–3s) + lint → Vitest units (watch
  re-runs <100ms) → component-render: DOM-emulation + a component testing library
  (mid-migration to Vitest browser mode — real browser, ~2–5× slower, closes fidelity gaps;
  check currency) → Playwright e2e.

### Vue / Nuxt — researched, as of 2026-07
- **Escalation holes:** Nitro server routes don't run below the integration layer.
- **Scaffold gap:** the create-command ships no runner.
- **Flake traps:** the framework-environment test project (auto-imports, data-fetching
  composables) boots a runtime per suite — keep it a *separate, slower* project from the plain
  fast one, or the whole suite pays the ~10× boot tax.
- **Ladder:** `vue-tsc --noEmit` (checks templates, ~5–20s) + the framework's lint plugin →
  Vitest units → component-render: the official test-utils + a fast DOM environment; a
  framework-environment project only for what needs auto-imports → Playwright e2e.

### SvelteKit — researched, as of 2026-07
- **Escalation holes:** **SSR and client are compiled as different code** — a component can
  pass every client test and crash on SSR; cover with a server-render project using the
  framework's server `render()`.
- **Scaffold gap:** none — the create-command's add-ons generate the full multi-project ladder
  (browser-mode client tests + node server tests + e2e). Select them at scaffold time.
- **Ladder:** `svelte-check` + lint → Vitest multi-project (browser-mode client project +
  node server project) → Playwright e2e.

## Cross-platform mobile

### React Native / Expo — researched, as of 2026-07
- **Escalation holes (the big one):** everything below e2e runs on Node with **all native
  modules mocked** — layout, gestures, permissions, and native rendering are invisible until a
  simulator/device run.
- **Flake traps:** the legacy test renderer is deprecated; the ecosystem has *not* migrated
  its unit runner the way web did (the older runner + the platform preset remains standard —
  check currency before assuming the web answer).
- **Ladder:** typecheck + the platform's lint config → the platform-preset unit runner + the
  native testing library (component-render on Node, native mocked) → e2e on
  simulator/device via the platform's current e2e driver (check which — this seat changed
  hands recently).

### Flutter — researched, as of 2026-07
- **Best-defined ladder in the survey; the scaffold ships it working** (analyzer + a passing
  widget test).
- **Escalation holes:** platform channels / real device behavior; permission dialogs need a
  device-level driver.
- **Flake traps:** golden tests must pin the CI renderer or they diff across machines.
- **Ladder:** format-check + analyzer → unit tests → **widget tests** (real widgets, headless
  VM, ~100ms–1s — the ecosystem's signature wiring layer) + goldens → integration tests on
  device.

## API backends

### Node API — researched, as of 2026-07
- **Escalation holes:** in-process request injection never binds a socket — pool exhaustion,
  backpressure, and shutdown behavior are invisible below a real-server smoke.
- **Flake traps:** test-runner parallelism vs a shared database (serialize or isolate);
  container-based DB tests amortize seconds of setup — keep them a separate project from the
  fast suite.
- **Ladder:** typecheck + lint → unit runner → in-process request tests against the app object
  (an in-process Postgres engine gets ~1s real-SQL tests without a container) → containerized
  real DB → real-server smoke.

### Python API — researched, as of 2026-07
- **Escalation holes:** **no compile step** — the static rung is the only thing between an
  edit and a runtime NameError, so it earns its keep here more than anywhere; untyped
  boundaries blind the typechecker (`Any` propagates silently).
- **Flake traps:** test-collection overhead grows with suite size (target single tests in the
  inner loop); emerging fast typecheckers are ~10× quicker but conformance still trails —
  check currency.
- **Ladder:** format+lint (ms, one tool) → typecheck (warm seconds) → unit tests →
  in-process ASGI test client (genuinely high fidelity) → containerized DB → real server.

### Go — researched, as of 2026-07
- **Famously flat ladder; the toolchain ships all of it.** `go build` is itself a real
  correctness layer; vet runs inside the test command; package-level test caching makes
  unchanged packages free.
- **Flake traps:** the race detector is the one cliff (2–20× time, 5–10× memory) — CI rung,
  not inner loop.
- **Ladder:** format+vet → build → `go test` + the stdlib HTTP test server (µs, in-process) →
  race-detector run in CI → containerized integration behind a short-mode flag.

### Rust — researched, as of 2026-07
- **The type system front-loads correctness into the check command** — `cargo check`
  (incremental, seconds) is *the* inner-loop rung; dominant ladder cost is codegen, not tests.
- **Flake traps:** the popular next-gen test runner **does not run doctests** (run those
  separately); clippy artifact-sharing with build is one-directional — order matters in CI.
- **Ladder:** format-check → `cargo check` → clippy → test runner + snapshot tests →
  real-binary + containerized integration.

## CLI tools

### Any-language CLI — researched, as of 2026-07
- **Escalation holes of in-process invocation:** signal handling, exit codes, TTY detection,
  stdin piping — a few true subprocess tests are non-negotiable.
- **Flake traps:** golden/snapshot output must normalize timestamps and paths or it flakes.
- **Ladder:** host language's static + unit rungs → in-process invoke (the arg-parser's test
  harness with injected I/O) → golden/snapshot layer → invoke the real binary (10–100ms).
