# Interaction craft — the motion & feel floor

The layer between "the design system was applied" and "the composition sings": how interactions
*feel*. `specs/design.md` owns the **decisions** (palette, type, density, motion stance, the
chosen motion library); this file owns the **craft** of using them well — checkable principles
for motion, micro-interactions, and the invisible details that separate a product from a mockup.

These principles are the **platform-neutral floor** — they hold on web, iOS, Android, or any
surface that renders a UI. They are stated in terms of *feel* (frequency, easing, press feedback,
reduced motion), not in terms of any one platform's API. The concrete web/CSS *techniques* that
implement them (WAAPI, `@starting-style`, `clip-path` reveals, Framer specifics, transform/opacity
compositing) live in the on-demand cookbook — see `motion-cookbook.md` — and are read only when a
feature needs them, not treated as the universal floor.

> Craft principles here are adapted from Emil Kowalski's design-engineering philosophy
> ([animations.dev](https://animations.dev/)), rewritten for this workflow.

**Design-system precedence.** If `specs/design.md` records a motion stance (static / functional /
expressive) or specific values, conform to it — apply this craft *within* those decisions, never
overriding them. This sharpens how the chosen design feels; it does not re-pick the design.

## Motion and states are tokens, not values

Motion and interaction-states are **token-level, not per-component** — expressed once per the
profile's **Q8.5 motion + interaction verb** and inherited everywhere, never re-decided per widget:

- **Motion tokens (easing / duration)** — a small named set of easing curves and a duration scale
  live in the token layer (the profile's Q8.2 token source). Components reference the named tokens;
  no widget hardcodes a raw curve or millisecond value.
- **Interaction-state tokens (hover / active / selected / disabled / focus)** — the deltas for each
  state are named tokens every component inherits, applied via the stack's state mechanism (on web,
  `:hover` / `:focus-visible` / a pressed-state marker; the platform equivalent elsewhere).
- **Reduce-motion is a first-class branch, read once at the token layer** — not bolted on per
  screen. The reduce-motion signal (on web, `prefers-reduced-motion`; the platform's accessibility
  flag elsewhere) is consulted at the token layer so honoring it is **structural**: when it is on,
  spatial motion collapses to fades *system-wide*, keeping opacity/color that aids comprehension
  and dropping movement. Wiring the check per-animation invites the one screen that forgets it and
  ships motion-sick; reading it once at the token layer makes that impossible.

## When this is read

- **`spec-feature` / `spec-change` Movement 2** — compose screens *with* interaction intent, and
  turn the relevant principles below into **fidelity done-conditions**, named with the motion
  vocabulary below (so motion is specced and checkable, not left to the builder's defaults).
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

- **Enter/exit → ease-out** (starts fast, feels responsive). **Never ease-in on UI** — the
  delayed start reads as sluggish at the exact moment the user is watching.
- **On-screen movement/morph → ease-in-out**; **hover/color → a gentle ease**; **constant motion → linear**.
- **Use custom curves** — a platform's default easings are weak. Keep a small named set (a strong
  ease-out, a strong ease-in-out, a drawer curve) as **motion tokens**, not per-widget values.
- **Keep UI animations under ~300ms.** A 180ms dropdown feels more responsive than a 400ms one.
  Rough budget: button press 100–160ms, tooltip/small popover 125–200ms, dropdown 150–250ms,
  modal/drawer 200–500ms. Author these as duration tokens.

### 3. Perceived performance

Speed is partly perception. A faster spinner makes loading *feel* faster at the same load time.
Ease-out at 200ms feels faster than ease-in at 200ms because movement is immediate. Once one
tooltip is open, adjacent ones should open instantly (skip the delay) so the toolbar feels fast.

### 4. The feel of components

- **Pressable things respond to press** — a subtle press-down (a small scale-down, ~0.97) on the
  pressed state confirms the UI heard the user. Applies to any pressable element.
- **Never animate from nothing** — nothing appears from a zero scale; start from a near-full scale
  (~0.95) plus opacity so the element grows into place instead of popping from a point.
- **Popovers scale from their trigger**, not center (origin at the trigger); **modals stay
  centered** (they aren't anchored to a trigger).
- **For anything triggered rapidly** (toasts, toggles), use an interpolation that **retargets
  mid-flight** rather than one that restarts from zero — so an interrupted animation continues from
  where it is instead of snapping back.
- **Asymmetric enter/exit** — slow where the user is deciding (a hold-to-confirm), snappy where the
  system responds (release). Don't reuse one duration for both directions.
- **Stagger** entering lists by 30–80ms per item; never block interaction while a stagger plays.
- **Hold the exit after a selection** — when the user picks from a menu or list that then
  dismisses, keep the selection visible ~200–400ms before it leaves (the delayed exit of a
  native context menu) so the result registers. This is a held *exit*, not a slower response —
  and the keyboard rule still wins: keyboard-initiated actions get no animation at all.
- **Focus and scroll chrome are designed surfaces** — the focus indicator is designed like any
  other state (shape and offset matched to the control, visible in both themes — on web,
  `:focus-visible` with an offset that follows the control's radius), and scroll chrome on a
  designed panel is deliberate rather than platform default (on web, thin token-colored
  scrollbars). Chrome left at defaults reads as unfinished on an otherwise designed surface.

### 5. Performance & accessibility (non-negotiable)

- **Animate cheap, compositor-friendly properties** — the ones that skip layout/paint (on web,
  `transform` and `opacity`; the platform equivalent elsewhere). Animating layout-affecting
  properties (width/height/margin/position) triggers the whole rendering pipeline.
- **Reduced motion is first-class** — read once at the token layer (see "Motion and states are
  tokens" above), fewer/gentler not zero: keep opacity/color that aids comprehension, drop movement.
- **Gate hover affordances behind an actual pointer** — a hover-capable, fine pointer — so touch
  taps don't trigger phantom hovers.

## The motion vocabulary

Fidelity done-conditions and review findings are only as precise as their words. Name motion
with these terms — in Movement 2 conditions ("rows enter with a 40ms stagger", "paging is
direction-aware") and in review-table findings — instead of describing it loosely ("animates
in nicely"), so the builder produces the intended motion and the verifier can check it.
(Vocabulary follows Emil Kowalski's animations.dev usage.)

- **stagger** — offset each item's start in an entering group (30–80ms per item) so the group
  reads as a sequence, not a block.
- **direction-aware** — enter/exit reflects where the element came from or is going: paging
  forward slides content one way, paging back reverses it; an indicator travels toward the
  newly selected item.
- **layout animation** — when layout changes (reorder, insert, remove, resize), the surviving
  elements animate to their new position/size instead of teleporting.
- **morph** — one element continuously transforms into another (position, size, and shape
  together) so the eye reads a single persistent object, not a swap.
- **crossfade** — the old state fades out as the new fades in, in place; the cheapest
  transition when the two states share no spatial relationship.
- **spatial consistency** — an element keeps one spatial identity across states: it exits the
  way it entered, returns along the same path, and anchors where it originated (a popover at
  its trigger).
- **rubber-banding** — resistance past a boundary: motion continues but progressively damped,
  then settles back — signaling an edge without a hard stop.
- **retarget mid-flight** — an interrupted animation continues from its current value and
  velocity toward the new target; it never restarts from zero.

## The review table (for review-feature)

Output interaction findings as a table, one row per issue. (The example rows below are in web/CSS
form because the web is the hardened stack; translate the *finding* to the surface under review.)

| Before | After | Why |
| --- | --- | --- |
| `transition: all 300ms` | name exact properties, ~200ms ease-out | naming the property is precise; animating "all" is a footgun |
| ease-in on a dropdown | a strong ease-out curve | ease-in feels sluggish; ease-out gives instant feedback |
| no press feedback on a button | ~0.97 scale-down on the pressed state | pressable things must feel the press |
| popover scaling from center | origin at the trigger | popovers scale from where they opened (modals stay centered) |
| animation on a keyboard action | none | seen too often; movement makes it feel slow |
| reduce-motion checked per screen | one branch at the token layer | one place to forget is one screen that ships motion-sick |

For deeper implementation techniques (clip-path reveals, gesture/drag physics, WAAPI, springs, 3D,
Framer hardware-acceleration caveats) — the **web/CSS cookbook**, read on demand — see
`${CLAUDE_PLUGIN_ROOT}/references/motion-cookbook.md`.
