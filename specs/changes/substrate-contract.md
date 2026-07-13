# Change — substrate-contract

One milestone, prose-only across seven files (+ one workflow prompt string): the
**local substrate contract** — a new profile question (Q12) plus its derivation,
provisioning, entry-preflight, and debug wiring. Approved by Michael 2026-07-12 (slate
group D; `specs/reviews/2026-07-12-structural-review.md` §3 "the substrate is keel's
unowned dependency" — the review digests move to `specs/reviews/` in this plan PR so
spec citations stop pointing at untracked files).

## Why (the substrate was the corpus's biggest wall-clock destroyer)

Everything above the unit tier — the runtime walk, the e2e rung, the vision diff —
rests on a local substrate (daemon, ports, env files, CLIs, simulators) that no verb
owns after the provision sitting. The dogfood transcripts show what that costs:

- A **3-day port-collision saga** (new-test-proj, Jul 8–10): the stack's config lived
  below repo root, so a root-CWD start silently fell back to default ports and sessions
  talked to *another project's database* — asked about three times before a fix landed.
- A **daemon sign-in stall** (cre-launch, Jun 21) killed a 14-milestone run at
  milestone 1; ports held by a *different project's* stack cost another session.
- A **2-hour hung suite** (bidlevel, Jul 11): "supabase status is slow… rather than
  poll" → an open-ended wait with the session showing "Running" from 11:59 to 2:06.
- **Env and toolchain re-derivation every session**: a user-global lesson file re-read
  73× doing a committed doc's job (env exports, JAVA_HOME, invocation-path quirks);
  known flake signatures (a DB-contamination probe, stale build artifacts) re-diagnosed
  three times *in one session*.

provision's step 6 already bakes flake *mitigations* into config; what's missing is the
**contract** — a recorded, checkable description of the healthy substrate — and the
**cheap assertion of it at verb entry**, so drift is caught in seconds at session start
instead of mid-run.

## Decisions taken

- **Q12 — Local substrate contract** joins the profile interface: the shared local
  singletons and their one-line health checks; the project's **unique port block /
  project identity** (collision-free against the user's other projects); the
  **canonical invocation path** for the local stack (the CWD/config-discovery trap);
  the **env re-derivation command** (the contract line provision already records — Q12
  names where it lives); a **known-failure-signature table** (signature → classified
  remedy, accreting like scars); and **per-suite duration budgets** with the timeout
  rule stated **in Q12 itself** (the budgets' home owns the bound; the suite-running
  verbs point at it). ⚠-style scars generalize the four incidents above.
- **Split authorship, stated in Q12**: the structural parts (singletons, invocation
  path) are *derived* at spec time like every other question — spec-foundation's and
  adopt's enumerated question lists gain the substrate items — while the ports/identity
  assignment, env command, signature seeding, duration budgets, and the proven-green
  health check are *provision's* (the derivation records "finalized at provision" for
  those).
- **Provision authors and proves Q12** — extending step 6's mitigation-baking: assign
  the unique ports/identity, record the invocation path + env command, seed the
  signature table with the known shapes, record the per-suite duration budgets from
  step 7's prove-the-ladder-once timings, and run the substrate health check once green
  before the sitting ends.
- **Entry preflight at the build/verify verbs** — implement-milestone's orient step and
  verify-milestone's **dispatch entry** (before any suite runs — the suites fire at the
  dispatch step, earlier than the runtime walk) each run the Q12 health check (seconds:
  daemon responsive, ports owned by *this* project's stack, toolchain resolves, env
  file present or re-derived). A red substrate is a **stop-point routed to the
  signature table's remedy** — never absorbed, never debugged ad hoc mid-milestone.
- **The timeout rule is universal, stated once**: the rule lives in Q12 next to the
  budgets it reads; every place that runs suites points at it — verify-milestone's hard
  rules, implement-milestone's suite-running step, debug's reproduce loop, and the
  verifier prompt string in `workflows/verify-all-milestones.js` — a one-line pointer
  each, no restatement.
- **spec-foundation's generated-CLAUDE.md protocol stays in sync**: its build-start
  protocol mirrors implement-milestone's orient step, so it gains the same one
  preflight line (otherwise generated projects drift from the verb the moment this
  lands).
- **debug consults the signature table by name** — one clause added to its existing
  "consult accumulated learnings first" rule.
- Stack-neutral throughout: Q12 is a profile question with web-reference answers, like
  Q1–Q11; keel ships no stack specifics.

## Milestone

`specs/milestones/substrate-contract.md` — edits `references/profile-interface.md`
(new Q12 + timeout rule), `skills/provision/SKILL.md` (step 6 extension),
`skills/spec-foundation/SKILL.md` (question list + generated-protocol preflight line),
`skills/adopt/SKILL.md` (question list), `skills/implement-milestone/SKILL.md` (orient
preflight + timeout pointer), `skills/verify-milestone/SKILL.md` (dispatch preflight +
timeout pointer), `skills/debug/SKILL.md` (signature-table clause + timeout pointer),
and the verifier prompt string in `workflows/verify-all-milestones.js` (timeout pointer).
