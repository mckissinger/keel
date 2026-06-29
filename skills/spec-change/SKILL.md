---
name: spec-change
description: Spec ONE small change — the sub-feature grain. A compressed feature-spec for a change below a whole feature (a tweak, a small addition, a fix that needs a spec) that fans into ONE milestone (rarely two). Focused mini-interview, mockups optional-and-asked, then author the milestone against the shared rules. NOT for a whole feature (that's spec-feature) or the app foundation (that's spec-foundation).
---

# Spec Change

Plan **one small change** to a depth that survives a fresh build session, without the weight of a full `spec-feature`. This is the grain *below* a feature: a tweak, a contained addition, a fix that's substantial enough to deserve a spec but small enough that the full feature interview + per-screen mockup set would be overkill. It fans into **one milestone** (rarely two).

The milestone-authoring + verification rules are in `${CLAUDE_PLUGIN_ROOT}/references/milestones-and-verification.md` — this skill **applies them unchanged**. It compresses the *interview and mockup* effort, never the done-condition standard. If you find the change fanning into three+ milestones, it's a feature — stop and use `spec-feature`.

## The three movements, compressed (one session, ends on your sign-off)

### 1. Mini-interview (focused, not feature-deep)

Restate the change in one sentence (who it's for, what it enables). Surface the open decisions; default what's defaultable; ask only what can't be — one batched round. For a change you only need the *delta*: which surface(s) it touches, the states it adds or alters, the exact data, the edges (validation, permissions), and the integration seam with existing code. **End with the confirm-before-author gate** — synthesize the resolved understanding (and, if it touches a new stack mechanic, the stack-profile delta) and **get explicit sign-off before authoring anything.**

### 2. Mockups — optional and asked (UI changes only)

For a no-UI change, skip this. For a UI change, **ask** rather than always mocking — most of the time the gallery already carries the intent:

- *"This change is [a novel screen/state] / [pure composition of existing gallery components]. Generate a mockup?"* — default **yes** for a novel archetype, **skip** for pure recomposition.
- If generated: `design/mockups/<change>/<screen>.html` (real data, real states), then *"review it now, or trust it and proceed?"* (open it for review).
- **Either way, keep a concrete fidelity reference.** If you skip the bespoke mockup, the fidelity done-condition points at the **named gallery components** it composes — never nothing. The build must have a fidelity target.

### 3. Author the milestone

One milestone (rarely two) per the shared rules:
- **Done-conditions span the applicable dimensions** — logic/invariants, UX completeness (the enumerated states/interactions), and — for a UI change — fidelity (tokens/fonts/themed components + the mockup *or* the named gallery components).
- **Tag each `[auto]`/`[runtime]`/`[attended]`** so the build/verify sessions know what gates the pin.
- **Name the verification method** (verifier subagent / dynamic workflow; + the runtime walk for any surface/action change; + `/security-review` pre-pin for a hard-invariant change).
- **Own every surface the change touches**; flag any stop-point.

Write the milestone spec to `specs/milestones/<slug>.md` (self-contained) and any change context to `specs/changes/<slug>.md` if useful.

## Output + handoff

Ends **attended**, on your sign-off. Then:
- **Open the plan PR** (plan-only — `specs/**` + `design/**`, no code — exempt from the verified-pin gate).
- **Build** via `implement-milestone` (fresh session) → **`verify-milestone`** appends the pin in the code PR.
- For a UI change, `review-feature` still applies if it's user-facing enough to warrant the aesthetic gate; for a small internal change it may not.

## Where this sits in the grain ladder

```
spec-foundation   the whole app, once
spec-feature      one feature (1–5 milestones)
spec-change       one change (1 milestone, rarely 2)   ← here
```
