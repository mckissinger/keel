# Hero treatments — the menu and its guardrails

The hero is the variant round's main axis (the skill's Movement 2): variants differ
mainly in which treatment carries the first screen. Pick from the menu deliberately —
the treatment is a **direction decision the user makes**, never a default the session
falls into.

## The menu

- **Staged real product shots** — the shipped app, screenshotted and staged (browser
  chrome or device frame, feature close-ups, honest data). The strongest option for a
  working product (the post-app fork's raw material): nothing sells a tool like the
  tool. Stage the app's best, most data-rich screen — the same load-bearing screen the
  design work optimized.
- **Generated image** — hero art / background plates from the asset pipeline
  (`references/asset-pipeline.md`): abstract brand-toned compositions, textures,
  illustrative scenes. Art-direct with the design system's palette in the prompt; judge
  candidates attended.
- **CSS gradient / motion** — layered gradients, subtle animated atmosphere, a
  high-impact page-load sequence. Zero asset weight, fully token-driven; the default
  *motion* channel (video is the exception, never the baseline).
- **WebGL scene** — a shader gradient, particles, or one 3D element
  (React-Three-Fiber-class tooling on a web stack). One signature moment, not a theme.
- **Typographic** — the display face *is* the hero: oversized type, tight copy, sharp
  accent color. The cheapest treatment to keep on-brand and the hardest to make
  forgettable — a strong pick when the brand's voice is the differentiator.

## Guardrails (these bind every variant)

- **WebGL is never the default treatment.** It enters only as a deliberate variant the
  user picks, when the brand earns it.
- **Always a static fallback.** Any WebGL/video treatment lazy-loads behind a designed
  static poster — the page must be whole without it (no-JS, low-power, old-device).
- **Always `prefers-reduced-motion`.** Every treatment with motion — CSS, WebGL, or
  video — ships a designed reduced-motion state. Not paused chaos: designed.
- **The same performance floor as every other treatment.** No treatment is exempt from
  `references/conversion-craft.md`'s budgets — a hero that blows LCP is a conversion
  bug wearing a costume, whatever it looks like in a screenshot.
