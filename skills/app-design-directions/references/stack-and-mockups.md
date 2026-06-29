# Stack & Mockup Mechanics

## Mockup file rules (Phase 2)

- One self-contained `.html` file per direction in `design/mockups/`, named after the direction (`ledger.html`, `operator.html`...). All CSS inline in a `<style>` block; fonts via Google Fonts `<link>`; no JS frameworks, no build step. Small vanilla JS is fine for a tab switch or hover demo.
- Define the direction's tokens as CSS custom properties at the top of the style block, and use only the variables below — this makes the mockup a living token spec and makes Phase 4 translation mechanical:

```css
:root {
  --bg: ...;            /* app background */
  --surface: ...;       /* panels, cards, table bg */
  --surface-2: ...;     /* nested/raised surface */
  --border: ...;
  --text: ...;
  --text-muted: ...;
  --accent: ...;
  --accent-contrast: ...; /* text on accent */
  --success: ...; --warning: ...; --danger: ...;
  --radius: ...; --radius-lg: ...;
  --space: 8px;          /* base unit; spacing = multiples */
  --font-ui: ...; --font-display: ...; --font-data: ...;
  --shadow: ...;         /* the ONE depth recipe */
}
```

- Build at desktop width (1280–1440 canvas) since apps are used there; a quick max-width media query showing the layout doesn't shatter is enough for the mockup stage.
- Populate with the real domain data gathered in Phase 0 — actual entity names, realistic dollar figures, plausible dates and statuses. Fifteen believable rows beat three placeholder cards.

## The compare gallery

Copy `templates/compare.html` to `design/mockups/compare.html` and fill the directions array (name, file, thesis, optimizes-for, tradeoff). It renders each mockup in a scaled iframe with its pitch, plus buttons to open any direction full-size. This is the artifact the user actually reviews — make sure every iframe loads (relative paths, same directory).

## Screenshot self-review loop

Sight is the highest-leverage QA step available. In order of preference:

1. **Playwright via bash** (works in Claude Code without MCP):
```bash
npx playwright install chromium --with-deps 2>/dev/null || npx playwright install chromium
npx playwright screenshot --viewport-size=1440,900 "file://$PWD/design/mockups/ledger.html" design/review/ledger.png
```
Then *read each PNG* and critique against the quality-floor checklist: contrast, overflow, alignment drift, whether the signature element reads at a glance, whether the directions actually look different. Fix, re-shoot, repeat once or twice. Don't present mockups you haven't seen.
2. **Playwright/Chrome MCP** if connected: navigate, screenshot, also grab a narrow viewport.
3. **No browser available**: re-read each file line-by-line against the checklist instead, and tell the user the review was static-only.

In Phase 4, the same loop runs against the real app (`localhost` dev server): screenshot the converted screen, diff it visually against the chosen mockup, fix drift before moving to the next screen.

## Wiring the winning tokens into real stacks (Phase 4)

**Tailwind CSS v4** (CSS-first config) — tokens go in the main CSS file:
```css
@import "tailwindcss";
@theme {
  --color-bg: oklch(0.98 0.005 95);
  --color-surface: ...;
  --color-accent: ...;
  --font-ui: "...", system-ui, sans-serif;
  --radius-md: 6px;
}
```
Utilities like `bg-bg`, `text-accent`, `font-ui` are generated automatically from `@theme`. Prefer OKLCH for new palettes (perceptually uniform lightness makes building neutral ramps and hover shades far more predictable than hex/HSL).

**shadcn/ui**: the design lives in the CSS variables (`--background`, `--foreground`, `--primary`, `--radius`, etc. in `globals.css`) plus the component files you own. Map the direction's tokens onto shadcn's semantic variables for both `:root` and `.dark` if applicable; adjust radius and shadow variables; then touch individual component files only where the direction demands structure changes (e.g., table density, button casing). Keep raw shadcn components in `components/ui/` and put modified compositions a level up so upstream updates stay safe. Shipping stock zinc shadcn is a recognized AI fingerprint — the token pass is mandatory, not optional.

**Tailwind v3 / plain CSS**: same tokens as `:root` custom properties; in v3 also mirror into `tailwind.config.js` `theme.extend` so utilities exist.

**Two themes**: if the app supports light + dark, the chosen direction needs both defined at token level from the start (don't auto-invert; dark surfaces get their own ramp and slightly desaturated accents), and contrast checked in both.

## Files this skill leaves behind in the project

```
design/
├── design-brief.md        # Phase 0 — what the app is, who uses it, density, constraints
├── design-decisions.md    # Phase 3 — chosen direction, full spec, why others lost
├── directions/            # Phase 1 — one spec .md per direction
├── mockups/               # Phase 2 — one .html per direction + compare.html
└── review/                # screenshots from self-review loops
```

`design-decisions.md` is the persistent design memory: future sessions should read it before touching UI, so decisions survive context resets and the design stops drifting between sessions.
