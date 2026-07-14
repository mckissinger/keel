# Change — env-check-preflight

One milestone, prose-only (one reference + four skills). Approved by Michael 2026-07-14
in direct response to a recurring incident diagnosed from a `bidlevel` build session:
the session's entry preflight attempted to read `.env.local`, the permission posture
denied it (correctly — `.env*` is exactly what sensitive-file protections deny), and
the session improvised a workaround ("I'll check env-var names a different way"). This
recurs across keel projects because the contract implies an assertion whose obvious
implementation is the one read the permission posture blocks.

## Why (the causal chain)

1. Q12's entry preflight and the env bullets across the verbs assert env-file
   presence/completeness ("env file present or re-derived", "bare env-var-name
   existence — never read values") but name **no mechanism** for the name check.
2. The obvious mechanism — reading the env file — is denied by default permission
   postures, so every build/verify session pays a denial plus an improvised
   workaround, per session, per project.
3. The improvisation is the real risk: some obvious alternatives (`cat` via Bash,
   `printenv`, sourcing the file) pull **values** into the transcript — the exact
   exposure the names-only rule exists to prevent. A safety rule whose compliant
   implementation is improvised under a denial is the pattern keel exists to remove.
4. Keel already owns the correct mechanism in one place: `check-auto-preflight.sh`'s
   section (c) asserts contract env-var names against the host env and the env file,
   names only, values never read out — but it is the **auto-run** gate; the attended
   entry preflight has no recorded equivalent.

## Decisions taken

- **Q12 records a committed env name-check command.** The substrate contract gains a
  bullet: the one command that asserts every contracted env-var **name** resolves
  (host env store or local env file), reporting names/status only — **values never
  appear in its output**. Finalized at provision like the env re-derivation command
  (the derivation may record it as a "finalized at provision" placeholder). The
  command's implementation is stack-appropriate (a package script, the stack's own
  env-schema validation at boot, a small committed script shaped like
  `check-auto-preflight.sh`'s section (c)) — keel records the command, never mandates
  the implementation.
- **The direct-read ban is stated where the preflight lives.** Sessions never read
  `.env*` directly — the permission denial is the posture working, not an obstacle to
  route around; the recorded name-check command is the sanctioned path. Stated in
  Q12 and in the two entry-preflight sentences (implement-milestone step 1,
  verify-milestone step 4), which gain "env-var names asserted via the recorded
  name-check command" alongside the existing presence/re-derivation clause.
- **Provision authors the command alongside the recipe it already owns.** Step 3
  (which records the env re-derivation recipe) also authors/records the name-check
  command; step 6's finalized-at-provision list carries it with the other Q12 parts.
- **A seeded signature row makes the denial self-remedying.** Q12's known-failure
  example rows gain: "permission denial on a `.env*` read → working as intended;
  run the recorded env name-check command instead" — so a session that hits the
  denial anyway is routed mechanically, never improvising.
- **spec-foundation's run-preflight clause aligns.** Its "bare env-var-name existence
  otherwise — never read values" gains "via the profile's recorded name-check
  command" so the same improvisation gap doesn't survive there.

## Revisions from the adversarial plan pass

- The Q12 provision-finalized enumeration is restated in **two derivation lists** the
  draft missed — `skills/spec-foundation/SKILL.md`'s "finalized at provision" parts
  list and `skills/adopt/SKILL.md`'s equivalent — both now owned by a done-condition
  (and `adopt` joins the milestone's file list), so a derivation session records a
  placeholder for the name-check command like the other provision-finalized parts.
- The "word-parallel" obligation on the two entry-preflight sentences was undecidable
  whole-sentence (their lead-ins and tails legitimately diverge today): rescoped to
  the parenthetical span the two files actually share word-identically, which is where
  the name-check clause lands.

## Milestone

`specs/milestones/env-check-preflight.md` — edits `references/profile-interface.md`,
`skills/provision/SKILL.md`, `skills/implement-milestone/SKILL.md`,
`skills/verify-milestone/SKILL.md`, `skills/spec-foundation/SKILL.md`,
`skills/adopt/SKILL.md`. No scripts
move (`check-auto-preflight.sh` section (c) already conforms and stays the auto-run
gate; the attended command is per-project, authored at provision).
