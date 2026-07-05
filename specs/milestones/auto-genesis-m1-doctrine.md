# Milestone — auto-genesis-m1-doctrine: the genesis envelope + the template contract

**Goal:** the doctrine amendment that authorizes genesis Phase 2, and the committed template
contract the bootstrap generates against, exist as reviewable plan artifacts — before any skill
or guard implements them.

**Feature:** `specs/features/auto-genesis.md`. **No-UI** → two-dimension done-conditions.
**Depends on:** nothing in this feature (first). **Parallelizable:** no (m2 cites both artifacts
by name).

## Done-conditions

### Logic / invariants
- [auto] A new append-only `decisions/2026-07-genesis-envelope.md` amends the autonomy doctrine
  **by reference** (it does not edit `2026-07-autonomy-modes.md` or the capability ledger in
  place) and states: (a) under `keel:auto genesis`, the human's **skeleton approval is the
  authorization trail** for a bounded Phase 2 envelope — `gh repo create` (one private repo),
  branch-protection + required-checks configuration, CI/allowlist/spec seeding per the template
  contract, and the dev-resource creations the approved service inventory names; (b) the
  envelope is bounded by the standing capped sandbox keys (`~/.config/keel/sandbox.env`,
  **names only — no session ever reads or prints key values**), formalizing
  spend-caps-as-authorization as keel doctrine rather than a per-project decision; (c) the
  **never-auto list is unchanged** and quoted (go-live, live-key swaps, spend beyond caps,
  `--dangerously-skip-permissions` banned outright); (d) rejection at the approval gate ends
  the flow with nothing created; (e) the residual (an approval artifact authorizing later
  scripted actions is forgeable the same way the mode file is) names
  `specs/deferrals/mode-file-binding-ttl.md` as the shared concern and the server-side required
  checks as the standing backstop.
- [auto] A new `references/template-contract.md` defines the two-tier contract a generated (or
  future forked) repo must satisfy to pass `scripts/check-auto-preflight.sh` on first run:
  **tier 1, invariant** — the three required-check CI jobs (`verified-pin`, `plan-lint`,
  `security-review`) wired and *required* in branch protection; a committed
  `.claude/settings.json` covering the core command inventory; the `specs/` scaffold with an
  architecture env-contract **section to fill** (never pre-filled keys); **tier 2, prunable
  stack scaffold** — declared per-project from the approved skeleton's service inventory, with
  the prune rule stated as a checkable condition ("the app builds and boots with only the
  declared services; no reference to a pruned service remains"). The contract states the
  asymmetry explicitly: strict on gates, loose on stack — an unused sandbox key is never an
  error because the preflight checks only names the project's own architecture doc declares.
- [auto] A new `specs/deferrals/genesis-template-repo.md` parks the fork-based template repo:
  what it would buy (faster, pre-proven bootstrap), why deferred (build the contract first,
  dogfood generate-from-scratch, then freeze the proven output as the template), and its
  reopen condition (first successful genesis dogfood run).
- [auto] `scripts/check-neutral.sh` and `scripts/check-plan.sh` pass on the repo with all three
  files present; no skill, script, hook, or guard behavior changes in this milestone.

### Behavioral completeness
- [auto] The decisions entry and the template contract each carry the cross-references the
  later milestones cite: the decisions entry names `references/template-contract.md` and the
  genesis posture in `skills/auto/SKILL.md` (forward reference acceptable — m2 lands next);
  the contract names `scripts/check-auto-preflight.sh` checks (a)–(d) as the machine gate it
  satisfies, including the `allow_auto_merge` assertion the auto-hardening feature adds.
- [auto] `claude plugin validate --strict .` passes; every pre-existing self-test suite still
  passes (prose-only milestone, scripts untouched).

## verification
verifier subagent against this file — each artifact present with every enumerated element
((a)–(e) in the decisions entry; both tiers + the asymmetry + the prune rule in the contract;
the deferral's reopen condition), the by-reference discipline (prior decisions files
byte-unchanged), the names-only key invariant stated, and the never-auto list quoted intact. A
doctrine amendment that widens an envelope is invariant-adjacent prose: the verifier
additionally attacks it with "does any sentence here weaken the verified-pin gate, the human
merge authority, or the never-auto list?" — but no code mechanism changes, so no
`/security-review` (that gate belongs to m3, where a guard's decision surface actually changes).
