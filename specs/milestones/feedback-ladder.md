# Milestone — Feedback ladder: the inner-loop half

**Goal:** Q11 gains cost-ordering + escalation holes + the routing scar; kickoff stands the
ladder up (scaffold-gap rule, CI = declared ladder, CLAUDE.md carries the commands + routing
rule); debug/build route to the cheapest layer that reproduces; provision preflight proves each
rung; a new dated, honesty-marked priors file seeds Q11 derivation.

**Change:** `specs/changes/feedback-ladder.md`. **No-UI** → two-dimension done-conditions.
**Depends on:** `tier-aware-verification` (landed). **Parallelizable:** n/a (single milestone).

## Done-conditions

### Logic / invariants
- [auto] `references/profile-interface.md` **Q11 extended in place** (no new question, Q5–Q10
  unrenumbered): tiers answered **cheapest→dearest** with rough speed + what each uniquely
  catches (shape/logic/wiring/environment); **escalation holes** answered per stack (what
  structurally can't be seen below the walk); a ⚠ routing scar — *inner loop reproduces at the
  cheapest layer that can see the failure class; the walk is the gate, not the debugger* — with
  the one-line CLI-over-MCP browser-automation note. All tool mentions hedged.
- [auto] `references/feedback-ladders.md` **new**: header disclaimer (priors that seed the Q11
  derivation and never replace its research step; run-discovered staleness updates the file);
  ~10 stack entries, each **date-stamped** and marked **hardened** vs **researched** (only
  stacks a keel run actually used are "hardened"); each entry leads with escalation holes /
  scaffold gaps / flake traps, then the tier commands. No denylisted hardcodes
  (`check-neutral.sh` green).
- [auto] `skills/spec-foundation/SKILL.md`: step-zero CI jobs = the profile's declared ladder
  (not a hardcoded trio); **scaffold-gap rule** (a declared tier whose runner the scaffold
  doesn't ship is added at kickoff); project-CLAUDE.md section carries the exact ladder
  commands, single-test-first, and the routing rule.
- [auto] `skills/debug/SKILL.md`: reproduce at the cheapest layer that can see the failure
  class (existing runtime-reproduction text retained, scoped to runtime-class bugs via ⚠ Q3/Q6
  + Q11 holes); regression-lock at the **lowest layer that reproduces** (backfill rule).
- [auto] `skills/implement-milestone/SKILL.md` step 4: self-check runs the ladder **bottom-up**,
  single-test-first (additive to the tier-aware text — authoring committed tests is unchanged).
- [auto] `skills/provision/SKILL.md`: green preflight runs each declared rung green once;
  edit-hooks mentioned as optional mitigation only.
- [auto] `references/milestones-and-verification.md` §3: one sentence — the ladder governs the
  inner loop, the walk earns the pin, neither substitutes for the other. **No weakening** of
  the walk, the pin gate, or the tier-aware coverage gate anywhere in the diff.

### Behavioral completeness
- [auto] No contradictions introduced: `debug`'s runtime-reproduction guidance and Q3/Q6 ⚠
  scars still hold for runtime-class bugs (grep-check the edited files agree ladder-for-inner-
  loop / walk-for-gate); no spine file names a specific tool un-hedged; Q-numbering and
  §-references resolve.
- [auto] `scripts/check-neutral.sh` exits 0; `check-neutral.test.sh` and
  `check-verified-pin.test.sh` self-tests pass; `scripts/` untouched vs `main`.

## verification
verifier subagent against this file (docs greps, cross-reference resolution, no-weakening
sweep, priors-file disclaimer/markers present) + `scripts/check-neutral.sh` + both script
self-tests. No surface/action change → no runtime walk; no hard invariant → no
`/security-review`.
