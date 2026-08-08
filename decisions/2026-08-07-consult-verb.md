# 2026-08-07 — The consult verb: one mechanism, two policies, no rename

## The decision

The consult mechanism (distill one question → dispatch the read-only `oracle` → recommendation +
rationale + disposition) is broadened from autonomy-only to a first-class attended verb,
`skills/consult/SKILL.md`, which owns the mechanism once. The autonomy consult contract in
`skills/auto/SKILL.md` keeps every policy clause (mode-gating, judgment-only boundary, 5-cap,
disposition halts, ledger) and cites the new skill for mechanics. The `oracle` agent is **not**
renamed. Spec: `specs/changes/consult-verb.md` + `specs/milestones/consult-verb.md`.

## Why one skill, not two (or zero)

The owner had been consulting Fable 5 off-the-cuff — debugging tie-breaks, design choices, spec
ambiguity — and finding it consistently useful. Splitting per-context verbs (`consult`,
`debug-consult`, `plan-consult`) would manufacture skills around one behavior; the debug call
site is a one-line citation (and any future call site would be the same), the way eight skills
cite the ledger contract. Skipping
the skill entirely (dispatch the agent ad hoc) loses the two things the habit lacks: the forced
brief distillation, and a durable `decisions/` record for adopted durable choices.

## Why attended semantics differ, deliberately

The cap and the disposition halts exist because an unattended run has no human to catch a bad
consult. Attended, the user *is* the cap, `uncertain` just continues the conversation, and an
authorization-shaped question is simply the user's to answer — so the skill states those relaxed
semantics itself rather than inheriting halt choreography that would misfire. What survives in
both postures: an oracle consult is never how an authorization question gets answered.

## Why no rename

Keel's naming is agents-as-role-nouns, skills-as-verbs (`verifier`/`verify-milestone`); `consult`
dispatching `oracle` mirrors it exactly. The name is also load-bearing in four just-shipped
1.25.0 sites (routing row, contract dispatch clause, anchor file — which per the file-per-feature
rule a later feature never edits — and the judgment-oracle decision record); a cosmetic rename one
release later is churn with no semantic gain.

## Recorded parameters

- Model-invocable (no `disable-model-invocation`): consulting grants nothing and mutates nothing,
  so self-invocation carries none of the risks that keep `auto` human-triggered.
- No cap attended; decision tail is offer-only (ask, never auto-write).
- Routing: `consult` in the default list (`inherit`/`high`); the coverage-audit drift
  (`arm-auto-merge`, `prep-auto-merge` missing, count stale at 29) is repaired in the same
  milestone.
