# Milestone — substrate-contract

Change context: `specs/changes/substrate-contract.md`. One milestone, prose-only; edits
`references/profile-interface.md`, `skills/provision/SKILL.md`,
`skills/spec-foundation/SKILL.md`, `skills/adopt/SKILL.md`,
`skills/implement-milestone/SKILL.md`, `skills/verify-milestone/SKILL.md`,
`skills/debug/SKILL.md`, and the verifier prompt string in
`workflows/verify-all-milestones.js`. No scripts, gates, hooks, or templates move.
Integration seams: profile-interface's "What stays in the methodology" section (the
serialization rule lives there — Q12 must not duplicate it); provision step 6's
existing flake-mitigation prose (Q12 extends it, one owner — the mitigations stay in
step 6, the *contract* is Q12's) and step 7's prove-the-ladder-once (the budgets'
recording moment); implement-milestone's orient step was just edited by status-verb
(the preflight sentence lands adjacent to, not inside, the `status`-skill pointer);
verify-milestone's environment-classification rule (the preflight routes *to* it, not
around it); spec-foundation's generated-CLAUDE.md build-start protocol mirrors the
orient step and must stay in sync.

## Done-conditions

- [auto] **Q12 exists in the profile interface, timeout rule included.**
  `references/profile-interface.md` gains **Q12 — Local substrate contract** (after
  Q11, before "What stays in the methodology"), asking the project to record: (a) the
  shared local singletons and a **one-line health check** per singleton; (b) the
  project's **unique port block / project identity**, collision-free against the
  user's other projects; (c) the **canonical invocation path** for the local stack
  (where its config discovery actually works); (d) the **env re-derivation command**
  (naming provision's environment-contract line as its source); (e) a
  **known-failure-signature table** (signature → classified remedy) that accretes like
  scars; (f) **per-suite duration budgets** for the Q11 tiers and the runtime walk,
  **with the timeout rule stated here as the single owner**: any suite/walk command
  runs bounded — exceeding roughly 2× its recorded budget means kill and classify as
  environment (signature table first), never an open-ended wait; long suites run
  backgrounded with periodic progress checks where the harness supports it. Carries
  ⚠ notes generalizing the recorded incidents: config-discovery silently falling back
  to another project's ports; a daemon stalled on an interactive prompt reading as a
  hung run; an unbounded status/suite command waiting hours.
- [auto] **Q12 states the authorship split.** Q12's prose says which parts are
  *derived* at spec time (the structural answers — singletons, invocation path) and
  which are **finalized at provision** (ports/identity assignment, env command,
  signature seeding, duration budgets, the proven-green health check) — so a derived
  profile carrying "finalized at provision" placeholders for those is well-formed, not
  incomplete.
- [auto] **Web-reference answers, stack-neutral.** Q12's prose gives *web reference*
  example answers (as Q8/Q11 do) and hardcodes no stack: `check-neutral.sh` still
  passes.
- [auto] **No duplication of the methodology rules.** Q12 does not restate the
  serial-runtime-proof rule or step 6's mitigation shapes — it references them; the
  "What stays in the methodology" section is unchanged except (at most) one pointer to
  Q12.
- [auto] **The derivation verbs pick Q12 up.** `skills/spec-foundation/SKILL.md`'s
  Stack-profile paragraph's enumerated question list and `skills/adopt/SKILL.md`'s
  stack-profile item's enumerated question list each gain the substrate contract
  (Q12), so a fresh derivation session cannot skip it; both make clear the
  provision-finalized parts are recorded as such at derivation time, not invented.
- [auto] **Provision authors and proves the contract.** `skills/provision/SKILL.md`
  step 6 states that provisioning **finalizes Q12** in the stack profile — assigns the
  unique ports/identity, records the canonical invocation path and the env
  re-derivation command, seeds the failure-signature table with the known shapes — and
  **runs each singleton's health check green once** before the sitting ends; the
  per-suite duration budgets are recorded from step 7's prove-the-ladder-once timings
  (step 6 or step 7 may carry that sentence, one owner).
- [auto] **Entry preflight at both build/verify verbs, before anything runs.**
  `skills/implement-milestone/SKILL.md`'s orient step and
  `skills/verify-milestone/SKILL.md`'s **Dispatch entry — before step 4 runs the
  committed suites** — each state: run the profile's Q12 substrate health check first
  (seconds — daemon responsive, ports owned by this project's stack, toolchain
  resolves, env file present or re-derived via the recorded command); a red substrate
  is a **stop-point routed to the Q12 signature table's remedy** (or classified as
  environment per the existing rule), never absorbed into the milestone and never
  debugged ad hoc mid-build. The status-verb pointer sentence and the cheapest-rung
  baseline in the orient step are unchanged.
- [auto] **The timeout rule has pointers everywhere suites run, restated nowhere.**
  One-line pointers to Q12's timeout rule (no restated thresholds) exist in:
  `skills/verify-milestone/SKILL.md`'s hard rules, `skills/implement-milestone/SKILL.md`'s
  self-check/ladder step (step 5), `skills/debug/SKILL.md`'s reproduce step, and the
  verifier prompt string in `workflows/verify-all-milestones.js` (its suite-running
  instructions). Grepping the four files finds exactly one Q12-timeout pointer each
  and no duplicated "2×" threshold outside `references/profile-interface.md`.
- [auto] **The generated project protocol stays in sync.**
  `skills/spec-foundation/SKILL.md`'s generated-CLAUDE.md **build start protocol**
  bullet gains the same one preflight line (run the profile's Q12 substrate health
  check before the green-baseline rung), so projects generated after this change
  match the verbs.
- [auto] **debug consults the table by name.** `skills/debug/SKILL.md`'s
  "consult the project's accumulated learnings first" rule names the stack profile's
  Q12 failure-signature table as one of the sources to check before diagnosing.
- [auto] **Repo checks green.** `claude plugin validate --strict .`,
  `scripts/check-neutral.sh`, `scripts/check-plan.sh`,
  `scripts/check-skill-frontmatter.sh`, `scripts/check-skill-anchors.sh`, and every
  `scripts/*.test.sh` pass on the branch.

## verification

verifier subagent against this file's done-conditions (all `[auto]`; prose-only —
closable by reading the named files and running the named checks).
