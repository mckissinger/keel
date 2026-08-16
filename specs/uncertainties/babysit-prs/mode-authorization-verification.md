# Uncertain choice — how the workflow verifies "an active mode" for drain

**The choice made:** the workflow treats `authorization: "mode"` as available only when the
dispatcher explicitly declared it AND the orient agent corroborates it against an active
run ledger under `specs/runs/`; the committed marker, by contrast, is verified wholly
independently (`git show origin/<default>:.claude/keel-auto-merge.json`). Neither signal
alone suffices for mode.

**Viable alternatives considered:** (a) dispatcher's word alone — simplest, and the
`keel:auto` orchestrator is itself already authorized, but it makes a prompt-injection or
a confused dispatcher sufficient to open the merge lane; (b) self-detection alone (ledger
presence without a dispatcher claim) — but a stale or abandoned run ledger would then arm
drain mode on a session that never entered the mode.

**Why it's uncertain:** the spec requires drain under "an active mode" without dictating
the verification mechanism (it dictates one only for the committed marker). A reasonable
reviewer could prefer (a) on the grounds that the mode orchestrator's own envelope is the
real control and the corroboration is redundant, or could want a stronger canonical
mode-marker file checked the same way the committed marker is. The two-signal AND was
chosen as the conservative reading of "never a queue/authorization the workflow infers"
— but it is a judgment call, not a spec derivation.
