# Milestone — auto-m3-envelope-preflight: the auto-provision envelope and its hard entry gate

**Goal:** an unattended run can be provisioned *ahead of time* — provision documents the
auto-provision envelope (pre-authed CLIs, standing sandbox env-var library,
machine-to-machine secret flow, attended swap-after) — and a shipped preflight script makes
"the run won't die on an undrained prompt" checkable before launch instead of discovered
mid-run.

**Feature:** `specs/features/autonomy-modes.md`. **No-UI** → two-dimension done-conditions.
**Depends on:** `auto-m1-doctrine`. **Parallelizable:** with m2 (disjoint files).

## Done-conditions

### Logic / invariants
- [auto] `skills/provision/SKILL.md` gains an **auto-provision envelope** subsection
  (extending the existing unattended-run posture section in place — one owner) covering:
  (a) a user-level provisioning profile — CLIs pre-authenticated at account/org level with
  scopes sufficient to create project resources non-interactively, plus a standing library
  of sandbox/test env vars for common services; (b) secrets flow **machine-to-machine or via
  the user's `!` terminal, never through agent context** (existence checks by name, never
  value); (c) the **attended swap-after** pattern — placeholder/sandbox values are replaced
  with project-specific ones by the user after the run, inverting the attended sitting from
  before-the-run to cleanup-after; (d) the never-allowlist carve-out — resource-creation
  verbs allowed for auto runs only as a **provision envelope** recorded in the project's
  `decisions/`, with spend caps as the backstop; (e) the rationale — headless auto runs
  abort after repeated classifier blocks, so an undrained prompt kills the run.
- [auto] The generated-CLAUDE.md guidance in provision gains one line: auto runs launch only
  after `check-auto-preflight.sh` passes; a preflight failure is fixed attended, never
  worked around by widening permissions mid-run.
- [auto] New `scripts/check-auto-preflight.sh` (canonical implementation, copied into
  projects like the pin gate): (a) dry-runs a run **command inventory** (a committed list of
  the command shapes the run will execute) against the committed
  `.claude/settings.json` allowlist, reporting any shape no allow rule covers; (b) asserts
  via `gh api` that branch protection on the default branch exists and its **required**
  status checks include the verified-pin job, the plan-lint job, and a security-review job
  (names read from a small config block, not hardcoded to one CI vendor); (c) asserts every
  env-var **name** in the architecture contract resolves in the host env store — names,
  never values; (d) exits non-zero on any gap with each gap named (fails closed, including
  on missing `gh`/`jq` context).

### Behavioral completeness
- [auto] `scripts/check-auto-preflight.test.sh` covers: full pass; uncovered command shape;
  branch protection missing; a required check present-but-not-required; missing env name;
  degraded context (no `gh`) → fail closed.
- [auto] One-owner sweep: the envelope is stated in provision only (the decisions entry and
  README from m1 are not restated); the preflight's checks are implemented in the script
  only, described in prose once.
- [auto] `scripts/check-neutral.sh` exits 0 (provision + the new script are scanned corpus —
  the new script must be added to its scan targets if not already covered by the `scripts/`
  pattern) and `scripts/check-plan.sh` passes the corpus.

## verification
verifier subagent against this file (envelope prose greps a–e, one-owner sweep) +
`scripts/check-auto-preflight.test.sh` + `scripts/check-neutral.sh` + `scripts/check-plan.sh`
+ all existing script self-tests (no regression). **`/security-review` pre-pin** — this
milestone defines the secrets-flow and permission-envelope guidance (a hard-invariant
surface): the review attacks the secret-leak channels (agent-context exfiltration, value
echo in preflight output) and the carve-out wording; confirmed findings become test cases +
done-conditions before the pin.
