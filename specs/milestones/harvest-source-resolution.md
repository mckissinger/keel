# Milestone — Harvest enumerates its sources and filters for human input

**Goal:** a harvest run derives its sweep set by enumeration from a defined floor, distinguishes
a broken enumeration from a quiet week, advances that floor only when it actually covered
everything, and extracts human input rather than machine text sharing the user role.

**Change:** `specs/changes/harvest-source-resolution.md`. **No-UI** → two-dimension
done-conditions. **Depends on:** none. **Parallelizable:** n/a (single milestone).

**Draft 9.** Eight prior drafts failed. Drafts 7 and 8 both returned no CRITICAL and every
empirical claim re-measured exactly; what kept failing was the *verification scheme*, three
drafts running, always the same way — **the plan reasoned about the verifier's constraints from
memory rather than from `agents/verifier.md:12-13`**, so each fix assigned an action the verifier
may not take (edit the tracked cursor → create scratch files) or checked a ref that cannot hold
the content sought (`HEAD` is the change commit at verification time, so it shows post-change
text). Draft 9 derives every verifier action from that file directly: **no file creation, no
mutation, Bash for observation only.** Everything below is performable with env vars, `git show`
against a pre-change ref, and reads.

## Done-conditions

### Logic / invariants

- [auto] **The floor is one watermark line in `specs/reviews/harvest-cursor.md` at a fixed
  location in a fixed format**: the first line of the file body, immediately under the H1, of the
  form `**Watermark:** YYYY-MM-DD`. `skills/harvest/SKILL.md` carries the literal command that
  reads it. Draft 5 said "one labelled watermark line" and left the label, format, and position
  open — three builders, three unparseable files.
- [auto] **"Newer than the watermark" is defined exactly, in one sentence in
  `skills/harvest/SKILL.md`: file mtime, inclusive of the watermark date itself** — a session
  file counts if its mtime falls on or after the watermark day. Both axes are pinned deliberately,
  because both have live divergence on the real store and each was silently readable three ways:
  - **mtime, not the session's internal timestamp.** They differ by days in both directions on
    real files (a resumed session gets a fresh mtime). mtime is chosen because its error direction
    is **over-inclusion** — a resumed old session gets re-swept, costing spend. The internal
    timestamp's error direction is under-inclusion, which is the exact defect this change exists
    to end. When the two candidate predicates fail differently, take the one that fails toward
    waste.
  - **Inclusive, not strictly-after.** 8 top-level files sit exactly on 2026-07-18; strict
    comparison drops a full day at every advance, silently.

  The verifier computes its own counts with **this same stated predicate**, so a build reading it
  either other legal way is bounced rather than accommodated.
- [auto] **The watermark is seeded `2026-07-18`, and the seed is recorded as a deliberate
  write-off**: **27** directories absent from the cursor's table hold **126** older sessions
  (`-Users-michaelkissinger-keel` 21, `-Users-michaelkissinger-cre-list` 33,
  `-Users-michaelkissinger-jarvis-2-0` 13, and others) which this floor places permanently out of
  scope. **"Never-listed" means absent from the table**, which is the mechanism that decided what
  got mined — not "unmentioned anywhere in the file." The distinction is load-bearing and cost
  draft 7 a finding: `-Users-michaelkissinger-cre-list` appears in the ⚠ prose but never in the
  table, so under the narrower reading the count is 26/93 and that directory is not a member —
  while both drafts named it as an exemplar. Prose mentions never caused a session to be swept. Enumeration fixes the defect **prospectively only**, and the file says so — an unstated
  floor reads as verified coverage, which is precisely the failure this change exists to end.
- [auto] **The watermark advances only when every enumerated source produced a returned miner
  report.** The discriminator is **returned vs did-not-return, not findings vs no findings**: a
  miner that reports "nothing of note in these sessions" is a *complete* result and does not hold
  the floor. Incomplete means a miner errored, was skipped, or its dispatch was aborted. On an
  incomplete run the watermark does not advance and the digest names the uncovered sources.
  Draft 5 said "returns empty or errors", which would have frozen the floor forever — most miners
  legitimately return little (the 2026-07-18 run: eleven miners, roughly ten claims).
- [auto] **The mining method begins with enumeration, and the command is committed verbatim into
  `skills/harvest/SKILL.md`** — returning `directory<TAB>count<TAB>newest-date` per immediate
  subdirectory of `~/.claude/projects/` holding at least one top-level `*.jsonl` newer than the
  watermark. **`count` is the watermark-filtered top-level session count**; `newest-date` is the
  newest qualifying file's mtime, and both are used in the scope announcement.
