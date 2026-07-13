# Milestone — isolation-contract

Feature context: `specs/features/worktree-isolation.md` (milestone 1 of 2). One
milestone, prose-only; edits `references/profile-interface.md`,
`skills/spec-foundation/SKILL.md`, `skills/adopt/SKILL.md`,
`skills/provision/SKILL.md`. No scripts, gates, hooks, or templates move. Integration
seams: Q13 lands after Q12 and reuses Q12's vocabulary (the port block / project
identity it derives from, the env re-derivation command it parameterizes) by
reference, never restating Q12's content; the spine's serialization rule in "What
stays in the methodology" gains a conditional clause — the serial default must remain
the stated default, and the existing "(Q12; informs Q3–Q6)" pointer stays; the
spec-foundation/adopt question lists and provision step 6 were edited by
substrate-contract and testing-doctrine this cycle — the new sentences land adjacent
to, without altering, the Q12 and §8 sentences; provision's proof follows the same
prove-it-once pattern as step 7's ladder rungs and Q12's health checks.

## Done-conditions

- [auto] **Q13 exists in the profile interface.** `references/profile-interface.md`
  gains **Q13 — Parallel-session (worktree) isolation contract** after Q12 (before
  "What stays in the methodology"), asking the project to record: (a) **instance
  identity** — how instance N derives its own port block / project identity from
  Q12's base, collision-free against sibling instances and other projects; (b) the
  **datastore isolation recipe** — a branch/namespace/schema/container per instance,
  seeded per Q5, writes in one instance invisible to the others; (c) **per-instance
  env derivation** — Q12's env command parameterized by instance identity, producing
  the worktree's own env file; (d) **teardown** — one command returning instance N's
  resources, run on **every** exit path including a crashed/failed session (a leaked
  instance is a named signature: Q12's table gains a leaked-instance row); (e)
  **allocation** — instance identity is ephemeral and claimed per session: workflows
  assign it by dispatch index, an attended session probes before claiming; (f) the
  **proven flag** — the contract is unproven until a sitting has run two simultaneous
  instances green (both health checks green at once, one instance's writes invisible
  to the other), recorded as `proven at <date>`; an unproven or absent contract
  changes nothing; and the flag proves the *recipe class* only — Q13 states that
  **every per-instance run opens with an instance-scoped substrate assertion**
  (health green + these-ports-are-instance-N's, the Q12 preflight parameterized by
  identity), and a failed assertion is classified environment/blocked, never walked
  against — the silent-fallback-to-shared-ports scar re-checked per run. The stated
  default answer is **"not provided — runtime-proof stays serial"**, and the question
  is recorded as finalized-at-provision like Q12's provision-owned parts.
- [auto] **Web-reference answers, stack-neutral.** Q13 gives web-reference example
  answers (as Q8/Q11/Q12 do), hardcodes no stack, and `scripts/check-neutral.sh`
  passes.
- [auto] **The spine's serialization rule gains exactly one conditional clause.** In
  "What stays in the methodology", the "Runtime-proof runs serially against shared
  local singletons" line states the condition under which it relaxes: a profile
  carrying a Q13 contract **marked proven** lets each parallel session stand up its
  own instance per that contract — and serial remains the default for every other
  case (no Q13, unproven Q13, or a stack that answered "not provided"). No other
  spine rule changes.
- [auto] **No duplication of Q12 — and Q12's signature row is scoped.** Q13
  references Q12's port-block/identity and env command; it does not restate their
  definitions. Q12's text is unchanged except (at most) one forward pointer to Q13
  **and** its gateway-502 example remedy row rescoped to "a second **unisolated**
  stack is running; stop it" — so on a proven-Q13 project the remedy no longer
  instructs killing a legitimate sibling instance (debug and demo consume that row
  by reference and need no edit).
- [auto] **The derivation verbs pick Q13 up.** `skills/spec-foundation/SKILL.md`'s
  Stack-profile question list and `skills/adopt/SKILL.md`'s stack-profile item each
  gain the isolation contract (Q13), recorded as finalized-at-provision — adjacent
  to, without altering, their existing Q12 and §8-smell sentences.
- [auto] **Provision authors and proves Q13, opt-in.** `skills/provision/SKILL.md`
  states (in or adjacent to step 6's Q12-finalization prose, one owner): Q13 is
  **asked, not assumed** — the user opts in (or the stack's answer is "not
  provided"); when opted in, provisioning authors the recipe parts and **runs the
  two-instances proof once green** (stand up a second instance alongside the primary
  — both health checks green simultaneously, a write in one invisible to the other —
  then tear the second down) and records `proven at <date>` in the profile. A
  contract authored but not proven is recorded as unproven and changes nothing.
- [auto] **Step 6's mitigation gains the same conditional.** The "one local backend
  stack at a time" sentence in provision step 6 is scoped: concurrent **unisolated**
  stacks remain the flake shape (the scar's mechanism is shared ports/gateways —
  exactly what Q13's per-instance identity removes); concurrent instances **per a
  proven Q13 contract** are the carve-out, and the two-instances proof is itself the
  per-project test of whether the mitigation can be lifted. An agent obeying step 6
  verbatim must no longer refuse the proof it is running. Single-stack remains the
  default for every non-proven case.
- [auto] **Repo checks green.** `claude plugin validate --strict .`,
  `scripts/check-neutral.sh`, `scripts/check-plan.sh`,
  `scripts/check-skill-frontmatter.sh`, `scripts/check-skill-anchors.sh`, and every
  `scripts/*.test.sh` pass on the branch.

## verification

verifier subagent against this file's done-conditions (all `[auto]`; prose-only —
closable by reading the named files and running the named checks).

verified: clean at b65b807, 2026-07-13, via verifier subagent against this spec's done-conditions — all 8 conditions evidenced with file:line, diff exactly the 4 named files with milestone-2 files untouched, 5 repo checks + 11 script self-tests green (evidence in PR #123)
