# Milestone — required-checks-doctrine: the corpus catches up to the enforced gate

**Goal:** with keel's `main` actually protected (milestone `required-checks-live`), the corpus stops
describing flows the protection now forbids and starts teaching the proven recipe: the two
direct-to-main plan-only flows open plan-only PRs instead, the template contract carries the concrete
job + protection recipes downstream, preflight check (b) asserts the security-review job's *content*
rather than its name alone, and a decision entry records the stance.

**Change:** `specs/changes/required-checks-wiring.md`. **No-UI** → two-dimension done-conditions
(logic + behavioral completeness). **Depends on:** `required-checks-live` (it records recipes that
milestone proves live). **Parallelizable:** no. **Routing:** reasoning-heavy — this edits the merge
gate's contract prose and the preflight's assertion surface; wrong wording weakens the compensating
control.

## Done-conditions

### Logic / invariants

- [auto] `skills/land-feature/SKILL.md`: the reconciliation step no longer instructs a direct commit
  to `main` — it opens a **plan-only PR** (plan paths only, pin-exempt by the existing gate rule) and
  states that the PR lands under the standing merge authority (the user's tap, or `--auto` under a
  valid marker/mode). The post-wave consolidated check is untouched.
- [auto] `skills/land-feature/SKILL.md`: the **independent-milestone landing step is
  strict-protection-aware** — the unconditional "no cascade" claim is rescoped: after each sibling
  squash-merges, every remaining independent PR must be updated to the moved base
  (branches-up-to-date), which pulls the sibling's squashed code into the pin's drift window; the step
  names the remedy as the existing cascade rule — update/rebase onto new `main`, full suite green,
  `scripts/repin.sh`, contexts re-fire — so the first post-protection wave follows a written rule
  instead of improvising at a red `verified-pin`. The stacked-series merge-commit choreography is
  unchanged (a content-identical update-branch merge keeps drift plan-only there).
- [auto] `skills/review-feature/SKILL.md`: its plan-note/refinement-record step likewise opens a
  plan-only PR instead of committing directly to `main`, same authority sentence.
- [auto] `references/template-contract.md`: the kickoff tier records the **concrete recipe** milestone
  `required-checks-live` proved — the four named CI jobs (contexts `verified-pin`, `plan-lint`,
  `guards`, `security-review`), the SHA-pinned `claude-code-security-review` job shape with its secret
  and least-privilege permissions (still hedged as the recorded default satisfying the contract, never
  a vendor mandate), and the full protection shape (PR required with zero approvals, strict
  up-to-date, `enforce_admins`, exact contexts). The tier split from
  `decisions/2026-07-29-security-review-wiring.md` is restated unchanged for downstream projects:
  kickoff wires `verified-pin` + `plan-lint`; the security-review job may be wired at kickoff (as keel
  itself now does) and **must** be wired before any auto posture arms. **The recipe states two
  protection shapes explicitly** so a verbatim kickoff cannot wedge a new repo: the kickoff-tier
  required contexts are the checks the kickoff wires (never a `security-review` context no job yet
  reports), and the context is **added to the required set at the moment the job is wired** —
  kickoff-optionally or at auto-entry.
- [auto] `skills/spec-foundation/SKILL.md` + `skills/adopt/SKILL.md`: their repo-setup steps point at
  the template contract's concrete recipe (named jobs + full protection) instead of the looser
  "wire two check jobs" prose; neither file claims the security-review job is optional for auto.
- [auto] `scripts/check-auto-preflight.sh`: a new sub-check **(b2)** — for the `security-review` check
  name in the required set, some file under `.github/workflows/` both declares that check context and
  matches a review-implementation pattern (default `claude-code-security-review`, overridable via
  `PREFLIGHT_SECREVIEW_PATTERN` for a different in-Actions implementation) — fails with a message
  naming the gap ("the required check exists in name; no workflow content performs a review") and the
  remediation. Because the template contract permits satisfying the check **outside** GitHub Actions
  (an external status-check provider has no workflow file), (b2) also accepts an explicit, named
  attestation — `PREFLIGHT_SECREVIEW_EXTERNAL=1` — whose use the preflight echoes loudly in its
  summary ("security-review content asserted by operator attestation, not by workflow scan"), so the
  bypass is deliberate and visible, never silent. Check (b)'s existing pass/fail semantics are
  untouched; (b2) is additive and fail-closed; `scripts/check-auto-preflight.test.sh` gains cases for
  (b2) pass, name-without-content fail, pattern override, and external attestation, with every
  existing expectation still holding.
- [auto] `skills/provision/SKILL.md` (the auto-provision envelope prose, the preflight's declared
  prose owner) and `skills/auto/SKILL.md` (the preflight-summary enumeration) both name the new (b2)
  sub-check alongside (a), (a2), (b), (c), (d) — the operator's stated mental model matches what fails
  closed, preserving exactly the repair `decisions/2026-07-29-security-review-wiring.md` made for the
  original set.
- [auto] New append-only `decisions/2026-08-01-required-checks-protection.md` amends (by reference,
  editing nothing in place) `decisions/2026-07-29-security-review-wiring.md` and the land-feature /
  review-feature flow descriptions: records the full-protection stance and its owner rationale, the
  two flows' move to plan-only PRs, the strict-cascade rescope of independent-wave landing, the live
  keel wiring, the (b2) content assertion, two accepted consequences (fork PRs cannot merge — the
  secret-backed required context can never go green on a fork; strict adds an update-and-repin cycle
  per landed sibling in independent waves), and states explicitly that
  `specs/deferrals/per-project-auto-merge.md` is *not* resolved — its precondition is now built;
  un-deferring stays a future spec-change.

### Behavioral completeness

- [auto] **Corpus coherence:** `grep -rniE "commit (it )?directly|made directly|directly to main" \
  skills/ references/` surfaces no surviving instruction to write to `main` without a PR — these
  patterns are chosen because they match today's two live instructions verbatim
  (`skills/land-feature/SKILL.md` "Commit it directly", `skills/review-feature/SKILL.md` "made
  directly"), so the sweep goes green only when the amendments actually happened (historical records
  under `specs/` and `decisions/` are out of scope); and `grep -rn "security-review" skills/
  references/ scripts/` shows every operative mention consistent with the two-control split (the
  per-milestone `/security-review` pre-pin pass untouched; the required check now content-asserted).
- [auto] All script self-test suites pass (`check-auto-preflight` with its new (b2) cases; every other
  suite unchanged and green), `check-neutral.sh`, `check-skill-frontmatter.sh`,
  `check-skill-anchors.sh`, `check-plan.sh`, and `claude plugin validate --strict .` all pass.
- [auto] **Gates otherwise untouched:** `scripts/check-verified-pin.sh`, `scripts/merge-guard.sh`,
  `scripts/guard-branch-rules.sh`, `scripts/repin.sh`, and `hooks/hooks.json` have empty diffs.

## verification

verifier subagent against this file — every `[auto]` condition checked with `file:line` evidence (the
two flow amendments and their authority sentences, the template contract's recipe field-by-field
against what `required-checks-live` wired, the (b2) sub-check's fail-closed logic and its test cases,
the decision entry's recorded elements (each item its condition enumerates), the corpus greps with named buckets, the empty gate
diffs); suites run, not re-derived. **Dispatch the verifier at `xhigh`** (reasoning-heavy).
**`/security-review` of the milestone's diff is a pre-pin precondition** — the adversarial question:
does any prose or preflight change open a path to arming auto, or landing a merge, with less than the
three-check contract (it must not); confirmed findings remediated before the pin.
