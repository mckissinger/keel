---
name: app-design-directions
description: Design-SYSTEM exploration workflow for application UI (dashboards, CRMs, SaaS products, internal tools, data-heavy apps). Learns the app, generates 3–5 distinct directions as cheap throwaway mockups (in the stack profile's exploration medium — HTML for web), helps the user pick one, then converges the winner into the real WORKBENCH — a reviewable gallery of real themed primitives, built via the profile's workbench verb (a styleguide route on web), which every feature composes from as the durable source of truth.
when_to_use: ONCE per app to decide and build the design system, or for a redesign — whenever the user wants to design an app's interface, explore visual directions, pick a design language, build a design system, theme components, or says "make this look good," "design options," "mockups," "new UI," "redesign," "what should this look like." NOT for designing one feature's screens against an already-decided system — that's spec-feature.
---

# App Design Directions

You are acting as a design lead running a direction-exploration engagement for a real software product. The deliverable is not "a pretty page" — it is a **decision**: which of several credible, distinct design directions this app should commit to, demonstrated with mockups of the app's own screens and its own data, then implemented.

This skill is for **product UI** (apps people work inside: dashboards, CRMs, tables, forms, editors), not marketing pages. Product UI lives by different rules than landing pages: users see these screens hundreds of times, so clarity, density, scannability, and consistency beat spectacle. A direction can still have personality — it just has to earn it without slowing the user down.

## The workflow at a glance

```
Phase 0  DISCOVER   → learn the app, record its platform target + native-feel conventions, write a design brief, confirm with user
Phase 1  DIRECT     → propose 3–5 structurally distinct directions (token specs)
Phase 2  MOCK       → build one throwaway mockup per direction (profile's exploration medium; one screen) + compare gallery
Phase 3  SELECT     → user reviews side-by-side, picks (or hybridizes), decision recorded
Phase 3.5 SPREAD    → mock the chosen direction across the app's screen archetypes (cap ~5), redline — still throwaway
Phase 4  APPLY      → converge the winner into the real workbench (the profile's workbench verb), the durable source of truth
```

**The governing principle: diverge cheap, converge real.** Phases 2 and 3.5 are *throwaway* — cheap mockups that pick a direction on **look alone** and are then discarded, **never re-implemented as a spec**. Phase 4 is the *convergence*: the chosen direction is rebuilt as real, themed components — the **workbench** — which becomes the durable fidelity source of truth. Motion, interaction, and native feel are behavioral: they exist only in that real code, never in the throwaway mockup.

The phase is complete when each of these holds — treat them as the exit conditions, not a form to transcribe:

- [ ] Phase 0: codebase explored, platform target + native-feel conventions recorded, design brief written, brief confirmed by user
- [ ] Phase 1: 3–5 directions specced, each passed the anti-slop check and the distinctness check, each implementable on the platform target
- [ ] Phase 2: throwaway mockups built (profile's exploration medium) with real domain data, compare.html gallery assembled, self-reviewed via screenshots if a browser is available — judged on look only
- [ ] Phase 3: user decision captured in the design decision file (`specs/design.md` in a spec project, else `design/design-decisions.md`)
- [ ] Phase 3.5: chosen direction mocked across screen archetypes (one per archetype, cap ~5), screenshot-reviewed, redlined by user — still throwaway, look only
- [ ] Phase 4: real workbench built via the profile's workbench verb (tokens + components + motion/interaction-state tokens), verified for directional fidelity and native feel

Do not skip Phase 0 to get to pixels faster. The single biggest failure mode of AI-generated design is producing a generic interface for a generic app because the model never learned what *this* app actually is. Every distinctive choice downstream comes from the discovery work.

**Hold the right altitude.** Both ends of the specification spectrum fail. *Under-specified* — direction decided, nothing else — is how an app ships vanilla (a winning palette nobody installs, charts left at stock Recharts). *Over-specified* — every library, pixel, and layout fixed upfront — is rigid, designs in the abstract, and fights what the build learns. Aim for the middle: a **complete material palette** (tokens + icons + motion + charts + primitives), **per-archetype structure** (the mockups), and a **craft floor** (real states, accessibility, motion budget) — then let instance-level detail be inherited or built. Specified enough that it can't go vanilla; loose enough that it isn't a straitjacket.

---

## Phase 0 — Discover: learn everything about the app

Before proposing anything visual, build a real model of the product. Investigate the codebase and any docs:

1. **What it is.** README, PRD, landing copy, package.json name/description. What's the product, in one sentence?
2. **Who uses it and for what jobs.** Roles, frequency of use (daily driver vs. occasional), expertise level. A tool used 6 hours a day by one analyst wants very different design than a tool a customer touches once a month.
3. **The screen inventory.** Routes/pages, and which 2–3 screens are the *load-bearing* ones — where users spend most of their time. Identify the single most representative, most data-dense screen: that becomes the mockup canvas.
4. **The data shapes.** What are the core entities and fields? Pull real or realistic examples (property names, dollar amounts, statuses, dates — whatever the domain uses). Mockups built with the app's real vocabulary are an order of magnitude more persuasive than ones with "Lorem ipsum" or "Item 1 / Item 2."
5. **The existing stack and design state.** Framework, CSS approach (Tailwind version, shadcn/ui presence, CSS variables), existing tokens, component library, dark mode support. The winning direction must be implementable in this stack.
6. **Constraints and brand.** Existing logo/colors that must stay? Accessibility requirements? Density expectations? Anything the user has said before about taste (check memory/prior context).
7. **Information density requirement.** Honestly classify: is this a dense professional tool (tables, many fields, comparison work) or a focused consumer flow? Density is the most consequential axis in app design and the one AI defaults get most wrong (everything becomes airy cards).
8. **Platform target and native feel.** Record the platform this surface targets — **web, mobile, or cross-platform** — from the stack profile's design-surface cluster (Q8.1 has-UI? and the platform-convention verb, Q8.6). For a **mobile or cross** target, capture the **platform-convention set** the surface must obey to feel native: navigation patterns, gestures, and system controls (pickers, date-pickers, share sheets) per Q8.6 — versus what is **brand-universal** (the token palette, type scale, iconography, information architecture, which port across platforms). Every direction proposed downstream **must be implementable on this platform target and must not impose a web look on a native surface** (a web-style top nav, hover-only affordances, or custom-drawn controls where the platform expects its own). The **exploration medium** itself is profile-driven: self-contained HTML mockups for web; a profile-appropriate throwaway medium for mobile (derivable from the platform's workbench/screenshot mechanisms, Q8.3/Q8.4).

Write the findings into `design/design-brief.md` using `templates/design-brief.md`. Then present a compact summary to the user and ask **at most 2–3 questions**, only about things you genuinely could not infer (e.g., "should the existing green logo color survive the redesign?"). Get a confirmation before Phase 1 — a wrong brief poisons everything downstream.

## Phase 1 — Direct: propose 3–5 genuinely distinct directions

Read `references/direction-recipes.md` before doing this phase, and `references/anti-slop.md` always.

A "direction" is a complete, named visual system — not a color swap. Each direction gets a spec (use `templates/direction-spec.md`):

- **Name + thesis** — one sentence on what this direction believes about the product.
- **Tokens** — 4–6 named hex colors, type pairing (display/UI/data faces with rationale), spacing unit, radius scale, depth/border strategy, density setting.
- **Material palette** — the design-consequential front-end libraries this direction commits to, each chosen *against* its slop default: icon set + style (e.g. Phosphor thin, not Lucide-everywhere), motion library + stance (none / functional / expressive, and where) together with its **motion + interaction-state tokens** (easing/duration, hover/pressed/focus/disabled deltas — named once, inherited by every component, never re-decided per widget), chart/data-viz library + treatment (palette-matched axes and grids, not stock Recharts), component primitives (unstyled shadcn/Radix you theme vs. an opinionated kit that imposes its own look). These are part of what makes a direction distinct and the single biggest source of "it went generic in the build" — a direction that leaves them at defaults isn't a direction. (Which file *owns* these once chosen — `design.md`, not the architecture spec — is set in Phase 3.)
- **Layout architecture** — nav pattern, screen composition, how density is handled.
- **Signature element** — the one memorable, ownable device (and only one).
- **What it optimizes for / what it trades away** — every honest direction has a tradeoff. If you can't name one, the direction is mush.

**The distinctness test:** any two directions must differ on at least three structural axes (layout architecture, type system, color strategy, shape/depth language, density, motion stance, material palette) — not merely hue. If a user squinting at two mockups couldn't tell them apart in grayscale, they are one direction, not two.

**The anti-slop gate:** check every direction against the banned-defaults list in `references/anti-slop.md`. The defaults aren't banned because they're ugly — they're banned because they're what you'd produce for *any* app, and this engagement is paid to be specific to *this* app. Derive choices from the discovery brief: the domain's own materials, vocabulary, and artifacts are where distinctive choices come from. (A manufactured-housing acquisitions CRM has a world of land plats, county records, rent rolls, and Sun Belt geography to draw from — a generic "modern SaaS" look ignores all of it.)

Spend most of this thinking privately; show the user the direction specs only once they're sharp. Present all directions in one message as a compact comparison table plus a short paragraph per direction, then proceed to mockups (don't wait for approval of specs — the mockups are the real conversation).

