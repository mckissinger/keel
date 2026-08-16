# Milestone — babysit-prs

Change context: `specs/changes/babysit-prs.md`. One milestone. Adds
`skills/babysit-prs/SKILL.md` (the verb: doctrine + dispatch) and
`workflows/babysit-prs.js` (the background loop), adds one dispatch-pointer sentence each
to `skills/land-feature/SKILL.md` and `skills/implement-feature/SKILL.md`, adds
`babysit-prs` to `references/model-routing.md`'s default list (coverage count moves with
it), and adds `scripts/skill-anchors/babysit-prs.txt`. No gate, guard, hook, or preflight
changes behavior; `scripts/merge-guard.sh` is untouched.

**Integration seams.**
- **`land-feature` stays the doctrine owner.** The babysitter *executes* the per-sibling
  cycle and the stacked-series choreography exactly as `land-feature` writes them; the new
  skill cites those sections and restates none of them. The post-wave consolidated check
  and the reconciliation are `land-feature`'s and are **not** part of the babysitter's
  loop. `land-feature`'s "Under the full protection contract" paragraph gains one sentence
  naming `babysit-prs` as the background form of the cycle; `implement-feature`'s
  marker-armed run-through path gains one sentence permitting the babysitter to carry the
  landing phase.
- **The wave-scripting contract binds this workflow.** `land-feature`'s wave-scripting
  contract constrains "whatever a project authors"; this workflow is keel authoring
  exactly that script, so its three behavioral rules (deletion scope, settle-only
  watching, pending ≠ failure) are done-conditions below, not advice.
- **Authorization is inherited, never granted.** The three-branch order (active `keel:auto`
  mode > committed `.claude/keel-auto-merge.json` marker > the user's per-merge tap) is
  consumed exactly as `implement-feature`/`land-feature` state it — with one recorded
  narrowing: the per-session attended marker (`.claude/keel-attended-merge.json`) is
  **not** a drain authorization here (it stays with the attended per-merge flow); the
  babysitter drains only under an active mode or the committed per-project marker. The
  skill carries `disable-model-invocation: true` (like `land-feature`): a babysitter
  that merges is human-dispatched, never self-invoked by a session that then hands
  itself a merge lane. The `implement-feature` pointer rides the `land-feature`
  precedent — a marker-armed run follows the *workflow* (doctrine dispatch), which the
  frontmatter flag does not bind; the flag bars only model-initiated Skill invocation.
- **Re-pins ride `scripts/repin.sh` unchanged.** The script's contract (green evidence is
  the caller's job; refuses a dirty tree; plan-only commit; postconditions) is consumed,
  not modified. The babysitter's re-pin evidence is always the CI-green rule
  (`references/milestones-and-verification.md` §5) — it never runs a local suite; a PR
  whose update is not CI-green-eligible drops from the loop instead.
- **Settle-only monitoring per the existing doctrine.** Watching follows
  `references/dispatch-and-monitoring.md` (all-settled or first-failure; empty `gh` output
  is a failed read, never "nothing left"); the workflow's watch calls are the blocking,
  settle-only kind — no per-check progress turns, no poll loops.
- **Anchor file is new, file-per-feature** (`scripts/skill-anchors/babysit-prs.txt`, never
  an edit to an existing anchor file).

## Done-conditions

- [auto] **The skill exists and owns exactly the babysitter doctrine, with the queue
  operationally defined.** `skills/babysit-prs/SKILL.md` exists, frontmatter well-formed
  with `disable-model-invocation: true`, and states: the loop
  (watch → prepare → drain-or-hold); that it automates waiting and never authorization;
  the queue definition — **hold mode**: the explicit PR list given at dispatch, or every
  open non-draft PR when invoked bare (preparing is merge-free, so breadth is safe);
  **drain mode**: only the explicit list the dispatching human/verb named, or — under
  the committed marker — the marker's own standing scope (gate-passing open non-draft
  PRs), and
  **never a queue the workflow infers from GitHub review state alone** (review approval
  and green checks are necessary signals, never a sufficient derivation of landing
  approval); and its boundaries (never merges without an active mode or committed
  marker; never edits code; never runs the consolidated check or reconciliation — those
  stay with `land-feature`). *Falsifiable:* a version missing the doctrine-ownership
  boundary, the no-marker-no-merge rule, the two-mode queue definition, or the
  frontmatter flag fails.
