# Feature — worktree-isolation (the parallel-session contract)

Slate group G item 14, approved by Michael 2026-07-12 — flagged across the reviews as
"the one real feature candidate" (`specs/reviews/2026-07-12-skill-mining.md`
§"Already-parked roadmap" item 3). Two milestones, prose + one workflow. No UI
(two-dimension done-conditions throughout; no composition, no review-feature gate).

flow research: skipped — no user-facing flow (methodology prose + a workflow script).

## The problem

The runtime-proof is keel's slowest **serial** section, by rule: "Runtime-proof runs
serially against shared local singletons" (the spine, stated in
`references/profile-interface.md` §"What stays in the methodology" and applied in
`skills/implement-feature/SKILL.md` and `workflows/verify-all-milestones.js`). The
rule is correct **today** because nothing records how a second session could get its
own stack: the parallel sweep's worktrees share one local DB/dev server, so it must
return `blocked` for every `[runtime]` milestone, and implement-feature must verify
`[runtime]` milestones one at a time. A wave of N milestones pays N serial runtime
walks while N idle worktrees wait.

The corpus also shows the *absence* of an isolation recipe biting attended sessions:
ports held by another project's stack, a second session's suite talking to the first
session's database. Q12 (the substrate contract) fixed cross-*project* collision; this
feature fixes cross-*session* collision inside one project — and turns the fix into
parallel runtime verification.

## The shape — a contract, opt-in, proven before trusted

A new profile question records **how to stand up instance N of the local stack,
isolated**, and the serial rule relaxes **only** where that contract is recorded *and
proven*. Stacks that can't isolate cheaply (single-socket daemons, licensed
simulators) answer "not provided" and everything behaves exactly as today — the serial
rule is the permanent safe default, not a legacy mode.

**Q13 — Parallel-session (worktree) isolation contract**, after Q12:

- **Instance identity**: how instance N derives its own port block / project identity
  from Q12's base assignment (e.g. base+offset), collision-free against sibling
  instances and other projects.
- **Datastore isolation recipe**: how an instance gets its own datastore state — a
  branch/namespace/schema/container per instance, seeded per Q5 — such that writes in
  one instance are invisible to the others.
- **Per-instance env derivation**: the Q12 env re-derivation command, parameterized by
  instance identity, producing the worktree's own env file.
- **Teardown**: the one command that returns instance N's resources (ports, datastore,
  processes).
- **Instance allocation is ephemeral, claimed per session**: workflows assign
  instance identity by dispatch index; an attended session probes before claiming;
  teardown runs on **every** exit path (a crashed session's leaked instance is a
  named failure signature in Q12's table).
- **The proven flag**: the contract is *unproven* until a sitting has run **two
  simultaneous instances green** (both health checks green at once, one instance's
  writes invisible to the other) — recorded as `proven at <date>` in the profile.
  An unproven contract changes nothing anywhere. The flag proves the *recipe class*;
  **every per-instance run still opens with an instance-scoped substrate assertion**
  (health green + these-ports-are-instance-N's) so a rotted recipe that silently
  falls back to the shared primary is caught per-run, never walked against.
- Default answer: **"not provided — runtime-proof stays serial"**; derivation records
  it as finalized-at-provision like Q12's parts.

**Owned contradictions** — the texts that today assume single-instance, each gaining
the same proven-Q13 conditional (serial/single-instance stays the default): the
spine's serialization rule; provision step 6's "one local backend stack at a time"
mitigation (the scar's mechanism — *shared* ports/gateways — is exactly what Q13
removes; concurrent *unisolated* stacks remain the flake shape); Q12's
gateway-502-signature remedy row (scoped to "a second **unisolated** stack");
`references/milestones-and-verification.md`'s three sweep-cannot-close-runtime
statements (§2, §3, §7); `agents/verifier.md`'s read-only charter (a bounded
instance-scoped mutation license when dispatched with a proven recipe);
implement-feature's frontmatter "[runtime] serial" phrase; verify-milestone's
"unique to this serial path" carve-out phrasing.

## What the sweep's per-instance walk covers — scoped, conservative

The newly-enabled sweep closure covers **activation (dev + prod build) + the
exploratory pass** per-instance; the **vision/fidelity diff** joins only when the
profile's Q8.4 driver is declared headless-capable; **Q7 capped-key live conditions
always stay serial-blocked** (the spend envelope is provisioned serial-sized — N
simultaneous draws would exhaust it mid-wave and turn later milestones red). A
fidelity- or live-shaped condition outside the covered set returns `blocked` for the
serial path exactly as today.

## Milestones (sequential via main — m2 builds only after m1 is merged; never stacked)

1. **`isolation-contract`** — the contract exists and is provable:
   `references/profile-interface.md` (Q13 + the spine rule's conditional + the Q12
   signature-row scoping), `skills/spec-foundation/SKILL.md` + `skills/adopt/SKILL.md`
   (derivation lists), `skills/provision/SKILL.md` (opt-in authoring, the
   two-instances-green proof, the step-6 mitigation conditional).
2. **`parallel-runtime-verification`** — the contract is consumed:
   `workflows/verify-all-milestones.js` (conditional closure — prompt strings,
   whenToUse, mergeOrder, the shared-state sentence, and the orchestrator's
   brief-assembly code/schema), `agents/verifier.md` (bounded instance-scoped
   mutation license), `references/milestones-and-verification.md` (§2/§3/§7
   conditionals), `skills/verify-milestone/SKILL.md` (sweep paragraph + carve-out
   phrasing), `skills/implement-feature/SKILL.md` (step + frontmatter phrase),
   `skills/punch-list/SKILL.md` (pointer).

## Lifecycle

- Plan PR (this spec + both milestone specs) — merged by Michael.
- `isolation-contract`: built (fresh context) → verified (pin + code PR) → merged.
- `parallel-runtime-verification`: built → verified (pin + code PR) → merged.
- Post-wave consolidated check: the full check suite green on `main` after both
  merges (the repo's checks are its suite; evidence: the second code PR's CI on the
  merged base).
- Spec reconciliation: feature spec updated to merged reality + both milestone specs
  archived to `specs/milestones/_landed/` in one plan-only commit (land-feature's
  reconciliation step).
- No review-feature gate (no UI); feature closes when both pins are on `main` and a
  release bump surfaces them.
