---
name: harvest
description: Mine real session transcripts into a proposed, grain-mapped improvement slate — the retrospective verb. Default scope (run in the keel repo) sweeps sessions across the user's projects for methodology findings; `retro` scope (run in any keel-managed project) mines that project's own sessions and feeds the apply-here-first protocol. Writes only a digest + cursor under specs/reviews/ — never skill or code changes.
when_to_use: Human-triggered only — when the user wants a retrospective over real session history. `harvest` in the keel repo mines across projects for keel improvements; `harvest retro` in a keel-managed project mines that project's own sessions for project-level fixes. NOT self-invoked (it reads private transcripts from other projects and spawns paid subagent work), and NOT a build verb — the output is a proposed slate the user approves; approved items run through the normal verbs later.
disable-model-invocation: true
allowed-tools: Bash(git log *), Bash(git diff *), Bash(git show *), Bash(git rev-parse *), Bash(ls *), Bash(jq *), Bash(grep *), Bash(wc *), Bash(head *)
---

# Harvest

Turn real session history into a proposed improvement slate. The method was piloted before
it was specced — `specs/reviews/2026-07-12-transcript-harvest.md` and
`specs/reviews/2026-07-12-skill-mining.md` are its output — and this skill encodes what the
pilot proved, especially the transcript-harvest digest's §"Lessons for the harvest skill
itself".

**The hard rule: harvest writes only the digest and the cursor (plus `retro`'s deferrals
entry) — never skill or code changes.** Findings become work through the normal verbs, in
later sessions, after the user approves the slate. A harvest run that "quickly fixes"
something it found has left its lane.

## Two scopes, one output home

- **Default** (run in the keel repo): mine session transcripts across the user's projects
  for methodology findings — friction keel should absorb, wins keel should keep.
- **`retro`** (run in any keel-managed project): the same mining scoped to *this* project's
  own sessions, feeding the apply-here-first protocol below instead of keel changes.

Both scopes write digest + cursor to `specs/reviews/` **in the repo they run in**; `retro`
creates the directory if the project lacks it — the convention travels with the verb.

## The mining method — the signal ladder

Transcripts live in the harness's per-project session directories —
`~/.claude/projects/<project-dir>/*.jsonl`, one file per session, with user messages
extractable via `jq`. Mine them in this order:

1. **User-typed messages first** — the highest-signal channel: friction, corrections,
   repeated asks. A question the user typed twice is a finding.
2. **Mechanism-marker grep of full transcripts second** — the keel-mechanism shapes:
   pin / drift / permission / port / env. This catches incidents the user never typed
   about.

**Fan out via parallel read-only subagents, bounded per project/date-range** — each
subagent gets one project (or one date slice), reads transcripts, and reports findings
with session IDs; the pilot ran two subagents over 35 sessions in about six minutes.
Provenance for all of this: `specs/reviews/2026-07-12-transcript-harvest.md` §"Lessons for
the harvest skill itself".

## Diff against HEAD before reporting

**Every finding is checked against current keel `main`** (or, in `retro` scope, the
project's current state) **and reported with a status — new / already-fixed-at-HEAD /
partially addressed — never raw.** The pilot found 3 of its 19 findings already fixed at
HEAD; an undiffed harvest re-proposes shipped work and burns the user's attention on it.

## The secret rule — hard, no exceptions

Transcripts contain pasted tokens, keys, and env values. **Nothing secret-shaped is ever
quoted into a digest or a subagent prompt.** User messages are quoted minimally, as
evidence only — the finding carries the session ID, not the paste.

## Cursor — never re-mine covered sessions

`specs/reviews/harvest-cursor.md`, in the repo the scope writes to, records per transcript
source which sessions are already covered. **Read it first; mine only sessions newer than
its per-source through-mark; update it in the same commit as the digest** — so repeated
runs never re-mine covered sessions. **No cursor in the target repo = ask**: ask the user
for a starting bound instead of silently mining all history.

## Output contract — a proposed slate, never applied work

The digest is `specs/reviews/YYYY-MM-DD-harvest.md` (both scopes): scope + method, ranked
findings each carrying session-ID evidence and its diff-against-HEAD status, wins
observed, and the noise discarded. It ends:

- **default scope**: with each accepted candidate **mapped to a keel grain** —
  spec-change / punch-list / spec-feature / reference update — ready to run as normal work.
- **`retro` scope**: with the project-level applications the retro protocol below drives.

**The session ends attended on the user's slate approval**; approved items run through the
normal verbs in later sessions. **Landing**: the digest + cursor commit on a branch and
land as a plan-only PR (`specs/**` only, never a commit to `main`) — the default scope
ends on that PR open.

## The retro protocol (`retro` scope)

Findings → discuss → **apply to the live project first** (project-level docs, config,
process) → ledger the change in **the project's deferrals ledger** (`specs/deferrals/`,
file-per-entry) as "deferred until proven", closing condition "proven in use → propose
promotion to keel" → promote to a keel skill/reference **only after proven in use**.
`retro` ends on that deferrals entry, not a keel PR.

## Boundaries

- **`allowed-tools` is a grant, not a restriction** — it pre-approves the read-only sweep
  set so the mining runs promptless; the writes-only-digest-and-cursor guarantee is the
  stated hard rule above, per keel's recorded frontmatter semantics.
- **The fan-out subagents are outside the frontmatter grant's reach** — they inherit the
  harness, not the grant — so each is dispatched with read-only, quote-minimal
  instructions in its prompt.
- **Human-triggered only** (`disable-model-invocation: true`): harvest reads private
  transcripts from other projects and spawns paid subagent work — never self-invoked.