- [auto] **The workflow encodes the loop with the wave-scripting contract's three rules.**
  `workflows/babysit-prs.js` exists with meta + phases and encodes: (a) **deletion
  scope** — the workflow deletes no branch an open descendant is based on, and deletes
  branches at all only when its queue equals the full remaining open stack; otherwise
  branch deletion is a decoupled post-wave step (or the user's) — **never a flag bundled
  into a drain-mode merge emission**, whose closed shape (`scripts/merge-guard.sh`
  header: `gh pr merge <PR> --auto` plus at most one merge-method flag, no other tokens)
  excludes `--delete-branch`; (b) **settle-only watching** — one announcement at watch start with the
  expected duration, then blocking settle calls reporting all-settled or first-failure,
  and empty `gh` output re-checks rather than concluding;
  (c) **pending ≠ failure** — an exhausted wait window reports "still pending — re-check"
  distinct from failure by status and message, and the window is sized from the repo's
  observed CI durations (read from recent runs), never a hard-coded default.
  *Falsifiable:* a prefix-invocation that could delete a live base, a poll loop, or a
  timeout that reports failure fails this condition.
- [auto] **Prepare = update, classify, re-pin-or-drop.** The workflow, when a landing
  moves the base: updates each remaining PR (`gh pr update-branch` or rebase per the
  stacked rules), then classifies the diff old-pin → new-tip; **empty outside plan
  paths** → wait for the re-fired required checks and, on green, re-pin via
  `scripts/repin.sh` citing the CI-green rule; **anything else** (conflict, code drift,
  update failure) → the PR drops from the loop with the reason recorded — the babysitter
  never resolves conflicts, never edits code, never writes a first pin. *Falsifiable:* a
  path where the workflow re-pins without the checks green at the new tip, edits any
  non-plan file, or writes a pin to a spec with no existing `verified:` line fails.
- [auto] **Drain honors the authorization order, the emission contract, and the
  stacked merge method.** Under an active mode or a valid committed per-project marker,
  each merge is emitted per the emission contract in `scripts/merge-guard.sh`'s header
  (its own bare, un-chained `gh pr merge <pr> --auto` call); a stacked queue merges
  bottom-up **with merge commits — never squash a stacked PR** (squashing rewrites the
  SHA the descendants' pins point at), with retarget-before-delete and close+reopen,
  while independent PRs squash per `land-feature`'s default. With neither of those two
  authorizations present (the per-session attended marker deliberately does not count —
  the recorded intake narrowing), the workflow contains **no merge invocation on any
  path** — it prepares and holds. *Falsifiable:* any code path that reaches
  `gh pr merge` without first finding a mode or committed marker, that chains the merge
  with another command, or that can squash-merge a PR with an open descendant, fails.
- [auto] **Hold = batch into one final report; red = report-only.** With no drain
  authorization: when every queued PR is either prepared-green or dropped, the workflow
  ends, returning **one** final report carrying the ready list and the dropped list
  (each with its reason and, for a red check, the failing check's name) — the report is
  the workflow's return value, which the dispatching session presents as the attended
  ask per `references/gate-presentation.md` (the five-line block); **no new
  notification infrastructure is invented** (keel has no push channel — the
  `implement-feature` precedent). Not per-PR endings: the loop keeps preparing the rest
  of the queue while any PR's checks are pending, and a re-invocation after the user's
  taps re-prepares and reports once more. A genuinely failing required check always
  drops the PR — no close/reopen re-fire, no retry, on any path. *Falsifiable:* a
  per-PR report-and-exit loop, a new notification mechanism, or any retry-on-red path
  fails.
- [auto] **The dispatch pointers land without disturbing their hosts — plus the one
  now-false sentence this milestone must reconcile.** `skills/land-feature/SKILL.md`'s
  protection-contract paragraph and `skills/implement-feature/SKILL.md`'s marker-armed
  path each gain one sentence naming `babysit-prs`; and `land-feature`'s wave-scripting
  sentence "Nothing above requires a script and keel ships none" is amended to reflect
  that keel now ships one (`workflows/babysit-prs.js`), bound by the contract's rules —
  this milestone falsifies that sentence, so leaving it is a doctrine lie. Every other
  rule in both files is byte-preserved (in particular `land-feature`'s "The user
  merges." boundary, the wave-scripting contract's three rules themselves, and
  `implement-feature`'s authorization branches). *Falsifiable:* any change to either
  file beyond the two pointer sentences and the ships-none amendment fails.
- [auto] **Routing coverage stays auditable.** `references/model-routing.md` lists
  `babysit-prs` in the default list (or a table row), the coverage-audit skill count
  moves 32 → 33, and the "every skill on disk is covered" property holds by enumeration.
- [auto] **The anchor file exists and pins the load-bearing sentences.**
  `scripts/skill-anchors/babysit-prs.txt` exists (a new file, per the §4 collision rule)
  and anchors at least: the no-marker-no-merge rule, the never-squash-stacked clause,
  the red-is-report-only rule, and the never-edits-code boundary — and
  `scripts/check-skill-anchors.sh` passes **with the file counted** (its anchor total
  rises), so the anchors are live, not vacuous. *Falsifiable:* an absent file, or one
  missing any of the four named sentences, fails.
- [auto] **No weakening — invariants the change must preserve.** Verify none of the
  following is removed, narrowed, or contradicted: the standing never-merge invariant and
  its two marker exceptions (the orientation text in `scripts/session-bootstrap.sh`,
  `land-feature`'s boundaries, `implement-feature`'s authorization branches); `scripts/merge-guard.sh`
  byte-unchanged; `scripts/repin.sh` byte-unchanged; the pin gate and its self-tests
  untouched; `references/milestones-and-verification.md` untouched. *Falsifiable:* any
  of these edited fails.
- [auto] **Repo checks green.** `claude plugin validate --strict .`,
  `scripts/check-neutral.sh`, `scripts/check-plan.sh`, `scripts/check-skill-frontmatter.sh`,
  `scripts/check-skill-anchors.sh`, and every `scripts/*.test.sh` pass on the branch.

## verification

verifier subagent against this file's done-conditions (all `[auto]`; skill prose + workflow
JS — closable by reading the named files, tracing the workflow's paths against conditions
2–5, and running the named checks). No `[runtime]` walk — keel is no-UI. Pre-pin
`/security-review` applies: this milestone touches merge-adjacent authorization prose (a
hard invariant), so the review runs before the pin even though no gate script changes.
