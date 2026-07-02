# Change — Accessibility as semantics: the scoped floor

**Grain:** one change → one milestone (`spec-change`). **No-UI** (methodology/docs change to keel
itself). **Stacked on:** `motion-review-depth` (edits the same product-ui-craft regions).

## Why (the gap)

Keel's design track treats accessibility almost entirely as a **rendering property** — AA
contrast, visible focus, reduced motion, color-never-the-only-channel are all covered — but
says nothing about the **assistive-tech contract**: what a screen reader can name, where focus
goes, what gets announced. The four highest-frequency failures in generated UI are all
semantic, all deterministic, and all currently invisible to keel's specs and gates:

1. **Icon-only controls with no accessible name** — a toolbar a screen reader reads as
   "button, button, button."
2. **Styled containers acting as controls** — a clickable div where a real button belongs, so
   keyboard and assistive tech never see it as interactive.
3. **Overlays that don't manage focus** — dialogs that leave focus behind them, don't contain
   it while open, or drop it on close instead of returning it to the trigger.
4. **Live content that arrives silently** — streaming replies, feed arrivals, async results a
   screen-reader user never hears about (this dovetails with the `live-surfaces` state set).

Because none of this is named in the UX-completeness dimension, specs can't require it and the
`[auto]` tier never asserts it — the exact "implicit → filled with generic defaults" failure
§2 of the verification rules exists to prevent.

**Deliberately scoped.** This is a floor, not an ARIA curriculum: names, real controls, focus
in overlays, announcements for self-arriving content. Full composite-widget ARIA authoring
(grids, trees, comboboxes) stays a per-feature concern for the feature that needs the widget.

## The mechanic

Two files, additive:

1. **`skills/app-design-directions/references/product-ui-craft.md`** — new section
   **"Semantics for assistive tech (the scoped floor)"**: every icon-only control has an
   accessible name (on web, `aria-label` / visually-hidden text; the platform's accessibility
   label elsewhere); interactive things are real controls, not styled containers (the
   platform's own button/link/input carries its semantics free — role-patching a container is
   the fallback, not the default); overlays manage focus (opening moves focus in, focus stays
   contained while open, dismissal returns it to the trigger, the platform's dismiss gesture —
   Escape on web — works); content that arrives without user action is announced at a
   comfortable pace (on web, a polite live region; streaming replies announce completion, not
   every token — cross-reference the live-surfaces state set). Ends with the scope line
   (floor, not curriculum). **The quality-floor checklist gains two items** — accessible
   names + real controls; focus containment/return + arrival announcements — because this
   change is precisely about moving semantics into the enforced floor.
2. **`references/milestones-and-verification.md` §2** — the **UX completeness** bullet's
   enumeration gains assistive-tech semantics (accessible names on icon-only controls, focus
   management in overlays, announcements for self-arriving content) so per-feature specs
   enumerate them and their deterministic core lands `[auto]` (component-tier tests can assert
   names, roles, and focus order) per the existing tagging rule. Spine file: platform-neutral
   phrasing, web examples hedged, no denylisted hardcodes.

**Not weakened:** the existing rendering-side floor (contrast, focus-visible, reduced motion)
is unchanged; the three-dimension structure and the tagging rule are unchanged — this extends
one enumeration and one reference file. Checklist growth is the declared intent here, unlike
the earlier craft changes.

## Scope

Two markdown files, pure prose. `check-neutral.sh` stays green (§2 edit is
platform-neutral; product-ui-craft is design-track and may name web mechanisms as examples).
