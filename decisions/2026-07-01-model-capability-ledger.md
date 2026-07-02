# 2026-07-01 — Model-capability ledger: what compensates for weakness vs. what is permanent machinery

keel accumulates mechanisms for two very different reasons, and they age in opposite
directions. This ledger keeps the two piles separate so that, as models get more capable,
we prune the first pile without ever touching the second. The test for which pile a
mechanism belongs in: **would it still be worth its cost against a hypothetically perfect
builder?** If the mechanism only exists because the model forgets, drifts, or over-claims,
it is compensating for weakness and is a *pruning candidate*. If it exists because a human
needs to trust the result regardless of who produced it, it is permanent.

## Compensates-for-weakness (pruning candidates as models improve)

These earn their cost only while the model's failure modes make them pay. Revisit each on a
model bump; loosen where the evidence says the failure mode has receded.

- **Very fine milestone decomposition.** Small units existed partly because a weaker model
  lost the thread over a long build. As horizon lengthens, low-stakes milestones can
  coarsen (see `references/milestones-and-verification.md` §4, the horizon-sizing lens).
  Pruning candidate **only along the recoverable/cheap-review axis** — never for
  correctness-critical work.
- **Exhaustive step-by-step prescription in skill prose.** Long imperative "do this, then
  this" sequences compensated for a model that wouldn't otherwise infer the how. A more
  capable model reads *objective + how-to-verify* and fills the how itself; over-prescription
  now mostly adds staleness surface. (This audit is that pruning pass.)
- **Sprint-decomposition scaffolding.** An explicit multi-sprint planning layer was removed
  in the Opus 4.6 era. See the honest-figures note below — it was a real saving but a
  confounded one.

## Permanent audit machinery (NOT prunable — independent of model capability)

These exist so a **human can trust the output no matter who or what produced it**. A more
capable builder does not reduce their value; if anything a faster builder raises the value
of a cheap, independent check on its work. **Do not prune these as models improve.**

- **The verified-pin gate — explicitly NOT prunable.** "Verified code == merged code,"
  commit-pinned, CI-enforced. It is not a crutch for a forgetful model; it is the record
  that lets a human (or a future session) trust that merged code was actually verified at a
  known state. A perfect builder still needs to *prove* it was perfect on this diff — the
  pin is that proof. This is the load-bearing invariant of the whole methodology; treat any
  proposal to weaken it as a defect.
- **Independent fresh-context verification.** Build and verify never share a context. This
  guards against self-justification, a failure a more capable model can exhibit *more*
  convincingly, not less.
- **Three-dimension done-conditions** (logic / UX completeness / fidelity). A capability
  ledger doesn't change what "done" means to a user.
- **The human merge gate + branch protection.** The user merges; nothing autonomous crosses
  go-live. Authority, not capability.

## Honest source figures (state these as they are, confounded where confounded)

- The Opus 4.6 removal of the sprint-decomposition layer coincided with a period whose
  end-to-end run cost dropped by **~38%**. That figure is **confounded** — other changes
  landed in the same window (prompt tightening, fewer verification re-runs) — so it is
  **not** a clean "sprint-decomposition halved cost" claim, and must not be cited as one.
  The honest statement is: removing the layer was net-positive on cost and quality in that
  window, magnitude entangled with concurrent changes.
- Auto mode's classifier carries a measured **~17% false-negative rate** (see
  `skills/provision/SKILL.md`) — cited as the reason the human merge gate stays, not as a
  figure to optimize away.

When a new figure enters keel's prose, record it here with its confounds rather than
rounding it into a clean headline.
