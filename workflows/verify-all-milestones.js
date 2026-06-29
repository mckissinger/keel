export const meta = {
  name: 'verify-all-milestones',
  description: 'Fan out independent verification across all milestones completed by a multi-milestone /goal run',
  whenToUse: 'After a long /goal run completes several milestones — a fast [auto]-dimension triage. The parallel sweep verifies + pins milestones whose done-conditions are fully [auto] (schema/RLS/unit/logic). It CANNOT close [runtime] conditions (no browser, one shared local DB), so any milestone with a render/action/live condition comes back blocked and must be finished by a serial /verify-milestone <slug>. Pass slugs as args to limit scope.',
  phases: [
    { title: 'Discover', detail: 'map milestone specs to branches and PRs' },
    { title: 'Verify', detail: 'one fresh-context verifier per milestone, each in its own worktree' },
  ],
}

const DISCOVERY_SCHEMA = {
  type: 'object',
  required: ['milestones'],
  properties: {
    milestones: {
      type: 'array',
      items: {
        type: 'object',
        required: ['slug', 'branch', 'doneConditions', 'verificationMethod'],
        properties: {
          slug: { type: 'string' },
          branch: { type: 'string' },
          pr: { type: 'number', description: 'PR number if one exists' },
          doneConditions: { type: 'string', description: 'verbatim done-conditions from the milestone spec' },
          verificationMethod: { type: 'string', description: 'the spec verification: line, or "unspecified"' },
          fanout: { type: 'boolean', description: 'true if the method is a dynamic workflow over many units' },
        },
      },
    },
  },
}

const VERDICT_SCHEMA = {
  type: 'object',
  required: ['verdict', 'verifiedSha', 'discrepancies', 'unverified'],
  properties: {
    verdict: { type: 'string', enum: ['clean', 'discrepancies', 'blocked'] },
    verifiedSha: { type: 'string', description: 'short SHA of the branch HEAD you verified: run `git rev-parse --short HEAD` immediately after the detached checkout' },
    discrepancies: {
      type: 'array',
      items: {
        type: 'object',
        required: ['requirement', 'actual', 'evidence', 'remediationCondition'],
        properties: {
          requirement: { type: 'string', description: 'what the spec requires' },
          actual: { type: 'string', description: 'what actually exists' },
          evidence: { type: 'string', description: 'file:line for code claims, record-level identification for data claims' },
          remediationCondition: { type: 'string', description: 'checkable condition phrased for a remediation /goal' },
        },
      },
    },
    unverified: { type: 'array', items: { type: 'string' }, description: 'conditions that could not be checked, each with the reason' },
  },
}

phase('Discover')
// The harness delivers args as a raw string regardless of the shape in the tool call,
// so accept: a real array, a JSON-encoded array string, or whitespace-separated slugs.
let slugs = args
if (typeof slugs === 'string') {
  const s = slugs.trim()
  if (s.startsWith('[')) {
    try { slugs = JSON.parse(s) } catch { slugs = [] }
  } else {
    slugs = s.split(/\s+/).filter(Boolean)
  }
}
if (!Array.isArray(slugs)) slugs = []
const scope = slugs.length ? ` Limit to these milestone slugs: ${JSON.stringify(slugs)}.` : ''
const discovery = await agent(
  `In the current repo, map completed milestones to their branches for verification.${scope}
1. Read every file in specs/milestones/. For each milestone extract: slug (from filename, e.g. m3-auth), the done-conditions verbatim, and the verification: line (or "unspecified").
2. Run \`gh pr list --state open --json number,headRefName\` and \`git branch -a\` to find each milestone's branch and PR — branch, PR, and spec file share the slug by convention.
3. Include only milestones whose branch exists and has work on it (commits beyond its base). Set fanout=true where the verification method is a dynamic workflow over many units.
Return the structured list.`,
  { label: 'discover-milestones', schema: DISCOVERY_SCHEMA }
)

const milestones = (discovery && discovery.milestones) || []
if (!milestones.length) return { report: 'No completed milestones with branches found to verify.' }
log(`Verifying ${milestones.length} milestone(s): ${milestones.map(m => m.slug).join(', ')}`)

