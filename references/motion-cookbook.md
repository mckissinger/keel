# Motion cookbook — deep **web/CSS** techniques (read on demand)

**These are web/CSS techniques**, not the platform-neutral floor. The always-on principles live in
`interaction-craft.md`; this file is the hardened-web implementation layer — reach here when a
feature on the web actually needs gestures, reveals, or hand-tuned physics. Everything below assumes
CSS / the DOM / a browser motion library. Adapted from Emil Kowalski's design-engineering philosophy
([animations.dev](https://animations.dev/)); the view-transition, scroll-driven, and detail-chrome
notes also draw on public breakdowns by Rauno Freiberg and Jhey Tompkins. Conform to
`specs/design.md`'s motion stance.

> **Per-platform technique references are derived when a mobile stack appears.** Consistent with
> "neutral seams now, web hardened": the neutral *principles* (in `interaction-craft.md`) already
> apply to mobile; only the *techniques* are platform-shaped. When a project's profile (Q8.5)
> names a non-web motion library, derive the equivalent cookbook then — e.g. a **Reanimated**
> (React Native), **SwiftUI** (`withAnimation` / `Animation`), or **Jetpack Compose**
> (`animate*AsState` / `AnimatedContent`) technique reference — rather than stubbing every platform
> up front.

## clip-path reveals

`clip-path: inset(top right bottom left)` clips a rectangle; each value eats in from that side.
Animating it is one of the most useful reveal tools because it changes *what's visible* without
moving or repainting the element.

- **Reveal L→R:** `inset(0 100% 0 0)` → `inset(0 0 0 0)`.
- **Reveal on scroll:** start `inset(0 0 100% 0)` (hidden from bottom) → `inset(0 0 0 0)` when it
  enters the viewport (`IntersectionObserver`, fire once).
- **Two-state color/encoding without a crossfade:** duplicate the element, style the copy as the
  "active" state, clip the copy, animate the clip on change — a seamless transition timing
  individual color transitions can't match. *This is also the safe way to "draw in" a chart line
  whose dash pattern carries meaning: reveal via a clip-path wipe so the `stroke-dasharray`
  encoding survives, instead of animating the dash and erasing it.*
- **Hold-to-confirm:** colored overlay `inset(0 100% 0 0)` → `inset(0 0 0 0)` over ~2s linear on
  `:active`; snap back 200ms ease-out on release (asymmetric — slow to decide, fast to respond).

## Gesture & drag

- **Momentum dismissal** — don't require crossing a distance threshold; compute velocity
  (`|distance| / elapsed`) and dismiss on a quick flick even if short.
- **Boundary damping** — past a natural edge, move less the more they drag (friction, not a wall).
- **Pointer capture** — once dragging starts, capture pointer events so it continues if the pointer
  leaves the element.
- **Multi-touch guard** — ignore additional touch points after the drag begins, or the element
  jumps to a new finger.

## Springs

Springs feel natural because they simulate physics and settle rather than run a fixed duration; they
keep velocity when interrupted (CSS keyframes restart from zero), which is ideal for interruptible
gestures. Use for drag-with-momentum, "alive" elements, decorative mouse-tracking. Keep bounce
subtle (0.1–0.3) and avoid it in most product UI. Apple-style `{ duration, bounce }` is easier to
reason about than raw stiffness/damping.

## Curved paths

When an element travels to a target — an item flying to a cart, a thumbnail to its slot — a
curved trajectory often reads better than a straight translate: a straight line between two
distant points looks mechanical, while a slight arc (with rotation following the path) reads as
moved, not teleported. Arc-style path APIs do the math — e.g. Motion's
`arc({ strength, peak, direction, rotate })` on the web — rather than hand-keyframing control
points. Reserve it for genuine travel across the screen; short hops don't need the arc.

## 3D & perspective

Tilt and flip need a `perspective` value on the **parent** (or `transform: perspective(...)`
first in the element's own transform) — without it, `rotateX`/`rotateY` flatten into a scale.
Smaller values are more dramatic; ~500–1000px is a sane range. `transform-origin` drives where
the rotation reads from — a card flipping about its left edge and one flipping about its center
are different objects to the eye. `backface-visibility: hidden` hides the mirrored back of a
flipped face.

## Cross-container motion

Motion that crosses container boundaries — an item dragged between panes, a card promoted from
a list into a split view — wants **one flat layer**: nested scrollers and stacking contexts
clip and re-coordinate anything that tries to cross them.

- **Flatten the logical tree to a single coordinate space** for rendering and animation: keep
  the nested tree as the model, but render the moving pieces in one flat layer so an element
  can travel anywhere in the composition without being clipped at a divider.
- **Transient affordances render as an overlay above the whole composition** — drag previews,
  drop-target highlights, insertion markers live in one overlay layer, never intrinsic to each
  container, so they can travel across dividers instead of being rebuilt inside every pane.
- **Place a new container at full size, then slide it in.** Animating a pane's size while its
  content lays out reflows every frame (resize jitter); mount it at its final size and
  translate it into place.

## View transitions

`document.startViewTransition(updateDOM)` snapshots the page, applies your DOM change, and
animates old → new — the platform's native crossfade/morph between two states, no library.

- **Element morphs:** give the element a `view-transition-name` present in both states and the
  browser morphs position/size between them; customize via
  `::view-transition-old(name)` / `::view-transition-new(name)`.
- **Where it shines:** state swaps that would otherwise need FLIP math — list reorders,
  card → detail expansions, theme switches, image → lightbox morphs.
- **Overlay caveat:** the transition renders in a top-layer snapshot. Fixed navs and overlays
  need their own `view-transition-name` or the root transition drags them through the morph —
  and paint order during the transition follows the snapshot tree, not your stacking contexts.
- **Fallback is free:** `if (!document.startViewTransition) { updateDOM(); return; }` — the
  state change still happens, just untransitioned.

## Scroll-driven animations

`animation-timeline: view()` / `scroll()` binds a CSS animation's progress to an element's
visibility in the viewport or a scroller's position — scroll reveals with no JS and no
IntersectionObserver.

- **Reveal-on-enter:** a keyframed fade/translate with `animation-timeline: view()` plus an
  `animation-range` (e.g. `entry 0% entry 100%`) plays as the element enters the viewport.
- **Progressive enhancement:** gate with `@supports (animation-timeline: view())`; unsupported
  browsers show the element static. For fire-once semantics, IntersectionObserver remains the
  tool — scroll-driven timelines scrub in both directions.
- ⚠ **The frequency table still governs.** Scroll-driven motion suits marketing/landing
  surfaces read once; app work surfaces are seen tens of times a day and rarely
  scroll-animate. Don't let the mechanism's cheapness argue the motion in.

## Performance specifics

- **CSS animations beat JS under load** — they run off the main thread; `requestAnimationFrame`-based
  libraries drop frames while the browser is busy (page loads). Use CSS for predetermined motion,
  JS for dynamic/interruptible.
- **Framer Motion shorthand (`x`/`y`/`scale`) is not hardware-accelerated** — it runs on the main
  thread. For acceleration under load, animate the full `transform` string.
- **WAAPI** (`element.animate([...], {...})`) gives JS control with CSS performance — accelerated,
  interruptible, no library.
- **Don't write a CSS variable on a parent to drive a child's transform** — it recalcs styles for all
  children; set `transform` directly on the moving element.

## Misc

- **`@starting-style`** animates entry without JS (replaces the `useEffect(setMounted)` pattern);
  fall back to a `data-mounted` attribute where unsupported.
- **`translateY(100%)`** moves an element by its own height regardless of size — how drawers hide and
  toasts position. Prefer percentages over hardcoded pixels.
- **Blur to mask an imperfect crossfade** — a subtle `filter: blur(2px)` during a state swap blends
  the two states so the eye reads one transformation, not two overlapping objects. Keep under ~20px
  (expensive, especially in Safari).
- **Scrollbar chrome** — `scrollbar-width: thin; scrollbar-color: <thumb-token> transparent`
  restyles overflow chrome to the design in two lines; color the thumb from a neutral token,
  never a raw gray.
- **Designed focus rings** — `:focus-visible { outline: 2px solid <focus-token>; outline-offset: 2px }`
  with the offset following the control's `border-radius`; the default UA outline hugging a
  rounded control is the tell of an unstyled state.

## Debugging motion

Play animations at 2–5× slowed (or DevTools' animation inspector) and review them the next day with
fresh eyes — timing flaws invisible at full speed show up slowed down. Test gestures on real
devices, not just a simulator. Look for: two states overlapping mid-crossfade, abrupt easing, wrong
transform-origin, and animated properties drifting out of sync.
