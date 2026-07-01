# M5 — Craft layer: neutral principles, tokenized motion/states, web-marked techniques

**Feature:** design-track-neutral. **Depends on:** M1 (motion verb, for consistency). **Parallelizable:** yes — off M1, with M2 and M3 (disjoint files).
**Files owned:** `references/interaction-craft.md`, `references/motion-cookbook.md`.

## Goal

Split the craft layer into **platform-neutral principles** (the always-on floor) and **web-specific techniques** (read on demand), and make motion + interaction-state **tokenized** with reduce-motion first-class — so the craft floor applies to mobile too, while CSS-specific technique stays labeled as such.

## Done-conditions

1. **[auto] Principles are platform-neutral.** `references/interaction-craft.md`'s principles (frequency-decides-whether-to-animate, ease-out on enter, asymmetric enter/exit, press feedback, perceived performance, reduced-motion, gate-hover-on-pointer) are stated in platform-neutral terms. CSS-specific *techniques* (WAAPI, `@starting-style`, clip-path, Framer specifics) are moved to / marked as belonging to the on-demand cookbook, not presented as the universal floor.
2. **[auto] Motion + states are tokenized.** `interaction-craft.md` states that motion (easing/duration) and interaction-states (hover/active/selected/disabled/focus) are expressed as **tokens** per the profile (the M1 motion verb), and that **reduce-motion is a first-class branch read at the token layer** (collapsing spatial motion to fades system-wide), not bolted on per screen.
3. **[auto] motion-cookbook is web-labeled + has a per-platform stub.** `references/motion-cookbook.md` is explicitly labeled as **web/CSS** techniques, with a short stub noting that per-platform motion technique references (Reanimated / SwiftUI / Compose) are **derived when a mobile stack appears** (consistent with "neutral seams now, web hardened").
4. **[auto] Neutrality + wiring.** `bash scripts/check-neutral.sh` passes for `interaction-craft.md` (principles neutral); `motion-cookbook.md` may retain web techniques but is labeled web. The "when this is read" wiring and the review-table remain valid for the callers (`spec-feature`, `spec-change`, `review-feature`).
5. **[completeness] Design-system precedence intact.** The rule that `design.md`'s motion stance overrides this craft (apply craft *within* the decisions) is retained.

## Verification

`verification: verifier subagent against this milestone's done-conditions, + bash scripts/check-neutral.sh`.