- [auto] **The watermark is a parameter the command reads, overridable by one environment
  variable.** The committed command resolves it as
  `WM="${HARVEST_WATERMARK:-$(<extraction from specs/reviews/harvest-cursor.md>)}"` and compares
  against `$WM` — the cursor is the default and the only source a real run uses. The override
  exists for exactly one reason: it is the **only discriminating watermark-varying method a
  read-only verifier can perform.** `agents/verifier.md:12` bars editing files, writing files,
  and file creation outright — not merely touching tracked files — so both earlier proposals were
  dead: editing the tracked cursor (draft 6) and writing scratch cursor copies (draft 8) are the
  same prohibition one step apart. Substituting a date into copied command text is permitted but
  does not discriminate, since a hardcoded build's literal is exactly what gets substituted.
  Setting an env var mutates nothing and discriminates.
- [auto] **No date literal appears anywhere in the committed command.** Enforced two ways, because
  a fixed-string anchor can only ever guard one spelling: a **negative anchor on `2026-07-18`**
  for the cheap case, plus a **verifier assertion that the command block matches no
  `[0-9]{4}-[0-9]{2}-[0-9]{2}` pattern at all**, which catches `2026-07-17`, `18 Jul 2026`, and
  every other spelling a `grep -F` anchor cannot. Without this, a build with the seed hardcoded
  satisfies every count assertion identically to a correct one — and silently makes the whole
  watermark-advance rule inert, since advancing a value nothing reads changes nothing.
- [auto] **`skills/harvest/SKILL.md`'s `allowed-tools` grant covers every command the committed
  blocks invoke — stated as a closure rule, not a fixed list.** The condition is: *every
  executable named in the committed enumeration and extraction blocks has a matching
  `Bash(<cmd> *)` entry in the frontmatter grant.* A fixed list goes stale the moment the
  builder's pipeline differs by one utility — draft 8 named `find` and `stat` and missed `sort`,
  which the `newest-date` derivation needs — and a skill that prompts on every run breaks the
  grant's own stated rationale ("so the mining runs promptless") through the very change that
  depends on it. The verifier checks the closure mechanically: extract command names from the
  blocks, diff against the grant, assert empty. Grant additions are the one frontmatter change
  the no-weakening condition below licenses.
- [auto] **The two real-layout hazards are stated as two separate guards, correctly attributed.**
  (a) **`-maxdepth 1`** — nested subagent transcripts are not sessions; one directory holds 10
  top-level entries against a recursive total an order of magnitude larger. (b) **The directory
  argument is always a full path, never a bare basename** — every transcript directory name
  begins with `-`, which `find` consumes as an option flag and errors on; **quoting does not fix
  this**, a path prefix does. Quoting is a *separate* guard, for the several names containing
  spaces. Draft 5 credited the dash hazard to quoting and would have anchored that error
  verbatim; verified false at authoring time — `find "-Users-…" -maxdepth 1` errors, while the
  same name reached through `~/.claude/projects/*/` expansion returns 10.
- [auto] **Step 1 is default-scope, and `retro`'s scoping is left open.** The skill states that
  `retro` does not run the enumeration and enters the ladder at the human-input recipe; it does
  **not** say what `retro` sweeps instead. Draft 5 wrote "scoped to its own project's directory",
  which is the singular-directory assumption the change document proves false (CRE Launch spans
  two directories sharing no discriminating substring). The scoping is a deferral, and a deferred
  question is not answered in passing.
- [auto] **A zero-row enumeration is disambiguated before it is reported.** Zero rows is the
  *expected* result of a quiet week, so stopping unconditionally cries wolf and reporting
  "nothing to mine" unconditionally reproduces the defect. The skill names the discriminator:
  **re-run the enumeration with no floor** — zero rows there means a broken or mistyped root and
  the run stops and asks; non-zero means genuinely nothing new since the watermark.
- [auto] **Every enumerated source is mined, and the retired name-matching mechanism is removed
  wherever it appears.** Five sites, all named because successive passes found each still standing
  behind a narrower removal scope:
  1. `skills/harvest/SKILL.md` — the `per-source through-mark` rule.
  2. `skills/harvest/SKILL.md` — the cursor section's framing of the file as a per-source coverage
     lookup, **and both occurrences** of `never re-mine covered sessions` (the section heading and
     the prose sentence below it). Naming only the heading leaves the prose standing and the
     negative anchor then fails the build it was meant to pass.
  3. `specs/reviews/harvest-cursor.md` — the contract sentence stating sources are identified by
     directory name `so a run can match them mechanically`, and the
     `newer than each source's through-mark` rule.
  4. `specs/reviews/harvest-cursor.md` — the ⚠ Path drift section's interim instruction to
     `reconcile them against this table`, whose
     `Until harvest resolves sources by project identity` clause this change satisfies —
     **capital `U`**, as it occurs in the file; draft 7 quoted it lowercase, which `grep -F`
     matches nowhere. The incident narrative stays as provenance; the instruction goes.
  5. `specs/reviews/harvest-cursor.md` — the closing note that the 2026-07-18 harvesting session
     `remains available to a later run`. Under an inclusive 2026-07-18 floor that promise is now
     kept by the floor itself rather than by the note; either way the note must be reconciled
     rather than left as an unbacked commitment.

  **Merged milestone specs are historical and are not edited** — `specs/milestones/harvest-verb.md`
  carries the retired literals as a record of what was decided then, and stays as it is.
