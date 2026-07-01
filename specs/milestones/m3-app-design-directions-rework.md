# M3 — app-design-directions: diverge-cheap / converge-real, workbench = truth, cross-platform

**Feature:** design-track-neutral. **Depends on:** M1 (workbench + medium + platform verbs). **Parallelizable:** yes — off M1, with M2 and M5 (disjoint files).
**Files owned:** `skills/app-design-directions/SKILL.md`, `skills/app-design-directions/references/anti-slop.md`, `skills/app-design-directions/references/stack-and-mockups.md`, `skills/app-design-directions/templates/design-brief.md`, `skills/app-design-directions/templates/direction-spec.md`.

## Goal

Rework the design-SYSTEM skill so exploration is cheap-throwaway, the chosen direction **converges into the real workbench as the source of truth**, the exploration medium + workbench are **profile-driven** (web hardened, mobile derivable), and **native feel** is a first-class discovery concern. Keep the skill's name, phase spine, and anti-slop discipline.

## Done-conditions

1. **[auto] Divergence is explicitly throwaway-only.** `SKILL.md` states the mockup medium (Phases 2/3.5) is for **direction-finding only**, judges **look only** (not motion/interaction/native-feel), and is **never re-implemented as a spec**. The exploration medium is **profile-driven** (HTML for web; profile-appropriate for mobile per the M1 medium verb).
2. **[auto] Convergence builds the real workbench.** Phase 4 ("apply") is reframed as **build the real workbench** via the profile's workbench verb — the durable **fidelity source of truth** every feature composes from. The web `/styleguide` route becomes the *web example* of the workbench verb, not a hardcode.
3. **[auto] Discovery captures platform + native feel.** Phase 0 records the platform target (web / mobile / cross) and, for mobile, the platform-convention set (navigation, gestures, system controls) from the M1 platform verb; directions must be implementable on that platform and must not impose a web look on native.
4. **[auto] Anti-slop gains a native/mobile companion.** `references/anti-slop.md` adds a section on native/mobile slop (forcing a web look onto native; missing/incorrect platform controls, nav, gestures) — as banned *defaults*, same framing as the web list.
5. **[auto] Mechanics + templates neutralized.** `references/stack-and-mockups.md` is framed as the **web** workbench/mockup mechanism (an instance of the profile verb), not the universal one. `templates/design-brief.md` "Framework / CSS" → platform + stack (neutral). `templates/direction-spec.md` material-palette rows stay as hedged examples. Design-consequential libraries remain owned by `design.md`, now including motion + interaction-state tokens.
6. **[auto] Neutrality.** `bash scripts/check-neutral.sh` passes on the non-design corpus; design-track files may retain web examples but frame mobile as derivable.
7. **[completeness] Phase spine coherent.** The phase list, the copyable checklist, and the reference-file table stay internally consistent after the edits; the "design SYSTEM not feature screens" boundary and the "do not re-run per feature" rule are intact.

## Verification

`verification: verifier subagent against this milestone's done-conditions, + bash scripts/check-neutral.sh`.
