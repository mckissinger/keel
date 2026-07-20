# Change — Harvest enumerates its sources and filters for human input

**Origin:** `specs/reviews/2026-07-18-harvest.md` findings A1 + A2, both verified directly
during that run. Slate Unit 1.

**Draft 6.** Five earlier drafts failed their adversarial pass. This document is rewritten
rather than amended, because draft 3's failure included superseded text surviving in its
earlier sections while only a later section reversed it — a builder reading top-down would
have built the wrong thing.

## The defect

Harvest's cursor (`specs/reviews/harvest-cursor.md`) identifies transcript sources by
**directory name**, with a per-source through-mark. Two failures follow, both observed on
2026-07-18:

- **A moved checkout falls out of the sweep silently.** CRE Launch's checkout moved to
  `~/Dev Projects/cre-list`, so its sessions land in a directory the cursor never listed. The
  run read the old path, found nothing newer than Jun 22, and reported the project *dormant* —
  while 13 uncovered sessions sat next door.
- **A never-listed project is never mined.** BidLevel (18 sessions that week, fully
  keel-managed) had never appeared in the cursor in any form.

Observed: the cursor listed **4** sources; **10** were active.

Separately, the ladder's step 1 treats every `type=="user"` entry as human intent. Measured:
**26 `human`, 46 `task-notification`, 545 with no origin field** — of which 521 are
`tool_result`. A naive extraction ingests ~24× more than actual human input.

## The fix

**Enumerate, don't look up.** The sweep set comes from a command run at the start of every
harvest, not from a list that can go stale. Nothing matches on directory names any more, so
both halves of the defect dissolve in default scope.

**A command in the skill, not a program in the repo.** Drafts 1 and 2 shipped
`scripts/harvest-sources.sh` with a nine-case suite, CI wiring and a watermark migration. Both
failed, and all six CRITICALs concerned the *script's* contract — where it lives, what it
counts, how it fails, how `retro` narrows it. None questioned enumeration itself. The whole fix
automates one command that worked first try, for a verb that runs occasionally. The machinery
outweighed the problem.

**The floor stays.** Draft 3 dropped the watermark as machinery and left two conditions
referencing an undefined "run's floor" — a hole the shrink created. The watermark was not
machinery; it *was* the floor. A single dated line survives as the sweep's lower bound. This is
the smallest thing that still defines where a run starts.

## Decisions taken

- **Floor = one global watermark line**, seeded `2026-07-18`. For the sources the cursor already
  lists, the collapse is lossless: the only two still marked through 07-12 have zero sessions
  after that date (newest 2026-06-22 and 2026-07-06, verified).
- **The pre-07-18 backlog is written off deliberately.** ~28 directories were never listed in the
  cursor at all, holding sessions the floor now places permanently out of scope
  (`-Users-michaelkissinger-keel` 21, `-Users-michaelkissinger-cre-list` 33, `-jarvis-2-0` 13,
  `-Email-Assistan-comfort-ai` 11, `-x-big-proj` 10, and others). Mining them would cost more
  subagent spend than the findings are worth, and the material is months old. The user chose the
  write-off explicitly. The milestone requires the cursor to **say so** — a silent floor reads as
  verified coverage, which is exactly the failure mode this change exists to end.
- **A zero-row enumeration is a stop-and-ask, never "nothing to mine."** Draft 3 had no condition
  here at all, which let a broken command reproduce the original symptom — silence read as
  dormancy — exactly.
- **`retro` is deferred, not designed.** Its scoping sank one CRITICAL in each of three drafts:
  a fixed source count that is empirically false, then an undefined notion of "belonging" where
  name-matching is precisely what broke. The two directories for CRE Launch share no
  discriminating substring, so no cheap rule exists. The user has never run a `retro`. It is
  recorded as an open deferral rather than guessed at.
- **The recipe's field path is `.origin.kind`, top-level.** Verified: `.message.origin.kind`
  returns nothing for all 617 user entries in the sampled session. A recipe with that one wrong
  path yields zero human entries — indistinguishable from "the user typed nothing," which is the
  class of unsafe finding this change exists to prevent. Hence the recipe is *executed* at
  verification, not merely read.
- **The leading-dash hazard needs a full path, not quoting.** Every transcript directory name
  begins with `-`, which `find` consumes as an option flag: `find "-Users-…" -maxdepth 1` errors
  even though the argument is quoted. Reaching the same directory through
  `~/.claude/projects/*/` expansion — a full path — works. Quoting is still required, for the
  several names containing spaces, but it is a *different* guard against a *different* hazard.
  Draft 5 credited the dash fix to quoting; a builder implementing that property literally ships
  a command that errors on every directory.
- **`<command-args>` is included, and needs care.** Slash-command arguments are human intent in
  a machine envelope. A first attempt at the inclusion also pulled in `<command-name>` and
  `<command-message>` wrappers and empty args — 38 lines where 28 were real. The committed
  recipe was iterated until envelope leakage measured zero.

## Deliberately not in scope

- **`retro` scope behaviour** — an open deferral, per above.
- **Re-deriving the 2026-07-18 digest's frequency claims** under the new filter. That digest's
  caveat is upgraded to cite the shipped recipe; the re-derivation itself is follow-on analysis.
- Any change to what harvest *writes* (digest + cursor only), the secret rule, the
  diff-against-HEAD rule, or `disable-model-invocation`.
