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

  **The three arrive in two tiers — which is who wires what, not a weakening of the set.**
  `verified-pin` + `plan-lint` are the **kickoff tier**: the attended kickoff wires them when the
  repo is stood up (`skills/spec-foundation/SKILL.md`, `skills/adopt/SKILL.md`).
  `security-review` is the **autonomy tier**: it is wired **before any auto posture arms** —
  genesis wires all three at bootstrap (`decisions/2026-07-genesis-envelope.md`), and an
  already-standing attended project wires it as **preflight remediation** when `auto:feature` /
  `auto:run` hit the check-(b) gap. All three are still required **before auto**: the preflight
  asserts the full set and fails closed, and the security-review check is auto mode's
  compensating control for the classifier residual the human merge eyeball no longer covers
  (`decisions/2026-07-autonomy-modes.md`). Dropping a job to clear the gate is never the fix.

  **Recorded default implementation of the security-review job (as of 2026-07):** Anthropic's
  `claude-code-security-review` GitHub Action, run on every code PR and exposed under a status
  check named `security-review`. It is recorded as a **default that satisfies the contract, never
  a mandate** — any job asserting the same class of review (a per-PR security read of the diff,
  surfaced as a required status check) satisfies it, and the check name is config
  (`PREFLIGHT_REQUIRED_CHECKS`), not a vendor hardcode. `scripts/check-auto-preflight.sh` check
  (b2) additionally asserts the job's **content**, not just its name — a workflow under
  `.github/workflows/` that declares the check context and matches a review-implementation
  pattern (default `claude-code-security-review`; `PREFLIGHT_SECREVIEW_PATTERN` for a different
  in-Actions implementation; `PREFLIGHT_SECREVIEW_EXTERNAL=1` as a loud, named attestation for a
  non-Actions provider).

  **The proven concrete recipe (as of 2026-08, dogfooded live on keel's own repo —
  `specs/milestones/_landed` will carry `required-checks-live` once its wave archives).** An
  example shape that satisfies the contract, never a mandate:

  - **CI jobs as named contexts** — one job per required check name (a job per context, so
    branch protection can reference each): `verified-pin` (the pin gate: its self-test always,
    `check-verified-pin.sh HEAD` on `pull_request` with `BASE_REF=origin/${{ github.base_ref }}`
    and `fetch-depth: 0`), `plan-lint` (`check-plan.sh` + self-test), the project's own suite
    job(s), and `security-review`: the pinned action invoked with **a full commit SHA, never a
    tag** (a tag move must not swap the reviewer's code), the API key from a repo secret, and
    least-privilege `permissions:` (`contents: read` + `pull-requests: write`).
  - **Caveat from live dogfood:** the default action's per-PR cache can mask an
    environmentally-failed scan as a later hollow green (`claudecode-scan: skipped`); after any
    such failure, delete the PR's `claudecode-*` caches or confirm the scan executed before
    trusting a green (`specs/walks/2026-08-02-security-review-cache-mask.md` in keel records
    the incident and the deletion command).
  - **Protection, in two shapes matching the tier split.** The **kickoff-tier shape** requires
    exactly the contexts the kickoff wires (`verified-pin`, `plan-lint`, plus the project's own
    suite contexts) — **never a `security-review` context no job yet reports**, which would
    wedge every PR in the new repo. When the security-review job is wired — kickoff-optionally,
    or at auto-entry at the latest — its context is **added to the required set at that
    moment**. Both shapes share the rest: `required_status_checks.strict` (branches
    up-to-date — load-bearing for the pin gate's merge-mode claim), a PR required for every
    change (`required_pull_request_reviews` with zero required approvals — the checks are the
    reviewers), `enforce_admins` enabled, no push restrictions. Fork PRs cannot go green under
    a secret-backed required check — an accepted consequence, not a bug
    (`decisions/2026-08-01-required-checks-protection.md`).
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
