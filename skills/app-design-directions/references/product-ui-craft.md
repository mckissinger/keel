# Product UI Craft: Fundamentals for Application Interfaces

Apps are not posters. A landing page is judged in 5 seconds once; an app screen is judged over the 400th hour of use. These are the rules of that game. Apply them inside *every* direction — they are the floor, not a style.

## Hierarchy and density

- **Hierarchy through scale and weight before color and boxes.** Most screens need only 2–3 text sizes and 2 weights. If everything is emphasized, nothing is. Try designing the screen in grayscale first; if hierarchy doesn't survive without color, it isn't hierarchy.
- **Density is a brief decision, then a spacing scale.** Pick a base unit (4px or 8px) and derive all spacing from the scale (4/8/12/16/24/32/48/64). One-off values are how systems rot. Dense tools: tighter row heights (32–40px table rows), smaller body (13–14px), more columns. Spacious tools: 44px+ touch targets, 15–16px body.
- **Proximity is grouping.** Related things sit closer than unrelated things — this beats boxes and dividers. Reach for whitespace first, a rule second, a box last. Boxes-in-boxes-in-boxes is how dashboards drown.
- **Alignment carries professionalism.** Numbers right-aligned in tables, text left-aligned, labels consistently placed. One sloppy column ruins the room.

## Tables and data (where app design is won or lost)

- Use **tabular (monospaced-figure) numerals** for any column of numbers — `font-variant-numeric: tabular-nums`. Misaligned digits make financial data look amateur.
- Right-align numbers and their headers; format consistently (same decimals, thousands separators, unit position).
- Row affordances: hover state, clear clickable surface, visible focus row for keyboard nav.
- Long tables need: sticky headers, a designed empty state, a loading skeleton, and a density that matches the user's comparison work — professionals scan dozens of rows; don't make them scroll through air.
- Truncation with title-tooltips beats wrapping for scannable columns; never truncate the column the user sorts by.

## Color as meaning

- In product UI, color's first job is **semantics**: status, severity, diff, selection. Define semantic tokens (success/warning/danger/info/neutral) separately from brand tokens, and never let decoration use semantic hues (a green button next to green "active" chips destroys the signal).
- A useful default budget: 1 accent, 4–6 neutrals (true greys or temperature-tinted to match the direction), the semantic set. Most of every screen should be neutral — accents are spent, not spread.
- **Contrast floor is non-negotiable**: WCAG AA — 4.5:1 body text, 3:1 large text and UI components/borders that convey state. Check both themes if the app has two. Grey-on-dark body text failing AA is the most common functional defect in generated UI.
- Color is never the only channel: pair status hues with an icon, label, or shape for color-blind users.

## Typography for interfaces

- Two families maximum for an app (often one family + a mono for data/code). The display-face flair budget that marketing pages enjoy mostly doesn't exist here — personality comes from the *system* (scale, weights, casing, data face), not from a decorative font.
- UI text: 13–16px depending on density; line-height ~1.4–1.5 body, tighter (1.1–1.2) for headings; never justify; sentence case for labels and buttons (all-caps only as a single deliberate device, with letterspacing).
- Choose faces with a tall x-height and open apertures for small sizes. Verify the chosen face has tabular figures and a real distinction between I/l/1 and 0/O if data-heavy.

## The state grammar (design these as a system, once)

Every interactive component needs the full set, derived from the same tokens: default, hover, active/pressed, **focus-visible (keyboard)**, disabled, error. Every data view needs: loading (skeletons shaped like the content, not spinners-in-voids), empty (an invitation to act: what this is + the next step, not just "No data"), error (what went wrong + how to fix, never vague, never apologetic), and partial/degraded where relevant. Improvised per-component states are the structural signature of generated UI; a designed grammar is the difference between a mockup and a product.

## Forms

- Labels above inputs (fastest scanning), left-aligned; placeholder text is a hint, never the label.
- Validate inline at the field, on blur or submit — not while the user is mid-keystroke; error text says how to fix it.
- Group with headings and spacing, not boxes; one column beats two for completion speed in most flows.
- The primary action is visually singular; destructive actions are spatially separated and styled by the semantic danger token.

## Interaction details that read as quality

- Visible keyboard focus everywhere (`:focus-visible` ring tied to the accent token); logical tab order.
- Motion budget for apps: 120–200ms ease-out transitions on state changes; nothing animates that doesn't communicate a state change; `prefers-reduced-motion` respected. Scattered effects read as AI-generated; one orchestrated moment (if the direction calls for any) reads as design.
- Hit targets ≥ 40px even in dense UIs (visual element can be smaller than its target).
- Overflow surfaces styled deliberately: thin scrollbars colored from the neutral tokens
  (`scrollbar-width`/`scrollbar-color`) — default scrollbar chrome on a designed panel reads
  as unfinished.
- Microcopy: name things by what the user controls, in their domain vocabulary ("Rent roll", "Close date" — not "Data records"). Verbs on buttons say exactly what happens ("Save changes", not "Submit"); the same action keeps the same name through the whole flow.

## The quality floor checklist (run in Phase 2 self-review and Phase 4)

- [ ] AA contrast on all text and stateful UI elements
- [ ] Keyboard focus visible on every interactive element
- [ ] Empty, loading, and error states present and styled for each data view
- [ ] All spacing values from the scale; all colors from tokens
- [ ] Numbers tabular and right-aligned in tables
- [ ] Hierarchy survives grayscale
- [ ] Reduced motion respected; no decoration-only animation
- [ ] Responsive: load-bearing screen sane at 1280 and at narrow width
- [ ] Copy uses the domain's vocabulary; buttons name their action
