---
name: harvest
description: Mine real session transcripts into a proposed, grain-mapped improvement slate — the retrospective verb. Default scope (run in the keel repo) sweeps sessions across the user's projects for methodology findings; `retro` scope (run in any keel-managed project) mines that project's own sessions and feeds the apply-here-first protocol. Writes only a digest + cursor under specs/reviews/ — never skill or code changes.
when_to_use: Human-triggered only — when the user wants a retrospective over real session history. `harvest` in the keel repo mines across projects for keel improvements; `harvest retro` in a keel-managed project mines that project's own sessions for project-level fixes. NOT self-invoked (it reads private transcripts from other projects and spawns paid subagent work), and NOT a build verb — the output is a proposed slate the user approves; approved items run through the normal verbs later.
disable-model-invocation: true
allowed-tools: Bash(git log *), Bash(git diff *), Bash(git show *), Bash(git rev-parse *), Bash(ls *), Bash(jq *), Bash(grep *), Bash(wc *), Bash(head *), Bash(find *), Bash(stat *), Bash(sort *), Bash(sed *), Bash(tr *), Bash(basename *)
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

## Step 0 — enumerate the sources. Never look them up.

**Default scope only.** A `retro` run does not run this step; it enters the ladder at step 1.
What `retro` sweeps instead is an open question — see `specs/deferrals/harvest-retro-scope.md`.

The sweep set is derived from the filesystem at the start of every run, never from a list.
A list goes stale silently: when a project's checkout moves, its sessions land in a directory
no list has ever named, and the run reports the project *dormant* instead of unmined. That is
not hypothetical — it happened on the run that motivated this step, where the cursor named 4
sources and 10 were
active, and one project's 13 sessions were missed entirely.

The floor is the watermark line in `specs/reviews/harvest-cursor.md`. **Freshness is file
mtime, inclusive of the watermark day** — a file counts if its mtime falls on or after that
date. mtime rather than the session's internal timestamp because mtime over-includes (a
resumed old session gets re-swept, costing spend) while the internal timestamp under-includes,
and under-inclusion is the defect this step exists to end.

```bash
WM="${HARVEST_WATERMARK:-$(grep -m1 '^\*\*Watermark:\*\*' specs/reviews/harvest-cursor.md | sed 's/.*\*\* *//')}"
for d in "$HOME"/.claude/projects/*/; do
  c=$(find "$d" -maxdepth 1 -name '*.jsonl' -newermt "$WM" | wc -l | tr -d ' ')
  [ "$c" = "0" ] && continue
  n=$(find "$d" -maxdepth 1 -name '*.jsonl' -newermt "$WM" -exec stat -f '%Sm' -t '%Y-%m-%d' {} \; | sort -r | head -1)
  printf '%s\t%s\t%s\n' "$(basename "$d")" "$c" "$n"
done
```

Three properties of this command are load-bearing, each for a reason the real store enforces:

- **`-maxdepth 1`** — nested subagent transcripts are not sessions. One directory holds 10
  top-level entries against 155 recursive; recursing inflates every count by an order of
  magnitude.
- **The directory argument is always a full path, never a bare basename** — every transcript
  directory name begins with `-`, which `find` consumes as an option flag and errors on.
  **Quoting does not fix this**; reaching the directory through the `"$HOME"/.claude/projects/*/`
  expansion does. With stderr suppressed, the bare-basename form fails as a silent zero.
- **The expansion stays quoted** — a separate guard, for the several directory names containing
  spaces.

**`HARVEST_WATERMARK` overrides the floor.** The cursor is the default and the only source a
real run uses; the override exists so a read-only verifier can vary the watermark without
writing anything. **No date literal ever appears in this command** — a hardcoded floor makes
the whole advance rule inert, since advancing a value nothing reads changes nothing.

**Mine every source the command returns.** Reconcile nothing against the cursor's table first;
the table is a historical record of what past runs covered, not an input to what this run
sweeps.

**Zero rows is ambiguous — disambiguate before reporting it.** A quiet week returns zero rows,
and so does a broken or mistyped root, and the second read as the first is exactly the original
defect. **Re-run the enumeration with no floor** (`HARVEST_WATERMARK=1970-01-01`): zero rows
there means the root is broken — stop and ask. Non-zero means genuinely nothing new since the
watermark, which is a legitimate result to report.

**Announce scope before dispatching any subagent**: session count, source count, watermark date.

## The mining method — the signal ladder

Transcripts live in the harness's per-project session directories —
`~/.claude/projects/<project-dir>/*.jsonl`, one file per session. Mine them in this order:

1. **Human-typed input first** — the highest-signal channel: friction, corrections, repeated
   asks. A question the user typed twice is a finding.

   **`type=="user"` alone is not a human-input filter.** The user role carries scheduler
   fallbacks, `/loop` re-fires, task notifications, and local-command stdout. Measured in one
   real session: **26 `human`, 46 `task-notification`, 545 with no origin field** — of which
   **521** are `tool_result`. A naive extraction ingests roughly 24× more than actual human
   input, and every "the user asked twice" finding built on it is unsafe.

   ```bash
   jq -r '
     select(.type=="user")
     | (if (.message.content|type)=="string" then .message.content
        else ([.message.content[]? | select(.type=="text") | .text] | join("\n")) end) as $t
     | if .origin.kind=="human" then $t
       elif ($t | test("<command-args>[^<]")) then ($t | capture("<command-args>(?<a>[^<]+)</command-args>").a)
       else empty end' "$FILE"
   ```

   **The path is `.origin.kind`, top-level — not `.message.origin.kind`.** The latter returns
   nothing for all 617 user entries in the sampled session, so that one wrong character yields
   zero human entries, which is indistinguishable from "the user typed nothing" — the exact
   class of unsafe finding this filter exists to prevent.

   **Non-empty `<command-args>` is included**: typed slash-command arguments are human intent
   inside a machine envelope. Excluded: `tool_result` content, `task-notification` origin,
   `<command-name>` / `<command-message>` / local-command-caveat envelopes, and injected skill
   bodies. The inclusion needs the emptiness guard — a first attempt pulled in the wrappers and
   empty args, yielding 38 lines where 28 were real.

2. **Mechanism-marker grep of full transcripts second** — the keel-mechanism shapes:
   pin / drift / permission / port / env. This catches incidents the user never typed
   about.

**Fan out via parallel read-only subagents, bounded per project/date-range** — each
subagent gets one project (or one date slice), reads transcripts, and reports findings
with session IDs; the pilot ran two subagents over 35 sessions in about six minutes.
**Every miner's dispatch prompt carries step 1's extraction recipe verbatim** — miners inherit
the harness, not this skill body, so a recipe left here is a recipe they never see.
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

## Cursor — the floor, and the record of what was covered

`specs/reviews/harvest-cursor.md`, in the repo the scope writes to, holds two things: the
**watermark line** that step 0 reads as its floor, and a **historical coverage table** recording
what past runs mined. The table is provenance — it is never consulted to decide what this run
sweeps. **Update the file in the same commit as the digest.** **No cursor in the target repo =
ask**: ask the user for a starting bound instead of silently mining all history.

**The watermark advances only when every enumerated source produced a returned miner report.**
The discriminator is **returned vs did-not-return, not findings vs no findings** — a miner that
reports "nothing of note in these sessions" is a complete result and does not hold the floor.
Incomplete means a miner errored, was skipped, or its dispatch was aborted. On an incomplete run
the watermark stays where it is and the digest names the uncovered sources; advancing past
sessions nobody read buries them below the floor permanently, which is the original defect
reintroduced through its own fix.

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
