# Milestone — spec-feature-reference-enforcement

Change context: `specs/changes/spec-feature-reference-enforcement.md`. One milestone; edits
skill prose only (`skills/spec-feature/SKILL.md` + one clause in
`skills/review-feature/SKILL.md`). No scripts, hooks, gates, or templates
move. Integration seam: the paragraph and enumerations named below, plus the existing
cross-references (`visual-reference.md` mechanics, `review-feature`'s recorded-lineage
consultation) which must remain true afterward.

## Done-conditions

- [auto] **Movement 1 default-on.** The "Scoped reference research — flows, not looks."
  paragraph states that when a design-reference MCP is connected and the feature has
  user-facing flows, the flow-level pull **runs**, replacing the permissive "may be
  consulted". The cite to `visual-reference.md` is scoped to its **delegation mechanics
  only** — pull and distillation in a subagent, compact text back, never raw volume into
  the session; the extraction vocabulary is **flow-shaped** (states surfaced, step
  sequences, action placements), explicitly **not** that file's looks deconstruction pass
  (palette/type/density/depth), which stays banned in Movement 1. And the paragraph states
  the floor explicitly: with no design-reference MCP connected, proceed text-only and
  record that mode — a paid source is never a hard dependency.
- [auto] **The recorded artifact.** The feature-spec contents sentence (the one enumerating
  what `specs/features/<feature>.md` carries) names a mandatory one-line `flow research:`
  entry — the mode that ran plus the findings that became UX-completeness done-conditions,
  or `skipped: <reason>` for a feature with no user-facing flow — and, when a divergence
  sketch was generated, the sketch's reference lineage (URLs + extraction notes).
- [auto] **Movement 2 default-on with lineage, no retroactivity.** In the novel-archetype
  divergence-sketch case, the text states that when an MCP is connected the reference pull
  per `visual-reference.md` runs by default before the sketch (not "may be fed"); that the
  pull's lineage — reference URLs + extraction notes — is recorded in the feature spec; and
  that lineage may cite only pulls that preceded the sketch (retroactive citation banned).
  The pure-recomposition guard survives with **unchanged meaning** (paraphrase allowed;
  the guarantee that pure recomposition triggers no reference pull must remain explicit).
- [auto] **Boundary intact.** Movement 1 findings still land only as UX-completeness
  done-conditions (never tokens or visual choices), and looks-level pulls remain gated to
  the novel-archetype sketch case and nowhere else — the change adds no new visual-pull
  surface.
- [auto] **Autonomy-mode clause.** The "Under an active autonomy mode" section states that
  the `flow research:` line and any sketch lineage double as the run-ledger record for
  these steps — one clause, no new gate.
- [auto] **A named consumer for the lineage.** `skills/review-feature/SKILL.md`'s
  fidelity-to-intent bullet names the feature spec's sketch lineage as consultable
  supplementary context alongside the decision-file lineage it already cites — same
  standing (supplementary, never the reference itself), one clause.
- [auto] **Repo checks green.** `claude plugin validate --strict .`,
  `scripts/check-neutral.sh`, `scripts/check-plan.sh`, `scripts/check-skill-frontmatter.sh`,
  and `scripts/check-skill-anchors.sh` all pass on the branch.

## verification

verification: fresh-context verifier subagent against this spec + the
`skills/spec-feature/SKILL.md` and `skills/review-feature/SKILL.md` diffs vs `main` — every condition is prose-checkable `[auto]`
(read the changed paragraphs, confirm each stated property, run the five repo checks). No
`[runtime]` conditions: the deliverable is skill prose with no runnable surface; the
behavioral effect (sessions actually running the pull) is observable only in later
downstream spec-feature sessions, out of milestone scope by construction.
