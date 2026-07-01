# Change — Motion vocabulary + craft-detail refresh

**Grain:** one change → one milestone (`spec-change`). **No-UI** (methodology/docs change to keel itself).

## Why (the gap)

Sourced from a July 2026 review of current design-engineering practice (Emil Kowalski's
animations.dev vocabulary work, Rauno Freiberg's detail catalogue, Jhey Tompkins's
progressive-enhancement breakdowns) against keel's craft layer:

1. **The craft floor has rules but no shared vocabulary.** `interaction-craft.md` says *when*
   and *how fast* to animate, but a fidelity done-condition can only be as precise as the words
   available to write it. Practitioners converged on a small named vocabulary — *stagger*,
   *direction-aware*, *layout animation*, *morph*, *crossfade*, *spatial consistency*,
   *rubber-banding* — precisely because a builder (human or agent) produces the intended motion
   when the spec names it and produces a guess when it doesn't. Keel's Movement 2 ("turn the
   relevant principles into fidelity done-conditions") has no such term list to draw from, so
   motion conditions come out vague ("animate the list in nicely") and unverifiable.
2. **The web cookbook predates two now-baseline mechanisms.** `motion-cookbook.md` covers
   clip-path, springs, WAAPI, `@starting-style` — but not **view transitions** (the platform's
   native morph/crossfade between states) or **scroll-driven animations** (`animation-timeline`,
   no-JS reveals). Both are progressive-enhancement-friendly and cheaper than the JS
   equivalents the cookbook currently implies.
3. **Three small quality tells are missing from the detail floor.** Default scrollbar chrome on
   an otherwise-designed surface; focus rings left as the browser default rather than designed
   (offset, radius matched to the control) — the floor requires a *visible* ring but not a
   *designed* one; and menu/list selection dismissing instantly, when a ~200–400ms held exit
   (the macOS menu pattern) is what lets the selection register.

## The mechanic

Three files, pure prose, additive:

1. **`references/interaction-craft.md`** — new **motion vocabulary** section (platform-neutral,
   one line per term, credited to animations.dev alongside the existing header credit): stagger,
   direction-aware, layout animation, morph, crossfade, spatial consistency, rubber-banding,
   retarget mid-flight — with the usage rule: *Movement 2 fidelity done-conditions and
   review-feature findings use these exact terms.* Plus two additions to "The feel of
   components": selection exit-delay (~200–400ms held exit on menu/list selection; the
   keyboard-initiated no-animation rule keeps precedence), and focus/scroll chrome as designed
   surfaces (neutral phrasing, web examples hedged).
2. **`references/motion-cookbook.md`** — two new technique sections: **view transitions**
   (same-document `startViewTransition`, `view-transition-name` morphs, the overlay/z-order
   caveat, graceful no-support fallback) and **scroll-driven animations** (`animation-timeline:
   view()/scroll()`, no-JS scroll reveals, `@supports` enhancement) carrying an explicit ⚠:
   scroll-driven motion is a marketing-page tool; the frequency table governs and app work
   surfaces rarely scroll-animate. Plus detail-chrome specifics: `scrollbar-width: thin` /
   `scrollbar-color`, and designed focus-ring CSS (`outline-offset`, radius affinity).
3. **`skills/app-design-directions/references/product-ui-craft.md`** — one bullet in
   "Interaction details that read as quality": overflow surfaces styled deliberately (thin,
   token-colored scrollbars on web-class surfaces), never default chrome on a designed panel.
   **The quality-floor checklist is unchanged** — these are details guidance, not new gates.

**Not weakened by this change:** the frequency table, the keyboard rule, the app motion budget
(120–200ms), token-layer motion/reduce-motion rules, and design-system precedence (`specs/
design.md`'s motion stance still wins). The vocabulary names *what* to build; the existing
rules still decide *whether* and *how fast*.

## Scope

Three markdown files. No scripts, no skill-flow changes, no profile-interface changes.
`check-neutral.sh` must stay green — interaction-craft additions stay platform-neutral with
hedged web examples; all raw CSS lands in the cookbook (already web-quarantined).
