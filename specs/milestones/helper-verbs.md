# Milestone — helper-verbs

Change context: `specs/changes/helper-verbs.md`. One milestone; adds two skills and
wires them — new `skills/demo/SKILL.md` and `skills/test-health/SKILL.md`, the
grain-ladder/skills-list/count lines in `README.md`, the orientation banner in
`scripts/session-bootstrap.sh` (both copies) + its self-test. No gates, guards, or
templates change. Integration seams: the bootstrap banner and its test follow the
`status`/`harvest` wiring pattern exactly; `demo` must state its non-overlap with
`review-feature` (that skill's gate framing is untouched); `test-health` audits
against owners that already exist — §8 of
`references/milestones-and-verification.md`, Q11/Q12 of
`references/profile-interface.md` — and cites them, never restates them; the
gate-presentation contract (`references/gate-presentation.md`) governs both skills'
attended endings by citation. Neutrality: both skill bodies cite the digest files for
provenance, never the dogfood projects' names.

## Done-conditions

- [auto] **Both skills exist and are well-formed.** `skills/demo/SKILL.md` and
  `skills/test-health/SKILL.md` have valid frontmatter (`name` matching the
  directory, a `description`, a `when_to_use`) and
  `scripts/check-skill-frontmatter.sh` passes with **21** skills. Neither carries
  `disable-model-invocation`; `test-health`'s body states why its fan-out doesn't
  trigger the flag where harvest's did (harvest's rationale was conjunctive —
  private cross-project transcripts *and* paid fan-out; this audit reads only the
  project's own committed state, attended). **Both** skills' `allowed-tools`
  pre-approve at most enumerated read-only shapes (the `status`/`harvest` grant
  shape) and grant no Edit/Write; demo's boot/seed commands go through the normal
  permission flow, nothing pre-approved beyond reads; each body states the
  grant-not-restriction semantics.
- [auto] **demo is gateless and distinct from review-feature.** The skill body
  states: attended, mid-build, any-time; produces no verdict and gates nothing; and
  names `review-feature` as the different thing (the once-per-feature aesthetic gate
  after landing) in its `when_to_use` or body.
- [auto] **demo encodes the five-step ritual.** The body states, in order: (1) the
  profile's Q12 substrate health check first; (2) stack activation per the profile
  (services, app/simulator boot per Q3, backgrounded where the harness supports it);
  (3) representative demo data seeded per Q5, never live credentials; (4) the **demo
  card** printed for the user — URL map/entry points, test credentials, what is
  stubbed vs live, and local-vs-deployed drift status; (5) stay resident — each user
  finding captured verbatim and triaged live into a keel grain (punch-list item or
  `spec-change`) so findings survive the sitting.
- [auto] **demo's write boundary, landing, and ending are stated.** The body states:
  demo authors no other verb's artifacts — triage labels findings with their grain
  and the owning verbs run in follow-up sessions; its one repo write, only when the
  user asks to record, is a dated findings note under `specs/reviews/`, committed on
  a branch as a plan-only PR (never a commit to `main`); and the sitting ends
  attended, presented per the gate-presentation contract
  (`references/gate-presentation.md`, cited).
- [auto] **demo batches screenshots when the driver exists.** The body states: when
  the profile declares a screenshot/review driver (Q8.4), offer batched captures of
  all surfaces up front instead of one-at-a-time round-trips.
- [auto] **test-health encodes the audit probes, durations from recorded evidence.**
  The body names its sweep inputs: per-suite durations vs the profile's Q12 budgets,
  flake evidence (retry configuration, serialized workers, shared fixtures), hygiene
  against **each rule of §8** of the shared rules (cited as the probe list, not
  restated), ladder shape vs Q11, and CI-vs-local parity; states that **durations
  come from recorded evidence** (Q12 budgets, CI logs/timing artifacts, prior run
  records) and that running suites to measure is state-changing — only with the
  user's go-ahead in the attended sitting, through the normal permission flow; and
  states that read-only subagents fan out where the suite count warrants.
- [auto] **test-health is distinct from debug, stated in the skill.** The
  `when_to_use` or body states the trigger boundary: one failing/flaky test with a
  repro in hand → `debug`'s root-cause loop; suite-wide health, flakiness-rate, or
  efficiency questions → this audit — and that a §8 smell found here routes its
  remediation through the grains, never an ad hoc fix in the audit sitting.
- [auto] **test-health decomposes findings into grains.** The body states the
  mapping: harness-contract rewrite → milestone; product bug surfaced by a flaky tier
  → `spec-change`; independent nits → `punch-list`; secret-gated infra → a deferred
  milestone in `specs/deferrals/`. Remediation never runs in the audit sitting.
- [auto] **test-health commits its diagnosis.** The body states: the audit lands as a
  dated note under `specs/reviews/` before the sitting ends — committed on a branch
  as a plan-only PR (never a commit to `main`), the same landing shape as `harvest` —
  and the sitting ends attended on the user's slate approval, presented per the
  gate-presentation contract.
- [auto] **Ladder wiring.** `README.md`'s Cross-cut ladder line and Cross-cutting
  skills bullet name both verbs, **and the skill count reads 21** (no "19 skills"
  text survives anywhere in the file); both banner copies in
  `scripts/session-bootstrap.sh` carry both verbs on their Cross-cut line; and
  `scripts/session-bootstrap.test.sh` gains assertions that the emitted banner names
  `demo` and `test-health`, with the full suite still passing and the banner under
  its word bound.
- [auto] **Repo checks green.** `claude plugin validate --strict .`,
  `scripts/check-neutral.sh`, `scripts/check-plan.sh`,
  `scripts/check-skill-frontmatter.sh`, `scripts/check-skill-anchors.sh`, and every
  `scripts/*.test.sh` pass on the branch.

## verification

verifier subagent against this file's done-conditions (all `[auto]`; the new skills
are prose + frontmatter, closable by reading the named files and running the named
checks).
