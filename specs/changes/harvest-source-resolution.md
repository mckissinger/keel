# Change — Harvest asserts its own coverage

**Origin:** `specs/reviews/2026-07-18-harvest.md` findings A1 + A2, both verified directly
during that run. Slate Unit 1.

## The defect

Harvest's cursor (`specs/reviews/harvest-cursor.md`) identifies transcript sources by
**directory name** under `~/.claude/projects/`, with a per-source through-mark. Two failures
follow, and both fired on 2026-07-18:

- **A moved checkout falls out of the sweep silently.** CRE Launch's checkout moved to
  `~/Dev Projects/cre-list`, so its sessions land in a directory the cursor never listed. The
  run read the old path, found nothing newer than Jun 22, and reported the project *dormant* —
  while 13 uncovered sessions sat next door. A moved project is indistinguishable from an
  inactive one under string matching.
- **A never-listed project is never mined.** BidLevel (`test-proj-1`, 18 sessions that week,
  fully keel-managed) had never appeared in the cursor in any form.

Observed: the cursor listed **4** sources; **10** were active.

Separately, the signal ladder's step 1 ("user-typed messages first — the highest-signal
channel") treats every `type=="user"` entry as human intent. Measured in one session: **26
`origin.kind=="human"`, 46 `task-notification`, 545 with no origin field** — of which 521 are
`tool_result`. A naive extraction ingests roughly 24× more than actual human input, so any
finding of the form "the user asked twice" is unsafe.

## The shape of the fix

**The per-source bookmark is the bug.** Replace it with a **single global watermark**: one
date, applying everywhere. Nothing per-source is left to drift, so a moved checkout is picked
up automatically because nothing matches on directory names any more. The per-source table
survives, demoted from *input* to *found-record* — it can no longer cause a miss.

Enumeration ships as a **committed script**, not as prose in the skill. This applies the same
digest's D4 finding — five documented gotchas in another project re-bit precisely because
documentation is not a control — to this change. A skill instruction to "enumerate and
reconcile" is exactly the kind of remembered step that gets skipped; a script that a fresh
session runs is not.

**Scope announcement replaces a mid-run gate.** Harvest is human-triggered and attended, so
reporting *"mining N sessions across M sources since `<date>`"* before spending anything is
itself the gate. No threshold logic, no interruption.

## Milestones

Two, not one. They share no file (apart from an append-only anchor file) and no failure mode:

- **`harvest-source-resolution`** — the enumeration script, its test suite, CI wiring, the
  watermark restructure, the skill's cursor section, `retro` scoping, and the anchors.
- **`harvest-human-input-filter`** — the signal ladder's extraction recipe and the digest
  citation.

The first draft bundled them into one milestone. The adversarial plan pass flagged the seam,
pointing at this document's own use of the word "Separately" to introduce the second half.

## Decisions taken

- **Global watermark over project-identity grouping.** Inferring canonical project identity
  from session cwd is more machinery than the bug requires, and the user chose reconciliation
  only. The watermark makes identity unnecessary rather than automating it.
- **Expanded from documented to executable.** The signed-off synthesis said skill text; this
  spec ships `scripts/harvest-sources.sh` instead. Flagged in the plan PR for review — revert
  to text-only is a one-line change to the done-conditions if not wanted.
- **The origin filter keeps `<command-args>`.** Slash-command arguments are real human intent
  in a machine envelope; a strict `origin.kind=="human"` filter would drop them. Verified: 24
  no-origin text entries in the sampled session, one of which carried typed user arguments.
- **`retro` filters after enumerating.** Enumeration stays total — that is what fixes the bug —
  and a scope-filter argument narrows the *result*, not the sweep. The alternative (a separate
  mechanism for `retro`) would leave two coverage paths in one skill, and the cheap option
  (defer `retro` entirely) would leave a known contradiction in the file.
- **The migration watermark is `2026-07-18`, and it is safe rather than assumed.** Coverage was
  ragged across 07-12 and 07-18 rows, so no single date is faithful *a priori*. Verified: the
  only two sources still marked 07-12 have zero sessions after that date (newest 2026-06-22 and
  2026-07-06), so the collapse loses nothing.
- **Protected rules move from prose to anchors.** `scripts/check-skill-anchors.sh` already
  supports negative anchors — asserting a string stays *absent* — which is the machine-checked
  form of "this rule was retired and must stay retired." The first draft hand-wrote "no
  weakening" prose that a verifier closes by eyeballing a diff, and which passes on a reworded
  gut.

## What the adversarial plan pass caught

Recorded because the findings are the reason this spec's conditions look the way they do:

- **The missing-root fail-open.** The first draft required "exit 0 with no output when nothing
  qualifies" *and* made it a test case — but a nonexistent root produces the identical
  observable, so harvest would announce "0 sources" and conclude there was nothing to mine.
  That is the original defect (silence read as dormancy) written into the spec as a
  requirement.
- **A vacuous regression lock.** The draft claimed a test case proved the enumeration-only
  property. Against a fixture root every directory "appears in no prior record," so the case was
  identical to a trivial one. The fix is the decoy-record case: a cursor-shaped file listing a
  subset must be present, and an unlisted-but-active directory must still be returned.
- **`retro` scope breakage.** "No source-name argument" plus "mine every source returned" meant
  a `retro` run would mine every project on the machine — a privacy violation given the skill's
  own stated reason for being human-triggered.
- **The deleted in-flight carve-out**, unwired CI (the workflow enumerates suites explicitly and
  does not glob), an `allowed-tools` condition that demanded two incompatible things, and a
  digest-note condition already satisfied by committed text.

## Deliberately not in scope

- Re-deriving the 2026-07-18 digest's frequency claims (E4 especially) under the new filter.
  Recorded as a note in that digest; it is follow-on analysis, not this change.
- Any change to what harvest *writes* (digest + cursor only), the secret rule, the
  diff-against-HEAD rule, or `disable-model-invocation`.