- [auto] **The cursor's `through` column is removed, the table is relabelled** a historical
  coverage record — read for provenance, never consulted to decide what to mine — **and its
  duplicate rows are collapsed.** Three directories currently occupy two rows each, the second
  carrying a `+N` session count that only parses against the through-mark being deleted. One row
  per directory, with the total sessions covered and the date range spanned. Draft 7 removed the
  column and left the `+N` notation orphaned.
- [auto] **The signal ladder's step 1 carries the executed recipe.** Inclusion: entries whose
  **top-level** `.origin.kind` is `human`, plus **non-empty** `<command-args>` content — typed
  slash-command arguments, human intent inside a machine envelope. Exclusion: `tool_result`
  content, `task-notification` origin, `<command-name>` / `<command-message>` /
  local-command-caveat envelopes, injected skill bodies. The path is `.origin.kind`, **not**
  `.message.origin.kind` — the latter returns nothing for all 617 user entries in the sampled
  session, so that one wrong character yields zero human entries while satisfying every prose
  condition. **The sampled session is named in the spec, not left for the verifier to find**:
  `~/.claude/projects/-Users-michaelkissinger-Dev-Projects-cre-list/d89b3abb-b161-4557-b589-73f9fdec3e66.jsonl`
  — 617 user entries, and it also carries the two non-empty `<command-args>` entries the
  inclusion arm needs.
- [auto] **The step states plainly that `type=="user"` alone is not a human-input filter**,
  carrying the measured scar: 26 `human`, 46 `task-notification`, 545 with no origin field, of
  which 521 are `tool_result` — roughly 24× more than actual human input.
- [auto] **The fan-out dispatch guidance requires each miner to be given the recipe**, since
  miners inherit the harness and not the skill body.
- [auto] **The run announces scope before dispatching any subagent**: session count, source
  count, watermark date.
- [auto] **`retro` scope is an open deferral, not a guess.** `specs/deferrals/harvest-retro-scope.md`
  records
  that `retro`'s narrowing rule is unresolved — name-matching is what broke, and the two CRE
  Launch directories share no discriminating substring — closing condition: the first genuine
  `retro` run, which asks the user for its bound. The skill points at it.
