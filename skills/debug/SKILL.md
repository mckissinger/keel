---
name: debug
description: Disciplined root-cause loop — reproduce at the cheapest layer that can see the failure class (runtime for runtime-class bugs), isolate, find the true cause, fix it through the normal change gate, and regression-lock it at the lowest layer that reproduces. Consults the project's accumulated learnings first and records new ones.
when_to_use: When something is broken and you need to find and fix why, not patch a symptom.
---

# Debug

Find and fix the *real* cause of a defect, and make sure it can't come back. Debugging is its own session: it does not silently expand scope, and its fix goes through the normal gate (a branch, a pin, a regression test) — never an ad-hoc patch to `main`.

## Before you start

- **Consult the project's accumulated learnings first.** If the project keeps a durable learnings log (a `lessons/` dir, `decisions/`, or stack-profile gotchas), read the relevant ones — this exact defect class may already be solved. Don't re-derive a known fix.
- **State the bug as an observation, not a theory.** What's the exact symptom, where, and what did you expect instead? If you can't reproduce it, that's step one.

## The loop

1. **Reproduce — at the cheapest layer that can see this failure class.** Route by the profile's ladder (Q11): a type/shape error reproduces at the static rung in a second; a logic bug in a unit test; a wiring/interaction bug in a component-render test; only a failure class in the stack's **escalation holes** needs the real runtime. Escalating past a rung that could have seen the bug wastes the cost gap (the e2e rung runs ~100× slower and flakier — the ⚠ Q11 scar); escalate deliberately, not by habit. **Runtime-class bugs still reproduce at runtime**: the framework's worst bugs live precisely where the test environment diverges from the real runtime (a component/module-boundary error, a build-transform error, a hydration mismatch — the profile's ⚠ Q3/Q6 divergences), so for those, reproduce by **running the real thing** (the profile's activation driver against the actual build), never by trusting a green lower rung. A bug you can't reproduce, you can't verify you fixed.
2. **Isolate.** Narrow to the smallest input/code path that still triggers it. Bisect (git, or by disabling halves). Read the actual values, run the actual checks — don't reason from "the code looks like it would."
3. **Root cause, not symptom.** Name the underlying cause and why it produces the symptom. A fix that makes the symptom disappear without explaining the cause is a patch, and it'll resurface.
4. **Fix through the normal gate.** A fix substantial enough to need a spec rides a `spec-change` milestone (branch → `implement-milestone` → `verify-milestone` → pin); a trivial fix still gets its own branch + PR. Never patch `main` directly.
5. **Regression-lock it — at the lowest layer that reproduces.** Every fix that reflects a defect *class* graduates into a test that fails before the fix and passes after, written at the **cheapest rung that can see it** (a unit test for a logic bug, a component-render test for a wiring bug, a no-fixture e2e only for a true runtime-class bug) — so the class is locked in CI where it can't recur silently, at the price of the rung it belongs on. This is the backfill rule: a defect that escaped to a higher rung *is* the evidence of missing coverage one rung down.
6. **Record the learning.** If the root cause was non-obvious or stack-specific, write it where the project keeps durable learnings: a one-line `lessons/` entry, a `decisions/` note, or — if it's a stack gotcha future verification should always check — an update to `specs/stack-profile.md`. The next session inherits it instead of re-debugging.

## Boundaries

- **One bug, one session.** Don't fold "while I'm here" refactors or adjacent fixes into a debug session — note them, spec them separately. Scope creep hides the root cause.
- **Verify the fix the way the bug was found.** If it took a runtime render to reproduce, it takes a runtime render to confirm — a green unit suite is not proof a runtime bug is fixed.
- **The fix is verified like any change.** Its `verified:` pin comes from `verify-milestone`, not from your own say-so in this session.
