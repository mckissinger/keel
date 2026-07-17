# Change — harden

One milestone, prose + skill assets (one new skill with references/templates, ladder
wiring, two routing pointers). Approved by Michael 2026-07-17 after a two-round
discussion (understanding conveyed and challenged, full-repo review completed, research
mode confirmed) and a bounded online research pass over the current hardening canon —
OWASP Top 10:2025, ASVS 5.0, the 2025–26 npm supply-chain attack wave, SRE
production-readiness practice, and the OWASP LLM Top 10 2025.

## Why

Every keel-built product that goes to market needs a pre-launch hardening pass, and
keel has no verb for it. The doctrine deliberately keeps hardening judgment *out* of
per-milestone verification — the verifier agent bans "speculative 'could be more
robust' hardening" as expensive noise in a milestone verdict, and `verify-milestone`
repeats the ban — which is correct per milestone and means whole-system hardening
currently has **no sanctioned home**: it either happens ad hoc (no spec, no evidence
chain, no record of accepted risk) or not at all.

The per-diff half already exists: §3 of the shared rules requires `/security-review`
pre-pin on any hard-invariant milestone, and the genesis template contract wires
`security-review` as a required check. What is missing is the **whole-codebase,
cross-cutting sweep** — the gaps that live *between* milestones (a surface nobody's
diff flagged, drift accumulated across waves, dependency rot, missing rate limiting,
headers, backup/restore posture, observability) — plus the reliability, data-safety,
and operational dimensions the security gate never covers. It composes naturally with
keel's launch model: the deferrals ledger is defined as "everything outstanding before
production is real," and launch is the one attended go-live event; hardening is the
verb that audits that ledger on the way in and writes accepted risks back into it.

The 2025–26 threat landscape makes the gap worth closing now: OWASP Top 10:2025
promoted Software Supply Chain Failures to A03 and added Mishandling of Exceptional
Conditions at A10, and the npm supply-chain wave (the September 2025 self-replicating
worm, the March 2026 compromise of a top-download package) moved lockfile discipline,
install-script posture, and release-cooldown checks from nice-to-have to baseline.

## Decisions taken

- **Name `harden`, an audit verb in the `test-health` shape.** Not the `marketing-site`
  plan-authoring shape: keel already has a mature audit-verb pattern — promptless
  read-only sweep via an `allowed-tools` grant, fan-out read-only subagents, findings
  decomposed into keel grains, a dated diagnosis under `specs/reviews/` landed as a
  plan-only PR, the sitting ending attended on slate approval — and hardening is that
  shape with a production-readiness probe list instead of a test-hygiene one. The
  hard rule carries over verbatim in spirit: **harden audits and proposes; remediation
  never runs in the audit sitting.** (No collision with the internal `auto-hardening`
  / `review-hardening` feature specs — those hardened keel's own skill prose; the
  namespaces do not overlap and no file is shared.)
- **Four dimensions, selected in the brief, all-on by default for a pre-launch run:**
  (1) **application security** — grounded in OWASP Top 10:2025 (broken access
  control/tenancy, security misconfiguration, software supply chain failures,
  cryptographic failures, injection, insecure design, authentication failures,
  integrity failures, logging/alerting failures), with ASVS 5.0 named as the deeper
  per-area source, plus an **AI-surface section** (per the OWASP LLM Top 10 2025:
  prompt injection, improper output handling, unbounded consumption) gated on the
  profile's Q7 answer — a project with "n/a — no external calls" skips it;
  (2) **reliability + data safety** — error handling at system boundaries,
  exceptional-condition handling (A10:2025), timeouts and rate limiting, backup and
  restore posture, migration rollback, PII handling;
  (3) **operations + launch readiness** — observability (logging/alerting that would
  actually surface an incident), test-vs-live environment separation, deploy/rollback,
  and the **deferrals-ledger drain**: every open `specs/deferrals/` item whose closing
  condition is "before launch" is a finding until closed or explicitly re-accepted;
  (4) **supply chain** — folded as a named section of the security dimension, not a
  fourth fan-out: lockfile committed and CI installs from it, install-script posture,
  release-cooldown/quarantine where the ecosystem supports it, audit tooling wired.
- **Probes are profile-derived, never stack-hardcoded.** Each probe reference
  dispatches through the stack profile: the surface inventory (Q1–Q2) scopes what to
  sweep, the environment contract names the services whose posture is probed, Q7
  gates the AI section, Q10 names the deployed surface, has-UI (Q8.1) gates the
  browser-facing probes (headers, CSP). A probe a stack cannot express is recorded
  "n/a + why," the same convention as the profile's own answers.
- **Evidence discipline is the verifier's.** Every finding carries `file:line` or
  command + output-excerpt evidence; a checked-clean dimension is reported as clean,
  never padded. The secrets rule is absolute: env **values** are never read — presence
  is asserted by name only via the profile's recorded name-check command.
- **The read-only grant covers only the sweep; scanners run attended.** Dependency
  scanners, suite runs, or any network/state-changing probe run only with the user's
  go-ahead in the attended sitting, through the normal permission flow — the same
  split `test-health` draws for actually running suites.
