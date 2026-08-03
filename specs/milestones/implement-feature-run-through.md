# Milestone — implement-feature-run-through: under a committed marker, run start-to-finish into a prepared review

**Goal:** deliver the owner's end-state — `/keel:implement-feature`, in a repo with a valid committed
auto-merge marker, runs **start to finish** (build → fresh-context verify → pin → open PR → arm
`--auto` → land the wave → post-wave consolidated check → **prepare** `review-feature`) and **ends
there**, leaving the human exactly the one judgment the framework reserves: the feature review. It
asks mid-run **only at true stop-points**; everything else is recorded as a run-note and the run
continues. It **never** auto-passes `review-feature`, never touches the never-auto list, and never
lands code that less than the three-check contract inspected.

**Feature:** `specs/features/per-project-auto-merge.md`. **No-UI** → two-dimension done-conditions.
**Depends on:** `committed-auto-merge-marker` + `arm-auto-merge-skill` (consumes the marker + the
arming primitive). **Parallelizable:** yes — with `auto-merge-doctrine` (disjoint files).
**Routing:** reasoning-heavy — it amends who drives the merge in the workflow's orchestration verb;
wrong wording either strands the owner at a stack of open PRs (the status quo it fixes) or lets the run
overrun a real stop-point. Dispatch the verifier at `xhigh`.

## Done-conditions

### Logic / invariants

