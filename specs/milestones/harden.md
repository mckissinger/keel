# Milestone — harden

Change context: `specs/changes/harden.md`. One milestone; adds one skill and wires
it — new `skills/harden/SKILL.md` with three skill-local references
(`references/probes-security.md`, `references/probes-reliability.md`,
`references/probes-operations.md`) and two templates (`templates/hardening-brief.md`,
`templates/hardening-report.md`); the grain-ladder / skills-list / count lines in
`README.md`; the orientation banner in `scripts/session-bootstrap.sh` (both the
neutral and mode-active copies) + its self-test; one routing sentence each in
`agents/verifier.md` and `skills/verify-milestone/SKILL.md`. No gates, guards, hooks,
or plugin-root references move. Integration seams: the session-bootstrap banner is
covered by `scripts/session-bootstrap.test.sh` (stays green, gains an assertion for
the new name); `test-health` is the wiring pattern to match (the closest audit verb —
its grant shape, hard rule, grain-mapped output, and plan-only landing); the
speculative-hardening ban sentences in `agents/verifier.md` and
`skills/verify-milestone/SKILL.md` are the routing seam — they gain a pointer, their
scope does not change, and no string named in `scripts/skill-anchors/*.txt` is
removed or reworded; the shared milestone rules
(`references/milestones-and-verification.md`) are cited by the skill body, never
restated or re-owned. Neutrality caution for the builder: scanner and ecosystem names
(an npm-audit-class scanner, a lockfile, a CSP header) appear only as examples of the
probe class on stacks that have them, never as hard requirements; the skill body and
references never name dogfood projects or real client brands; example content uses
invented products.

## Done-conditions

- [auto] **The skill exists and is well-formed.** `skills/harden/SKILL.md` has valid
  frontmatter (`name: harden`, a `description`, a `when_to_use`) and passes
  `scripts/check-skill-frontmatter.sh` (now 24 skills). It does **not** carry
  `disable-model-invocation` — the body states why it is model-invocable (reads only
  the project's own committed state, in an attended sitting, and spends nothing). It
  carries an `allowed-tools` grant of **read-only shapes only** (no Edit, Write, or
  state-changing shape pre-approved), and the body states the grant-not-restriction
  semantics per the existing audit verbs. The `when_to_use` states the trigger (pre-launch, then
  pre-major-release re-runs), and distinguishes the verb from the §3
  `/security-review` pre-pin gate (per-milestone diff, not whole-codebase), from
  `test-health` (the suite/test-infrastructure audit), and from `debug` (one bug with
  a repro) so the router picks the right verb.
- [auto] **The audit-and-propose hard rule is encoded.** The skill body states:
  harden audits and proposes — remediation never runs in the audit sitting; the
  report lands as a dated note under `specs/reviews/` committed on a branch and
  landed as a plan-only PR, never a commit to `main` — the note's path follows the
  `specs/reviews/YYYY-MM-DD-harden.md` pattern (date-slugged with the verb name, so
  re-runs can find the prior report by name); and the sitting ends attended
  on the user's slate approval, presented per the gate-presentation contract
  (`references/gate-presentation.md`, cited not restated).
- [auto] **The brief movement is encoded.** The skill body states the scoping inputs
  — `specs/stack-profile.md`, the environment contract in `specs/01-architecture.md`,
  the deferrals ledger, `specs/00-product.md` — and that dimension selection is a
  brief decision — all four dimensions on by default for a pre-launch run, with
  supply chain **folded as a named section of the security dimension** (three probe
  references, three fan-out subagents; supply chain rides the security one) —
  recorded in `templates/hardening-brief.md`, which exists (scope, launch context, dimensions
  in/out with reasons, services in play by name) and is named by the skill body at
  its point of use.
- [auto] **The sweep is profile-derived, fanned out, and evidence-backed.** The skill
  body states: one read-only subagent per in-scope probe reference (supply chain
  rides the security subagent per the folding above), each dispatched with
  read-only, quote-minimal instructions in its prompt (subagents inherit the harness,
  not the grant — the same clause the existing audit verbs carry) and with the
  profile's runtime facts; probes dispatch through the profile (Q1–Q2 surface
  inventory scopes the sweep, the environment contract names the services, Q7 gates
  the AI-surface section, Q10 names the deployed surface, Q8.1 gates browser-facing
  probes), and a probe the stack cannot express is recorded "n/a + why"; every
  finding carries `file:line` or command + output-excerpt evidence, and a
  checked-clean dimension is reported clean, never padded.
- [auto] **The secrets rule and the attended-scanner split are encoded.** The skill
  body states: env **values** are never read — presence is asserted by name only via
  the profile's recorded name-check command; and the `allowed-tools` grant covers
  only the read-only sweep — dependency scanners, suite runs, and any
  network/state-changing probe run only with the user's go-ahead in the attended
  sitting through the normal permission flow.
