# Change — harvest-verb

One milestone: a new human-triggered `harvest` skill — the transcript-mining /
retrospective verb that turns real session history into a proposed, grain-mapped keel
improvement slate — plus its ladder wiring. Approved by Michael 2026-07-12 (slate group
C item 7, retrospective folded in; the concept was **piloted before speccing** at his
direction — `specs/reviews/2026-07-12-transcript-harvest.md` and
`specs/reviews/2026-07-12-skill-mining.md` are its output).

## Why

The pilot run (35 sessions across two projects, 2 parallel subagents, ~6 minutes)
produced 19 actionable findings that became the approved improvement slate now landing
change by change — and the same protocol had already been commissioned by hand four
times in one project ("review this session as well as previous sessions… give me
recommendations", near-identical prompts across four days,
`specs/reviews/2026-07-12-skill-mining.md` §4). The method works and is currently
nowhere: its signal ladder, its diff-against-HEAD rule, its secret-handling rule, and
its cursor problem (which sessions were already reviewed) live only in one session's
memory. Encoding it is what makes the improvement loop repeatable.

## Decisions taken

- **Two scopes, one skill, one output home.** `harvest` (default, run in the keel
  repo): mine session transcripts across the user's projects for methodology findings.
  `harvest retro` (run in any keel-managed project): the same mining scoped to *this*
  project's sessions, feeding the apply-here-first retrospective protocol instead of
  keel changes. **Both scopes write digest + cursor to `specs/reviews/` in the repo
  they run in** — retro creates the directory if the project lacks it (the convention
  travels with the verb; nothing else assumes it exists).
- **Human-triggered only** (`disable-model-invocation: true`): it reads private
  transcripts from other projects and spawns paid subagent work — never self-invoked.
- **The signal ladder, encoded from the pilot**: user-typed messages first (the
  highest-signal channel — friction, corrections, repeated asks), full-transcript
  mechanism-marker grep second (pin/drift/permission/port/env shapes); parallel
  read-only subagents fan out per project/date-range, bounded and reported.
- **Findings diff against keel HEAD before reporting** — the pilot found 3 of 19
  already fixed; a finding is reported with its current-keel status (new /
  already-fixed-at-HEAD / partially addressed), never raw.
- **The secret rule is hard**: transcripts contain pasted tokens and env values —
  nothing secret-shaped is ever quoted into a digest; user messages are quoted
  minimally and only as evidence.
- **Cursor state** so the loop never re-mines: `specs/reviews/harvest-cursor.md` (in
  whichever repo the scope writes to) records, per transcript source, the sessions
  already covered (through-date/session ID); each run reads it first, mines only newer
  sessions, and updates it in the same commit as the digest. **This milestone seeds the
  keel repo's cursor with the pilot's coverage** (the 14 + 21 + 5 sessions the two
  digests scanned, through 2026-07-12) so the first real run doesn't re-mine the pilot
  corpus and re-report its 19 findings. **No cursor = ask**: with no cursor file in the
  target repo, the skill asks the user for a starting bound rather than silently mining
  all history.
- **Output is a proposed slate, never applied work.** The digest
  (`specs/reviews/YYYY-MM-DD-harvest.md`, both scopes) carries: scope + method, ranked
  findings with session-ID evidence, the diff-against-HEAD status, wins observed, noise
  discarded — ending, in the default scope, with each accepted-candidate finding
  **mapped to a keel grain** (spec-change / punch-list / spec-feature / reference
  update), and in `retro` scope with the project-level applications the protocol below
  drives. The session ends attended on the user's slate approval; approved items run
  through the normal verbs in later sessions. Harvest itself writes only the digest +
  cursor (plus retro's ledger entry).
- **Landing choreography for the one write**: the digest + cursor commit on a branch
  and land as a plan-only PR (`specs/**` only — exempt from the verified-pin gate,
  never a commit to `main`); the default scope ends on that PR open, `harvest retro`
  ends on the ledger entry below.
- **The retro protocol** (from the four hand-commissioned retros): findings → discuss →
  **apply to the live project first** (project-level docs/config/process) → ledger the
  change **in the project's deferrals ledger** (`specs/deferrals/`, file-per-entry) as
  "deferred until proven", closing condition "proven in use → propose promotion to
  keel" → promote to a keel skill/reference **only after proven in use**. `harvest
  retro` ends on that deferrals entry, not on a keel PR.
- **Ladder wiring**: README's grain ladder + skills list gain `harvest` (cross-cutting,
  next to `debug`/`status`) and the skill count bumps to 19; both session-bootstrap
  banner copies gain it on their Cross-cut line, with the self-test asserting the new
  name.
- Honest frontmatter semantics, as recorded for `status`: `allowed-tools` is a grant,
  not a restriction — the skill pre-approves an enumerated read-only sweep set **that
  covers the method's own rungs (including the grep rung)**; the
  writes-only-digest-and-cursor guarantee is the skill's stated hard rule. The fan-out
  subagents are outside the frontmatter's reach — the body states they are dispatched
  with read-only, quote-minimal instructions in their prompts (the harness, not the
  grant, is what they inherit).

## Milestone

`specs/milestones/harvest-verb.md` — new `skills/harvest/SKILL.md` + seeded
`specs/reviews/harvest-cursor.md`; one line each in `README.md` (ladder + skills list +
count), `scripts/session-bootstrap.sh` (both banner copies) + its test.
