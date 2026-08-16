export const meta = {
  name: 'babysit-prs',
  description: 'Background landing-cycle babysitter — watch a queue of landing-approved PRs, update branches onto the moved base, re-pin under the CI-green rule, drain merges under a standing authorization or hold everything prepared with one batched report',
  whenToUse: 'Dispatched by the babysit-prs skill (attended), or by land-feature / implement-feature to carry the landing phase. Pass {queue:[<pr-numbers>]} (omit to derive per the skill\'s mode rules) and authorization:"mode" ONLY when an active keel:auto orchestrator is the dispatcher. It automates the waiting, never the authorizing: with no active mode and no valid committed marker it merges nothing — prepare-and-hold only.',
  phases: [
    { title: 'Orient', detail: 'derive the queue and stack order, verify the drain authorization independently, size the wait window from observed CI durations' },
    { title: 'Cycle', detail: 'settle-only watch → update-branch → CI-green re-pin or drop → drain (authorized) or mark ready' },
    { title: 'Report', detail: 'one batched final report: merged / ready / dropped-with-reasons' },
  ],
}

const ORIENT_SCHEMA = {
  type: 'object',
  required: ['queue', 'authorization', 'watchWindowSeconds'],
  properties: {
    queue: { type: 'array', items: { type: 'object', properties: {
      pr: { type: 'number' }, headRef: { type: 'string' }, baseRef: { type: 'string' },
      specPath: { type: 'string', description: 'the milestone/chore spec carrying this PR\'s verified: pin, or "plan-only"' },
      stackDepth: { type: 'number', description: '0 = based on the default branch; N = N open ancestors below it' },
    } } },
    authorization: { type: 'string', enum: ['mode', 'committed-marker', 'none'],
      description: 'committed-marker only after independently verifying .claude/keel-auto-merge.json on the remote default branch; mode only if the dispatcher declared it AND a run ledger corroborates; else none' },
    watchWindowSeconds: { type: 'number', description: 'sized from observed CI durations on this repo (recent gh run list), never a script default' },
    note: { type: 'string' },
  },
}

const CYCLE_SCHEMA = {
  type: 'object',
  required: ['merged', 'ready', 'dropped', 'pending'],
  properties: {
    merged: { type: 'array', items: { type: 'number' } },
    ready: { type: 'array', items: { type: 'number' }, description: 'prepared-green, awaiting the user\'s tap (hold mode only)' },
    dropped: { type: 'array', items: { type: 'object', properties: {
      pr: { type: 'number' }, reason: { type: 'string', description: 'e.g. "required check <name> failing", "update-branch conflict", "code drift in pin window"' } } } },
    pending: { type: 'array', items: { type: 'number' }, description: 'checks still running at round end — still pending is NEVER reported as failure' },
    note: { type: 'string' },
  },
}

phase('Orient')
let input = args
if (typeof input === 'string') { try { input = JSON.parse(input) } catch { input = {} } }
const explicitQueue = (input && input.queue) || null
const dispatcherClaimsMode = !!(input && input.authorization === 'mode')

const oriented = await agent(
  `Orient a PR-landing babysitter run in this repo. READ-ONLY except noted. Steps:\n` +
  `1. AUTHORIZATION — verify independently, never on the dispatcher's word alone:\n` +
  `   - committed marker: does .claude/keel-auto-merge.json exist ON THE REMOTE DEFAULT BRANCH (git show origin/<default>:.claude/keel-auto-merge.json) with scope "project"? If yes → "committed-marker".\n` +
  `   - mode: the dispatcher ${dispatcherClaimsMode ? 'DECLARED an active keel:auto mode — corroborate it (an active run ledger under specs/runs/); if corroborated → "mode"' : 'did NOT declare a mode — "mode" is not available to this run'}.\n` +
  `   - neither verified → "none". When authorization is "none" this run is HOLD MODE: it will merge NOTHING.\n` +
  `2. QUEUE — ${explicitQueue ? `exactly these PR numbers, no additions: ${JSON.stringify(explicitQueue)}` : `no explicit list was given: in hold mode, every open non-draft PR; under the committed marker, its standing scope (gate-passing open non-draft PRs); under a mode, a derived queue is NOT permitted — a mode run must name its queue explicitly, so report the queue you would have derived but expect the run to fall back to hold`}. Never infer landing approval from GitHub review state alone — an explicit list or the marker's standing scope are the only queue sources. For each PR record head/base refs, the spec file carrying its verified: pin (or "plan-only" for a specs/design/decisions/deferrals-only diff), and stackDepth (walk each open PR's base back to the default branch).\n` +
  `3. WAIT WINDOW — size it from this repo's OBSERVED CI durations: read the last ~10 completed runs (gh run list --json), take the slowest required-check duration, add headroom (~2x). Never use a hard-coded default.\n` +
  `Return per the schema.`,
  { label: 'orient', phase: 'Orient', schema: ORIENT_SCHEMA }
)
if (!oriented || !oriented.queue || !oriented.queue.length) {
  return { report: 'Nothing to babysit — queue is empty.', merged: [], ready: [], dropped: [] }
}
let auth = oriented.authorization || 'none'
// Deterministic gates the agent's returned enum cannot override: "mode" requires the
// dispatcher to have declared it (the agent only corroborates, never originates), and a
// mode run with no explicit queue falls back to hold — the spec's drain-queue rule
// (explicit list or committed-marker standing scope; a mode never drains a derived queue).
if (auth === 'mode' && !dispatcherClaimsMode) auth = 'none'
if (auth === 'mode' && !explicitQueue) { log('mode run with no explicit queue — falling back to HOLD (drain requires a named queue)'); auth = 'none' }
const drain = auth === 'mode' || auth === 'committed-marker'
// Bottom-up: ancestors merge before descendants; equal depth = independent siblings.
const queue = [...oriented.queue].sort((a, b) => (a.stackDepth || 0) - (b.stackDepth || 0))
log(`queue=[${queue.map(q => q.pr).join(', ')}] authorization=${auth} (${drain ? 'DRAIN' : 'HOLD'} mode) window=${oriented.watchWindowSeconds}s`)

