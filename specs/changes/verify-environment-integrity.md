# Change — verify-environment-integrity

One milestone, prose-only (one agent contract + two references + one skill).
Harvest-slate Unit 2 (Tier B, B1 + B2) from `specs/reviews/2026-07-18-harvest.md`
(lines ~104–140). B1 and B2 are one coherent contract — B2 is explicitly *downstream
of B1* in the corpus and the fix is a single guard — so they land as one milestone, not
two.

## Why (the defect)

The week's most expensive failures were verifications that rendered a runtime **verdict
for reasons unrelated to the code** — a poisoned local environment read exactly as a
code defect.

- **B1 — environment state masquerading as a code defect (three instances in one week).**
  BidLevel verified M1 against **uncommitted `supabase/config.toml` captcha blocks
  belonging to M3**, so M1's correctly token-less sends were rejected — *"an environment
  failure that reads exactly like a code defect."* Jarvis loaded a **hosted** service-role
  key against the **local** stack (a copied `.env.local`) — every DB test failed
  "permission denied." Relay's Release build crashed on a missing env var. In each, the
  running environment did **not** reflect committed code, and the verdict was rendered
  anyway.
- **B2 — reproduction count mistaken for confidence (the sharpest finding in the corpus).**
  Downstream of B1: a verifier reported "no 6-digit code found," **reproduced it 4×
  across dev+prod and new+existing users**, and concluded users had no code. The
  environment was poisoned; after a restart on committed config the same probe returned
  real codes immediately. The tell that distinguished a genuine reload was an
  **independent signal change** (an email subject changed) — **not** the repetition.
  Reproducing a failure N times inside one un-restarted, poisoned environment is worth
  nothing; N poisoned reads are one poisoned read. This *inverts an assumption the whole
  verification model rests on*: that a reproduced failure is a confident one.

The two share one root: a `[runtime]`/environment-dependent **negative** verdict was
permitted to stand without first proving the running environment reflects committed
state.

## The fix (the contract)

Before a verifier (or the runtime walk) renders a `[runtime]`/environment-dependent
**negative** finding, it must:

1. **Assert the working tree is CLEAN for the stack profile's declared service-config
   paths.** Uncommitted changes to the config the running services read (the local-stack
   config, the env-derivation source) mean the environment does not reflect committed
   code. A dirty tree there is the environment poisoned — classified environment, never a
   code discrepancy.
2. **Establish an independent POSITIVE CONTROL that the environment reflects committed
   state.** Probe the gate rather than trusting a CLI start banner: restart the service,
   hit the endpoint, expect a real response — and require an **independent signal to
   change** (the B2 tell), never a repetition to recur. Only once that control has gone
   from absent/stale to present may a negative `[runtime]` finding stand.

keel is stack-neutral, so the **specifics are declared by the stack profile** (which
paths count as service-config; which independent signal + probe proves a genuine reload);
the **requirement itself is the spine's** — the verifier contract and the shared
verification rules mandate it, and `verify-milestone` runs it.

## Decisions taken

- **The profile declares the two specifics (a new profile question).**
  `references/profile-interface.md` gains a verification-integrity question (Q14, or an
  equivalently-discoverable placement) with two declarations: (a) the **service-config
  paths** whose uncommitted state poisons a runtime verdict, and (b) the **positive-control
  probe** — the independent signal and the restart/probe recipe that prove the environment
  reflects committed state. Derived at spec time (which paths, which signal), the exact
  restart/probe commands **finalized at provision** like Q12's provision-owned parts. A
  scar note records the B2 case (reproduction count is not confidence).
- **The spine rule feeds off the profile, in the two neutral homes.**
  `references/milestones-and-verification.md` (§3, the runtime-walk/verification rules)
  states the requirement authoritatively; `agents/verifier.md` carries it as a ground rule
  in the environment-classification family (beside "classify infra-shaped failures as
  environment" and "the profile is runtime ground truth"). Both defer the specifics to the
  profile.
- **`verify-milestone` runs it.** Step 4 (substrate preflight) asserts the clean tree for
  the declared service-config paths; the Verdict section gates a negative
  `[runtime]`/environment-dependent finding on the positive control, classifying a
  control-less negative finding as environment, not a discrepancy.
- **Scope is `[runtime]`/environment-dependent NEGATIVE findings only.** Never
  `[auto]`/static findings (they don't depend on the running environment), and **never a
  clean pass** — a passing runtime walk already exercised the environment; the positive
  control is the price of a *negative* runtime verdict, not of every verdict. This carve-out
  is stated in every one of the four edited sites so no reader over-applies it.
- **The B2 tell is stated explicitly, not implied.** An **independent signal change**
  certifies a genuine reload; a **repetition does not**. This one sentence is what B2 adds
  on top of B1's clean-tree assertion, and it is anchored so a reword can't drop it.

## Deliberately not in scope

- **B3 (`reuseExistingServer` / stale-server / `next start` never rebuilds).** A separate
  slate unit (`spec-change`, runtime-proof contract) — the stale-build variant of a
  poisoned environment, but its fix is the build/serve procedure, not the negative-finding
  guard. Not touched here.
- **No script, hook, gate, or template moves.** keel's standing suites already assert
  what a prose contract needs; the only new committed artifact is this feature's
  prose-anchor file (below). The clean-tree assertion and positive control are *per-project*
  (the profile supplies them), so there is no keel-level script to author.
- **No renumbering or relocation of existing profile questions.** Q14 appends; Q1–Q13 and
  every cross-reference to them are untouched.

## Milestone

`specs/milestones/verify-environment-integrity.md` — edits `agents/verifier.md`,
`references/profile-interface.md`, `references/milestones-and-verification.md`,
`skills/verify-milestone/SKILL.md`, and adds
`scripts/skill-anchors/verify-environment-integrity.txt` (positive anchors on the four new
mandate sentences; file-per-feature per the §4 no-shared-file rule).

## Integration seams (must stay coherent across the four sites)

- **The scope carve-out** ("negative `[runtime]`/environment-dependent findings only —
  never `[auto]`/static, never a clean pass") must read identically in intent at all four
  sites; a site that states the mandate without the carve-out would over-apply it (the
  positive control becoming the price of every pass is a real regression).
- **The authorship split** ("profile supplies the paths + probe; the requirement is
  keel's") must be consistent — the two references and the verifier defer specifics to the
  profile; the profile declares specifics and does not restate the spine mandate as its own
  rule.
- **Q14's provision-finalized parts** join Q12/Q13's authorship pattern (derived at spec
  time, restart/probe commands finalized at provision) — the "finalized at provision"
  language must match, so a derivation session records a placeholder rather than inventing
  commands.
