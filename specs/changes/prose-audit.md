# Change — Fable-era prose audit + model-capability ledger

**Grain:** one change → one milestone (`spec-change`). **No-UI** (prose audit of keel's own
skills). **Stacked on:** nothing (targets `main`). **Build LAST** — it audits the final text of
every other change this cycle produced.

## Why (the gap)

Item 15 from the research pass, with official backing (@alexalbert__, 2026-06-09): "instructions
written for prior models anchor the model to stale patterns." keel's 15 SKILL.md bodies were
written across many sessions against older models; some carry over-prescriptive step-by-step
sequencing that anchors a stronger model (Fable/Opus-class) away from the objective. Anthropic's
current guidance is keel's own done-condition philosophy verbatim — "describe what done looks
like and how to verify it, then let the model find the path" — so the audit is bringing the
*prose* into line with the *principle keel already espouses*, not a new direction.

Two parts:
1. **The audit** — a pass over all 15 SKILL.md bodies for over-prescriptive sequencing that
   should become objective + verification, and for foreground-subagent assumptions now that
   background-by-default subagents ship (implement-feature / punch-list orchestration). This is
   a *judgment* pass: it must **not** flatten load-bearing sequence (branch-first, verify-then-pin,
   the confirm-before-author gate, the stacked-PR merge order are real ordering constraints, not
   stale prescription) — the audit tightens wording, never removes a guardrail.
2. **The model-capability ledger** — a dated `decisions/` entry recording which keel mechanisms
   compensate for model weakness (fine decomposition, instruction restatement) vs. which are
   permanent audit/permanence machinery (the verified-pin gate is explicitly marked
   **not-prunable** — it exists because confident self-validation is what a human can't audit).
   Plus a lens in `milestones-and-verification.md` §4: sizing tracks the running model's
   demonstrated horizon; over-fine decomposition is a cost (branch/PR/verify overhead), not a
   safety margin — prefer coarser where correctness stakes allow, without deleting the
   scar-backed parallel-collision guidance. (Source figures stated honestly: sprint-decomposition
   removal on Opus 4.6 cut cost ~38%, confounded — not "halved and improved output.")

## The mechanic

1. Audit each of the 15 `skills/*/SKILL.md` bodies; where sequencing is stale prescription,
   rewrite to objective + how-to-verify; where it's a load-bearing ordering constraint, leave it.
   Record the audit outcome per skill (changed / left-as-is-and-why) in the change spec's PR body
   so the judgment is reviewable. Correct any foreground-subagent assumption in implement-feature
   / punch-list prose to background-by-default.
2. Add `decisions/YYYY-MM-DD-model-capability-ledger.md`: the compensates-for-weakness vs.
   permanent-machinery split, verified-pin marked not-prunable, with the honest source figures.
3. Extend `milestones-and-verification.md` §4 with the horizon-sizing lens (coarser where stakes
   allow; parallel-collision guidance retained).

**Guardrail (the whole risk of this change):** the audit must preserve every real invariant. A
done-condition enumerates the ordering constraints that may **not** be flattened; the verifier
checks that none were lost. This is why it builds last and why its verification is heavier than a
normal prose change.

## Scope

Prose across the 15 `skills/*/SKILL.md`, one new `decisions/` entry,
`references/milestones-and-verification.md` §4. `check-neutral.sh` + `check-plan.sh` green. No
script change. Because it touches every skill's body, it must be the **last** change built this
cycle (re-check against `main` at build time — earlier merges changed several of these files).
