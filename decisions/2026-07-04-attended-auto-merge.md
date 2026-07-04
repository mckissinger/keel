# 2026-07-04 — Attended auto-merge: dropping the redundant tap on a human-instructed merge

This entry amends the permanent-human-merge-gate doctrine **by reference**. It does **not**
edit `decisions/2026-07-01-model-capability-ledger.md` or `decisions/2026-07-autonomy-modes.md`
in place — both remain the record of why the gate exists and how the autonomy modes carve out
their exception. The line this entry scopes is the ledger's permanent-audit-machinery item
**"The human merge gate + branch protection"** ("The user merges; nothing autonomous crosses
go-live. **Authority, not capability.**"). That doctrine stays the default. This entry carves
out one attended, per-session convenience and states exactly what is — and is not — traded.

## (a) What it is

A human-invoked-only skill, `keel:auto-merge on|off` (`disable-model-invocation: true`), writes
or removes an **untracked** per-session marker `.claude/keel-attended-merge.json` (fields
`scope: "session"`, `created`, `invoker`). Both merge guards honor it. Under a valid marker —
and no active autonomy mode — a **bare, explicitly-instructed** `gh pr merge <pr> --auto` on a
verified-pin-gate-**passing** PR is allowed with **no per-merge tap** (`merge-guard.sh`: the
ask-floor becomes allow) and **no build-session refusal** (`guard-branch-rules.sh`: the
categorical `exit 2` becomes `exit 0`, deferring the gate decision to `merge-guard.sh` on the
same call). Every other shape — plain `gh pr merge`, a push or `git merge` to the default
branch, a bundled/chained `--auto`, a gate failure — stays exactly as today.

## (b) The trade — the tap, not the authority

The toggle delegates the per-merge **tap** to an explicit human invocation; it does **not**
delegate the merge **authority**. Per the ledger, the human merge gate is *"authority, not
capability"* — and the authority here is the human's, being exercised by the very act of
invoking the skill and typing the instructed merge. Dropping the redundant confirmation on a
**user-instructed, gate-passing** merge does not weaken that authority. Letting the **agent**
decide to merge would — and that is precisely what stays blocked: with no human-minted marker,
every guard is byte-for-byte today's ask/deny/exit-2, and `disable-model-invocation` keeps the
model from arming the toggle itself.

## (c) What stays load-bearing

- **Only the `--auto` handoff is unlocked** — the server-side required checks still decide what
  lands. GitHub merges when and only when they pass.
- **The verified-pin gate still blocks unverified code** — the marker never overrides a gate
  failure (that stays `deny`); it only removes the tap on a gate *pass*.
- **The agent still cannot merge on its own initiative** — no marker → today's behavior.
- **Autonomy precedence** — when a valid `keel:auto` mode file is active, the attended marker is
  ignored; the mode path (entry (b)/(e) of `2026-07-autonomy-modes.md`) governs that decision.

## (d) The residual, and where it is recorded

A stale or forged marker is the same class of concern the autonomy mode file already carries —
an agent-writable, TTL-less marker whose only backstop is delegation to the required checks.
Because this marker unlocks **only** the `--auto` handoff, that same
delegation-to-required-checks backstop holds it: a stale/forged marker cannot land code the
required checks reject. The shared stale/forged-marker + trigger-binding concern is recorded in
`specs/deferrals/mode-file-binding-ttl.md` (referenced here, not re-argued).

## (e) Explicitly out of scope

The **per-project, committed** variant of this toggle — always-on for every session in a repo,
including headless ones where no human is watching — is **deferred** with its compensating
required security-review check, in `specs/deferrals/per-project-auto-merge.md`. This entry
covers the per-session, attended path only.
