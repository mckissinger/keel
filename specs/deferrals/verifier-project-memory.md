# Verifier `memory: project` — method-never-conclusions

**Parked 2026-07-01.** Give `agents/verifier.md` `memory: project` so verification *method*
(flaky checks + convergence counts, seed-data gotchas, runtime-proof quirks) persists in
`.claude/agent-memory/verifier/` — with a hard line: never verdicts, never conclusions, so
independence isn't contaminated. Add `maxTurns` as a runaway guard for the parallel sweep.

**Gate:** untested platform interaction — whether the verifier's `disallowedTools: Edit,
Write` blocks the memory mechanism's own writes (precedence undocumented). Resolve by live
test; fallbacks: a memory-dir carve-out, or the sequential record-writer persists learnings.
Also mind parallel writers and worktree isolation stranding memory writes.
