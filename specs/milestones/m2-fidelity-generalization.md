# M2 — Fidelity done-condition generalized to profile terms

**Feature:** design-track-neutral. **Depends on:** M1 (uses the token + workbench verbs). **Parallelizable:** yes — off M1, with M3 and M5 (disjoint files).
**Files owned:** `references/milestones-and-verification.md`, `skills/implement-milestone/SKILL.md`.

## Goal

Replace the Tailwind/web-hardcoded **fidelity** definition (the parked leak) with a profile-driven one, and state the **workbench-is-the-fidelity-truth** principle where fidelity is defined. (All edits to `check-neutral.sh` that enforce this live in **M6**, not here — so the two milestones never collide on the guard.)

## Done-conditions

1. **[auto] Fidelity is neutral.** In `references/milestones-and-verification.md` §2, the fidelity bullet no longer names `@theme`, native `<select>`, Lucide, or Recharts. It expresses fidelity in profile terms: uses the design system's **tokens** (per the M1 token verb, no raw values), **themed components not platform defaults**, the **`design.md`-recorded icon / chart / motion libraries**, and **"layout matches the feature's workbench composition"** (per the M1 workbench verb).
2. **[auto] Workbench = fidelity source of truth.** Where fidelity/layout-by-reference is defined (§2 and/or §6), the file states that the **real workbench composition is the fidelity reference, not a static mockup** — consistent with the diverge-cheap/converge-real decision. §6's "layout is specified by reference" points at the feature's workbench composition (the mockup is downgraded to an optional divergence sketch).
3. **[auto] implement-milestone neutralized.** `skills/implement-milestone/SKILL.md` step 3 no longer says `@theme` tokens; it uses the neutral phrasing (design tokens per the profile; themed components; the `design.md` libraries; matches the feature's workbench composition).
4. **[auto] Neutrality holds.** `bash scripts/check-neutral.sh` passes (these files are in the shared neutral corpus).
5. **[completeness] Framework intact.** §2's three-dimension model (logic / UX-completeness / fidelity) still holds — only the *fidelity* dimension's wording changed; the `[auto]`/`[runtime]`/`[attended]` tag rules and every other section are unchanged. The no-UI two-dimension carve-out (fidelity skipped when has-UI? = no) still reads correctly against the M1 verb.

## Verification

`verification: verifier subagent against this milestone's done-conditions, + bash scripts/check-neutral.sh`.

verified: clean at 9c90d68, 2026-06-30, via verifier subagent against done-conditions + bash scripts/check-neutral.sh (first pass BLOCKED on a §3↔§6 mockup-vs-workbench contradiction; remediated, re-verified CLEAN — all five DCs PASS; evidence in PR)