- **Findings decompose into keel grains** (the audit's output contract): a
  hard-invariant fix → a `spec-change` milestone that names `/security-review` pre-pin
  per §3 of the shared rules (cited, not restated); a substantive fix → `spec-change`;
  independent nits → one `punch-list` batch; a consciously accepted risk or a
  can't-fix-yet → a `specs/deferrals/` file-per-entry record with its closing
  condition. Remediation runs through the normal verbs in later sessions.
- **The report is the durable artifact.** A dated note
  `specs/reviews/YYYY-MM-DD-harden.md` — scope + dimensions run, ranked findings with
  severity/evidence/grain, accepted risks with their deferral pointers, and what came
  back clean — committed on a branch and landed as a **plan-only PR, never a commit to
  `main`**; the sitting ends attended on the user's slate approval per the
  gate-presentation contract. It doubles as the launch go/no-go record.
- **Re-runnable, fresh each time.** No harvest-style cursor: the codebase is
  re-audited whole on every run (pre-launch, then pre-major-release). Prior accepted
  risks are read from the deferrals ledger and the prior report so they are
  re-surfaced deliberately, never re-litigated silently and never silently dropped.
- **Model-invocable.** Like `test-health`: the verb reads only the project's own
  committed state, in an attended sitting, and spends nothing — a session noticing
  "we're about to launch" should be able to propose it; running it is still attended.
  No `disable-model-invocation`.
- **Ladder wiring + routing seams.** README's grain ladder gains a Harden row and the
  skills list a Hardening bullet (count 23 → 24); both session-bootstrap banner copies
  gain the same line, with the self-test asserting the new name. The two places whose
  prose already touches the boundary — the verifier agent's speculative-hardening ban
  and `verify-milestone`'s copy of it — each gain one pointer sentence routing that
  judgment to `harden`; neither ban's scope changes.

## Seams owned up front

- **§3's `/security-review` pre-pin gate stays the per-milestone-diff owner**; `harden`
  is the whole-codebase, cross-cutting, pre-launch sweep. The skill body states the
  boundary so neither absorbs the other, and an accepted hard-invariant remediation
  still goes through the §3 gate in its own milestone.
- **`test-health` stays the suite/test-infrastructure audit; `debug` stays one bug
  with a repro.** The `when_to_use` distinguishes all three so the router picks the
  right verb.
- **The verifier/`verify-milestone` speculative-hardening ban is unchanged in scope**
  — the routing pointers redirect, they do not narrow the ban.
- **The deferrals ledger and the run preflight keep their owners**; harden *reads*
  the ledger and *writes* accepted-risk entries in the ledger's own file-per-entry
  format — it never re-owns the drain rule.
- **Anchored seams preserved**: no string named in `scripts/skill-anchors/*.txt` is
  removed or reworded by the routing edits.

## Revisions from the adversarial plan pass

Four findings, all folded in before the PR opened:

- **Four dimensions vs three fan-outs was internally ambiguous.** The change context
  folded supply chain into the security dimension but the milestone still read "one
  subagent per dimension" against four dimensions and three probe references; the
  brief and sweep conditions now state the folding explicitly (three references,
  three subagents; supply chain rides the security one).
- **The severity scale was promised in triage but not required of the template.**
  The report-template condition now requires the template to define the scale's
  levels and meanings, not merely carry a severity column.
- **The report filename pattern traced to no enforcing condition.** The
  `specs/reviews/YYYY-MM-DD-harden.md` pattern is now in the hard-rule condition —
  re-runs find the prior report by name.
- **"Matching test-health's grant pattern" graded similarity, not an outcome.** The
  condition now states the outcome: read-only shapes only, no Edit/Write or
  state-changing shape pre-approved.

## Research lineage

OWASP Top 10:2025 (owasp.org/Top10/2025) — A03 Software Supply Chain Failures and
A10 Mishandling of Exceptional Conditions new; SSRF folded into A01. OWASP ASVS 5.0.0
(May 2025, 17 chapters, ~350 requirements; owasp.org/www-project-application-security-
verification-standard). npm supply-chain wave 2025–26 (Unit 42's npm threat-landscape
tracking; Sonatype 2026 State of the Software Supply Chain: 454k+ new malicious
packages in 2025) — lockfile + `npm ci`, install-script posture, release cooldown.
OWASP Top 10 for LLM Applications 2025 (genai.owasp.org/llm-top-10) — prompt
injection, improper output handling, unbounded consumption. SRE production-readiness
practice (observability / alerting / rollback / backup-and-restore as checklist
domains). Distilled and rewritten in keel's own words in the probe references; no
source text reproduced.

## Milestone

`specs/milestones/harden.md` — new `skills/harden/SKILL.md` + `references/`
(probes-security, probes-reliability, probes-operations) + `templates/`
(hardening-brief, hardening-report); one row/bullet/count edit in `README.md`; the
`Harden:` line in both `scripts/session-bootstrap.sh` banner copies + its test; one
routing sentence each in `agents/verifier.md` and `skills/verify-milestone/SKILL.md`.
No gates, guards, hooks, or plugin-root references move.
