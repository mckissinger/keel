# Milestone — Accessibility as semantics: the scoped floor

**Goal:** the design track's floor covers the assistive-tech contract (names, real controls,
focus in overlays, announcements for self-arriving content) and the UX-completeness dimension
can require it per feature — scoped to the four failure classes, not an ARIA curriculum.

**Change:** `specs/changes/a11y-semantics-floor.md`. **No-UI** → two-dimension
done-conditions. **Depends on:** `motion-review-depth` (stacked — edits the same
product-ui-craft regions). **Parallelizable:** n/a (single milestone).

## Done-conditions

### Logic / invariants
- [auto] `skills/app-design-directions/references/product-ui-craft.md` gains a **"Semantics
  for assistive tech"** section covering exactly the four classes: accessible names on
  icon-only controls (web mechanism hedged, platform equivalent noted); real controls over
  styled containers (platform semantics free; role-patching the fallback, not the default);
  overlay focus management (focus moves in on open, contained while open, returned to the
  trigger on close, platform dismiss gesture works); announcements for content arriving
  without user action (comfortable pace; streaming replies announce completion, not every
  token; cross-references the live-surfaces state set). Ends with an explicit scope line
  (floor, not curriculum — composite-widget ARIA stays per-feature).
- [auto] The **quality-floor checklist** in the same file gains exactly two items: (1)
  icon-only controls have accessible names + interactive elements are real controls; (2)
  overlays contain and return focus + self-arriving content is announced. No other checklist
  items changed.
- [auto] `references/milestones-and-verification.md` §2 **UX completeness** bullet's
  enumeration gains assistive-tech semantics (accessible names on icon-only controls, focus
  management in overlays, announcements for self-arriving content) — platform-neutral
  phrasing, no web hardcode, no change to the three-dimension structure or the
  `[auto]`/`[runtime]`/`[attended]` tagging rule text beyond this enumeration extension.
- [auto] **No weakening:** the existing rendering-side floor items (AA contrast,
  focus-visible, reduced motion, color-not-only-channel) unchanged in the diff; §2's fidelity
  bullet and tagging paragraph unchanged apart from nothing (pure enumeration addition to the
  UX-completeness bullet only).

### Behavioral completeness
- [auto] Cross-reference resolves: the announcements text points at the live-surfaces state
  set in the same file (present on the stack base); §2's edited bullet still reads as one
  enumeration (no broken sentence structure).
- [auto] `scripts/check-neutral.sh` exits 0 (§2 is a spine file — verify no denylisted
  hardcode in its diff); `check-neutral.test.sh` and `check-verified-pin.test.sh` self-tests
  pass; `scripts/` untouched vs `main`.

## verification
verifier subagent against this file (docs greps: four classes present + scope line, exactly
two new checklist items, §2 enumeration extended with platform-neutral phrasing, no-weakening
sweep) + `scripts/check-neutral.sh` + both script self-tests. No surface/action change → no
runtime walk; no hard invariant → no `/security-review`.