## Phase 2 — Mock: build comparable mockups

Read `references/product-ui-craft.md` before building, and `references/stack-and-mockups.md` for the mechanics.

**These mockups are throwaway — they exist to find a direction, and nothing more.** They are judged on **look only** — palette, type, density, layout architecture, the signature element — and **never** on motion, interaction, or native feel, which are behavioral and live only in real code (Phase 4). A mockup is **never re-implemented as a spec**: the moment a direction is chosen it converges into the real workbench and the mockup is discarded. Build them in the **profile's exploration medium** — self-contained HTML for a web target; a profile-appropriate throwaway medium for a mobile target (per Q8.3/Q8.4). The rules below are written for the web medium; a mobile target uses its equivalent.

Rules that make the comparison fair and the decision easy:

1. **Same screen, same data, every direction.** Build the load-bearing screen identified in Phase 0, with identical content across all mockups. The only variable is the design. This is what makes side-by-side judgment possible.
2. **Self-contained files in the exploration medium (web: HTML).** One file per direction (`design/mockups/direction-name.html`), inline CSS, Google Fonts via link tag, no build step — they must open by double-click. Static is fine; a couple of hover states bring it to life, but they are decoration for the look, not a spec for interaction.
3. **Real states, not just the happy path.** Each mockup should show at least one non-ideal moment: a loading row, an empty section, an error or warning chip, a focused input. Product UI is judged by its worst screen, not its best.
4. **Realistic density.** If the brief says dense professional tool, the mockup shows 15 rows, not 3 beautiful cards.
5. **Build the compare gallery.** Generate `design/mockups/compare.html` from `templates/compare.html`: it shows all directions in labeled frames with the thesis and tradeoff of each, viewable in one window.
6. **Self-review before presenting.** If Playwright, a browser MCP, or any screenshot capability is available, render each mockup and *look at it* — check contrast, alignment, overflow, whether the signature element actually reads. A picture is worth a thousand tokens; fix what you see before the user sees it. If no browser is available, re-read each file critically against the Phase 2 rules and the anti-slop list.

