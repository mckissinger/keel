# app-design-directions — a Claude Code skill

A design-direction exploration workflow for **application UI** (CRMs, dashboards, data tools — not landing pages). It makes Claude:

1. **Discover** — read your codebase and learn what the app is, who uses it, and which screen matters most
2. **Direct** — propose 3–5 *structurally distinct* design directions (not five color swaps)
3. **Mock** — build a self-contained HTML mockup of the same real screen, with your real data, per direction, plus a side-by-side `compare.html` gallery
4. **Select** — you pick (or hybridize); the decision gets written to `specs/design.md` (or `design/design-decisions.md`) so it survives context resets
5. **Spread** — mock the chosen direction across the app's screen *archetypes* (one per type — table, form, detail, empty state… capped at ~5, not every screen), screenshot-review, redline
6. **Apply** — translate the winner into your actual stack (Tailwind v4 `@theme` / shadcn CSS variables); the real build is more polished than the HTML, so verify for *directional* fidelity, not pixel parity

## Install (Claude Code)

Personal (all projects):
```bash
mkdir -p ~/.claude/skills
cp -r app-design-directions ~/.claude/skills/
```

Per-project (shared with the repo):
```bash
mkdir -p .claude/skills
cp -r app-design-directions .claude/skills/
```

Then in any Claude Code session: *"Use the app-design-directions skill — learn this app and give me design directions."* It will also trigger automatically on phrases like "design options," "mockups," "redesign," "make this look good."

## Structure (follows Anthropic's skill-authoring patterns)

```
app-design-directions/
├── SKILL.md                          # workflow + checklist (always loaded on trigger)
├── references/                       # progressive disclosure — loaded only when needed
│   ├── anti-slop.md                  # the empirical AI-design fingerprint list (22 patterns)
│   ├── direction-recipes.md          # axes of variation + 6 app archetypes + domain-derivation
│   ├── product-ui-craft.md           # density, tables, states, color-as-meaning, a11y floor
│   └── stack-and-mockups.md          # mockup mechanics, Playwright screenshot loop, token wiring
└── templates/
    ├── design-brief.md               # Phase 0 output
    ├── direction-spec.md             # Phase 1 output (one per direction)
    └── compare.html                  # the side-by-side gallery shell
```

## What the research behind it found (summary)

- **Anthropic's official frontend-design skill** is loved for breaking the "AI look," but reviewers consistently flag that its bias toward bold marketing aesthetics misfits product UI — dashboards and internal tools need consistency, density, and state coverage over spectacle. This skill is built for that gap, with a separate vocabulary for apps.
- **The slop fingerprint is now measured.** A 1,590-page audit identified 16 DOM/CSS tells (Inter-everywhere, VibeCode purple, default dark mode, colored left-border cards, icon-card grids, stock shadcn, glassmorphism...). `references/anti-slop.md` encodes the full list — as *banned defaults*, not banned options: anything you explicitly choose is fair game.
- **The deeper app-UI slop is structural**, not visual: everything-is-a-card density failure, missing focus/empty/error/loading states, arbitrary spacing with no scale. `product-ui-craft.md` makes the state grammar and quality floor mandatory in every direction.
- **Multiple-direction comparison is the workflow that works** — same screen, same data, only the design varies, viewed side-by-side. Hybrid picks ("layout of B, palette of D") are treated as normal.
- **Screenshot self-review is the highest-leverage practice** in agentic frontend work — the skill makes Claude render and *look at* its own mockups via Playwright before showing you, and re-uses the loop when applying to the real app.
- **Skill structure follows Anthropic's official guidance**: SKILL.md under 500 lines, "pushy" trigger description, progressive disclosure into reference files, explain-the-why over all-caps rules, and a copyable phase checklist.

## Tips for use

- Run it from the repo root of the app so discovery has full visibility.
- Have a dev server running during Phase 4 so the screenshot-verify loop can hit `localhost`.
- Keep `design/design-decisions.md` in the repo — future Claude sessions read it and stop re-litigating the design.
- For brand-new apps with no code yet, point it at your PRD/notes; discovery works on documents too.
