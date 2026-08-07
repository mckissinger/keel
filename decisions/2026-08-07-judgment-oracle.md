# 2026-08-07 — The judgment oracle: decorrelated mid-run judgment, never delegated authority

## The decision

Under an active autonomy mode, a would-be **judgment** ask may be consulted against a dedicated
read-only `oracle` agent on `claude-fable-5` before its default is taken and ledgered. A would-be
**authorization** ask may not — ever. The spec is `specs/changes/judgment-oracle.md` +
`specs/milestones/judgment-oracle.md`; the contract lands in `skills/auto/SKILL.md`.

## Why

The two-model policy (`decisions/2026-07-25-two-model-routing.md`) is built on decorrelation: the
Fable-5 verifier catches the Opus-5 builder's mistakes because it does not share them. But that
decorrelated judgment arrives only after the work exists. Mid-run, the ledger contract resolves
every would-be ask to a build-model default — correct for authorization (where the answer is the
human's by construction), but for genuine ambiguity it hands the decision to the model most
invested in its current path, at its most convincing. The oracle applies the same decorrelation
one step earlier, on exactly the class of ask where better *judgment* — not more *authority* — is
the missing ingredient.

## The line, and why it is hard

"Which / how / why" is consultable; "may I" is not. The delegation principle of
`decisions/2026-07-autonomy-modes.md` §(e) — delegation is to server-side required checks, never
to agent judgment — is precisely why: a more capable model consulted by the agent **is still the
agent**. Routing a merge-authority, scope, or never-auto question through the oracle would launder
authorization through capability. So the boundary is enforced from both sides: the contract
forbids dispatching authorization questions, and the oracle's own protocol returns
`reframed-as-authorization` instead of an answer when one arrives — the run halts per the
stop-point semantics, as it always would have. An `uncertain` disposition also halts the run
attended: the consult was made because the default was not confidently takeable, and an uncertain
frontier verdict confirms the ambiguity is beyond unattended resolution. A consult may thus turn a
would-be default into a halt (conservative, always legal); **a consult never converts a stop-point
into forward motion** — `answered` is the only disposition on which the run proceeds, and only on
a decision it was already entitled to take on its own.

## Recorded parameters

- Oracle: read-only repo access (grounded answers over brief-only — owner's call, 2026-08-07),
  `claude-fable-5` at `high`, one question per dispatch.
- Cap: **5 consults per feature**; the would-be 6th is a stop-point — that volume is the signal
  the spec was too ambiguous to run unattended, and the fix is attended re-speccing, not more
  consulting.
- Every consult is a ledger entry (question, brief, recommendation, rationale, disposition,
  outcome), adjudicated at the debrief like every other recorded deferral.
- No guard, gate, preflight, or never-auto-list change; the mode file, TTL, and merge path are
  untouched.
