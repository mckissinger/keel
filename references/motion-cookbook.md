# Motion cookbook — deep techniques (read on demand)

Implementation specifics for building a particular interaction well. Not the always-on floor
(that's `interaction-craft.md`) — reach here when a feature actually needs gestures, reveals, or
hand-tuned physics. Adapted from Emil Kowalski's design-engineering philosophy
([animations.dev](https://animations.dev/)). Conform to `specs/design.md`'s motion stance.

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

## Debugging motion

Play animations at 2–5× slowed (or DevTools' animation inspector) and review them the next day with
fresh eyes — timing flaws invisible at full speed show up slowed down. Test gestures on real
devices, not just a simulator. Look for: two states overlapping mid-crossfade, abrupt easing, wrong
transform-origin, and animated properties drifting out of sync.
