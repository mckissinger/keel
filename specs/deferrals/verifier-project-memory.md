# Verifier `memory: project` — method-never-conclusions

**Method/runtime-brief half RESOLVED 2026-07-05 by `auto-hardening-m2-seams`.** The specific
*method* gap this deferral names — the verifier lacking the project's how-to-run facts and so
bouncing a green milestone on a wrong stack assumption (the ShipLog ledger-005 false negative) —
is closed without the memory mechanism: `skills/verify-milestone/SKILL.md`'s dispatch now quotes
the project's `specs/stack-profile.md` runtime facts into the verifier/workflow prompt, and
`agents/verifier.md` is told the profile is the runtime ground truth it must not override with
stack assumptions (and that an environment-assumption mismatch is classified, not recorded).
Method-never-conclusions holds: the brief carries how-to-run facts only, never a prior verdict.
**The conclusions-memory half — a persistent `memory: project` store under
`.claude/agent-memory/verifier/` for flaky-check/convergence learnings, plus `maxTurns`, and its
untested `disallowedTools`-vs-memory platform interaction — remains deferred** with its original
rationale below.

**Parked 2026-07-01.** Give `agents/verifier.md` `memory: project` so verification *method*
(flaky checks + convergence counts, seed-data gotchas, runtime-proof quirks) persists in
`.claude/agent-memory/verifier/` — with a hard line: never verdicts, never conclusions, so
independence isn't contaminated. Add `maxTurns` as a runaway guard for the parallel sweep.

**Gate:** untested platform interaction — whether the verifier's `disallowedTools: Edit,
Write` blocks the memory mechanism's own writes (precedence undocumented). Resolve by live
test; fallbacks: a memory-dir carve-out, or the sequential record-writer persists learnings.
Also mind parallel writers and worktree isolation stranding memory writes.