Present: **open `design/mockups/compare.html` in the browser for the user** (`open` on macOS / `xdg-open`), give a 1–2 sentence honest pitch per direction including its tradeoff, and ask which direction wins — noting that hybrid answers ("layout of B, palette of D") are normal and welcome.

## Phase 3 — Select: capture the decision

When the user picks (or hybridizes):

1. If hybrid, produce one merged direction spec and (if the merge is non-obvious) one merged mockup for sign-off.
2. Write the decision file: the chosen direction's full spec — tokens, type, density, signature element, **and the material palette (icon set, motion library + stance, the motion + interaction-state tokens, chart/data-viz library + treatment, component primitives)** — the rejected directions with one line each on *why* they lost, and any user quotes about taste. **Location: if the project has a `specs/` folder, write `specs/design.md` — the spec is the single source of design memory; otherwise `design/design-decisions.md`.** `design.md` is the *owner* of the design-consequential library choices; the architecture spec's stack list references them, it does not re-decide them (one owner per fact, or the two files drift). Future sessions (and future Claude instances) read it instead of re-litigating.
3. Emit the final token set in the project's native format (Tailwind v4 `@theme` block, shadcn CSS variables, or plain CSS custom properties — whatever Phase 0 found).
4. **Name any two recorded behaviors that act on the same element or attribute** — each may be individually correct yet collide in code. A motion treatment and a static encoding on the same mark are the classic trap: "the chart line draws in on mount" and "series are differentiated by dash pattern" both target the line's `stroke-dasharray`, so the naïve draw-in (animating the dash) silently erases the differentiator — and *both* requirements still read as satisfied on paper (this is a real bug from an earlier run; the fix was to draw in via a clip-path reveal so the dash survives). When the same surface carries two requirements (motion + encoding, theme-swap + a hardcoded value, density + a fixed height), write the interaction into `design.md` so they're built to compose, not as independent lines that each pass alone.

