# Milestone — env-check-preflight

Change context: `specs/changes/env-check-preflight.md`. One milestone; edits
reference/skill prose only (`references/profile-interface.md`,
`skills/provision/SKILL.md`, `skills/implement-milestone/SKILL.md`,
`skills/verify-milestone/SKILL.md`, `skills/spec-foundation/SKILL.md`,
`skills/adopt/SKILL.md`). No scripts,
hooks, gates, or templates move. Integration seams: Q12's authorship-split paragraph
enumerates which parts are finalized at provision — the new command joins that list in
both places (the bullet and the split paragraph) or neither reads complete;
`scripts/check-auto-preflight.sh` section (c) is the existing names-only mechanism for
**auto runs** and stays untouched — the new command is the **attended/entry** analog,
per-project, authored at provision (the prose must not imply the script is replaced or
that it serves the attended path); Q13's per-instance preflight is "the Q12 preflight
parameterized by identity" (`references/profile-interface.md` ~line 305) and inherits
the name-check command without new text — no Q13 edit; the Q12 provision-finalized
enumeration is restated in two derivation lists (`skills/spec-foundation/SKILL.md`
~line 66 and `skills/adopt/SKILL.md` ~line 32) that must gain the new command or read
incomplete; the two entry-preflight sentences (implement-milestone step 1,
verify-milestone step 4) share a word-identical parenthetical span today ("daemon
responsive, ports owned by *this* project's stack, toolchain resolves, env file
present or re-derived via the recorded command") while their lead-ins and tails
legitimately diverge — the parallelism obligation is on that shared span only.

## Done-conditions

- [auto] **Q12 records the env name-check command.** The Q12 bullet list in
  `references/profile-interface.md` gains a bullet: the one **committed env name-check
  command** that asserts every contracted env-var **name** resolves (host env store or
  local env file), reporting names/status only — values never appearing in its output;
  implementation stack-appropriate (a package script, the stack's own env-schema
  validation, a small committed script) with the command recorded, the implementation
  never mandated. The bullet also states the direct-read ban: sessions never read
  `.env*` files directly — a permission denial on such a read is the posture working,
  and the recorded command is the sanctioned path. The authorship-split paragraph's
  finalized-at-provision enumeration includes the name-check command alongside the env
  re-derivation command.
- [auto] **The signature table's example rows include the denial row.** Q12's
  known-failure-signature bullet's example list includes a row shaped as: a permission
  denial on a `.env*` read → working as intended; run the recorded env name-check
  command instead.
- [auto] **Provision authors the command.** `skills/provision/SKILL.md` step 3 states
  that alongside the recorded env re-derivation recipe it authors/records the env
  name-check command (names/status output only, never values); step 6's
  finalized-at-provision list (the sentence enumerating the Q12 parts finalized there)
  includes the name-check command.
- [auto] **Both entry preflights name the mechanism.** The Q12 entry-preflight
  sentence in `skills/implement-milestone/SKILL.md` step 1 and in
  `skills/verify-milestone/SKILL.md` step 4 each gains the name-check clause — env-var
  names asserted via the profile's recorded name-check command, never by reading the
  env file directly — added inside the parenthetical span the two files share today
  ("daemon responsive, ports owned by *this* project's stack, toolchain resolves, env
  file present or re-derived via the recorded command"), and that shared span remains
  **word-identical** between the two files after the edit (their lead-ins and tails
  may keep their existing divergence).
- [auto] **Both derivation lists carry the new command.** The provision-finalized
  enumerations restated in `skills/spec-foundation/SKILL.md` (the "finalized at
  provision" parts list, ~line 66) and `skills/adopt/SKILL.md` (~line 32) each include
  the env name-check command alongside the env re-derivation command, so a derivation
  session records a placeholder for it like the other provision-finalized parts.
- [auto] **spec-foundation's run-preflight aligns.** The run-preflight paragraph in
  `skills/spec-foundation/SKILL.md` ("bare env-var-name existence otherwise — never
  read values") names the profile's recorded name-check command as the mechanism for
  that existence check.
- [auto] **No stale contradiction.** No sentence in the six edited files still
  implies a session checks env-var names by reading the env file, and nothing implies
  `check-auto-preflight.sh` serves the attended entry preflight or is replaced by the
  new command.
- [auto] **Repo checks green.** `claude plugin validate --strict .`,
  `bash scripts/check-neutral.sh`, `bash scripts/check-plan.sh`,
  `bash scripts/check-skill-frontmatter.sh`, `bash scripts/check-skill-anchors.sh`,
  and every `scripts/*.test.sh` pass on the branch.

## verification

verifier subagent against this file's done-conditions (all `[auto]`; prose-only change —
each condition is closable by reading the named files and running the named checks).
verified: clean at da3279d, 2026-07-14, via fresh-context keel:verifier subagent against this spec's done-conditions — all 8 prose conditions evidenced per-file/line; diff scope exactly the six named files; the shared entry-preflight span proven byte-identical mechanically; read-ban scoped precisely (no collision with the three legitimate env-file write paths); 5 repo checks + 11 script self-tests green (348 assertions) (evidence in PR #130)
