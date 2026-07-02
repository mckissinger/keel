# 2026-07 — Autonomy modes: a scoped amendment to the permanent-human-merge-gate doctrine

This entry amends `decisions/2026-07-01-model-capability-ledger.md` **by reference** — that
ledger is never edited; it remains the record of why the gate exists. The line this entry
scopes is the ledger's permanent-audit-machinery item **"The human merge gate + branch
protection"** ("The user merges; nothing autonomous crosses go-live. Authority, not
capability."). That doctrine stays the default. This entry carves out one explicit,
human-triggered exception — the `keel:auto` modes — and states what is traded to get it.

## (a) Scope

Per-merge human approval is delegated to **server-side required checks** *only under an
active `keel:auto` mode* (`auto:feature` or `auto:run`), entered by an explicit human
invocation and never by agent escalation. Attended keel is unchanged: the ask-floor on
merges stays exactly as the ledger records it. Outside an active mode, nothing in this
entry applies.

## (b) The trade — what now compensates the ~17% residual

The ledger's honest-figures section records a measured **~17% classifier false-negative
rate** in auto mode, cited there as the reason the human merge gate stays. Under an active
mode, the compensation for that residual moves from the human merge eyeball to the
**required checks**: the verified-pin gate, plan-lint, and the profile CI ladder, **plus a
blanket required security-review check** on every code PR in auto-mode projects. The
residual is not claimed to have shrunk; its compensating control changes, and the
security-review check is added precisely because the human eyeball is out of the loop.

## (c) Accepted design-pick trade in auto:run

In `auto:run`, when a design direction must be chosen, the agent picks one and **ledgers**
the rationale plus the comparison artifact; the user adjudicates at the debrief. A possible
redesign pass is accepted as the cost of zero interrupts. This is a consciously accepted
trade, recorded here so it is never mistaken for an oversight.

## (d) Never auto, at any level

These stay attended under every posture, including both auto modes:

- `--dangerously-skip-permissions` — banned outright.
- Go-live and live-key swaps.
- Spend beyond the pre-authorized caps.

## (e) Delegation is to GitHub's required checks, never to agent judgment

The delegation target is the server-side branch-protection machinery, not the agent's
opinion of readiness. Concretely: under an active mode, only `gh pr merge --auto` on a
gate-passing PR becomes allowed — GitHub merges when and only when the required checks
pass. Plain `gh pr merge` stays **ask** even in auto mode; a gate failure stays **deny**.
No agent ever decides a PR is good enough to merge; it may only hand a PR to the checks
that decide.
