# Interaction craft — the motion & feel floor

The layer between "the design system was applied" and "the composition sings": how interactions
*feel*. `specs/design.md` owns the **decisions** (palette, type, density, motion stance, the
chosen motion library); this file owns the **craft** of using them well — checkable principles
for motion, micro-interactions, and the invisible details that separate a product from a mockup.

> Craft principles here are adapted from Emil Kowalski's design-engineering philosophy
> ([animations.dev](https://animations.dev/)), rewritten for this workflow.

**Design-system precedence.** If `specs/design.md` records a motion stance (static / functional /
expressive) or specific values, conform to it — apply this craft *within* those decisions, never
overriding them. This sharpens how the chosen design feels; it does not re-pick the design.

## When this is read

- **`spec-feature` / `spec-change` Movement 2** — compose screens *with* interaction intent, and
  turn the relevant principles below into **fidelity done-conditions** (so motion is specced and
  checkable, not left to the builder's defaults).
- **`review-feature`** — the rubric for the "does it sing" judgment. Phrase findings as a
  `| Before | After | Why |` table (one row per issue), so the aesthetic call is concrete.

## The principles

### 1. Should this animate at all?

Frequency decides. The more often a user sees it, the less it should move.

| How often the user sees it | Decision |
|---|---|
| 100+×/day (keyboard shortcuts, palette toggle) | **No animation.** Ever. |
| Tens of times/day (hovers, list nav) | Remove or drastically reduce |
| Occasional (modals, drawers, toasts) | Standard animation |
| Rare / first-run (onboarding, celebrations) | Can add delight |

**Never animate a keyboard-initiated action** — it's repeated constantly and animation makes it
feel laggy. Every animation must answer "why does this move?" (feedback, spatial continuity, state
indication, preventing a jarring jump). "It looks cool" + seen-often = don't.

### 2. Easing and duration

- **Enter/exit → `ease-out`** (starts fast, feels responsive). **Never `ease-in` on UI** — the
  delayed start reads as sluggish at the exact moment the user is watching.
- **On-screen movement/morph → `ease-in-out`**; **hover/color → `ease`**; **constant motion → `linear`**.
- **Use custom curves** — the built-in CSS easings are weak. Keep a small named set (a strong
  ease-out, a strong ease-in-out, a drawer curve) in the token layer.
- **Keep UI animations under ~300ms.** A 180ms dropdown feels more responsive than a 400ms one.
  Rough budget: button press 100–160ms, tooltip/small popover 125–200ms, dropdown 150–250ms,
  modal/drawer 200–500ms.

### 3. Perceived performance

Speed is partly perception. A faster spinner makes loading *feel* faster at the same load time.
`ease-out` at 200ms feels faster than `ease-in` at 200ms because movement is immediate. Once one
tooltip is open, adjacent ones should open instantly (skip the delay) so the toolbar feels fast.

### 4. The feel of components

- **Pressable things respond to press** — a subtle `scale(0.97)` on `:active` confirms the UI
  heard the user. Applies to any pressable element.
- **Never animate from `scale(0)`** — nothing appears from nothing. Start at `scale(0.95)` + opacity.
- **Popovers scale from their trigger**, not center (`transform-origin` at the trigger); **modals
  stay centered** (they aren't anchored to a trigger).
- **Use transitions, not keyframes, for anything triggered rapidly** (toasts, toggles) — transitions
  retarget mid-flight; keyframes restart from zero.
- **Asymmetric enter/exit** — slow where the user is deciding (a hold-to-confirm), snappy where the
  system responds (release). Don't reuse one duration for both directions.
- **Stagger** entering lists by 30–80ms per item; never block interaction while a stagger plays.

### 5. Performance & accessibility (non-negotiable)

- **Animate only `transform` and `opacity`** (GPU, skips layout/paint). Animating width/height/
  margin/top triggers the whole pipeline.
- **`prefers-reduced-motion`** — fewer/gentler, not zero: keep opacity/color that aids
  comprehension, drop movement.
- **Gate hover effects** behind `@media (hover: hover) and (pointer: fine)` so touch taps don't
  trigger phantom hovers.

## The review table (for review-feature)

Output interaction findings as a table, one row per issue:

| Before | After | Why |
| --- | --- | --- |
| `transition: all 300ms` | `transition: transform 200ms ease-out` | name exact properties; `all` is a footgun |
| `ease-in` on a dropdown | strong `ease-out` curve | `ease-in` feels sluggish; `ease-out` gives instant feedback |
| no `:active` on a button | `scale(0.97)` on `:active` | pressable things must feel the press |
| `transform-origin: center` on a popover | origin at the trigger | popovers scale from where they opened (modals stay centered) |
| animation on a keyboard action | none | seen too often; movement makes it feel slow |

For deeper implementation techniques (clip-path reveals, gesture/drag physics, WAAPI, 3D, Framer
hardware-acceleration caveats), see `${CLAUDE_PLUGIN_ROOT}/references/motion-cookbook.md`.