- [auto] **`scripts/skill-anchors/harvest.txt` anchors verbatim sentences, not concepts.** Each
  positive anchor is a **full sentence carrying its rule's operative clause** — covering
  `-maxdepth 1`, the **full-path** guard (not the quoting guard), `.origin.kind`, the
  enumerate-first rule, and the zero-row discriminator. **Negative anchors come in two classes,
  and only one of them is confirmable** — draft 8 collapsed them and produced a condition no
  assignment could satisfy:
  - **Retirement anchors** guard text being *removed* (the five removal-site literals). These are
    confirmed present in pre-change content, per the rule below.
  - **Prohibition anchors** guard text that must *never* appear — here, `2026-07-18` in
    `skills/harvest/SKILL.md`, where it has never occurred. **These are exempt from the
    confirm-present rule by definition**: requiring a forward-looking prohibition to have existed
    first is unsatisfiable, and chasing "the file it actually occurs in" instead lands the anchor
    on the cursor, where the seed line guarantees permanent failure.

  Two authoring rules, both learned from anchors that would have passed vacuously:
  - **Name the right file.** `per-source through-mark` occurs only in `skills/harvest/SKILL.md`;
    the cursor's wording is `newer than each source's through-mark`. One anchor covering both
    files passes vacuously on one of them.
  - **Every anchor literal must occur on a single line, confirmed by `grep -cF` returning
    non-zero — and for a retirement anchor the confirmation runs against the *merge-base*:
    `git show "$(git merge-base HEAD main)":<path> | grep -cF`.** Not `HEAD`: by the time the
    verifier runs, `HEAD` **is** the change commit, so `git show HEAD:<path>` returns the
    post-change file with the literal already deleted and the check returns 0 by construction —
    draft 8's rule bounced every retirement anchor for exactly the reason it was written to
    prevent. The merge-base is the last commit before this change and is the only ref that holds
    the pre-change text. It is read-only, satisfying `agents/verifier.md:12`.
    `check-skill-anchors.sh`
    matches fixed strings line-by-line and case-sensitively, so a literal that spans a line break
    or differs in case matches nothing and guards nothing — draft 7 shipped one of each.

  `bash scripts/check-skill-anchors.sh` green.
- [auto] **No weakening.** Unchanged in the diff: the secret rule, diff-against-HEAD, the
  writes-only-digest-and-cursor rule, **"No cursor in the target repo = ask"**,
  `disable-model-invocation: true`, the two-scope structure, and the
  fan-out-via-read-only-subagents instruction.

### Behavioral completeness

- [auto] **The verifier proves the committed enumeration discriminates against both broken
  builds, by measurement rather than by a bound.** It computes three counts for one directory it
  selects at run time (any directory where the three differ — not hardcoded to keel, whose
  activity varies), **each computed with the freshness predicate defined above: mtime, inclusive**:
  - **A** = top-level, watermark-filtered — what the committed command must emit for that row
  - **B** = recursive, watermark-filtered
  - **C** = top-level, unfiltered

  Assertions: the emitted count **equals A**, and **A < B** (proves `-maxdepth 1` is present) and
  **A < C** (proves the watermark filter is present). If no directory yields three distinct
  values, the verifier reports the check **inconclusive and escalates** — it does not pass by
  default. Draft 5 asserted only "emitted < unfiltered recursive", which measurement showed is
  satisfied by dropping `-maxdepth 1` (32 < 153) *and* by dropping the watermark (10 < 153) — it
  passed both builds it existed to reject. At draft-6 authoring six directories satisfied the
  three-distinct-values requirement, so an inconclusive result is unlikely but not assumed away.
- [auto] **The verifier proves the watermark is read, not hardcoded, by varying `HARVEST_WATERMARK`
  — creating nothing, mutating nothing.** It runs the committed command twice: once with the
  variable unset (the cursor's seed), once with it set to **one day before the oldest top-level
  `*.jsonl` mtime anywhere under `~/.claude/projects/`**, measured at run time so the second run
  is guaranteed to admit strictly more sessions rather than depending on a lucky pick. It asserts
  the two runs **emit different row counts**. A build with the date typed into the command emits
  identical output both times and is bounced. Measured at draft-9 authoring, the spread is wide:
  the seed yields 7 rows, the floor-date run 39. Combined with the no-date-literal assertion
  above, this closes the hardcoded-watermark hole that draft 6 left and drafts 7 and 8 each
  stated in a form the verifier could not execute.
- [auto] **The verifier proves the sweep set is derived from the filesystem, not from the
  cursor.** The committed enumeration command's text contains **no reference to the cursor's
  table**, and its output contains **more than one row**. This is the property the whole change
  exists for; draft 5 asserted only on a single directory already listed in the cursor, which an
  enumeration that read the old list would have satisfied.
- [auto] **The `newest-date` column is asserted, not merely specified.** For the selected
  directory, the emitted `newest-date` equals the mtime date of the newest qualifying top-level
  file, computed independently. Draft 6 specified the column and never checked it.
- [auto] **The verifier runs the committed extraction recipe against the named session
  (`d89b3abb-b161-4557-b589-73f9fdec3e66.jsonl`) and asserts three things**: a **non-zero** count
  of `.origin.kind == "human"` entries; **at least one** line derived from `<command-args>` — that
  session carries two non-empty ones, both with `origin.kind` absent, so the inclusion arm is
  genuinely exercised rather than passing through the `human` branch; and **zero** lines matching
  `<command-name>`, `<command-message>`, `<local-command`, or `Base directory for this skill`.
  The first catches the wrong-field-path failure; the third catches envelope leakage that the
  first attempt at this recipe actually exhibited (38 lines where 28 were real).
- [auto] **`specs/reviews/2026-07-18-harvest.md`'s existing caveat is upgraded to a citation** —
  the line cites the shipped recipe by location and states re-derivation is available. No finding
  is rewritten.

verification: fresh-context verifier subagent against this spec, **executing the enumeration and
extraction commands and `bash scripts/check-skill-anchors.sh` itself**, plus the standing suites
(`check-skill-frontmatter`, `check-neutral`, `check-plan`, `claude plugin validate --strict .`).
No runtime walk — skill/reference text, one anchor file, one deferral entry; the executed
commands are the runtime proof.

## Accepted limitation — stated, not hidden

**Text is a weaker control than a program.** Nothing forces a session to run the enumeration;
the anchors keep the instruction present and correct, not obeyed. Three things make that
proportionate: harvest is `disable-model-invocation` and human-triggered, so a human is present
at every run; the scope announcement surfaces the sweep set before spending; and the verb runs
occasionally, not on a schedule. **If harvest ever becomes scheduled or self-invoked, this
tradeoff expires** and the script version — mapped in detail by the adversarial passes in this
branch's history — is the correct successor.
