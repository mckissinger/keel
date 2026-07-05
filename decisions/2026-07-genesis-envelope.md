# 2026-07 — The genesis Phase 2 envelope: skeleton approval as the authorization trail

This entry amends the autonomy doctrine **by reference**. It edits neither
`decisions/2026-07-autonomy-modes.md` nor the capability ledger
`decisions/2026-07-01-model-capability-ledger.md` in place — both remain the standing
record of why the human merge gate exists and what the two hardened postures traded. This
entry adds one thing on top: what a human's **skeleton approval** authorizes when the third
posture, `keel:auto genesis "<idea>"` (the genesis posture documented in
`skills/auto/SKILL.md`), crosses from its attended Phase 1 into its unattended Phase 2. The
bootstrap it authorizes generates a repo against the committed contract in
`references/template-contract.md`.

The governing idea: genesis has exactly **one** human decision — the approval of the Phase 1
artifact (validation assessment + product skeleton + direction boards). That approval is not
just a "go"; it is the **authorization trail** for the bounded set of scripted, no-judgment
setup actions Phase 2 then performs. Nothing in Phase 2 is a fresh authority the agent grants
itself; every action below traces to the human approval that opened the envelope.

## (a) What the skeleton approval authorizes — the bounded Phase 2 envelope

On approval (and only on approval), Phase 2 may perform these scripted actions **without a
further per-action human tap**, because each is a no-judgment consequence of the approved
skeleton and the committed template contract:

- `gh repo create` — **one private repo**, named from the approved skeleton.
- **branch-protection + required-checks configuration** on that repo's default branch —
  wiring the three required checks (`verified-pin`, `plan-lint`, `security-review`) exactly as
  `references/template-contract.md` tier 1 mandates.
- **CI, allowlist, and `specs/` seeding** per the template contract — the committed CI
  workflow, the `.claude/settings.json` command allowlist, and the `specs/` scaffold.
- the **dev-resource creations the approved service inventory names** — and only those: a
  Postgres branch, a preview project, a storage bucket — each a development-tier resource
  drawn from the service inventory the human approved, never a production or go-live resource.

The envelope is **exactly this set**. An action not on this list — anything the approved
skeleton did not name, anything in the never-auto list at (c) — is outside the envelope and
stops the run attended.

## (b) The envelope is bounded by the standing capped sandbox keys — names only

Every credential Phase 2 wires is a **standing, capped, environment-level sandbox key** from
`~/.config/keel/sandbox.env` (sourced by the shell). The session wires them **by name only**:
no genesis session ever reads, echoes, logs, or prints a key value — it references
`STRIPE_SECRET_KEY` the token, never its contents, exactly as
`scripts/check-auto-preflight.sh` check (c) already enforces (names resolve; values are never
read into output).

This formalizes **spend-caps-as-authorization** as keel *doctrine*, not a per-project
decision: because the keys are pre-capped at the environment level, spending against them
within the caps needs no per-project human sign-off — the cap **is** the authorization. A key
being capped is what lets its use sit inside the envelope; spend beyond the cap is never
authorized (see (c)).

## (c) The never-auto list is unchanged — quoted intact

Genesis widens no part of the never-auto list. These stay attended under every posture,
genesis included, quoted verbatim from `decisions/2026-07-autonomy-modes.md` §(d):

- `--dangerously-skip-permissions` — banned outright.
- Go-live and live-key swaps.
- Spend beyond the pre-authorized caps.

Genesis **ends at preview, never live.** The envelope authorizes development-tier setup and a
preview deploy; it authorizes no go-live, no live-key swap, and no spend past the caps that
bound it. The human merge authority and the verified-pin gate are untouched — genesis reaches
merges only through the existing `auto:run` land path, where the delegation is to the
server-side required checks and never to agent judgment (see (f)).

## (d) Rejection creates nothing

The Phase 1 approval gate has three outcomes; one of them is **reject**. A rejected validation
assessment **ends the flow with nothing created** — no repo, no branch protection, no
resources, no mode file. The envelope opens on approval and only on approval; there is no
partial-on-rejection state to clean up because nothing outside the approval artifact itself
was ever written.

## (e) Residual: the approval artifact is forgeable the same way the mode file is

An approval artifact that authorizes later scripted actions carries the **same forgeability
residual** the autonomy mode file carries: an agent could in principle write the artifact
directly rather than earning it through the attended Phase 1. This is not a new class of risk —
it is the **shared concern already parked in `specs/deferrals/mode-file-binding-ttl.md`** (the
run-binding / write-gating half still deferred there), and it is held by the **same standing
backstop**: the server-side required checks. A forged approval cannot land unpinned or unsafe
code, because genesis still reaches merges only through `gh pr merge --auto` on a PR that
GitHub merges **when and only when** `verified-pin`, `plan-lint`, and `security-review` pass.
The approval artifact is not the merge authority; the required checks are. Resolving the
run-binding mechanism is that deferral's gate, not this envelope's.

## (f) Extends the delegation carve-out's mode enumeration to genesis

`decisions/2026-07-autonomy-modes.md` §(a) scopes per-merge delegation-to-required-checks to
an active `auto:feature` / `auto:run` mode. This entry **extends that enumeration** — by
reference, without editing the prior entry — to an **active genesis-level mode** (`level:
"genesis"` in the mode file). Under genesis, the same one row changes and no other: a bare
`gh pr merge <pr> --auto` on a gate-passing PR becomes `allow`; plain `gh pr merge` stays
`ask`; a gate failure stays `deny`. §(e)'s rule is **unchanged**: the delegation target is
GitHub's required checks, never the agent's opinion of readiness. Genesis adds a third
enumerated level to the same carve-out; it does not loosen it.
