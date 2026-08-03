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
