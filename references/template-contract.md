# The genesis template contract

The two-tier contract a genesis-generated repo (and, once
`specs/deferrals/genesis-template-repo.md` is reopened, a future *forked* template repo) must
satisfy to pass `scripts/check-auto-preflight.sh` on its **first** run. The bootstrap in the
genesis posture (`skills/auto/SKILL.md`) generates against this contract; the preflight is the
machine gate it must clear before the unattended Phase 2 loop begins. v1 generates from
scratch — the fork-based shortcut is deferred (`specs/deferrals/genesis-template-repo.md`).

The contract's shape is deliberately **asymmetric: strict on the gates, loose on the stack.**
Tier 1 is invariant — every genesis repo has it, identically, or the preflight fails closed.
Tier 2 is per-project and prunable — declared from the approved skeleton's service inventory,
and an *unused* sandbox key is **never** an error, because `scripts/check-auto-preflight.sh`
check (c) verifies only the env-var names the project's **own** `specs/01-architecture.md`
declares. A key sitting unused in `~/.config/keel/sandbox.env` is invisible to the gate.

## Tier 1 — invariant (every genesis repo, identical)

These are the same in every generated repo and are exactly what the preflight asserts:

- **The three required-check CI jobs — `verified-pin`, `plan-lint`, `security-review` — wired
  and *required* in branch protection.** A job that runs but is not a *required* status check
  does not gate the merge; the contract requires them **required**. This is what
  `scripts/check-auto-preflight.sh` check (b) asserts against the default branch's protection.
- **A committed `.claude/settings.json`** whose `permissions.allow` list covers the core
  command inventory the run issues — the allowlist `scripts/check-auto-preflight.sh` check (a)
  dry-runs the committed `specs/run-command-inventory.txt` shapes against.
- **The `specs/` scaffold**, including an `specs/01-architecture.md` carrying an
  **environment-contract section to fill** — backtick-quoted `ALL_CAPS` env-var *names* the
  project needs. The section is a **template to complete, never pre-filled with key values**:
  it lists names (`STRIPE_SECRET_KEY`), never contents. `scripts/check-auto-preflight.sh`
  check (c) resolves those names against the host env / env file — names only, values never
  read into output.
- **The repo allows auto-merge** (`allow_auto_merge` enabled) so the `--auto` land path queues
  rather than stalling on a prompt — `scripts/check-auto-preflight.sh` check (d).

Tier 1 maps one-to-one onto the preflight's four checks (a)–(d): satisfy tier 1 and the
machine gate is green. Miss any of it and the preflight fails closed, ending the run attended.

## Tier 2 — prunable stack scaffold (per-project, declared from the skeleton)

The stack scaffold is **declared per-project from the approved skeleton's service inventory** —
the services the human approved in Phase 1, and only those. Everything else the generator
might scaffold is pruned. The prune rule is a **checkable done-condition**:

> The app builds and boots with only the declared services, and no reference to a pruned
> service remains anywhere in the tree.

This is where the asymmetry bites: tier 2 is loose because the stack is the project's own
business. The generator may start from a broad scaffold, but the *contract* only requires that
what survives the prune builds and boots cleanly and leaves no dangling reference to what was
cut. An unused sandbox key — a service the environment offers but this project's skeleton did
not name — is not a pruned-service reference and is **never** a preflight error, because the
gate checks only the names `specs/01-architecture.md` declares, not the whole key set.
