# Feature — Framework-neutral, real-stack, motion-aware design track

**One-paragraph definition.** Rework keel's design/frontend track so it is (1) **framework-neutral** — web *or* mobile, dispatched through profile verbs the way verification already is; (2) **real-stack** — the built component **workbench** (not a throwaway HTML mockup) is the fidelity source of truth; and (3) **motion + interaction-state first-class** — expressed as tokens and reviewed executably. This touches `references/profile-interface.md`, `references/milestones-and-verification.md`, `skills/app-design-directions/**`, `skills/spec-feature` + `skills/spec-change`, `skills/implement-milestone`, `references/interaction-craft.md` + `references/motion-cookbook.md`, the top-level `README.md`, and the `check-neutral.sh` guard. It is a **no-UI change to keel itself** (a methodology/docs feature), so done-conditions cover two dimensions — correctness + completeness — with **no fidelity dimension** and no mockups.

## Why (the gap)

keel's design track today assumes a web/Tailwind/shadcn stack (`@theme`, `<select>`, Lucide, Recharts, Playwright, a `/styleguide` route) and treats a **throwaway HTML mockup as the fidelity spec** a later build re-implements. Deep research (four threads: cross-platform tokens, AI design-to-code, component workbenches, elite design-eng orgs) converged on five principles this feature adopts:

1. **Tokens are the neutral spine**, layered primitive→semantic→component; interaction-states and motion live as tokens. DTCG is stable (Oct 2025); Style Dictionary compiles one source to web/iOS/Android/RN/Flutter. Values port; spring physics is authored per-platform.
2. **The living workbench is the source of truth, not the mockup.** "A gallery of real themed components in every state + interactions, screenshotted for review" is one concept with per-platform mechanisms (Storybook / SwiftUI `#Preview` / Compose `@Preview` / Widgetbook / RN both).
3. **Diverge cheap, converge real.** Throwaway mockups only pick a direction and are never re-implemented as a spec; the moment a direction is chosen, converge into real themed components. States + motion are behavioral — they exist only in real code.
4. **Define once, implement per platform + respect native feel.** One token source; platform-specific components; brand/tokens/IA universal; navigation/gestures/system controls native.
5. **Motion + reduce-motion are first-class and tokenized**, chosen by role; reduce-motion read at the token layer.

## Resolved decisions (from the interview)

- **Mobile = neutral seams now, web hardened.** Build the profile-driven abstraction; keep web as the proven reference implementation. Mobile mechanisms are *derivable* against the profile interface and validated when a real mobile project appears — **no mobile toolchain work in this feature.**
- **Cheap divergence, real workbench = truth.** Throwaway mockups pick a direction only; the real workbench is the durable fidelity source of truth and is never re-implemented from HTML.
- **Tokens profile-decided.** Native for single-platform (e.g. Tailwind `@theme`); a portable DTCG/Style-Dictionary source for web+mobile. Layered primitive→semantic→component; interaction-states + motion as tokens.
- **One keel feature; parked neutrality fixes folded in** (the `@theme`/Lucide/Recharts fidelity hardcode, the README mobile claim, the vestigial `app-design-directions/README.md`).
- **Out of scope (parked):** the "craft ceiling" layer (design-research pass, reference/exemplar library, optional MCP accelerants, signature-motion/bespoke-asset, craft-budget dial). Not in this feature.

## What stays (unchanged topology)

The two-skill split (design SYSTEM once via `app-design-directions`; design SCREENS per feature via `spec-feature`), the diverge→converge→redline gates, the anti-slop discipline, and design-consequential-library ownership by `design.md`.

## File → milestone map (every file owned by exactly one milestone)

| Milestone | Files owned |
|---|---|
| **M1** profile design-verbs | `references/profile-interface.md` |
| **M2** fidelity generalization | `references/milestones-and-verification.md`, `skills/implement-milestone/SKILL.md` |
| **M3** app-design-directions rework | `skills/app-design-directions/SKILL.md`, `skills/app-design-directions/references/anti-slop.md`, `skills/app-design-directions/references/stack-and-mockups.md`, `skills/app-design-directions/templates/design-brief.md`, `skills/app-design-directions/templates/direction-spec.md` |
| **M4** spec-feature/spec-change Movement 2 | `skills/spec-feature/SKILL.md`, `skills/spec-change/SKILL.md` |
| **M5** craft layer | `references/interaction-craft.md`, `references/motion-cookbook.md` |
| **M6** cleanup + guard | `README.md`, `skills/app-design-directions/README.md`, `scripts/check-neutral.sh`, `scripts/check-neutral.test.sh` |

No file appears in two milestones → parallel branches never collide.

## Dependencies + build order

```
M1 (foundation: the design verbs)
 ├─ M2 (fidelity → profile terms)      ─┐
 ├─ M3 (design skill rework)            ├─ parallelizable off M1 (disjoint files)
 └─ M5 (craft layer)                   ─┘
M4  depends on M1 + M2 (composes on the workbench verb + neutral fidelity)
M6  LAST — depends on M2 + M3 + M5 (the guard's new checks require the corpus already clean)
```

- **Parallelizable:** M2, M3, M5 off M1. M4 after M2. M6 last.
- **Cadence:** by-wave recommended — M1, then the M2/M3/M5 wave, then M4, then M6.

## Verification (feature-wide)

Every milestone is a **no-UI** change → **two-dimension** done-conditions (correctness + completeness), **no fidelity**, **no runtime walk** (keel ships no rendered surface). All done-conditions are **`[auto]`**: a `verifier` subagent reads the changed docs against the milestone's done-conditions, plus `check-neutral.sh` / `check-neutral.test.sh` where a milestone touches neutrality. Because every condition is `[auto]`, the wave can be swept by `verify-all-milestones` and each milestone pinned by it — a full dogfood of keel on keel.

## Handoff

This is the **plan PR** (plan-only: `specs/**`). The verified-pin gate exempts it. Each milestone's `verified:` pin is appended later in its own code PR after `/verify-milestone`.