- [auto] **`skills/implement-feature/SKILL.md`'s "Stops at merge" boundary gains a committed-marker
  branch** (without deleting the default): with **no** committed marker and **no** active mode, "stops
  at merge" holds **exactly as written** (the user merges). With a **valid committed marker present**
  (and no active mode), the run **continues through landing** — it drives the `land-feature`
  choreography with a bare, un-chained `gh pr merge <pr> --auto` on each **pinned, gate-passing** PR
  (the merge-guard's committed-project row emits `allow`; the build-session guard-branch-rules row
  defers to it), runs the **post-wave consolidated check** on `main`, and then **prepares**
  `review-feature`. This mirrors the autonomy-mode branch ("enable `gh pr merge --auto` on each
  pinned, gate-passing PR") but is reached by the **committed marker**, not a mode — the run states
  which authorization it is acting under.
- [auto] **The run PREPARES `review-feature` and ends there — it never auto-passes it.** For a **UI**
  feature the run renders the surfaces and stages the review inputs (per `review-feature`'s pass — the
  activation driver, screenshots, the composition to diff against) and **halts at the human
  aesthetic/completeness judgment**, reporting the feature as **built-verified-merged, review
  prepared, not done**. For a **no-UI** feature `review-feature` is **skipped** (as its own skill
  states) and the run reports the feature done at the consolidated check. Either way the taste gate,
  the feature-spec sign-off, and the never-auto list are **untouched** — the run does not render a
  verdict on any of them.
- [auto] **The stop-point-vs-notify-and-continue mechanism is defined** (the owner's "ask mid-run only
  at true stop-points"): a **stop-point halts the run attended** — the un-pre-authorizable set the
  framework already names (live/paid/irreversible spend, a missing credential, a red substrate routed
  to the Q12 remedy, a required `/security-review` finding, a `verify-milestone` **`blocked`** verdict
  (or a `discrepancy` a remediation pass does not clear — the verdict tokens are `clean`/`discrepancy`/`blocked`,
  there is no `fail`), a merge-guard
  `deny`, a genuine scope change) — surfaced with the five-line gate block and the run ends on it,
  never silently deferred. **Everything else is notify-and-continue**: recorded as a **run-note**
  (in-transcript, and appended to the run's ledger when one exists) and the run **proceeds to the next
  independent milestone**, with all such notes **surfaced together in the final handoff**. The
  milestone spec **enumerates the stop-point set explicitly** so the boundary is a written rule, not a
  per-run judgment. **No new notification infrastructure is invented** — the mechanism is run-notes +
  the existing five-line halt; if the harness exposes a push affordance the run *may* additionally use
  it, but nothing in the flow depends on one (keel has none today, and the required-checks floor means
  a missed notification never lands unreviewed code).
- [auto] **`skills/implement-feature/SKILL.md`'s frontmatter is made truthful.** The `description`
  ("stopping at the user's merge … Never merges") and `when_to_use` ("NOT for merging the reviewed
  PRs") are amended to state the committed-marker exception — the run stops at the user's merge
  **unless a committed auto-merge marker (or an active mode) authorizes the run-through**, in which
  case it drives landing itself. The **hooks block is unchanged** (the `guard-branch-rules.sh`
  PreToolUse hook stays); only the prose fields move, so the skill still reads as never-merges *by
  default*, true to the standing invariant, while no longer contradicting its own new standing branch.
- [auto] **`skills/land-feature/SKILL.md` gets a one-line pointer** (no behavior change) noting that
  under a committed marker `implement-feature` drives this choreography start-to-finish with `--auto`,
  exactly as it already notes for an active mode — the merge mechanics (bottom-up, retarget-before-
  delete, close+reopen, re-pin, consolidated check, reconciliation) are unchanged; only who fires the
  merge command differs.
- [auto] **A new append-only `decisions/2026-08-02-implement-feature-run-through.md`** records the
  run-through posture: the three authorization branches ("stops at merge" default / committed-marker
  run-through / autonomy-mode run-through) and why the committed branch stops at a **prepared**
  `review-feature` rather than the open-PR stack; the stop-point set; and that `review-feature` and
  the never-auto list stay human. It amends by reference `decisions/2026-07-04-attended-auto-merge.md`
  and the run-through's sibling `decisions/2026-08-02-per-project-auto-merge-authorization.md` (M3).

### Behavioral completeness

- [auto] **The three authorization branches are mutually exclusive and totally ordered in the prose:**
  active mode → the autonomy branch; else valid committed marker → the run-through branch; else → the
  "stops at merge" default. The precedence matches the guards' `mode > committed` (the attended
  per-session marker is not an `implement-feature` concern — that skill's per-merge flow is
  interactive), and no branch claims an unobservable outcome (it reports what `gh`/the checks
  returned, never "merged without a prompt").
- [auto] **Corpus coherence:** `grep -rn "stops at merge\|run-through\|prepare.*review-feature" \
  skills/implement-feature/SKILL.md` shows the committed branch and the prepared-review end-state
  present and consistent with `review-feature`'s own "this gate is the human's" prose (no claim that
  the run passes it); `grep -rn "keel-auto-merge\|committed marker" skills/` shows `implement-feature`
  naming the same marker M1 shipped; and the **frontmatter no longer asserts an unconditional
  "Never merges"** — `grep -n "Never merges\|stopping at the user" skills/implement-feature/SKILL.md`
  shows any surviving phrasing carries the committed-marker/mode exception, not a bare claim the
  standing branch contradicts.
- [auto] **All lints and suites green:** `claude plugin validate --strict .`,
  `check-skill-frontmatter.sh` (the amended `description`/`when_to_use` still satisfy the frontmatter
  schema; the `hooks` block is unchanged), `check-skill-anchors.sh`, and every script self-test suite
  pass (this milestone changes skill prose + adds decision markdown; it edits **no** script, so all
  gate/guard/preflight suites are unchanged and green).
- [auto] **No unowned surface moved:** `git diff --stat` is confined to
  `skills/implement-feature/SKILL.md`, `skills/land-feature/SKILL.md` (one-line pointer),
  `decisions/2026-08-02-implement-feature-run-through.md`, and this milestone spec. The M1/M2 scripts +
  guards + arming skill, and M3's doctrine surfaces, have empty diffs.

## verification

verifier subagent against this file — every `[auto]` condition with `file:line` evidence: the
"Stops at merge" committed-marker branch (drives `--auto` on pinned/gate-passing PRs, consolidated
check, prepares review), the prepared-not-passed `review-feature` end-state for both UI and no-UI, the
stop-point set enumerated + notify-and-continue as run-notes with no invented infrastructure, the
land-feature pointer, the decision entry's three branches + precedence, the mutual-exclusion ordering,
the greps, and the confined diff. Suites run, not re-derived. **Dispatch the verifier at `xhigh`**.
**`/security-review` of the milestone's diff is a pre-pin precondition** — the adversarial question:
does the run-through branch ever land a PR that is **not** both pinned and gate-passing, or ever
render a verdict on `review-feature` / the never-auto list, or overrun an enumerated stop-point — it
must not; confirmed findings remediated before the pin.

verified: clean at f072b48, 2026-08-02, via a fresh-context verifier subagent against this file — every `[auto]` condition checked against the real code. The "stops at merge" default is unchanged in prose (SKILL.md:48: "With no committed auto-merge marker and no active mode... the user merges, exactly as written") while the frontmatter is made truthful: `description`/`when_to_use` (SKILL.md:3-4) and the body (SKILL.md:16) state the committed-marker/mode exception without deleting the default, and "Never merges" is qualified to "on its own initiative" (SKILL.md:3) — `grep -n "Never merges\|stopping at the user" skills/implement-feature/SKILL.md` shows only the qualified frontmatter line, no bare unconditional claim survives. The `hooks` block is confirmed byte-identical to main (`diff` of the extracted `hooks:` stanza from `git show main:...` vs `git show HEAD:...` is empty) — only prose fields + body moved. The new "Where the run ends" section (SKILL.md:50-58) totally orders the three branches (active mode → committed marker → default) matching the guards' `mode > committed` precedence, states no branch claims an unobservable outcome, and the run-through branch (SKILL.md:60-62) states which authorization it acts under and drives a bare, un-chained `gh pr merge <pr> --auto` on each pinned, gate-passing PR. Cross-checked against the real guard code (not conflated): `merge-guard.sh`'s committed-project row (L821-830) is the five-way guard `MODE_ACTIVE=0 && ATTENDED_ACTIVE=0 && COMMITTED_ACTIVE=1 && AUTO_MERGE=1 && SHAPE==gh-pr-merge` binding `d_auto="allow"` (L829) — it does emit `allow`; `guard-branch-rules.sh`'s committed row (L557-567) never emits `allow` (exit-code only) and defers via `exit 0` at L567 — matching the prose exactly. Both continuing branches PREPARE, never pass, `review-feature` (SKILL.md:68-75): UI renders+stages+halts reporting "built-verified-merged, review prepared, not done"; no-UI is skipped per `review-feature`'s own prose (`skills/review-feature/SKILL.md:14`: "this gate is skipped") and reports done at the consolidated check; the taste gate, feature-spec sign-off, and never-auto list are explicitly "untouched." The stop-point set (SKILL.md:77-83, mirrored in `decisions/2026-08-02-implement-feature-run-through.md:39-47`) enumerates exactly: live/paid/irreversible spend, missing credential, red substrate→Q12, a required `/security-review` finding, a `verify-milestone` `blocked` verdict (a `discrepancy` a remediation pass does not clear), a `merge-guard` `deny`, and a genuine scope change — using the corrected verdict vocabulary `clean`/`discrepancy`/`blocked` (no `fail`), matching this milestone spec's own corrected line 43-44. Notify-and-continue (SKILL.md:82-83) is run-notes only, surfaced together in the handoff, with no new notification infrastructure invented. `land-feature/SKILL.md:79` gets the one-line pointer under the existing autonomy-mode paragraph, naming the committed marker and this decision file, with the merge mechanics (bottom-up, retarget-before-delete, close+reopen, re-pin, consolidated check, reconciliation) otherwise unchanged. `decisions/2026-08-02-implement-feature-run-through.md` (new, append-only) records the three branches + precedence (§"The three authorization branches"), why the committed branch stops at a prepared review rather than the open-PR stack (§"Why the committed branch stops..."), the stop-point set, and amends by reference both `decisions/2026-07-04-attended-auto-merge.md` and the sibling `decisions/2026-08-02-per-project-auto-merge-authorization.md` (M3, on the not-yet-merged `auto-merge-doctrine` branch — a forward reference to a parallel sibling PR, not a defect). Corpus greps: `grep -rn "stops at merge\|run-through\|prepare.*review-feature" skills/implement-feature/SKILL.md` shows the committed branch and prepared-review end-state present and consistent, no claim the run passes review-feature; `grep -rln "keel-auto-merge\|committed marker" skills/` names `implement-feature`, `land-feature`, `arm-auto-merge`, `auto-merge`, all naming the same `.claude/keel-auto-merge.json` M1 shipped. All 12 script self-test suites green (464 passed, 0 failed): attended-marker-parity 20, check-auto-preflight 30, check-branch-protection 19, check-neutral 17, check-plan 21, check-skill-anchors 14, check-skill-frontmatter 12, check-verified-pin 38, guard-branch-rules 79, merge-guard 140, repin 13, session-bootstrap 61. `check-skill-frontmatter.sh` and `check-skill-anchors.sh` both PASS directly, and `claude plugin validate --strict .` passes — this milestone changes no script, so all gate/guard/preflight suites are unchanged and green (confirmed via empty diffs, not assumption). `git diff --stat main...HEAD` is confined to exactly the 4 expected files (`decisions/2026-08-02-implement-feature-run-through.md`, `skills/implement-feature/SKILL.md`, `skills/land-feature/SKILL.md`, `specs/milestones/implement-feature-run-through.md`); `scripts/merge-guard.sh`, `scripts/guard-branch-rules.sh`, `skills/arm-auto-merge/SKILL.md`, and M3's doctrine surfaces (`scripts/session-bootstrap.sh`, `skills/auto-merge/SKILL.md`, `references/template-contract.md`, `specs/deferrals/per-project-auto-merge.md`) all have empty diffs against main. `/security-review` of the milestone's diff ran as the pre-pin precondition (documentation-only diff; `scripts/merge-guard.sh`/`scripts/guard-branch-rules.sh` confirmed unmodified) — no findings: every landing instruction is qualified "pinned, gate-passing," the review-feature/never-auto-list prose explicitly disclaims passing/waiving/pre-judging, the enumerated stop-point set drops nothing, and the "bare, un-chained" instruction reinforces rather than bypasses the unmodified guard scripts. (evidence: verifier report in PR)