const results = await parallel(milestones.map(m => () =>
  agent(
    `You are verifying milestone "${m.slug}" against its spec. You are in a dedicated git worktree.
First run: git checkout --detach origin/${m.branch} 2>/dev/null || git checkout --detach ${m.branch}
(Detached checkout avoids same-branch worktree conflicts.) Immediately capture the commit you are verifying: run \`git rev-parse --short HEAD\` and return it as verifiedSha. Run installs if needed to execute checks.

Done-conditions (verbatim from specs/milestones/${m.slug}.md — also re-read the spec file yourself after checkout):
${m.doneConditions}

Verification method from the spec: ${m.verificationMethod}
${m.fanout ? 'This method fans over many independent units — check every unit yourself against the cited ground truth; list any you could not check as unverified.' : ''}

Hard rules:
- Fix nothing. Verification and remediation never share a session.
- Every discrepancy needs evidence: file:line for code claims, record-level identification (which row, unit, record) for data claims.
- Anything you could not check goes in unverified with the reason — never assumed passing.
- **You can only close [auto] done-conditions** (schema/RLS/unit/logic/static). This is a parallel detached worktree with no browser and a SHARED local DB/dev server — you CANNOT run the [runtime] walk (render a route, drive a server action through the real runtime, make a live call). If this milestone touches a route (\`src/app/**\`) or a server action, OR carries any [runtime]/live done-condition, you MUST return verdict "blocked" with those conditions in unverified ("runtime walk not runnable in the parallel sweep — needs serial /verify-milestone"). Do NOT return "clean" for a UI/action milestone — that would let it be pinned without ever rendering, the exact failure this gate exists to stop. "clean" is only for a milestone whose conditions are entirely [auto] and all passed.
- This branch may contain earlier milestones' work underneath it (branches stack until PRs merge). Verify THIS milestone's done-conditions; attribute discrepancies to conditions, not to the branch.
- Shared local services (databases, local Supabase, dev servers) carry the stack head's state, not this checkout's. When a schema- or state-dependent failure involves an artifact a later milestone introduces, and the head branch passes that check, classify it as environment skew in unverified — not a defect. Never reset or mutate shared state to get a pristine environment.
- On any test failure, record the failing test identities (names/files) before re-running — a transient failure without identities is unreportable. Include them in the verdict even if the suite passes on retry.
Return the structured verdict.`,
    { label: `verify:${m.slug}`, phase: 'Verify', schema: VERDICT_SCHEMA, agentType: 'verifier', isolation: 'worktree' }
  ).then(v => (v ? { slug: m.slug, branch: m.branch, pr: m.pr, ...v } : null))
))

const verified = results.filter(Boolean)
const skipped = milestones.filter((m, i) => !results[i]).map(m => m.slug)
const clean = verified.filter(r => r.verdict === 'clean')
const failed = verified.filter(r => r.verdict !== 'clean')

// --- Record phase: write the pinned `verified:` line for each clean milestone ---
// The parallel verifiers ran on detached HEADs and cannot commit; this single sequential, non-detached
// step writes the records so the bulk sweep satisfies the SAME pre-PR gate the per-milestone skill enforces.
// Records are non-code (verify-milestone carves "fix nothing" out for the verdict line) and land only on
// feature branches, in stack order, never main.
const methodBySlug = Object.fromEntries(milestones.map(m => [m.slug, m.verificationMethod]))
let recordResult = null
if (clean.length) {
  phase('Record')
  const ordered = [...clean].sort((a, b) => a.slug.localeCompare(b.slug, undefined, { numeric: true }))
  recordResult = await agent(
    `Write the pinned \`verified:\` record for each clean milestone below, IN THE GIVEN ORDER (bottom-up / stack order). ` +
    `The parallel verifiers ran on detached HEADs and could not commit, so you write the records now — this is what makes ` +
    `the bulk sweep satisfy the same pre-PR gate the per-milestone /verify-milestone enforces. A record is NOT code.\n\n` +
    `For each milestone, in order:\n` +
    `1. \`git checkout <branch>\` (the real branch, not detached).\n` +
    `2. Run \`git rev-parse --short HEAD\`. If it does NOT equal the given verifiedSha, the branch moved since verification — ` +
    `do NOT record it; report it as needs-reverify and move on.\n` +
    `3. Append this exact line to \`specs/milestones/<slug>.md\` (get the date from \`date +%Y-%m-%d\`):\n` +
    `   \`verified: clean at <verifiedSha>, <date>, via <method> (evidence in PR #<pr>)\`  — if pr is "pending", write \`(PR pending)\`.\n` +
    `4. \`git add specs/milestones/<slug>.md && git commit -m "verify(<slug>): record clean verdict"\`.\n\n` +
    `HARD LIMITS: touch NO code; do NOT push; do NOT checkout, commit to, or otherwise touch main. After your commit the ` +
    `record commit is the branch tip and the pinned SHA equals HEAD^ (the verified code state) — that is exactly the gate's rule.\n\n` +
    `Milestones in order:\n${JSON.stringify(ordered.map(r => ({ slug: r.slug, branch: r.branch, verifiedSha: r.verifiedSha, pr: r.pr || 'pending', method: methodBySlug[r.slug] || 'verifier subagent' })), null, 2)}\n\n` +
    `Return a short summary: which milestones got a record (with the record commit sha) and which were skipped as needs-reverify.`,
    { label: 'write-records', phase: 'Record' }
  )
}

return {
  summary: `${clean.length}/${milestones.length} clean, ${failed.length} with findings` +
    (skipped.length ? `; could not verify: ${skipped.join(', ')}` : ''),
  clean: clean.map(r => ({ milestone: r.slug, pr: r.pr, verifiedSha: r.verifiedSha, unverified: r.unverified })),
  failed: failed.map(r => ({
    milestone: r.slug,
    pr: r.pr,
    discrepancies: r.discrepancies,
    unverified: r.unverified,
    remediationGoal: (r.discrepancies || []).map(d => d.remediationCondition).join('; '),
  })),
  recordsWritten: recordResult || 'No clean milestones — no verified: records written.',
  mergeOrder: 'Records were written ONLY for fully-[auto] clean milestones, in stack order. Any milestone returned "blocked" because its [runtime] walk could not run in this parallel sweep has NO pin yet and is not failing — finish it with a serial `/verify-milestone <slug>` (which renders the routes, drives the actions, and runs any live call, then writes the pin). Milestones with real discrepancies also have no record and need a remediation /goal. Branches stack until PRs merge: merge bottom-up, and only merge a milestone once it and everything beneath it are pinned clean.',
  runtimePending: failed.filter(r => r.verdict === 'blocked').map(r => r.slug),
}
