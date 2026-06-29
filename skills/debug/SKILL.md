---
name: debug
description: Disciplined root-cause loop — reproduce at runtime, isolate, find the true cause, fix it through the normal change gate, and regression-lock it. Consults the project's accumulated learnings first and records new ones. Use when something is broken and you need to find and fix why, not patch a symptom.
---

# Debug

Find and fix the *real* cause of a defect, and make sure it can't come back. Debugging is its own session: it does not silently expand scope, and its fix goes through the normal gate (a branch, a pin, a regression test) — never an ad-hoc patch to `main`.

## Before you start

- **Consult the project's accumulated learnings first.** If the project keeps a durable learnings log (a `lessons/` dir, `decisions/`, or stack-profile gotchas), read the relevant ones — this exact defect class may already be solved. Don't re-derive a known fix.
- **State the bug as an observation, not a theory.** What's the exact symptom, where, and what did you expect instead? If you can't reproduce it, that's step one.

## The loop

1. **Reproduce — at runtime, not just in units.** The framework's worst bugs live precisely where the unit-test environment diverges from the real runtime (a component/module-boundary error, a build-transform error, a hydration mismatch — the profile's ⚠ Q3/Q6 divergences). So reproduce by **running the real thing** (the profile's activation driver against the actual build), not by trusting a green unit suite. A bug you can't reproduce, you can't verify you fixed.
2. **Isolate.** Narrow to the smallest input/code path that still triggers it. Bisect (git, or by disabling halves). Read the actual values, run the actual checks — don't reason from "the code looks like it would."
3. **Root cause, not symptom.** Name the underlying cause and why it produces the symptom. A fix that makes the symptom disappear without explaining the cause is a patch, and it'll resurface.
4. **Fix through the normal gate.** A fix substantial enough to need a spec rides a `spec-change` milestone (branch → `implement-milestone` → `verify-milestone` → pin); a trivial fix still gets its own branch + PR. Never patch `main` directly.
5. **Regression-lock it.** Every fix that reflects a defect *class* graduates into a test that fails before the fix and passes after — a no-fixture e2e in the stack's test driver for a runtime bug, a unit test for a logic bug — so the class is locked in CI where it can't recur silently.
6. **Record the learning.** If the root cause was non-obvious or stack-specific, write it where the project keeps durable learnings: a one-line `lessons/` entry, a `decisions/` note, or — if it's a stack gotcha future verification should always check — an update to `specs/stack-profile.md`. The next session inherits it instead of re-debugging.

## Boundaries

- **One bug, one session.** Don't fold "while I'm here" refactors or adjacent fixes into a debug session — note them, spec them separately. Scope creep hides the root cause.
- **Verify the fix the way the bug was found.** If it took a runtime render to reproduce, it takes a runtime render to confirm — a green unit suite is not proof a runtime bug is fixed.
- **The fix is verified like any change.** Its `verified:` pin comes from `verify-milestone`, not from your own say-so in this session.
