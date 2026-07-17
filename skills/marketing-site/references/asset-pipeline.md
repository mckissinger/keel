# Asset pipeline — generated marketing art, attended spend

Marketing pages need art the codebase doesn't have — hero imagery, background plates,
an `og:image`. This file owns the mechanics; the skill's Movement 3 owns the timing
(attended, in-session, while the user judges).

## The script contract

Generation runs through a **committed, project-side script** — never ad-hoc API calls
improvised in a session. Seed it from `templates/generate-asset.mjs`:

- **Provider-pluggable, one default.** The template defaults to the Gemini image API
  (current cost posture: cents per image at marketing quality — a whole page's art
  costs less than a dollar, so iterate freely); the provider is a template default,
  never a hard dependency — swap the request function for another provider without
  touching the calling convention (prompt + output path in, image file out).
- **The key travels the provision-miniature / environment-contract path.** Adding the
  provider is a miniature `provision`: the key lands in the host env store, the
  project's environment contract gains its **name**, and sessions assert it **by name
  only via the recorded name-check command — values never read, never pasted** (a
  permission denial on a direct env-file read is the posture working; route to the
  name-check command).
- **Spend is attended.** The script runs while the user is present and judging. Under
  an active autonomy mode, asset generation is a **planned stop point** unless the
  run's pre-authorized envelope covers it — never silent spend.

## The flow

1. **Prompt from the brief, art-direct from the design system** — palette, mood, and
   type vocabulary from `design.md` go into the prompt; generic prompts produce the
   generic art the anti-slop bar exists to kill.
2. **Generate candidates cheaply** (2–4 per slot — hero, background, `og:image`),
   judge them with the user, iterate. Bad generations are cents; a bad review round
   later is expensive.
3. **Chosen assets commit with the plan PR under `design/marketing/`** — they are
   design artifacts, part of the plan, reviewable in the PR.
4. **The build milestone owns optimization into the app** — resizing, modern formats,
   compression, the final `public/`-equivalent placement per the stack profile — under
   `references/conversion-craft.md`'s weight budgets. The plan carries originals; the
   app ships optimized derivatives.

## Video — the optional attended offer

Video generation (Veo/Sora-class APIs; a short hero loop runs a few dollars at
mid-2026 prices) is **off by default** and only ever an **attended offer**: name the
cost, generate one candidate, judge it live. CSS/WebGL motion is the default motion
channel — cheaper to art-direct, token-driven, and weightless next to a video file.
A video that survives the offer still obeys the hero guardrails (static poster
fallback, reduced-motion state, weight budget). This offer covers generative hero
video only — product walkthrough, demo, and onboarding video is `product-video`'s
verb, so route there.
