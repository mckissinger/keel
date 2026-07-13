# Milestone — parallel-runtime-verification

Feature context: `specs/features/worktree-isolation.md` (milestone 2 of 2; builds only
after `isolation-contract` is merged — it cites Q13's landed text; sequential via
`main`, never stacked). Edits `workflows/verify-all-milestones.js` (prompt strings,
whenToUse, mergeOrder, the shared-state sentence, **and the orchestrator's
brief-assembly code/schema**), `agents/verifier.md`,
`references/milestones-and-verification.md`, `skills/verify-milestone/SKILL.md`,
`skills/implement-feature/SKILL.md` (step **and** frontmatter description),
`skills/punch-list/SKILL.md`. No gates or guards move. Integration seams: the sweep's
**fail-safe is the load-bearing thing** — `blocked` for every `[runtime]` milestone
remains the behavior in every case except the one newly-enabled path, and the
"Do NOT return clean for a surface/action milestone" instruction survives verbatim on
that default path; the condition's full statement is owned by the profile interface
(Q13, landed by `isolation-contract`) — the files here point at it; the sweep's
per-instance walk is **scoped** (activation + exploratory; fidelity only under a
headless Q8.4 driver; Q7 live conditions always serial-blocked — the spend envelope
is provisioned serial-sized).

## Done-conditions

- [auto] **The sweep's runtime closure is conditional, fail-safe preserved.** In
  `workflows/verify-all-milestones.js`, the verifier prompt states: `[runtime]`
  conditions may be closed **only when** the runtime brief passed by the orchestrator
  declares (a) the profile's Q13 contract **marked proven**, (b) a headless
  activation driver (Q3), and (c) the per-instance recipe (identity assigned by the
  orchestrator per dispatch index, env command, teardown) quoted into the prompt — in
  which case the verifier claims its assigned instance, **opens with the
  instance-scoped substrate assertion** (health green + these-ports-are-instance-N's;
  a failed assertion → classified environment, verdict `blocked`, never a walk
  against whatever answered), runs the scoped walk against its own instance, and
  **tears it down on every exit path, including failure**. In **every other case**
  the existing behavior is verbatim-preserved: `blocked`, those conditions
  unverified, "Do NOT return clean for a surface/action milestone".
- [auto] **The walk is scoped in the prompt.** The per-instance walk covers
  activation (dev + prod build) + the exploratory pass; the vision/fidelity diff
  joins **only when the brief declares the Q8.4 driver headless-capable**; **Q7
  capped-key live conditions are never closed by the sweep** (serial-sized spend
  envelope) — a fidelity condition without a headless driver, or any live condition,
  returns `blocked` for the serial path exactly as today.
- [auto] **The orchestrator assembles the brief in code.** The workflow's discovery
  schema/phase gains the Q13 fields (proven flag, recipe, Q3/Q8.4 headless-ness)
  read from `specs/stack-profile.md`, and the per-milestone prompt template includes
  the brief only when Q13 is present, proven, and not "not provided" — omitting it
  forces the blocked path. Instance identity is assigned per dispatch index by the
  template/code, never self-chosen by the verifier.
- [auto] **The stale shared-state sentence is conditioned.** The prompt's "shared
  local services carry the stack head's state … never reset or mutate shared state"
  passage applies verbatim on the default path and is explicitly superseded on the
  per-instance path (the instance carries this checkout's seeded state; the verifier
  may reset/seed **its own instance** freely and must not touch the shared primary).
- [auto] **The verifier agent gains a bounded instance-scoped mutation license.**
  `agents/verifier.md` states: read-only everywhere, **except** when the dispatching
  prompt passes a proven Q13 instance recipe — then the verifier may create, seed,
  reset, and tear down **only its own instance's resources** (its worktree's env
  file, its datastore branch/namespace, its assigned ports/processes), never the
  shared primary, never the repo's tracked files; teardown on every exit path. The
  Edit/Write disallow stays for tracked files; the license names the env-file write
  as its one file-write shape.
- [auto] **The canonical reference's three statements gain the conditional.** In
  `references/milestones-and-verification.md`: §2's "cannot close
  [runtime]/[attended] … never by the sweep", §3's "not the parallel
  verify-all-milestones sweep", and §7's `[auto]`/`[runtime]` tag definitions each
  carry the one-clause conditional (the sweep closes `[runtime]` per-instance under
  a proven Q13 contract, scoped per this milestone; `[attended]` stays human,
  unconditional). No other section changes; serial remains the stated default.
- [auto] **verify-milestone's sweep paragraph and carve-out are reconciled.** The
  "For sweeping many milestones at once" paragraph states the conditional (the
  shared-DB reason stays as the why for the default case); the serial walk remains
  canonical for fidelity-without-headless-driver and live conditions; and the
  "One carve-out unique to this serial path" phrasing is reworded to cover the
  runtime-capable paths (any path that stands up its own services may retry after a
  classified resource fix; the plain read-only verifier still may not).
- [auto] **implement-feature parallelizes conditionally, frontmatter included.** Its
  "Verify in a fresh context" step states: `[runtime]` verification runs serially
  **unless** the profile carries a proven Q13 contract, in which case each verifier
  subagent claims its own instance per the contract and `[runtime]` milestones
  verify in parallel; and the frontmatter `description`'s "([auto] parallel,
  [runtime] serial)" phrase is reworded to match (e.g. "[runtime] serial unless the
  profile's isolation contract is proven"). The cadence-ask and merge rules are
  untouched.
- [auto] **punch-list points at the same conditional.** Its `[runtime]`-items note
  cites the proven-Q13 condition instead of restating it (one pointer, serial as
  fallback).
- [auto] **One owner for the condition.** Q13's full statement lives in the profile
  interface; grep finds no restatement of Q13's recipe parts outside
  `references/profile-interface.md` and the workflow's orchestrator brief (which
  quotes the *project's* recorded recipe at run time, not the interface's
  definition).
- [auto] **Repo checks green.** `claude plugin validate --strict .`,
  `scripts/check-neutral.sh`, `scripts/check-plan.sh`,
  `scripts/check-skill-frontmatter.sh`, `scripts/check-skill-anchors.sh`, and every
  `scripts/*.test.sh` pass on the branch.

## verification

verifier subagent against this file's done-conditions (all `[auto]`; prose + prompt
strings + bounded workflow code — closable by reading the named files and running the
named checks).

verified: clean at 08a2c14, 2026-07-13, via verifier subagent against this spec's done-conditions — all 11 conditions evidenced with file:line, default fail-safe paths proven byte-identical to main by extracted-string diff, node --check green, 5 repo checks + 11 script self-tests green (evidence in PR #124)