## Phase 3.5 — Spread: prove the direction across screen archetypes

Phase 2 chose a direction on one screen. Before committing it to real code, validate it survives the app's structural variety — in throwaway HTML, where mistakes are cheap and the redline is fast.

1. **Mock by archetype, not by screen.** An archetype is a structural layout pattern (dense table/list, detail view, form/multi-step, empty/dashboard state, calendar/timeline, data-viz/charts, conversational/live-stream (chat, feed, live log), marketing/landing) — many screens share one. Build one representative screen per archetype the app actually has, **capped at ~5**. A 30-screen app still collapses to ~5 archetypes; complexity adds instances per archetype, not new archetypes. A simple app may only have 2–3. Pick the archetypes from the Phase 0 screen inventory.
2. **Why this set and not "all screens":** each archetype stresses the direction differently — a table tests density, a wizard tests flow, an empty state tests "what does nothing look like," a detail view tests hierarchy. A direction that sings on a dashboard can collapse on a form. Five archetypes catch that; thirty screens just repeat the finding.
   - **If the app has charts or a dashboard, a data-viz screen is a mandatory archetype** — not an optional one. Charts are where data apps look most generic, and the chart treatment (palette-matched axes/grids/labels, the recorded data-viz library) only gets proven on a real data-viz mockup. Skip it and the dashboard defaults to stock Recharts no matter how good the rest of the direction is. For data-heavy apps this is the single highest-leverage screen to mock.
   - **If the app has a conversational or live-stream surface (chat, feed, live log, agent progress pane), that archetype is likewise mandatory** — it's where generated UI defaults hardest. The mockup proves the direction on the surface's *states* (streaming vs loading, the unread boundary, jump-to-latest, the transcript's density and turn hierarchy); the scroll-intent *behavior* is proven only in the real workbench/build, per the interaction floor's live-surfaces principle (`references/interaction-craft.md` at the plugin root).
3. **These are direction references, not pixel specs — still throwaway, still look-only.** Same exploration-medium mechanics as Phase 2 (self-contained, real data, real states). They capture the *transferable* decisions — palette, type, density, layout architecture, the signature element — not final fidelity, and are **never re-implemented as a spec**; motion, interaction, and native feel are proven only in the real workbench. The real build will look different and more polished (see Phase 4).
4. **Screenshot-review each, then redline.** **Open the archetype set in the browser for the user** (`open` / `xdg-open`) and present it for sign-off. This is the milestone's human checkpoint — the direction isn't locked until the user has redlined the spread, not just the single Phase 2 screen.

For a project using the spec workflow, this completes the **design-system kickoff gate** — which is *not* a numbered build milestone. The gate runs attended during the kickoff sitting (the redline is the user's live judgment) and **ends at a redlined archetype set + `specs/design.md` + the built workbench (Phase 4), all committed to main** (durable, like the other spec files — never carried on a milestone branch where a later merge/squash can orphan them).

**This gate decides and builds the design SYSTEM — not any one feature's screens.** After it, individual features are designed *per feature* by the `spec-feature` skill, which mocks that feature's own screens by **composing from this system** (the workbench + `design.md` tokens). Do **not** re-run this skill per feature — the direction is locked; per-feature screen design that re-explores directions is the bug. The system is decided once here; the screens are designed many times, downstream, from it.

## Phase 4 — Apply: converge into the real workbench (the durable source of truth)

This is the **convergence** — where cheap divergence becomes real code. It builds the **system**, not the whole app. Its deliverable is the **workbench**: a reviewable gallery of the real, themed primitives in every state, built via the **stack profile's workbench verb (Q8.3)** — design as **code**, not prose. The workbench is the durable **fidelity source of truth** every feature later composes from and diffs against; the throwaway mockups from Phases 2/3.5 are now discarded, **never re-implemented from HTML**. (Wide per-screen application happens downstream, per feature, in `spec-feature` + the feature's build milestones — not here.)

The workbench verb is **profile-driven**. On the hardened web stack it is a **`/styleguide` route** that imports the real primitives and lays them out in every state; on a mobile stack it is the platform's native preview harness (the profile's Q8.3 answer — e.g. a SwiftUI `#Preview` set, a Compose `@Preview`, Widgetbook). The web `/styleguide` route below is the **web example** of the workbench verb, not the universal mechanism.

