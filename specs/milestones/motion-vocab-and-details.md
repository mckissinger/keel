# Milestone — Motion vocabulary + craft-detail refresh

**Goal:** the craft layer gains a named, platform-neutral motion vocabulary that Movement 2 and
review-feature write against; the web cookbook gains view transitions + scroll-driven
animations (with the app-vs-marketing ⚠); the detail floor gains scrollbar/focus-ring/exit-delay
guidance — all additive, no existing rule weakened.

**Change:** `specs/changes/motion-vocab-and-details.md`. **No-UI** → two-dimension
done-conditions. **Depends on:** nothing (independent, branches off `main`).
**Parallelizable:** n/a (single milestone).

## Done-conditions

### Logic / invariants
- [auto] `references/interaction-craft.md` gains a **motion vocabulary** section defining, at
  minimum: **stagger, direction-aware, layout animation, morph, crossfade, spatial
  consistency, rubber-banding, retarget mid-flight** — each a one-line platform-neutral
  definition, no raw CSS — plus the usage rule that `spec-feature`/`spec-change` Movement 2
  fidelity done-conditions and `review-feature` findings use these exact terms. Vocabulary
  credited to animations.dev consistent with the existing header credit.
- [auto] `references/interaction-craft.md` "The feel of components" gains: **selection
  exit-delay** (menu/list selection holds ~200–400ms before dismissal so the result registers;
  explicitly subordinate to the keyboard-initiated no-animation rule) and **focus/scroll chrome
  as designed surfaces** (focus indicator designed — offset/shape matched to the control, not
  platform default; scroll chrome on designed panels deliberate) — neutral phrasing, web
  examples hedged in parentheses.
- [auto] `references/motion-cookbook.md` gains a **view transitions** section (same-document
  `document.startViewTransition`, `view-transition-name` for element morphs, the overlay/
  z-order caveat, and the no-support fallback: the state change still happens, untransitioned)
  and a **scroll-driven animations** section (`animation-timeline: view()` / `scroll()`,
  no-JS scroll reveals, `@supports` progressive enhancement) that carries an explicit ⚠:
  the frequency table governs — scroll-driven motion suits marketing/landing surfaces; app
  work surfaces rarely scroll-animate.
- [auto] `references/motion-cookbook.md` carries detail-chrome specifics: thin token-colored
  scrollbars (`scrollbar-width` / `scrollbar-color`) and designed focus rings
  (`outline-offset`, radius affinity with the control).
- [auto] `skills/app-design-directions/references/product-ui-craft.md` "Interaction details
  that read as quality" gains one overflow-chrome bullet (deliberately styled scrollbars on
  web-class surfaces, never default chrome on a designed panel). **The quality-floor checklist
  list is unchanged** (no new checkbox items).
- [auto] **No weakening / no contradiction:** the frequency table, keyboard rule, ~300ms cap +
  duration budgets, app motion budget (120–200ms) in product-ui-craft, token-layer
  motion/reduce-motion rules, and design-system precedence text are unchanged in the diff;
  new prose defers to `specs/design.md`'s motion stance.

### Behavioral completeness
- [auto] Cross-references resolve: interaction-craft's pointer to the cookbook still valid; the
  vocabulary section is reachable from the "When this is read" flow (Movement 2 mention); no
  Q-numbering or spine files touched.
- [auto] New material derived from named practitioners is credited inline (animations.dev /
  Emil Kowalski for the vocabulary; detail/technique sources noted once where they land),
  consistent with the file's existing credit style.
- [auto] `scripts/check-neutral.sh` exits 0; `check-neutral.test.sh` and
  `check-verified-pin.test.sh` self-tests pass; `scripts/` untouched vs `main`.

## verification
verifier subagent against this file (docs greps: term list present + one-line definitions,
usage rule present, ⚠ present in scroll-driven section, checklist unchanged, no-weakening
sweep on the named rules) + `scripts/check-neutral.sh` + both script self-tests. No
surface/action change → no runtime walk; no hard invariant → no `/security-review`.