- [auto] **The security probes are encoded and current.**
  `skills/harden/references/probes-security.md` exists, is organized by the OWASP
  Top 10:2025 categories (naming it as the grounding and ASVS 5.0 as the deeper
  per-area source), covers as checkable probes: access control/tenancy enforced at
  the data layer where the stack has one, security misconfiguration (headers/CSP
  gated on Q8.1, debug surfaces, default credentials), a **software supply chain
  section** (lockfile committed and CI installs from it, install-script posture,
  release-cooldown/quarantine where the ecosystem supports it, audit tooling),
  cryptographic failures (transport, at-rest, password hashing), injection at the
  system boundaries, authentication failures (session handling, rate-limited auth
  endpoints), integrity failures, and security logging/alerting — plus an
  **AI-surface section** (grounded in the OWASP LLM Top 10 2025: prompt injection
  posture for untrusted content reaching a model, model output treated as untrusted
  at every executing boundary, unbounded-consumption caps — tied to keel's existing
  capped-key doctrine) explicitly gated on the profile's Q7 answer.
- [auto] **The reliability + data-safety probes are encoded.**
  `skills/harden/references/probes-reliability.md` exists and covers as checkable
  probes: error handling at system boundaries (naming keel's only-validate-at-
  boundaries posture so the probe list does not mandate speculative internal
  handling), exceptional-condition handling (fail closed vs fail open, per OWASP
  A10:2025), timeouts and rate limiting on outbound and inbound calls, backup and
  **restore** posture (a backup never restore-tested is a finding), migration
  rollback/forward-only discipline per the profile's Q9, and PII inventory +
  retention (what personal data exists, where, and whether the product's stated
  scope covers it).
- [auto] **The operations + launch-readiness probes are encoded.**
  `skills/harden/references/probes-operations.md` exists and covers as checkable
  probes: observability (would an incident on a load-bearing surface actually
  surface — error tracking, alerting, log retention), test-vs-live environment
  separation (live keys never in the dev environment, per the environment contract's
  own rule), deploy + rollback (the path to undo a bad deploy is known and recorded),
  and the **deferrals-ledger drain**: every open `specs/deferrals/` item whose
  closing condition falls at or before launch is enumerated in the report as a
  finding until closed or explicitly re-accepted.
- [auto] **Triage and the grain map are encoded.** The skill body states: findings
  are triaged attended, ranked by a severity scale the report template owns, with
  the user accepting or deferring each; accepted findings decompose into exactly one
  keel grain — a hard-invariant fix → a `spec-change` milestone whose spec names
  `/security-review` pre-pin per §3 of the shared rules (cited, not restated); a
  substantive fix → `spec-change`; independent nits → one `punch-list` batch; an
  accepted risk or can't-fix-yet → a `specs/deferrals/` file-per-entry record with
  its closing condition — and remediation runs through the normal verbs in later
  sessions, never in the audit sitting.
- [auto] **The report template exists and re-runs are governed.**
  `skills/harden/templates/hardening-report.md` exists (scope + dimensions run;
  **a defined severity scale** — the template owns the scale's levels and their
  meanings, per the triage condition above; ranked findings each with
  severity/evidence/grain; accepted risks with their deferral pointers; checks that
  came back clean; and a prior-report pointer) and is
  named by the skill body at its point of use; the body states the re-run posture —
  the codebase is re-audited whole each run (no cursor), and prior accepted risks
  are read from the deferrals ledger and the prior report so they are re-surfaced
  deliberately, never re-litigated silently and never silently dropped — and states
  that the report doubles as the launch go/no-go record.
- [auto] **The routing seams land.** The speculative-hardening ban sentence in
  `agents/verifier.md` and its counterpart in `skills/verify-milestone/SKILL.md`
  each gain one sentence routing whole-system hardening judgment to the `harden`
  verb (neither ban's scope changes), and every anchor in
  `scripts/skill-anchors/*.txt` still resolves
  (`scripts/check-skill-anchors.sh` passes).
- [auto] **Ladder wiring.** `README.md`'s grain ladder gains a Harden row (matching
  the ladder's existing row format) and the skills list gains a Hardening bullet,
  and the skill count reads 24 (no "23 skills" text survives anywhere in the file);
  both orientation-banner copies in `scripts/session-bootstrap.sh` carry the same
  `Harden:` line; and `scripts/session-bootstrap.test.sh` gains an assertion that
  the emitted banner names `harden`, with the full suite still passing.
- [auto] **Repo checks green.** `claude plugin validate --strict .`,
  `scripts/check-neutral.sh`, `scripts/check-plan.sh`,
  `scripts/check-skill-frontmatter.sh`, `scripts/check-skill-anchors.sh`, and every
  `scripts/*.test.sh` pass on the branch.

## verification

verifier subagent against this file's done-conditions (all `[auto]`; the new skill is
prose + frontmatter + templates, closable by reading the named files and running the
named checks).

verified: clean at 24de6eb, 2026-07-17, via verifier subagent against this spec's done-conditions — all 13 conditions evidenced with file:line, git-tracking + scope-creep inverse checks run, 5 repo checks + 11 script self-test suites green, plugin validate --strict passed (evidence in PR #141)
