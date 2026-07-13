# Change — helper-verbs

One milestone: the two remaining approved skills — **`demo`** (the mid-build, attended
"show me the app, now" verb) and **`test-health`** (the suite flakiness/efficiency
audit that decomposes into keel grains) — plus their ladder wiring. Approved by
Michael 2026-07-12 (slate group C items 8 and 9); evidence in
`specs/reviews/2026-07-12-skill-mining.md` §2 and §3.

## Why

**demo**: the boot-and-show ritual was fully re-derived ~4 times in one project (keys
→ mock flags → background dev server → URL map → seed data) and another spent ~5
round-trips per surface on one-at-a-time simulator screenshots, then repeated the
setup the next day. User demos repeatedly caught what verification missed — dead nav
links, non-functional dropdowns, a deployed-DB schema-drift 404 — so making the demo
cheap makes the strongest bug-finder run more often. It is *not* `review-feature` (a
once-per-feature gate after landing): no gate, no verdict, any time.

**test-health**: the same ask arrived twice in nine hours ("more efficient faster e2e
testing suite without reducing quality" / "our testing is a bit inconsistent, flaky,
and inefficient") — the first diagnosis lived only in chat, so the second session
re-derived it with a fresh 4-subagent audit. The audit method and the
remediation-to-grain mapping are both reusable, and both now have committed doctrine
to audit against: §8 of the shared rules and the profile's Q11/Q12.

## Decisions taken

### demo

- **Attended, gateless, any-time.** Boot the app and hand the user the keys; no
  verdict is produced and nothing is gated on it. Distinct from `review-feature` by
  its own statement (mid-build vs the once-per-feature aesthetic gate).
- **The ritual, encoded**: (1) the Q12 substrate preflight first (seconds — the same
  entry check the build verbs run); (2) activate the stack per the profile — services
  up, app/simulator booted per Q3, backgrounded per the harness's background support;
  (3) seed representative demo data per Q5 (never live credentials); (4) print the
  **demo card**: URL map / entry points, test credentials, **what is stubbed vs
  live**, and local-vs-deployed drift status (is what you're seeing on `main`, a
  branch, or ahead of the deployed preview); (5) **stay resident**: capture each
  user finding verbatim and triage it live into the keel grain it belongs to —
  punch-list item or `spec-change` — so findings survive the sitting (the recorded
  incidents all died in chat).
- **demo's write boundary and landing**: demo authors no other verb's artifacts — the
  triage labels findings with their grain; the owning verbs (`punch-list`,
  `spec-change`) run in follow-up sessions. Its one repo write, and only when the
  user asks to record: a dated findings note under `specs/reviews/`, committed on a
  branch as a plan-only PR (never a commit to `main`) — the same landing shape as
  harvest/test-health. The sitting ends attended, presented per the
  gate-presentation contract.
- **Multi-surface batch**: when the profile declares a screenshot/review driver
  (Q8.4), offer batched screenshots of all surfaces up front instead of
  one-at-a-time round-trips (the ~5-round-trips-per-surface scar).
- Model may self-invoke ("show me the app" in plain words routes here). Its
  `allowed-tools` pre-approves at most read-only shapes; the boot/seed commands run
  through the normal permission flow — booting a runtime unflagged is the
  verify-milestone/review-feature/debug precedent, and nothing is pre-approved
  beyond reads.

### test-health

- **An audit with a grain-mapped output, like harvest.** Sweep the committed suites
  and test infrastructure: per-suite durations vs the Q12 budgets, flake evidence
  (retries, serialized workers, shared fixtures), hygiene against **§8 of the shared
  rules** (each rule is an audit probe), ladder shape vs the profile's Q11, CI vs
  local parity. Fan out read-only subagents for scale where the suite count warrants
  it (the recorded session used four).
- **Durations come from recorded evidence first** — the Q12 budgets, CI logs and
  timing artifacts, prior run records. Actually *running* suites to measure is
  state-changing and outside the promptless grant: it happens only with the user's
  go-ahead in the attended sitting, through the normal permission flow.
- **Distinct from `debug` by trigger shape, stated in the skill**: one failing or
  flaky test with a repro in hand → `debug`'s root-cause loop; suite-*wide* health,
  flakiness-rate, or efficiency questions → this audit. A §8 smell test-health finds
  routes its remediation through the grains below, never an ad hoc fix in the audit
  sitting.
- **Findings decompose into keel grains, verbatim from the evidence**: a
  harness-contract rewrite → a milestone; a product bug hiding in a flaky tier → a
  `spec-change` (one real shipped UX bug was found exactly this way); independent
  nits → a `punch-list` batch; secret-gated infra → a deferred milestone in
  `specs/deferrals/`.
- **The diagnosis is committed before the sitting ends** — a dated audit note under
  `specs/reviews/` (the recorded failure: the first diagnosis lived only in chat and
  was re-derived the same day). Same landing shape as harvest: plan-only, on a
  branch, PR opened, user merges.
- **Read-only toward the suites**: it audits and proposes; remediation runs through
  the normal verbs in later sessions. Attended ending on the user's slate approval,
  presented per the gate-presentation contract.
- Model may self-invoke (a session noticing chronic flake may propose it; running it
  is still an attended sitting). The body states why the subagent fan-out doesn't
  trigger `disable-model-invocation` where harvest's did: harvest's flag rationale
  was conjunctive (private cross-project transcripts *and* paid fan-out) — this
  audit reads only the project's own committed state, in an attended sitting.

### Shared wiring

- README's grain-ladder Cross-cut line and the Cross-cutting skills bullet gain both
  verbs; the skill count bumps **19 → 21**; both session-bootstrap banner copies gain
  them on the Cross-cut line, with self-test assertions.
- Neither skill carries `disable-model-invocation` (both are safe to propose;
  both end attended). Frontmatter `allowed-tools` grants stay honest per the recorded
  semantics: demo needs no pre-approved writes; test-health pre-approves the
  read-only sweep set (the same grant shape as `status`/`harvest`).

## Milestone

`specs/milestones/helper-verbs.md` — new `skills/demo/SKILL.md` +
`skills/test-health/SKILL.md`; one line each in `README.md` (ladder + list + count)
and `scripts/session-bootstrap.sh` (both banner copies) + its test.
