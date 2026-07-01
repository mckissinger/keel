# Change — Tier-aware, artifact-based verification

**Grain:** one change → one milestone (`spec-change`). **No-UI** (methodology/docs change to keel itself).

## Why (the gap)

When keel went framework-neutral, the stack profile abstracted *how to verify* into actor verbs —
Q3 "activate + assert healthy," Q4 "drive action + assert effect" — and the **test-tier ladder**
every stack has (unit → component-render → end-to-end) silently fell out of the interface. Two
consequences compounded:

1. **`[auto]` collapsed to pure-logic units.** With no profile question naming a component-render
   harness, projects derive profiles with a unit runner only. Deterministic *interaction* bugs —
   a render-loop from an unstable store snapshot, a focus-ordering bug that closes a panel the
   same keystroke that opens it — pass every `[auto]` check by construction, because nothing
   below the runtime walk ever mounts a component.
2. **Verification became actor-based, not artifact-based.** "Drive action + assert effect" reads
   as *an agent hand-drives it*, not *a committed test asserts it*. So for everything above pure
   units, a passing verdict leaves **no durable, re-runnable artifact**: the pin certifies a
   point-in-time pass by an agent, not regression coverage. Break the surface next week and
   nothing goes red — the only detector is re-spawning the whole walk.

**Evidence (dogfood, an earlier run on the hardened web stack, 2026-07):** a feature's detail
slide-over shipped two deterministic interaction bugs — an external-store snapshot-stability
violation that crashed the route on open (dev *and* prod), and an open-on-keypress whose
keyboard-activation click landed on the just-focused close button, closing the panel in the same
stroke. Both passed all `[auto]` checks (26 green pure-logic unit tests, typecheck, lint, clean
production build). Both were caught only by agent-driven runtime walks — one of which burned
~150k tokens / 21 minutes and still could not deterministically isolate an intermittent
recurrence, because a hand-driven browser session is a non-repeatable harness. A ~30-line
component-render test (mount the shell, open the panel, assert no throw + panel present) would
have caught both in under a second, deterministically, on every future run.

The walk is *right* as an acceptance layer — it catches what only a real runtime can (the
test-runtime ≠ production-runtime and dev-build ≠ prod-build divergences, profile-interface ⚠
Q3/Q6). It is *wrong* as the regression harness: expensive, non-deterministic, and it leaves
nothing behind.

## The mechanic

**1. Profile: add the test-tier ladder (Q11).** `references/profile-interface.md` gains
**Q11 — Test tiers**: the concrete, runnable command for each tier on this stack — **unit**
(pure logic), **component-render** (mount a real component/screen tree in a fast headless
harness — e.g. a DOM-emulation runner on web, a native preview/snapshot harness on mobile — and
drive interactions), and **end-to-end** (scripted checks against the real runtime — e.g. a
committed browser-automation spec). Each tier answers concretely **or "n/a + why"** (some stacks
genuinely lack a middle tier; the reason is recorded, not assumed). Cross-referenced from the
Q3/Q4 ⚠ notes, with a new ⚠ scar generalizing the dogfood evidence above.

**2. Rules: `[auto]` means a committed artifact asserts it.** In
`references/milestones-and-verification.md`:
- **§2/§7 —** `[auto]` is redefined as *"a committed automated check asserts this"* across
  **every tier the profile can run headlessly** — unit **and component-render interaction
  tests**, not pure logic only. A deterministic interaction (open/close, focus order, an edit
  commits, a filter re-derives) belongs in a committed tier, tagged `[auto]`; it is **not**
  `[runtime]` merely because it involves a UI.
- **§3 — the walk narrows** to what only a live runtime proves: activate each new/changed
  surface on **both dev and production builds** (Q3/Q6), the **vision/fidelity diff** (Q8.4),
  the **capped live variant** (Q7), and a short **exploratory pass** (the unscripted layer that
  finds what no enumerated condition anticipated). The enumerated action→effect assertions move
  into committed tests the verifier **runs**, rather than hand-driving each one.
- **§3/§5 — coverage gates the pin (hard).** Every `[runtime]` condition names the committed
  test that covers its deterministic core, in the **highest tier the profile supports**;
  `verify-milestone` refuses a `clean` verdict when a `[runtime]` condition lacks its named
  committed test — unless the profile marked that tier "n/a + why". The pin then certifies
  regression coverage, not just a point-in-time actor pass.

**3. Skills: three touch points.**
- `skills/spec-feature/SKILL.md` — the tagging bullet no longer routes every "a route renders /
  an action runs" condition to `[runtime]`; it routes the deterministic core to a committed tier
  (`[auto]`) and reserves `[runtime]` for the divergence/live/fidelity remainder.
- `skills/implement-milestone/SKILL.md` — the builder **authors the committed tests the
  done-conditions name** as part of the build (tests are code, not verification), and self-checks
  them green before handoff.
- `skills/verify-milestone/SKILL.md` — runs the committed suites first (all tiers), then the
  narrowed walk; enforces the coverage gate above.

**4. Fold-in (same files): spec-time fidelity reference is named components, never spec-time
code.** In `skills/spec-feature/SKILL.md` (Movement 2), `skills/spec-change/SKILL.md`
(movement 2), and `references/milestones-and-verification.md` §6: for a pure-composition
feature, the fidelity reference at spec time = the **named workbench/gallery components** (plus
an optional throwaway divergence sketch for a novel archetype). A **real composed feature
story/preview route is design-gate infrastructure committed on `main`** — never code inside a
plan-only PR. (Dogfood scar: a real story route built during spec-feature broke the plan-only
boundary and had to be re-homed to `main` as design infra.)

## Decisions taken (user AFK; recorded for PR review)

- **Gate strength: hard** — no pin without the named committed tests (profile "n/a + why" is the
  only escape). A soft norm is how the tier got lost the first time.
- **Walk scope: narrowed per-milestone** (dev+prod activation, vision diff, exploratory pass) —
  not removed, not once-per-feature; prod-divergence must land per-milestone or a broken
  milestone can pin.
- **Fold-in #3: yes** — same files, one review; separate PRs would conflict.

## Scope

Docs-only: two references + three skills, plus the `[auto]`-enumeration strings in
`workflows/verify-all-milestones.js` (run-discovered — the sweep restates the tag semantics, so
leaving it stale would contradict the new definition). No script changes (`check-verified-pin.sh`
is untouched — the coverage gate is procedural in `verify-milestone`, like the existing no-pin-
while-unrun rule). `scripts/check-neutral.sh` must stay green: all tier examples are hedged
("e.g."), no framework hardcodes. One-owner rule holds: the rules change lives in
`milestones-and-verification.md`; the skills reference it, they don't restate it.

Run-discovered housekeeping riding this branch: `.gitignore` gains a browser-automation
scratch dir (`.playwright-mcp/`) that verification sessions had been leaving untracked in the
repo root.