1. **Tokens first.** Install the design tokens — colour, type, spacing, radius, **and the motion + interaction-state tokens** (easing/duration; hover/pressed/focus/disabled deltas; reduce-motion read once at the token layer) — via the profile's token source (CSS variables / `@theme` on web; the portable token source per Q8.2 elsewhere). Never hardcode a value in a component that exists as a token.
2. **Build the workbench — the whole material palette, as real components, on the profile's workbench surface** (the `/styleguide` route on web; the native preview harness on mobile — Q8.3). Themed primitives replacing native controls (on web, e.g. `<select>` → a themed Select; on native, the platform's own system controls, themed through the tokens rather than re-drawn), the chosen icon package, the chosen motion library, the chosen chart/data-viz library — each themed to the palette — **and the load-bearing states every feature needs: default, hover, pressed, focus, disabled, empty, loading, error, populated.** This surface is the reviewable artifact: the user signs off on the *system* here, and `spec-feature` assembles feature screens from these exact primitives so features can't drift to defaults. Capture it (the profile's screenshot/review driver, Q8.4) and compare against the direction for **directional fidelity** (palette, type, density, architecture, signature element) — not pixel parity; the real stack will and should look more polished than the throwaway mockup. Fix *directional* drift only.
3. **Retheme, don't fight, the component library (web example).** With shadcn/ui, change the CSS variables and a small number of component files — that's the whole point of owning the components. Default shadcn styling is itself a recognized AI fingerprint, so the tokens must actually move away from stock. On a native stack the equivalent is theming the platform's own control set through the tokens, not re-implementing controls.
4. **Verify the workbench visually** (screenshot loop again, via the Q8.4 driver) and against the quality floor in `references/product-ui-craft.md`: keyboard focus visible, WCAG AA contrast, empty/loading/error states styled, responsive behavior sane, reduced-motion respected. On a **mobile or cross** target, also verify the **platform-convention set (Q8.6)** — native navigation, gestures, and system controls — so the build honours native feel instead of forcing a web look onto native.
5. Update the design decision file (`specs/design.md` in a spec project, else `design/design-decisions.md`) with anything that changed during implementation — the same single owner written in Phase 3, never a second file.

---

## Reference files — when to read what

| File | Read when |
|---|---|
| `references/anti-slop.md` | Always, before Phase 1. The empirical list of AI-design fingerprints to avoid, and why. |
| `references/direction-recipes.md` | Phase 1. Axes of variation, direction archetypes for app UI, how to make 5 directions truly different. |
| `references/product-ui-craft.md` | Phase 2 and 4. App-specific craft: density, hierarchy, tables, forms, states, color-as-meaning, typography for data, accessibility floor. |
| `references/stack-and-mockups.md` | Phase 2 and 4. The **web** mockup + workbench mechanics — one instance of the profile's exploration/workbench verbs: mockup file rules, web token wiring, screenshot self-review. Mobile is derivable against the stack profile (Q8.2–Q8.4), not spelled out here. |

## Tone with the user

The user is the client and the decider. Bring opinions — recommend a direction and say why — but never railroad. When they push toward something on the anti-slop list, distinguish: if they *chose* it for this app, it's a choice and you execute it excellently; the list bans defaults, not options. Keep updates brief; let the mockups do the talking.
