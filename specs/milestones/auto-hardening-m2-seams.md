# Milestone — auto-hardening-m2-seams: the verifier runtime brief + the kickoff→run charter seam

**Goal:** a fresh verification session reads the project's real runtime from
`specs/stack-profile.md` before judging any `[runtime]` condition (closing the ShipLog ledger-005
false-negative class), and a kickoff sitting's outputs seed a subsequent `keel:auto run` charter
without re-derivation.

**Feature:** `specs/features/auto-hardening.md`. **No-UI** → two-dimension done-conditions.
**Depends on:** `auto-hardening-m1-guards` (sequential — both touch `skills/auto/SKILL.md`;
see the feature spec's seam note). **Parallelizable:** no.

## Design (decided at the 2026-07-05 sitting)

- **Verifier brief = the stack profile, not a new artifact.** ShipLog ledger 005: a fresh
  verifier bounced a green milestone by assuming a local Docker stack when the project runs
  hosted resources. The project's `specs/stack-profile.md` already records how the project
  actually runs; the fix is that the dispatching skill *quotes the profile's runtime facts into
  the verifier's prompt* and the verifier agent is told the profile is the runtime ground truth
  it must not override with stack assumptions. This resolves the *method* half of
  `specs/deferrals/verifier-project-memory.md` (method-never-conclusions holds: the brief
  carries how-to-run facts, never prior verdicts).
- **Kickoff→run seam = charter seeding, prose only.** Today `keel:auto run`'s entry audit
  re-derives the project state that an immediately-preceding kickoff sitting just established.
  The seam: kickoff's final step (after the green preflight) writes its synthesis — backlog,
  build order, resolved decisions — to **`specs/runs/<date>-<slug>-kickoff/charter.md`** (the
  location the ShipLog kickoff already used), and the run's entry audit reads **the most recent
  `specs/runs/*/charter.md`** as its first input. Kickoff *offers* the `keel:auto run`
  invocation, never issues it (the human invocation stays the authorization).
- **The prose-anchor lint (new, owned here).** The behavioral conditions below need a committed
  check that skill prose keeps its load-bearing sentences. Mechanism: a new
  `scripts/check-skill-anchors.sh` that, for each `scripts/skill-anchors/<feature>.txt`
  (one `file-path<TAB>literal-anchor` pair per line), asserts the anchor string is present in
  the named file — wired into CI beside the other lints. Anchor sets are **file-per-feature**
  (this milestone ships `auto-hardening.txt`; later features add their own file, never edit an
  existing one — the §4 collision rule).

## Done-conditions

### Logic / invariants
- [auto] `skills/verify-milestone/SKILL.md`: the dispatch section instructs quoting the stack
  profile's runtime facts (how services run — hosted vs local, how the app is activated, seeded
  state) into the verifier/workflow prompt, and names an environment-assumption mismatch as a
  classify-before-recording case (profile says hosted → a local-stack assumption is the
  verifier's error, not a discrepancy).
- [auto] `agents/verifier.md`: instructs reading `specs/stack-profile.md` (when the project has
  one) as the runtime ground truth before judging any `[runtime]`/environment-dependent
  condition, and forbids bouncing work for not matching a runtime the profile does not describe.
  The agent's read-only stance and "find problems, never fix" mandate are byte-unchanged.
- [auto] `skills/kickoff/SKILL.md`: the final step (post-preflight) writes the kickoff synthesis
  to `specs/runs/<date>-<slug>-kickoff/charter.md` as the charter seed and offers — never
  invokes — the `keel:auto run` continuation, naming the human invocation as the authorization.
- [auto] `skills/auto/SKILL.md`: the entry-state audit (step 1) names the most recent
  `specs/runs/*/charter.md` as its first input when present, falling back to today's
  from-scratch audit unchanged.
- [auto] `specs/deferrals/verifier-project-memory.md` updated in place: the method/runtime-brief
  half marked resolved by this milestone; the conclusions-memory half explicitly remains
  deferred with its original rationale.
- [auto] `scripts/check-neutral.sh` and `scripts/check-skill-frontmatter.sh` pass on every
  touched skill/agent file; **no shipped guard, hook, preflight, or bootstrap behavior changes**
  in this milestone (the new anchor lint below is additive test-tier, not a behavior change to
  any existing script).

### Behavioral completeness
- [auto] New `scripts/check-skill-anchors.sh` exists, is wired into CI, and passes: it reads
  every `scripts/skill-anchors/<feature>.txt` (one `file-path<TAB>literal-anchor` per line) and
  fails when a named file lacks its anchor string; it passes on an empty/missing anchors dir
  (wireable before anchors exist); it carries its own `scripts/check-skill-anchors.test.sh`
  (present anchor → pass, absent → fail, malformed line → fail).
- [auto] `scripts/skill-anchors/auto-hardening.txt` pins the four seams: verify-milestone's
  dispatch names the stack profile; `agents/verifier.md` names `stack-profile.md` as runtime
  ground truth; kickoff names `charter.md` + the offer-not-invoke sentence; auto step 1 names
  `specs/runs/*/charter.md` — so any later rewording that drops a seam fails CI.
- [auto] `claude plugin validate --strict .` passes; every pre-existing self-test suite still
  passes (no existing script's behavior changed).
- [attended] During the next dogfooded kickoff→auto sequence, the user confirms the run's
  charter reflected the kickoff synthesis without re-interviewing, and no verifier bounce cites
  a runtime the stack profile contradicts (the machine-checkable text anchors above are the
  committed ground truth; this bullet is the human's end-to-end confirmation).

## verification
verifier subagent against this file — each prose change present and scoped (the text anchors),
the offer-not-invoke boundary in kickoff, the entry-audit fallback preserved, both deferral
updates accurate, and the read-only/never-fix mandate of `agents/verifier.md` unchanged. No
mechanism or guard touched → no `/security-review`; no runtime surface → no walk.
