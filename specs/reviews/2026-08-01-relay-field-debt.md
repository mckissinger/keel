# Field note — 2026-08-01: Relay's accumulated run debt

**Status: parked for discussion. Nothing here is authored work, and none of it is keel-repo work.**

This records what the `digest-feed` feature wave left behind in the downstream project **Relay**
(`new-test-proj`), so the items survive the next context switch. Every remediation below belongs in
Relay's repo, not keel's — the note lives here only because that is where the discussion is.

## Provenance and evidence grade

Read directly from `origin/main` of the Relay checkout on 2026-08-01, at the file:line cited. Two
items are **report-derived** — they come from a Relay session's own status write-up pasted into the
keel session, not from anything this session observed — and are marked as such. Grade them lower.

## What the wave actually did

The `digest-feed` feature landed across four milestone PRs (#86 core, #87 blocked-recovery, #88 web,
#89 mobile), with a refinement PR (#90) trailing. The quality bar held: M4's pin records three
verifier rounds, a clean `/security-review`, the Q7 capped-key live variant, and a Q6 Release build.

**A predicted hazard did not materialize.** The keel session had flagged a collision risk in Wave A —
M1's done-conditions require `supabase db reset`, while M4's `[runtime]` walk depends on seeded state,
on one shared local stack. M4's pin line resolves it: the `[runtime]` legs were **orchestrator-run,
serial on the exclusive local stack**. The builds parallelized; the runtime proof did not. That is the
isolation contract working, and the earlier "stop the wave" alarm was louder than the evidence
warranted. Recorded here so the correction outlives the session that made the error.

## Open items

### 1. Two learnings from the wave were never written down

One *was* captured, and captured well: the stale-Kong-upstream row at `specs/stack-profile.md:297`
(added 2026-07-30 during `digest-feed-core`, cross-linked to `lessons/supabase-db-reset-kong-502.md`)
diagnoses a 502 that reads as a code defect and is not. That is the signature table doing its job.

Two others did not make it:

- **`vercel link --yes` names the project after the working directory.** Run from a worktree, it
  silently created a stray empty Vercel project named for the worktree dir. The remedy is to always
  pass an explicit project name rather than accepting the inferred default. *(Report-derived.)*
- **A milestone whose done-conditions require a destructive DB reset must be serialized against any
  DB-backed sibling.** The orchestrator got this right in Wave A, but the reasoning lives only in a
  pin line — not in the profile, where the next wave-planner would look.

### 2. Duration budgets are still placeholders

`specs/stack-profile.md:314-320` — four of the five budget rows still read **finalized at provision**:
`turbo run typecheck lint`, `turbo run test`, `turbo run test:e2e`, and the Mobile Maestro walk.

This is load-bearing, not cosmetic. The rule at `:309-312` kills a suite at **~2× its recorded
budget** and classifies the overrun as an environment fault. With no recorded budget, the rule cannot
fire — and these are precisely the suites that hang. The health check, which has a budget, is the one
that never does.

### 3. The fragile-gate row is unhardened — and should stay that way for now

`specs/stack-profile.md:307` still reads: the reset+seed command is *"not yet wrapped in a single
assert-and-fail-loud preflight; harden if it re-bites."*

It has not re-bitten. The row's own stated policy is therefore satisfied by leaving it alone.
Listed here so it is visibly deferred rather than forgotten — not as work to schedule.

### 4. The stray Vercel project

An empty project named after a worktree directory, created by the `vercel link --yes` trap above. The
Relay session was blocked from deleting it by the autonomy classifier. **This is the user's action to
take** — deleting a remote project is not something a session should do on its own initiative.
*(Report-derived.)*

### 5. `specs/flakes/` is empty

Confirmed empty on `origin/main`. Not a defect by itself — an empty flake ledger is the correct state
if nothing flaked. Noted only so a later reader does not mistake absence for non-adoption.

## The pattern worth discussing

Capture is real but partial: one hard-won diagnosis was recorded, two were not, and the budget rows
have sat as placeholders since provision. The asymmetry is structural rather than a discipline
failure — building has a natural trigger and capture does not, so capture happens when a learning is
painful enough to be unforgettable and lapses when it is merely useful.

keel already has the verb for this (`harvest`: transcript-mining retrospective producing a proposed
improvement slate, human-triggered only). Whether the answer is running `harvest` on Relay after each
feature, or something with a tighter loop, is the open question this note exists to raise.

## Not in scope here

The keel-side gap surfaced alongside these items — nothing detects a `specs/stack-profile.md` that
predates the current profile interface, so an out-of-date profile degrades silently instead of
reporting — is a keel-repo concern and gets its own record. It is **not** part of the Relay work above.
