# Milestone — logo-m1-skill-craft

Feature context: `specs/features/logo.md`. First of two; lands the `logo` skill, its
craft reference, and its two templates — all-new files, nothing existing moves.
Integration seams: the craft reference is written to be **cited, never restated** by
the skill body; the optional concept stage cites `marketing-site`'s asset-pipeline
reference across skills (if that citation cannot resolve at runtime, surface it —
never duplicate the reference). Neutrality caution: no image-model vendor, font
foundry, or SVG-rendering tool is named as required — hedged as-of-2026-07 examples
only; invented example products only. `check-neutral.sh` scans `references/` and
`skills/` — the prose must pass as written.

## Done-conditions

- [auto] **The logo skill exists and is well-formed.** `skills/logo/SKILL.md` has
  valid frontmatter (`name: logo`, a `description`, a `when_to_use`) and passes
  `scripts/check-skill-frontmatter.sh`. It does **not** carry
  `disable-model-invocation` — the body states why it is model-invocable (plan-only
  output in the repo it runs in; the only spend is the optional attended concept
  stage). The `when_to_use` disambiguates from `marketing-site` (the marketing
  surface, which consumes the kit), `app-design-directions` (the app's design
  system), and generic image generation (this verb ships a versioned kit + an
  integration milestone, not a one-off picture), so the router picks the right verb.
- [auto] **The session contract is encoded.** The skill body states, as its
  workflow: (1) **Discover** — the dual fork (post-app: derive palette + type
  lineage from committed `specs/design.md`; brand-first/greenfield: record the brand
  decisions for a later `design.md` to inherit), with `specs/gtm/` positioning
  consumed for brand personality when it exists, never required; a brief confirmed
  with the user before anything visual. (2) **Concepts** — 3–5 concepts via
  parallel subagents, each built by **parametric construction** (computed from a
  construction grid; flat color; strokes on unit multiples; no freehand organic
  paths), rendered and self-reviewed via the **render-and-verify loop** before
  showing; the user shortlists. The **optional image-model concept round is
  off-by-default attended spend** — offered, run via the committed
  asset-generation script path with the key asserted by name only, and its winner
  is **rebuilt as clean SVG, never auto-traced** into the deliverable. (3)
  **Iterate** — attended art direction on the winner (the body sets the
  expectation that real convergence takes multiple rounds). (4) **Kit** — assemble
  the deliverable matrix and manifest (template below), commit under
  `design/brand/`, and author ONE integration milestone spec (favicon/manifest/OG
  wiring, built by the normal pipeline) whose done-conditions carry the three
  quality gates tagged `[auto]` against the committed contact-sheet script. The
  session ends attended, on a **plan PR** (`specs/**` + `design/**`).
- [auto] **The craft reference exists and carries the floor as rules.**
  `skills/logo/references/logo-craft.md` states, each as a rule: (a) **parametric
  construction** — the mark is computed (grid units, circle geometry, stroke
  multiples), never freehand; (b) the **anti-slop bans** — no gradient-defaulting
  (the indigo/purple-gradient fingerprint named), no generic swoosh/abstract-blob
  marks, no default-font wordmarks, no elements distinguished only by color; (c)
  the **three quality gates** with their pass bars — legible at 16px (favicon
  strip), survives pure monochrome, survives dark/light reversal — and that they
  ride as `[auto]` done-conditions in the integration milestone; (d) the
  **deliverable matrix + naming convention** — lockups (horizontal / stacked /
  icon) × colorways (color / mono / reversed) as SVG masters named
  `<product>-logo-<lockup>-<colorway>.svg`, plus the favicon/PWA minimal set (ICO
  32, SVG favicon, apple-touch 180 opaque, 192 + 512 PNG, 512 maskable with the
  central-safe-zone rule), OG image (1200×630), and social avatar; (e) the **font
  rule** — wordmark fonts are OFL or license-verified for logo use, text is
  converted to outlines in the masters, and font name + license are recorded in
  the manifest; and (f) the **legal note verbatim for the manifest** — AI-generated
  marks are trademark-registrable but not copyrightable (as of 2026; Thaler line of
  cases), so run clearance and add human modification. The skill body cites this
  reference at point of use and does not restate the rules.
- [auto] **The two templates exist and are named at point of use.**
  `skills/logo/templates/brand-kit-manifest.md` (the `design/brand/` manifest
  shape: product + mark rationale, lockup/colorway inventory with filenames, font
  name + license, palette values with their `design.md` lineage when post-app, the
  usage sheet — clear space, minimum size, don'ts — and the legal note from the
  craft reference) and `skills/logo/templates/render-contact-sheet.mjs` (the
  committed render script template: renders each SVG master to the raster matrix —
  16/32/64px favicon strip, monochrome-forced and reversed variants, the
  favicon/PWA set and OG sizes — into a contact sheet for the render-and-verify
  loop and the integration milestone's `[auto]` gates; local rendering only, no
  network calls, rendering tool named as a hedged example and pluggable) exist,
  and the skill body names each at its point of use.
- [auto] **Repo checks green.** `claude plugin validate --strict .`,
  `scripts/check-neutral.sh`, `scripts/check-plan.sh`,
  `scripts/check-skill-frontmatter.sh`, `scripts/check-skill-anchors.sh`, and every
  `scripts/*.test.sh` pass on the branch.

## verification

verifier subagent against this file's done-conditions (all `[auto]`; the milestone is
prose and templates in all-new files, closable by reading the named files and running
the named checks — plus `node --check` on the `.mjs` template and a grep for network
calls in it).

verified: clean at dee79d6, 2026-07-18, via verifier subagent against this spec's done-conditions — all 6 conditions evidenced with file:line, scope exactly four added files under skills/logo/, plugin validate + 4 repo checks + 11 script self-tests green, .mjs local-only (zero network hits) with node --check OK (evidence in PR #153)
