# Milestone — harvest-verb

Change context: `specs/changes/harvest-verb.md`. One milestone; adds one skill and
wires it — new `skills/harvest/SKILL.md` + seeded `specs/reviews/harvest-cursor.md`,
the grain-ladder/skills-list/count lines in `README.md`, the orientation banner in
`scripts/session-bootstrap.sh` (both the neutral and mode-active copies) + its
self-test. No gates, guards, or templates change. Integration seams: the
session-bootstrap banner is covered by `scripts/session-bootstrap.test.sh` (stays
green, gains an assertion for the new name); the `status` skill's Cross-cut ladder
placement is the pattern to match; the two pilot digests under `specs/reviews/` are
cited as the method's provenance, never moved. Neutrality caution for the builder: the
skill body cites the digest files, never the dogfood projects' names — those names pass
`check-neutral.sh`'s denylist while violating its intent.

## Done-conditions

- [auto] **The skill exists and is well-formed.** `skills/harvest/SKILL.md` has valid
  frontmatter (`name: harvest`, a `description`, a `when_to_use`) and passes
  `scripts/check-skill-frontmatter.sh` (now 19 skills). It **carries
  `disable-model-invocation: true`** — it reads private transcripts from other projects
  and spawns subagent work, so it is human-triggered only, like `auto`/`auto-merge`.
- [auto] **Two scopes are specified, one output home.** The skill body distinguishes:
  default scope (run in the keel repo — mine transcripts across the user's projects)
  and `retro` scope (run in any keel-managed project — the same mining scoped to that
  project's own sessions, feeding the apply-here-first protocol). Both scopes write
  digest + cursor to `specs/reviews/` **in the repo they run in**; the body states that
  `retro` creates the directory if the project lacks it.
- [auto] **The mining method is encoded from the pilot.** The skill body states: the
  signal ladder (user-typed messages first, mechanism-marker grep of full transcripts
  second), fan-out via parallel **read-only** subagents bounded per project/date-range,
  and cites `specs/reviews/2026-07-12-transcript-harvest.md` §"Lessons for the harvest
  skill itself" as provenance.
- [auto] **Findings are diffed against HEAD before reporting.** The skill body states
  the rule: every finding is checked against current keel `main` (or the project's
  current state, in `retro` scope) and reported with a status — new /
  already-fixed-at-HEAD / partially addressed — never raw; the pilot's 3-of-19
  already-fixed rate is the stated reason.
- [auto] **The secret rule is a hard rule.** The skill body states: transcripts contain
  pasted tokens, keys, and env values — nothing secret-shaped is ever quoted into a
  digest or subagent prompt; user messages are quoted minimally, as evidence only.
- [auto] **Cursor state is specified — and seeded.** The skill body names
  `specs/reviews/harvest-cursor.md` (in the repo the scope writes to) as the cursor:
  read first, mine only sessions newer than its per-source through-mark, update it in
  the same commit as the digest — so repeated runs never re-mine covered sessions. The
  body also states the no-cursor rule: absent a cursor file in the target repo, the
  skill asks the user for a starting bound instead of silently mining all history.
  **And this milestone commits the keel repo's seeded cursor**:
  `specs/reviews/harvest-cursor.md` exists on the branch recording the pilot's
  coverage per source (the two 2026-07-12 digests' scanned sessions — 14 + 21 + 5 —
  each source marked covered through 2026-07-12), so the first real run mines only
  newer sessions.
- [auto] **The output contract is a proposed slate, never applied work.** The skill
  body specifies the digest shape for both scopes (`specs/reviews/YYYY-MM-DD-harvest.md`:
  scope + method, ranked findings with session-ID evidence and diff-against-HEAD
  status, wins, discarded noise), ending in the default scope with accepted candidates
  **mapped to keel grains** (spec-change / punch-list / spec-feature / reference
  update) and in `retro` scope with the project-level applications the retro protocol
  drives; states that the session ends attended on the user's slate approval with
  approved items running through the normal verbs in later sessions; states the write
  boundary — harvest writes only the digest and the cursor (plus retro's deferrals
  entry), never skill/code changes; and states the landing choreography — digest +
  cursor commit on a branch and land as a plan-only PR (`specs/**` only, never a
  commit to `main`), the default scope ending on that PR open.
- [auto] **The retro protocol is encoded, ledger named.** The skill body states the
  `retro`-scope protocol: findings → discuss → apply to the live project first
  (project-level docs/config/process) → ledger the change in **the project's deferrals
  ledger (`specs/deferrals/`, file-per-entry)** as "deferred until proven" with closing
  condition "proven in use → propose promotion to keel" → promote to a keel
  skill/reference only after proven in use — and that `retro` ends on that deferrals
  entry, not a keel PR.
- [auto] **Promptless read sweep, honestly stated, covering the method's own rungs.**
  The frontmatter's `allowed-tools` pre-approves an enumerated read-only sweep set that
  includes the grep rung (`Bash(git log *)`, `Bash(git diff *)`, `Bash(ls *)`,
  `Bash(jq *)`, `Bash(grep *)`) and grants no Edit/Write; the body states the recorded
  semantics — `allowed-tools` is a grant, not a restriction; the write boundary is the
  stated hard rule — and states that the fan-out subagents, which the frontmatter grant
  does not reach, are dispatched with read-only, quote-minimal instructions in their
  prompts.
- [auto] **Ladder wiring.** `README.md`'s grain ladder Cross-cut line and the
  cross-cutting skills-list bullet both name `harvest`, **and the skill count reads 19**
  (no "18 skills" text survives anywhere in the file); both orientation-banner copies in
  `scripts/session-bootstrap.sh` carry it on their Cross-cut line; and
  `scripts/session-bootstrap.test.sh` gains an assertion that the emitted banner names
  `harvest`, with the full suite still passing.
- [auto] **Repo checks green.** `claude plugin validate --strict .`,
  `scripts/check-neutral.sh`, `scripts/check-plan.sh`,
  `scripts/check-skill-frontmatter.sh`, `scripts/check-skill-anchors.sh`, and every
  `scripts/*.test.sh` pass on the branch.

## verification

verifier subagent against this file's done-conditions (all `[auto]`; the new skill is
prose + frontmatter, closable by reading the named files and running the named checks).

verified: clean at a4f026f, 2026-07-12, via verifier subagent against this spec's done-conditions — all 12 conditions evidenced with file:line, 5 repo checks + 11 script self-tests green (evidence in PR #113)
