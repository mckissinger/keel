---
name: test-health
description: Suite-wide test health audit — sweep the committed suites and test infrastructure for flakiness, efficiency, and hygiene against the shared doctrine, then decompose findings into keel grains and land the diagnosis as a dated note. Audits and proposes; remediation runs through the normal verbs later.
when_to_use: When the question is suite-WIDE — "our tests are flaky/slow/inconsistent", flakiness-rate or efficiency questions, a health check on the whole ladder. NOT debug — one failing or flaky test with a repro in hand goes to debug's root-cause loop; this is the audit for the suite as a system.
allowed-tools: Bash(git log *), Bash(git diff *), Bash(git show *), Bash(git rev-parse *), Bash(ls *), Bash(jq *), Bash(grep *), Bash(wc *), Bash(head *), Bash(cat *)
---

# Test-health

Audit the committed suites and test infrastructure as a system — flakiness, efficiency,
hygiene — and turn what you find into a grain-mapped remediation slate. The method was
paid for before it was specced: the same suite-health ask arrived twice in nine hours and
the first diagnosis, living only in chat, was re-derived from scratch
(`specs/reviews/2026-07-12-skill-mining.md` §3). This skill makes the audit repeatable and
its output durable.

**The hard rule: test-health audits and proposes — remediation never runs in the audit
sitting.** A §8 smell found here routes its remediation through the grains below, never an
ad hoc fix. An audit that "quickly fixes" a fixture has left its lane.

## The probes — what the sweep reads

- **Per-suite durations vs the profile's Q12 budgets**
  (`references/profile-interface.md`) — which suites have drifted past what they're
  supposed to cost.
- **Flake evidence**: retry configuration, serialized workers, shared fixtures — the
  configuration shapes that mask or manufacture flakes.
- **Hygiene against each rule of §8 of the shared rules**
  (`references/milestones-and-verification.md` §8) — §8 *is* the probe list; walk its
  rules one by one against the suites. The rules live there, not here.
- **Ladder shape vs Q11**: does the committed ladder match the profile's tier
  derivation — a missing middle tier, an e2e rung doing a unit rung's job?
- **CI-vs-local parity**: do the suites run the same way in both columns, or does green
  mean something different in each?

## Durations come from recorded evidence

Read durations from what's already recorded — the Q12 budgets, CI logs and timing
artifacts, prior run records. **Actually running suites to measure is state-changing and
outside the promptless grant**: it happens only with the user's go-ahead in the attended
sitting, through the normal permission flow.

Where the suite count warrants it, **fan out read-only subagents** — one per suite family
or directory slice, each dispatched with read-only instructions in its prompt (the
subagents inherit the harness, not this skill's grant, so the instruction rides in the
dispatch). The recorded session used four.

## Findings decompose into keel grains

Every finding maps to exactly one grain — this mapping is the audit's output contract:

- A **harness-contract rewrite** (fixture ownership overhaul, a tier restructure) → a
  **milestone**.
- A **product bug surfaced by a flaky tier** → a **`spec-change`** (one real shipped UX
  bug was found exactly this way).
- **Independent nits** (a stray retry budget, a mislabeled suite) → a **`punch-list`**
  batch.
- **Secret-gated infra** (a rung needing credentials CI doesn't hold) → a **deferred
  milestone in `specs/deferrals/`**.

Remediation never runs in the audit sitting; approved grains run through the normal verbs
in later sessions.

## The diagnosis is committed before the sitting ends

The audit lands as a **dated note under `specs/reviews/`** before the sitting ends —
committed on a branch and landed as a **plan-only PR, never a commit to `main`** — the
same landing shape as `harvest`. The sitting ends attended on the user's slate approval,
presented per the gate-presentation contract (`references/gate-presentation.md`).

## Boundaries

- **`allowed-tools` is a grant, not a restriction** — it pre-approves the read-only sweep
  set so the audit runs promptless; the audits-and-proposes guarantee is the stated hard
  rule above, per keel's recorded frontmatter semantics. No Edit or Write is
  pre-approved.
- **Not `debug`**: one failing/flaky test with a repro in hand → `debug`'s root-cause
  loop. Suite-wide health, flakiness-rate, or efficiency questions → this audit.
- **Why no `disable-model-invocation` where `harvest` carries it**: harvest's rationale
  was conjunctive — it reads private cross-project transcripts *and* spawns paid
  fan-out. This audit reads only the project's own committed state, in an attended
  sitting, so the model may propose it (a session noticing chronic flake should); running
  it is still attended.
