# Reference research for the marketing surface — the marketing delta only

## Why this file exists

`marketing-site` explores its variants at *spectacle*, but for a long time it derived
them from prose alone — the text-only ceiling the app-side visual-reference change was
built to break, left in place on the one design-track verb whose whole job is the look.
This file wires reference research into the marketing surface **without re-owning the
pipeline**: every mechanic — the source ladder, generous volume, subagent delegation,
the deconstruction discipline, diversity, licensing, inspiration-not-transplant — is
owned by `skills/app-design-directions/references/visual-reference.md` and is **cited
here, never restated**. What this file adds is only the *marketing delta*: which
movement each pull runs in, the marketing-shaped vocabulary a reference is extracted
into, where the lineage lands, and how a marketing-page corpus is detected. When the
guidance below and `visual-reference.md` seem to overlap, `visual-reference.md` governs
the mechanics; this file governs only the marketing scoping.

## The movement scoping — two pulls, and nowhere else

Reference research runs in exactly two places, each scoped to what that movement is
allowed to decide:

- **Discover (Movement 1) — the pattern pull, structure only.** When a connected
  design-reference MCP's corpus includes marketing pages, a **pattern-level pull runs
  during Discover, default-on** (not a step a session skips by preference): section-level
  research into which sections comparable products' pages carry, how the category shapes
  its pricing and proof, where the actions sit. Findings land as **structure** — in the
  brief and the section-system plan — and **never as tokens or visual choices**. Looks
  stay gated at Movement 2. This is the marketing analog of `spec-feature`'s flow pull:
  a pattern pull for *structure*, explicitly **not** the looks deconstruction pass.
- **Explore (Movement 2) — the looks pull, fork-scoped.** This is the only movement
  where a looks-level pull is allowed, and its scope depends on the fork:
  - *Greenfield fork:* the delegated `app-design-directions` Phase 1–2 discipline runs,
    **including its Phase 0.5 visual-reference pass** — there is no committed design
    language to protect, so the full reference-fed direction round applies at one-screen
    marketing scale.
  - *Post-app fork:* the committed design language is **never re-litigated**. A scoped
    looks-level pull may inform **only the amplification round's variant axes — hero
    treatment, section spectacle, motion posture** — and the committed tokens are
    **amplified, never replaced**. References feed the 2–3 variants; the variants still
    converge into the marketing section system per the skill's existing rules.

Outside these two pulls, reference research does not run. In particular, no pull runs in
Assets or Author, and the Discover pull may not reach for looks "while it's there."

## The marketing extraction vocabulary — movement-scoped

`visual-reference.md`'s six-item deconstruction (palette, type roles, density, layout,
depth grammar, signature devices) is **app-UI vocabulary**. Marketing references are
deconstructed into a complementary, marketing-shaped set — and the set is **split
between the two movements**, so a Discover pull can never legally extract a look:

- **The Discover pattern pull extracts the structure items only:**
  - **Section sequence actually used** — the order comparable pages put their sections in
    (hero → proof → features → pricing → FAQ → footer, or whatever this category does).
  - **CTA count and placement** — how many calls-to-action a page carries and where they
    sit relative to the fold and the sections.
  - **Proof placement** — where social proof, logos, testimonials, and metrics land in
    the flow.
- **The Movement 2 looks pull owns the look items — and only Movement 2 may extract them:**
  - **Hero treatment type** — mapped to `references/hero-treatments.md`'s menu (staged
    real product shots, generated image, CSS gradient/motion, WebGL, typographic).
  - **Style stance** — the reference's overall aesthetic posture (restrained vs.
    maximal, editorial vs. utilitarian, the tonal read).

A pull's extraction must stay inside its movement's slice of this vocabulary. Style
stance and hero treatment type are **out of bounds for the Discover pattern pull**;
pulling them there would satisfy the letter of "a pull ran" while gutting the
structure-only rule the Discover pull exists to honor.

## Detection — generic, dependency soft

Detection is **generic, not instance-specific**: the trigger is "a connected
design-reference MCP whose corpus includes marketing pages," any server whose tools
search marketing-page screenshots by query.

**Every marketing pull scopes to the website / marketing-page corpus — never the
mobile-app corpus.** Marketing references are landing pages and marketing sites; the
mobile-app side of a reference corpus is the wrong raw material and is out of bounds for
every pull this verb runs. Concretely: prefer a website-**section** search verb (one that
searches the website corpus and carries no platform axis), and when a search verb does
take a platform, scope it to **web** — never the app / mobile platform.

As of 2026-07 the known instance (Mobbin) splits its corpus into **Sites** (websites)
and **Apps** (mobile), and this verb uses **Sites only**: its website-section search verb
(which has no platform axis) and, for any screen- or flow-level search, `platform: web`.
Its Sites side is observed to carry a **marketing-pages content type** with page patterns
like "Landing Page" and **Sections / Styles filter taxonomies**, reached through that
section-search verb — but those capabilities are named here only as **as-of-2026-07
observations**, never as a requirement, and the corpus's shape may have moved since. The
paid MCP is **never a hard dependency**: the ladder's user-supplied-screenshots and
text-only rungs (owned by `visual-reference.md`) apply unchanged, and **with no such MCP
connected each movement proceeds text-only and records that mode.**

## The first-pull probe

Whether a connected MCP's search verbs actually reach the marketing-page corpus is not
assumed. On the **first connected pull of a session**, probe: confirm the server's
search verbs return marketing-page results. If they don't — the server is connected but
its corpus or verbs don't cover marketing pages — **fall back one ladder rung**
(user-supplied screenshots, then the text-only floor) and **record the mode that
actually ran**, exactly as a disconnected server would. The skill text is mode-disclosing
either way, so a corpus that turns out unreachable at runtime changes the guidance the
pull gives, not the plan's design.

## Lineage — pointers persist in the marketing artifacts

The licensing stance (owned by `visual-reference.md`) records lineage as **text and
pointers, never image files** — but the app pipeline lands that lineage in its Phase 3
decision file, which the marketing surface has no equivalent of. So the marketing
artifacts carry it:

- The **Discover pattern pull's** reference URLs and extraction notes persist in the
  **marketing spec** (alongside the brief and the section-system plan the pull informed).
- The **Explore looks pull's** reference URLs and extraction notes persist in the
  **variant specs** — each variant records the references it drew from.

In both cases what persists is **URLs and extraction notes only** — never a committed
reference image. A pull whose extractions land nowhere has not satisfied this rule, even
if every other condition reads as met.
