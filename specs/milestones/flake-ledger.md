# Milestone — flake-ledger

Change context: `specs/changes/flake-ledger.md`. One milestone, no-UI (keel is a
methodology plugin — skills/ and references/ are the product); prose plus one new
convention directory and one new anchor file. Creates
`specs/flakes/README.md`; edits `references/milestones-and-verification.md` (a new
rule appended to §8) and `skills/status/SKILL.md` (Sources sweep + Output
contract); adds `scripts/skill-anchors/flake-ledger.txt`. No scripts, gates,
hooks, or templates move; no existing §-reference renumbers.

**Integration seams** (this change touches files other contracts read):

- **§8 of `references/milestones-and-verification.md`** ends today at rule 8
  ("Retry budgets are CI-only, waits are explicit"). The new rule **appends as the
  next-numbered rule (9)** and must not renumber or contradict rules 1–8. §8 rule 2
  already defers verification-side flake handling to its owner — the new rule cites
  that same owner (`verify-milestone`'s run-to-convergence hard rule) as the
  *detection* seam and must not restate or relocate it.
- **`verify-milestone`'s run-to-convergence hard rule** (in that skill's hard
  rules, *not* a §-number of the shared rules file) is the detection owner: it stays
  unchanged; the new §8 rule names it by that home, never as a §-number.
- **`skills/status/SKILL.md`** already surfaces open `specs/deferrals/` in both its
  **Sources** list and its **Output contract** (E5's deferrals section, output
  contract item 4). Open `specs/flakes/` entries are added to those same two places,
  in the same read-only one-line-each shape, **without disturbing the deferrals
  surfacing** and without changing status's write-nothing / derive-don't-store
  contract or its ~twenty-line budget.
- **`specs/flakes/` vs the CI gates**: `scripts/check-plan.sh` scans
  `specs/milestones/` and `specs/chores/` only, so a new `specs/flakes/` directory is
  invisible to it (no gate over flake files is added — a decision, per the change
  context's out-of-scope). `specs/flakes/` is a **plan path** (`specs/**`, §5) so
  its files never trip the verified-pin gate.

## Done-conditions

- [auto] **`specs/flakes/` convention exists with the documented file shape.** A new
  `specs/flakes/README.md` establishes the directory as a **file-per-flake**
  convention (one `<slug>.md` per flake) drained by a **batch chore**, explicitly
  paralleling `specs/deferrals/`. It documents the required flake-file shape naming
  **all** of: id/slug; the spec-or-test path the flake attaches to; the **measured
  reproduction rate(s)** (in CRE's measured form — a fraction or count such as
  `2/6 clean main`, `1/5 prod only`, `~50 runs to slug exhaustion`, not a vague
  "sometimes"); a **hit count** that rises on recurrence; **first-seen and last-seen**
  dates; and the **escalation / closing condition** (what escalates by hit count and
  what closes it — the draining batch chore). The directory carries no flake entries
  at adoption (no backfill). *Falsifiable:* a README missing any of the six shape
  fields, or omitting the measured-rate requirement, or describing a repeat-count
  threshold, fails.
- [auto] **§8 gains a rule naming the flake ledger, appended not renumbered.**
  `references/milestones-and-verification.md` §8 gains a **new rule numbered 9**
  after the existing rule 8, whose operative clause states that a flake surfaced by a
  run-to-convergence check is **recorded as a file in `specs/flakes/` carrying its
  measured reproduction rate**, **escalated by hit count**, and **closed in a batch
  chore** — so a verifier has a recorded rate to classify a new observation against
  instead of re-litigating "is this real?" each session. The rule **cites** (does not
  restate) `verify-milestone`'s run-to-convergence hard rule as the detection owner,
  by that home and never as a §-number. Rules 1–8 keep their numbers and text.
  *Falsifiable:* the rule missing the measured-rate / hit-count / batch-chore triad,
  or renumbering any of rules 1–8, or restating the convergence rule inline, fails.
- [auto] **No threshold mechanism, no auto-promotion.** Neither the README nor the
  §8 rule describes a repeat-count-threshold that promotes a flake (or a `lessons/`
  file) into a milestone after N repeats — the superseded B5 draft. Escalation is by
  a **recorded hit count a reader acts on**, never an automated N-repeats trigger.
  *Falsifiable:* any "after N repeats, promote/escalate automatically" mechanism in
  either file fails this condition.
- [auto] **`status` surfaces open flakes alongside deferrals.**
  `skills/status/SKILL.md` names `specs/flakes/` in its **Sources** sweep and adds an
  **open-flakes surfacing** to its Output contract — one line per open flake (slug,
  the attached path, its measured rate and hit count), in the same read-only shape as
  the deferrals section, appearing even when the list is empty-or-short as a count.
  The existing deferrals sweep + section are unchanged. *Falsifiable:* status
  surfacing flakes only inside the deferrals bullet (conflated), or dropping/altering
  the deferrals surfacing, or adding any write/mutation to status, fails.
- [auto] **No weakening of the contracts this edit borders.** The edit must preserve:
  (a) §8 rules 1–8 and §-reference stability across `skills/`, `references/`,
  `workflows/` — repo-wide grep finds no §-citation broken by the append, and no
  pre-existing "§9" citation whose meaning the new rule breaks; (b)
  `verify-milestone`'s run-to-convergence hard rule, unmoved and unrestated; (c)
  status's **derive-don't-store / write-nothing / ~twenty-line** contract and its
  existing deferrals surfacing; (d) the `specs/deferrals/` convention (this change
  adds a sibling directory, it does not fold flakes into deferrals — a flake and a
  deferral remain distinct artifacts). *Falsifiable:* any of these four invariants
  regressing fails.
- [auto] **Anchor file guards the load-bearing sentences.** A new
  `scripts/skill-anchors/flake-ledger.txt` declares **positive** anchors — a full
  sentence from the §8 rule carrying its operative clause (measured reproduction rate
  + file-per-flake + batch-chore drain) and a full sentence from the status open-flakes
  surfacing — each confirmed present verbatim on a single line in its named file.
  `scripts/check-skill-anchors.sh` passes. No negative anchors are required (pure
  adoption; nothing is removed). *Falsifiable:* a missing anchor file, or an anchor
  string not present verbatim, fails the lint.
- [auto] **Repo checks green.** `claude plugin validate --strict .`,
  `scripts/check-neutral.sh`, `scripts/check-plan.sh`,
  `scripts/check-skill-frontmatter.sh`, `scripts/check-skill-anchors.sh`, and every
  `scripts/*.test.sh` pass on the branch.

## verification

verifier subagent against this file's done-conditions (all `[auto]`; no-UI,
prose-plus-convention — closable by reading the named files and running the named
checks). No `[runtime]` conditions exist (keel has no runtime surface); the standing
suites plus a fresh verifier subagent are the verification.
