---
name: harden
description: Pre-launch production-readiness audit — a whole-codebase, profile-derived sweep across application security (OWASP-grounded, supply chain included), reliability + data safety, and operations + launch readiness; evidence-backed findings triaged attended into a grain-mapped remediation slate plus a dated report under specs/reviews/. Audits and proposes; remediation runs through the normal verbs later.
when_to_use: Before a product goes to market — the pre-launch hardening pass — and again before each major release. NOT the §3 /security-review pre-pin gate (that reviews one milestone's diff before its pin; this sweeps the whole codebase across waves). NOT test-health (the suite/test-infrastructure audit). NOT debug (one bug with a repro in hand). Route here when the question is "is this system ready for real users," not "is this change correct."
allowed-tools: Bash(git log *), Bash(git diff *), Bash(git show *), Bash(git rev-parse *), Bash(ls *), Bash(jq *), Bash(grep *), Bash(wc *), Bash(head *), Bash(cat *)
---

# Harden

Audit the whole codebase for production readiness — security, reliability, data
safety, operational posture — and turn what you find into a grain-mapped remediation
slate the normal pipeline builds. This is the go-to-market hardening verb: run it
once before launch, then again before each major release.

**The hard rule: harden audits and proposes — remediation never runs in the audit
sitting.** Findings become work through the normal verbs, in later sessions, after
the user approves the slate. The audit's one durable artifact is a dated report,
`specs/reviews/YYYY-MM-DD-harden.md` (date-slugged with the verb name, so a re-run
finds the prior report by name), committed on a branch and landed as a **plan-only
PR, never a commit to `main`**. The sitting ends attended on the user's slate
approval, presented per the gate-presentation contract
(`${CLAUDE_PLUGIN_ROOT}/references/gate-presentation.md`). An audit that "quickly
fixes" a finding has left its lane.

## Why this exists

keel's doctrine deliberately keeps hardening judgment out of per-milestone
verification: the verifier bans speculative "could be more robust" findings as
expensive noise in a milestone verdict, and §3 of the shared rules
(`${CLAUDE_PLUGIN_ROOT}/references/milestones-and-verification.md`) scopes the
`/security-review` pre-pin gate to a hard-invariant milestone's own diff. Both are
correct at their grain — and they leave whole-system hardening with no sanctioned
home: the gaps that live *between* milestones (a surface nobody's diff flagged,
drift accumulated across waves, dependency rot, a backup nobody ever restored) reach
launch unexamined. This verb is that home, at the one moment the stakes justify the
rigor.

## Movement 1 — Brief

Read the scoping inputs: `specs/stack-profile.md` (the sweep dispatches through it),
the environment contract in `specs/01-architecture.md` (the services whose posture
is probed), the deferrals ledger (`specs/deferrals/` — open launch-scoped items are
audit input), and `specs/00-product.md` (what the product claims to be, so data
probes know what "in scope" means).

**Dimension selection is a brief decision, not a verb choice.** Four dimensions:
**application security** (with **supply chain folded in as a named section** — three
probe references, three fan-out subagents; supply chain rides the security one),
**reliability + data safety**, and **operations + launch readiness**. All four are
**on by default for a pre-launch run**; a scoped re-run may narrow, with the
exclusions and their reasons recorded. Write the scope into
`templates/hardening-brief.md` — launch context, dimensions in/out with reasons,
services in play by name — and confirm it with the user before the sweep runs.

## Movement 2 — Sweep

Fan out **one read-only subagent per in-scope probe reference** (supply chain rides
the security subagent), each dispatched with read-only, quote-minimal instructions
in its prompt — the subagents inherit the harness, not this skill's grant, so the
instruction rides in the dispatch — and with the profile's runtime facts quoted in.
Each subagent walks its probe reference:

- `references/probes-security.md` — application security, OWASP-grounded, supply
  chain and the AI surface included.
- `references/probes-reliability.md` — reliability + data safety.
- `references/probes-operations.md` — operations + launch readiness, including the
  deferrals-ledger drain.

**Probes dispatch through the stack profile, never through stack assumptions**: the
surface inventory (Q1–Q2) scopes what to sweep, the environment contract names the
services, Q7 gates the AI-surface section (a project answering "n/a — no external
calls" skips it), Q10 names the deployed surface, and Q8.1 gates the browser-facing
probes. A probe this stack cannot express is recorded **"n/a + why"** — a recorded
reason, not an assumed gap, the profile's own convention.

**Evidence discipline is the verifier's.** Every finding carries `file:line` or
command + output-excerpt evidence; no finding is reported without pointing at where
it lives. A checked-clean dimension is reported clean — never padded: the job is
"every probe actually checked," whichever verdict that produces.

**Secrets are never read.** Env **values** never enter this session or any subagent:
presence is asserted by name only via the profile's recorded env name-check command.
A permission denial on a `.env*` read is the posture working, not an obstacle.

**The grant covers only the read-only sweep.** Dependency scanners, suite runs, and
any network/state-changing probe run only with the user's go-ahead in the attended
sitting, through the normal permission flow — the same split `test-health` draws for
running suites.

## Movement 3 — Triage (attended)

Present the findings ranked by the severity scale `templates/hardening-report.md`
owns (the template defines the levels and their meanings; this body does not
restate them). The user accepts or defers each finding. A deferred finding is a
**conscious, recorded risk**, never a silent drop: it gets a `specs/deferrals/`
file-per-entry record with its closing condition, in the ledger's own format — this
verb reads the ledger and writes entries; it never re-owns the ledger's rules or
the run preflight's drain rule.

## Movement 4 — The slate and the report

Every accepted finding decomposes into **exactly one keel grain** — this mapping is
the audit's output contract:

- A **hard-invariant fix** (auth/tenancy, payments, data migration) → a
  `spec-change` milestone whose spec names `/security-review` **pre-pin** per §3 of
  the shared rules (cited, not restated — the per-diff gate still governs the fix's
  own milestone).
- A **substantive fix** → `spec-change` (one milestone).
- **Independent nits** (a missing header, a stray debug flag) → one `punch-list`
  batch.
- An **accepted risk / can't-fix-yet** → the `specs/deferrals/` entry from triage.

Write the report from `templates/hardening-report.md` — scope + dimensions run, the
severity scale, ranked findings each with severity/evidence/grain, accepted risks
with their deferral pointers, and what came back clean — and land it as the
plan-only PR per the hard rule above. **The report doubles as the launch go/no-go
record.** Remediation runs through the normal verbs in later sessions.

**Re-runs audit fresh.** There is no cursor: the codebase is re-audited whole each
run — a prior clean says nothing about the code that landed since. Prior accepted
risks are read from the deferrals ledger and the prior report so they are
re-surfaced deliberately: never re-litigated silently, never silently dropped.

## Boundaries

- **`allowed-tools` is a grant, not a restriction** — it pre-approves the read-only
  sweep set (no Edit, Write, or state-changing shape) so the audit runs promptless;
  the audits-and-proposes guarantee is the stated hard rule above, per keel's
  recorded frontmatter semantics.
- **Not the §3 gate**: `/security-review` pre-pin stays the per-milestone-diff
  owner; this verb is the whole-codebase, cross-cutting sweep, and an accepted
  hard-invariant remediation still passes through that gate in its own milestone.
  Neither absorbs the other.
- **Not `test-health`** (the suites and test infrastructure as a system) and **not
  `debug`** (one bug with a repro → the root-cause loop).
- **Model-invocable, like `test-health`**: this verb reads only the project's own
  committed state, in an attended sitting, and spends nothing — a session noticing
  "we're about to launch" should propose it; running it is still attended. No
  `disable-model-invocation`.

## Where this sits

```
/security-review   one hard-invariant milestone's diff, pre-pin      (per milestone)
test-health        the committed suites as a system                  (audit verb)
harden             the whole codebase, before real users             ← here (pre-launch, re-run per major release)
```
