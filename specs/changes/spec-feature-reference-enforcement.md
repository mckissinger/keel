# Change — spec-feature reference enforcement: default-on, recorded, never retroactive

## Why

The 1.6.0 flow-research provision in `spec-feature` Movement 1 is permissive ("may be
consulted"), and permissive prose in a skill is keel's weakest enforcement — a session that
skips it leaves no trace. The same weakness sits in Movement 2's novel-archetype case, where
the divergence sketch "may be fed" by a reference pull. A downstream project's post-mortem
(the visual-reference-pipeline confession) showed the concrete failure shape: reference work
skipped or run after the fact, then citations stapled on retroactively —
lineage-as-annotation, not lineage-as-derivation.

## What changes (one milestone)

Every design-reference-MCP touchpoint in `spec-feature` becomes **default-on when a source
is connected, recorded always, and never retroactive**:

1. **Movement 1 (flows):** when a design-reference MCP is connected and the feature has
   user-facing flows, the flow-level pull *runs* (subagent-delegated per
   `visual-reference.md`'s mechanics) rather than *may run*. The no-MCP floor stays: text-only
   is a recorded mode, never a hard dependency.
2. **The record:** `specs/features/<feature>.md` carries a mandatory one-line
   `flow research:` entry — the mode that ran plus the findings that became UX-completeness
   done-conditions, or an explicit `skipped: <reason>` (e.g. no user-facing flow).
3. **Movement 2 (looks, novel-archetype sketch case only):** when a divergence sketch is
   being generated and an MCP is connected, the reference pull per `visual-reference.md`
   runs by default, and its lineage (reference URLs + extraction notes) is recorded in the
   feature spec. Lineage may cite only pulls that **preceded** the sketch — retroactive
   citation is banned. Pure recomposition stays reference-free (unchanged guard).
4. **Autonomy modes:** the recorded lines double as the run-ledger record; no new gate.

## What does not change

The flows-not-looks boundary (Movement 1 findings land only as UX-completeness
done-conditions; visual pulls stay gated at the novel-archetype case). The done-condition
standard, the plan pass, the plan-PR shape. No scripts, hooks, or gates — this is skill
prose, enforced by artifact (the recorded lines a verifier can check), the same mechanism as
"tell the user which mode ran."

Milestone: `specs/milestones/spec-feature-reference-enforcement.md`.
