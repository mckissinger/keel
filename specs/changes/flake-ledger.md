# Change — flake-ledger

One milestone, no-UI — prose plus one new convention directory and one new anchor
file. (Note: the *change grain* is documentation-only, but the milestone's **build**
edits code paths — `references/milestones-and-verification.md` and
`skills/status/SKILL.md` — not just plan paths, so the later build PR carries a
`verified:` pin; only *this* plan PR is plan-only. It is not a "plan-only" build.)
Adopt CRE's concrete **flake-tracking practice** — flakes recorded as
**files carrying measured reproduction rates**, escalated by hit count, closed in
a batch chore — as a lightweight `specs/flakes/` convention, referenced from the
test-authoring doctrine (§8 of `references/milestones-and-verification.md`) and
surfaced in `skills/status/SKILL.md` alongside the deferrals ledger. Harvest slate
Unit 4 (B5), review `specs/reviews/2026-07-18-harvest.md` lines 173–193.

## Why

The motivating observation is B5: a `lessons/` file
(`full-e2e-suite-when-touching-shared-render-path.md`) reached **five recorded
repeats** — and had already concluded, after repeat four, that its rule should be
"a hard pre-pin checklist item, not a judgment call" — then recurred three more
times. **Documentation is not an enforcement mechanism.** A prose note that a
class of failure keeps happening does not give the next session anything to *act*
on; it re-litigates "is this real?" from scratch each time.

**This is adoption of a good pattern, not remediation of a recurring defect, and
not the superseded threshold mechanism.** An earlier draft of B5 proposed a
generic *repeat-count threshold* — promote a `lessons/` file into a remediation
milestone after N repeats. **That is explicitly superseded and must not be
built.** The replacement is CRE's proven practice: a flake is tracked as a **file**
recording its **measured reproduction rate** (`2/6 clean main`, `1/5 prod only`,
`~50 runs to slug exhaustion`), its **hit count** rising as it recurs, and its
**closing condition**; the batch is drained by a chore (in CRE, closed by
`specs/chores/e2e-harness-reliability.md`). The point is that it gives a verifier a
recorded rate to **classify a new observation against** instead of re-deciding
whether a flake is real every session. **Correction on framing:** those flake
files were a **one-time batch** in CRE, not a standing ledger, and they are *not*
in CRE's `deferrals/` (that directory holds feature deferrals). So keel adopts the
*shape* — file-per-flake with measured rates, drained by a batch chore — as a
standing lightweight convention, justified as importing a practice proven in use
rather than inventing an escalation machine here.

## Decisions taken

- **Home: a `specs/flakes/` directory, file-per-flake, drained by a batch chore** —
  mirroring how `specs/deferrals/` (file-per-entry, `README.md` documenting the
  convention) and the punch-list chore lane already work. A `specs/flakes/README.md`
  documents the convention and the file shape; the directory starts otherwise empty
  (keel has no open flakes today — adoption, not backfill). This deliberately reuses
  the file-per-entry discipline (§4 of the shared rules) so parallel branches never
  collide on a shared ledger.
- **A flake file's shape** (documented in the README, one `<slug>.md` per flake):
  **id/slug**; the **spec or test path** it attaches to (the suite/spec/surface);
  the **measured reproduction rate(s)** in CRE's form (`2/6 clean main`,
  `1/5 prod only`, `~50 runs to slug exhaustion` — a measured fraction or count, not
  "sometimes"); a **hit count** that rises each time the flake recurs; **first-seen
  and last-seen** dates; and the **escalation / closing condition** (what hit count
  or evidence escalates it, and what closes it — the batch chore that drains it).
- **Referenced from the test-authoring doctrine (§8).** A new rule is appended to
  §8 of `references/milestones-and-verification.md` (the cross-stack test-authoring
  doctrine) naming the `specs/flakes/` convention: when a run-to-convergence check
  surfaces a real flake, it is **recorded as a file with its measured rate**, not
  left as a re-litigated judgment; the rule points at the convention's home and
  cites (does not restate) `verify-milestone`'s run-to-convergence hard rule as the
  *detection* owner and the batch chore as the *drain*. §8's existing eight rules
  keep their numbers and text; this appends as the next-numbered rule.
- **Surfaced in `status` alongside deferrals.** `skills/status/SKILL.md` already
  lists open `specs/deferrals/` in its Sources sweep and Output contract (E5 added
  the deferrals section). Open `specs/flakes/` entries are added to both — the same
  read-only, one-line-each surfacing — so a flake with a rising hit count is visible
  at "where are we / what's next" and does not depend on anyone remembering the
  directory exists. Status still writes nothing.
- **One anchor file, `scripts/skill-anchors/flake-ledger.txt`** — positive anchors
  on the §8 rule's operative clause (measured reproduction rate + file-per-flake +
  batch-chore drain) and on the status surfacing sentence, so a later reword can't
  silently gut either. No retirement anchors: nothing is removed (pure adoption).

## Deliberately not in scope

- **No repeat-count-threshold mechanism, and no auto-promotion of a flake into a
  milestone.** The superseded B5 draft is not built; escalation is by recorded hit
  count that a human/verifier reads, not by an automated N-repeats trigger.
- **No new CI gate or lint over `specs/flakes/`.** `check-plan.sh` scans
  `specs/milestones/` and `specs/chores/` only; the flake ledger is a convention,
  not a gated artifact. (A future lint over flake-file shape is a possible later
  `spec-change`, explicitly not this one.)
- **No backfill of historical flakes.** keel has no open flakes to record; the
  directory is established empty. The `lessons/` file that motivated B5 is not
  migrated — lessons and flakes are different artifacts (a lesson is a durable
  learning; a flake is a tracked, measured, closable instance).
- **No change to `verify-milestone`'s run-to-convergence hard rule** — it stays the
  detection owner; this change only gives what it detects a recorded home.

## Milestone

`specs/milestones/flake-ledger.md` — creates `specs/flakes/README.md`, edits
`references/milestones-and-verification.md` (§8 new rule),
`skills/status/SKILL.md` (Sources + Output contract), and adds
`scripts/skill-anchors/flake-ledger.txt`.
