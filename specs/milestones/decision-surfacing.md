# Milestone — decision-surfacing: builder-flagged uncertain choices at the build→verify handoff

**Goal:** `implement-milestone` surfaces the genuine judgment calls it made under ambiguity as
file-per-entry records; `verify-milestone` reports them for the human to adjudicate at the existing
attended gates — a complement to verification that weakens no code-level check.

**Change:** `specs/changes/decision-surfacing.md`. **No-UI** → two-dimension done-conditions.
**Depends on:** nothing. **Parallelizable:** no (single coupled edit to two skills + one reference).
**Routing:** reasoning-heavy — edits build/verify handoff doctrine.

## Done-conditions

### Logic / invariants
- [auto] `skills/implement-milestone/SKILL.md`'s handoff step (step 8) instructs the builder to write
  **zero or more** file-per-entry records under `specs/uncertainties/<milestone-slug>/` (one file per
  choice), each naming: the choice made, the viable alternative(s) considered, and why it's uncertain.
  The prose states the write happens **before** handoff to `verify-milestone`, on the milestone branch.
- [auto] The **logging bar** is stated in `implement-milestone` prose exactly as the three-part test: a
  choice is logged only if (1) the builder selected among viable alternatives, (2) the spec did not
  dictate the selection, and (3) a reasonable reviewer could have chosen differently — and a
  milestone with no genuine uncertainty writes **no** entries (a clean handoff, explicitly not a gap).
  Two-readers bar: the three conditions and the "empty is clean" rule are present in the text.
- [auto] `skills/verify-milestone/SKILL.md` instructs the **`verify-milestone` skill session itself**
  (the orchestrator that has Read tools — **not** the read-only `verifier` subagent) to **read**
  `specs/uncertainties/<milestone-slug>/` and **include each entry, verbatim, alongside** the subagent's
  correctness report — surfaced, not adjudicated, and explicitly a **complement** to verification: it
  changes no done-condition check and does not treat a flagged choice as pre-cleared. `agents/verifier.md`
  is **not** edited (its read-only report of correctness is unchanged; the uncertain-choices read lives in
  the orchestrating skill).
- [auto] **Complement-not-replacement invariant (stated in both skills + the reference):** the artifact
  adds a human-facing signal and removes nothing — the verifier still checks every done-condition, the
  pin gate is unchanged, and correctness-critical milestones keep their full treatment. No done-condition
  standard, no verifier-independence rule, and no pin-gate rule is edited by this milestone (git diff
  shows no edits to `scripts/check-verified-pin.sh` or `agents/verifier.md`'s read-only body/tools).
- [auto] `references/milestones-and-verification.md` documents the uncertain-choices artifact: its
  path (`specs/uncertainties/<milestone-slug>/`), the file-per-entry discipline (so parallel milestones
  don't collide), the three-part logging bar, and that it is a complement to — never a substitute for —
  the verification method already specified.
- [auto] Path + slug agreement: the write location in `implement-milestone` and the read location in
  `verify-milestone` are the identical `specs/uncertainties/<milestone-slug>/` string, **and both skills
  state that `<milestone-slug>` is derived from the milestone's canonical spec-file stem**
  (`specs/milestones/<slug>.md` → `<slug>`) — so the reader can never silently miss the writer's entries
  by resolving the slug differently.
- [auto] `specs/uncertainties/**` is a plan path (under `specs/`) so entries riding a milestone branch
  are covered by the plan-only handling and never trip the verified-pin gate as "code."

### Behavioral completeness
- [auto] **Calibration anchor (not a tautology):** because the three-part bar is an irreducible
  judgment call that two readers can genuinely split on, the milestone verifier does **not** grade an
  artifact's contents against reality (no `[auto]` condition does — usefulness is the `[attended]`
  dogfood's job). Instead, `implement-milestone`'s prose carries **at least one concrete worked example**
  — a specific, *unlabeled* build choice shown as loggable and one shown as not-loggable — so a builder
  has a calibration anchor rather than only the abstract test. Verifiable: the two worked examples are
  present in the prose.
- [auto] **Empty case:** the prose makes explicit that a milestone with no genuine uncertainty produces
  an empty/absent `specs/uncertainties/<milestone-slug>/` and that `verify-milestone` treats absence as
  a normal clean handoff (no entry to report), never as a missing-artifact failure.
- [auto] All pre-existing self-tests pass with no regression (`check-verified-pin`, `check-plan`,
  `check-skill-frontmatter`, `check-skill-anchors`, `check-neutral`); `claude plugin validate --strict .`
  passes.
- [attended] **Dogfood:** on the next real milestone built after this lands, the builder produces a
  short, genuinely-useful uncertain-choices list (or none, correctly), and the owner confirms at the
  `verify-milestone` report that it surfaced the right judgment calls without noise. This is the human
  judgment the mechanism exists to serve; no CI check can score "was the list useful."

## verification
verifier subagent against this file — every `[auto]` condition checked against the edited
`implement-milestone`, `verify-milestone`, and reference prose with `file:line` evidence (the handoff
write, the read+report, the three-part bar, the complement-not-replacement invariant, path agreement,
the gates-untouched git-diff assertion); self-tests trusted from the committed suites. **No
`/security-review`** — no hard invariant is touched (the artifact is advisory; the gates-untouched
condition is the proof). The `[attended]` dogfood is the owner's confirmation that the surfaced choices
are useful, which no CI check can observe.
