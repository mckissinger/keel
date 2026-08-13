# 2026-08-13 — Build-model era mining: remediation rates across five projects

The keel-side evidence the build-model decisions ask for
(`decisions/2026-08-03-build-model-opus-5.md`: "keel-side evidence in either direction should be
recorded here, with confounds, per the capability ledger's honest-figures rule"). Owner-requested,
prompted by a perceived Opus-5 regression: builds feeling slower, more remediation rounds, more
review discoveries than under Opus 4.8.

## Method

Mined every `verified:` pin (milestones + chores, `_landed/` included) in five keel-managed repos —
**keel** (this repo), **CRELaunch** (`~/Dev Projects/cre-list`), **Relay**
(`~/Dev Projects/new-test-proj`), **SessionSmith** (`~/Dev Projects/sessionsmith-ai.ai`),
**BidLevel** (`~/test-proj-1`) — 414 pinned records, 2026-06-24 → 2026-08-13. Each pin was
classified `clean_first` / `clean_after_remediation` / `nuanced` from the pin text **plus git
evidence** (pre-pin remediation commits override a clean-reading pin — five such reclassifications
across four repos, so pin text alone under-reports remediation, most severely in the early era).
Era assignment is by pin date against the routing timeline (`decisions/2026-07-25-two-model-routing.md`
and the 08-01/08-03 amendments); none of the four product repos records its own build model, so
pin-date-vs-timeline is the only attribution available, and a pin can lag its build by a day
(boundary smear in both directions).

**Eras:** pre-07-25 = Sonnet builds / Opus verifier (three-tier routing). 07-25→07-31 = Opus 5
builds / Fable 5 verifier. 08-01→08-02 = Opus 4.8 builds / Fable 5. 08-03→now = Opus 5 builds /
Fable 5.

## Results

All five projects pooled (remediation rate = share of pins that needed at least one
finding-remediation round before the clean verdict):

| era | builder | verifier | pins | remediated | rate |
|---|---|---|---|---|---|
| pre-07-25 | Sonnet (mech) | Opus | 288 | 87 | 30% |
| 07-25 → 07-31 | Opus 5 | Fable 5 | 51 | 23 | **45%** |
| 08-01 → 08-02 | Opus 4.8 | Fable 5 | 12 | 0 | **0%** |
| 08-03 → now | Opus 5 | Fable 5 | 62 | 33 | **53%** |

Controlled for the milestone's `Routing:` tag (tags exist only from ~07-24 on):

| era | mechanical | reasoning-heavy |
|---|---|---|
| Opus 5 v1 | 8/14 remediated (57%) | 14/21 (67%) |
| Opus 4.8 | 0/2 (0%) | 0/4 (0%) |
| Opus 5 v2 | 13/20 (65%) | 8/12 (67%) |

The Opus-4.8 window is **12/12 clean first-pass across four projects**, including four
reasoning-heavy milestones (SessionSmith's apply-containment-roots, codex-skill-wrapper,
mine-command-skill, cli-inference-client). Under the same Fable-5 verifier and the same process
(the verification-economy tightening landed 08-06, *after* this window — it inflates only the
Opus-5-v2 row), the Opus-5-v1 rate was 45%. If 45% were the true rate, twelve consecutive clean
pins have chance probability ≈ 0.55¹² ≈ 0.08% — the gap is very unlikely to be luck *if the pin
populations are comparable*.

## Confounds (the honest-figures part)

1. **The 4.8 sample is tiny and mix-skewed.** 12 pins over two days, 8 of 12 from SessionSmith,
   whose own miner judged 5 of its 7 as mechanical-routed or small-scope; the four
   reasoning-heavy tags there sit on CLI/skill/prose milestones, not the heaviest work. A wave of
   small cleanup milestones right after a big feature wave would read exactly like this.
2. **Verifier and builder switched together on 07-25**, so pre-era's 30% is measured by a weaker
   (Opus) verifier and is not comparable to any Fable-verified row. The only clean builder-only
   contrast is Opus-5-v1 (45%, n=51) vs Opus-4.8 (0%, n=12) — same verifier, same process.
3. **Process strictness tightened inside Opus-5-v2** (verification-economy #213/#214 landed
   08-06; letter-level diff conditions and adversarial plan passes became routine), so the 53%
   row overstates any builder effect. CRELaunch's o5v2 rate (7/8) is dominated by one
   multi-round generation-lint wave (m90–m93).
4. **Pin-date lag** smears the 07-31/08-01 and 08-02/08-03 boundaries by up to ~a day in both
   directions.
5. **Classification bias corrected but not eliminated:** early-era pins under-narrate remediation
   (five git-evidence reclassifications prove the mechanism), so the pre-era 30% is a floor.

## Verdict

**Suggestive, not conclusive — but the suggestion runs the owner's way.** Under identical
verifier and process, Opus-5 windows show 45–53% remediation against a 0%-in-12 Opus-4.8 window
whose cleanliness is statistically unlikely to be chance, yet whose sample is too small and
mix-skewed to settle the question. The retrospective cannot fully separate builder capability
from task mix. The decisive instrument is the **paired bake-off**: build the same milestone on
both models in parallel worktrees off the same base, verify each with the same Fable-5 dispatch,
compare first-pass findings — the within-milestone pairing removes the mix confound entirely.

Raw per-pin data: session scratchpad `mine-*.tsv` (BidLevel 57 rows, CRELaunch 103, Relay 76,
SessionSmith 50, keel 128); regenerable from the repos' specs + git history by the same method.