phase('Cycle')
// Serial rounds: each landing moves the base for the rest, so the cycle is inherently
// per-sibling (land-feature's protection-contract paragraph). A round watches, prepares,
// and (drain mode) merges what is mergeable; rounds repeat until the queue is spent.
const MAX_ROUNDS = 3 * queue.length + 2 // termination cap, generous: each PR needs at most ~3 rounds (watch, update+re-green, merge)
let state = { merged: [], ready: [], dropped: [], pending: queue.map(q => q.pr) }
for (let round = 0; round < MAX_ROUNDS && state.pending.length; round++) {
  const remaining = queue.filter(q => state.pending.includes(q.pr))
  state = await agent(
    `Round ${round + 1} of a PR-landing babysitter (${drain ? `DRAIN mode under ${auth}` : 'HOLD mode — you MUST NOT merge anything; no gh pr merge invocation exists for you on any path'}). ` +
    `Queue this round (bottom-up stack order): ${JSON.stringify(remaining)}. Already merged: ${JSON.stringify(state.merged)}; ready: ${JSON.stringify(state.ready)}; dropped: ${JSON.stringify(state.dropped)}.\n` +
    `RULES — behavioral contract, every clause load-bearing:\n` +
    `1. WATCH settle-only: announce ONCE what you are watching and the expected duration (~${oriented.watchWindowSeconds}s window), then for each PR run a single blocking 'gh pr checks <pr> --watch' bounded by the window. Report all-settled or first-failure only — no per-check progress. Empty gh output is a FAILED READ: re-check once; never conclude "nothing to do" from it.\n` +
    `2. An exhausted window means STILL PENDING, never failure: put the PR in "pending" with no failure language. A red required check means DROP: record {pr, reason:"required check <name> failing"} — no close/reopen re-fire, no retry, no fix. You never edit code.\n` +
    `3. OUT-OF-DATE branch (base moved): run 'gh pr update-branch <pr>'. Then classify 'git diff <old-pinned-sha> <new-tip>' against the plan-path rule (specs/**, design/**, decisions/**, deferrals/** minus the carve-outs scripts/check-verified-pin.sh names): diff empty outside plan paths → wait for the re-fired checks (next round if the window is spent) and on green run 'scripts/repin.sh <spec-path> "CI-green at new tip"' — repin.sh refuses dirty trees and first pins by contract; establish the green evidence BEFORE invoking it (its header: evidence is the caller's job). Diff NOT plan-only, update conflicts, or update fails → DROP with the reason. Never resolve conflicts, never write a first pin. A "plan-only" PR (no pin) needs no re-pin — just re-green.\n` +
    (drain
      ? `4. MERGE (drain): for each green, up-to-date, gate-passing PR whose open ancestors are all merged, emit the merge as ITS OWN Bash call, bare and un-chained per scripts/merge-guard.sh's emission contract: exactly 'gh pr merge <pr> --auto --squash' for a PR with stackDepth 0 and no open descendant, or 'gh pr merge <pr> --auto --merge' for a stacked PR — NEVER squash a PR that has (or had) open descendants: squashing rewrites the SHA their verified: pins reference. Never bundle the merge with &&, ;, |, $(), or any other token — and NEVER --delete-branch on the merge (the closed shape excludes it). After a stacked parent merges: retarget each open descendant to the default branch ('gh pr edit <child> --base <default>') BEFORE any branch deletion, then 'gh pr close <child> && gh pr reopen <child>' to re-fire CI. ` +
        `Branch deletion: before deleting ANY branch, verify via a fresh 'gh pr list' (including drafts) that this queue equals the FULL remaining open PR set; if it does not — an explicit list may be a prefix of a stack, and a marker-scope queue excludes drafts — DELETE NO BRANCHES (deletion is a decoupled post-wave step). Even then, never delete a branch any open PR is based on.\n`
      : `4. HOLD: a green, up-to-date, gate-passing PR goes in "ready". There is NO merge step in hold mode.\n`) +
    `5. Terminal for this round: every queue PR is merged, ready, dropped, or pending. Return per the schema (carry forward the already-merged/ready/dropped lists, updated).`,
    { label: `cycle:r${round + 1}`, phase: 'Cycle', schema: CYCLE_SCHEMA }
  ) || state
  // Hold mode terminal: everything settled (nothing pending) — one report, no re-loop.
  if (!drain && state.pending.length === 0) break
}

phase('Report')
const stillPending = state.pending || []
return {
  authorization: auth,
  mode: drain ? 'drain' : 'hold',
  merged: state.merged || [],
  ready: state.ready || [],
  dropped: state.dropped || [],
  pending: stillPending,
  report:
    (drain
      ? `Drained ${state.merged.length} PR(s) under ${auth}.`
      : `Prepared ${state.ready.length} PR(s) — ready for your merge taps; no merges attempted (no drain authorization).`) +
    (state.dropped.length ? ` Dropped: ${state.dropped.map(d => `#${d.pr} (${d.reason})`).join('; ')}.` : '') +
    (stillPending.length ? ` Still pending (not failed — re-check): ${stillPending.map(p => `#${p}`).join(', ')}.` : '') +
    ` This single batched report is the run's ending; the dispatching session presents it per references/gate-presentation.md. Post-wave consolidated check + reconciliation remain land-feature's steps.`,
}
