# M1 — Profile design-surface verbs

**Feature:** design-track-neutral. **Depends on:** nothing (foundation). **Parallelizable:** no — M2/M3/M5 build on these verbs.
**Files owned:** `references/profile-interface.md`.

## Goal

Expand the stack-profile interface so the *design* track is dispatched through profile verbs exactly as verification already is — so "web vs mobile" is a profile difference, not a fork in any skill. Today Q8 only asks "has UI? + where do design tokens install." This milestone grows it into a **design-surface verb cluster**, keeping the file's existing voice (numbered questions, ⚠ generalized-scar notes, concrete web reference answers, "derived ~80%, hardened by running it").

## Done-conditions

1. **[auto] The design-verb cluster exists and is complete.** `references/profile-interface.md` defines, as concrete questions a project answers in `specs/stack-profile.md`, at minimum:
   - **has-UI?** (retained).
   - **Token source + install**, including the native-vs-portable rule: single-platform → native tokens (e.g. CSS variables / a theme file); multi-platform (web+mobile) → a portable DTCG/Style-Dictionary source compiled per platform. Names the two-tier structure (primitive→semantic) and that **interaction-states and motion are token-level**, not per-component.
   - **Workbench mechanism** — how this stack renders a *reviewable gallery of real themed primitives with every state* (web route / Storybook; SwiftUI `#Preview`; Compose `@Preview` + `@PreviewParameterProvider`; Flutter Widgetbook; RN both Storybooks).
   - **Design screenshot/review driver** — how a surface is captured for the redline (Playwright/Chromatic; simulator + snapshot test; emulator + Compose screenshot test; Widgetbook goldens).
   - **Motion + interaction mechanism** — the stack's motion library and how motion tokens (easing/duration) + interaction-state tokens are expressed; reduce-motion signal.
   - **Platform-convention set (native feel)** — web / iOS-HIG / Android-Material; what must be native (navigation, gestures, system controls) vs. brand-universal.
2. **[auto] Web reference answers + mobile-derivable framing.** Each new verb carries a concrete web example answer AND a note that mobile answers are derived-when-needed against the interface (consistent with the "neutral seams now, web hardened" decision and the file's existing derivation framing). At least one verb carries a ⚠ generalized-scar note in the file's existing style.
3. **[auto] Neutral phrasing.** No new verb names a framework except as a hedged example (`e.g.`); `bash scripts/check-neutral.sh` passes.
4. **[auto] Gating section updated.** The "Has UI? — what Q8 gates" section references the expanded cluster (design track + fidelity dimension gate off has-UI?; the workbench/medium/motion verbs feed `app-design-directions`, `spec-feature`, `review-feature`).
5. **[completeness] Coherence + cross-refs intact.** The file still reads as one contract; existing references to it (`spec-foundation`, `adopt`, `milestones-and-verification`, `implement-milestone` say "derived against profile-interface.md") remain valid — no dangling verb numbers.

## Verification

`verification: verifier subagent against this milestone's done-conditions, + bash scripts/check-neutral.sh`.
