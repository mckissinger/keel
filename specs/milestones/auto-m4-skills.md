# Milestone — auto-m4-skills: the keel:auto skill and the mode deltas

**Goal:** the modes become drivable — a new human-triggered `keel:auto` skill (entry-state
audit, preflight gate, mode-file write, orchestration, ledger + debrief contract) and a
small mode-delta in each existing skill whose attended gate the modes change, so no skill's
prose contradicts an active mode.

**Feature:** `specs/features/autonomy-modes.md`. **No-UI** → two-dimension done-conditions.
**Depends on:** `auto-m1-doctrine`, `auto-m2-mode-plumbing`, `auto-m3-envelope-preflight`.
**Parallelizable:** no.

## Done-conditions

### Logic / invariants
- [auto] New `skills/auto/SKILL.md` (`keel:auto`) with `disable-model-invocation: true`,
  args `feature` / `run [scope]`, specifying in order: (a) the **entry-state audit** —
  grain-ladder position from the project's specs/ + git state, producing the run's
  definition of done for the given scope (posture, not phase: any entry point is valid);
  (b) the **preflight gate** — `check-auto-preflight.sh` must pass before the mode file is
  written; a failure ends the sitting attended; (c) the **mode-file write** (the m2
  contract) and its removal at run end — the only writer is this skill; (d) orchestration —
  `auto:feature` drives implement-feature over one feature's milestones and lands each
  gate-passing PR via `gh pr merge --auto` per the land-feature choreography (referenced,
  not restated); `auto:run` iterates spec-feature (default-taking for unspecced features) →
  build → land over the scope; (e) the **ledger contract** — every would-be ask writes a
  file-per-entry record under `specs/runs/<run-id>/` (decision, rationale, the artifact it
  would have shown), committed with the work it explains; (f) the **debrief mandate** —
  the run is not complete until the batched per-feature `review-feature` sitting happens;
  features are *built-verified-merged* but never *feature-done* before adjudication;
  (g) stop-point semantics unchanged — halt + surface; never widen permissions; the
  never-auto list from the decisions entry restated by reference only.
- [auto] Mode-delta sections (one short block each, conditional on an active mode, pointing
  at the decisions entry rather than re-arguing) in: `skills/land-feature/SKILL.md` (its
  choreography is invoked by keel:auto with `--auto`; the flag and attended flow unchanged),
  `skills/implement-feature/SKILL.md` (cadence ask → ledgered default; "stops at merge" →
  enables `--auto` and proceeds), `skills/spec-feature/SKILL.md` (confirm-before-author +
  redline → ledgered synthesis under `auto:run`), `skills/review-feature/SKILL.md` (batched
  per-feature debrief scheduling), `skills/interview/SKILL.md`, `skills/spec-change/SKILL.md`,
  `skills/punch-list/SKILL.md` (confirm gates → ledgered defaults under `auto:run`), and
  `skills/app-design-directions/SKILL.md` (agent picks + ledgers the comparison artifact
  under `auto:run`, per the accepted trade).
- [auto] `disable-model-invocation: true` is preserved on `land-feature` and `kickoff` and
  present on `auto` — asserted by grep in the verification pass.
- [auto] The bootstrap orientation (m2's mode-aware text) names `keel:auto` among the verbs
  it lists, in both mode and no-mode variants.

### Behavioral completeness
- [auto] No skill instructs the agent to answer, suppress, or auto-approve a harness
  permission prompt: the mode changes *which gates exist* (via the m2 guard path), never
  tells the agent to work around one — grep sweep across `skills/` for
  approve/bypass/skip-permission phrasing plus reviewer judgment on the eight deltas.
- [auto] One-owner sweep: the ledger contract and debrief mandate are specified in
  `skills/auto/SKILL.md` once; the eight mode-delta blocks reference, never restate; the
  never-auto list lives in the decisions entry alone.
- [auto] `claude plugin validate --strict .` passes with the new skill;
  `scripts/check-neutral.sh` exits 0 (all of `skills/` is scanned corpus);
  `scripts/check-plan.sh` passes the corpus.

## verification
verifier subagent against this file (skill-by-skill greps for a–g and the eight deltas, the
flag greps, both one-owner sweeps, the no-prompt-workaround sweep) + `claude plugin validate
--strict .` + `scripts/check-neutral.sh` + `scripts/check-plan.sh` + all script self-tests
(no script changes expected vs m2/m3 — confirm untouched). Prose-only over already-reviewed
mechanism → no separate `/security-review` (m2/m5 carry the adversarial passes on the allow
path); no UI surface → no runtime walk (composition proof is m5's).

verified: clean at f397f77, 2026-07-02, via fresh-context verifier subagent — skills/auto carries disable-model-invocation: true with a–g in spec order and quoted evidence (entry-state audit :19–23, preflight-before-mode-write :25–29, m2-contract mode file with sole-writer + every-exit-path removal :33, orchestration with land-feature choreography referenced-not-restated :39–41, ledger contract :45, debrief mandate :49, stop-points + never-auto by reference :53); all eight mode-delta blocks present with the spec'd content and no ninth skill touched; flag greps pass on auto/land-feature/kickoff; bootstrap names keel:auto in both variants proven behaviorally (script run with and without a mode file); no-prompt-workaround sweep clean; both one-owner sweeps clean; plugin validate --strict + check-neutral + check-plan + all 7 suites green (13/17/18/17/16/62/29); the script diff audited as exactly the minimal two-line orientation change done-condition 4 forces plus one additive test case (the disclosed deviation from the verification line's no-script-changes expectation — done-condition wins), zero deletions repo-wide. (evidence: verifier report in PR)
