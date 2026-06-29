export const meta = {
  name: 'punch-list',
  description: 'Resolve a batch of tiny, independent changes — one focused subagent per item in its own worktree, then assemble into a single verified chore PR',
  whenToUse: 'For a laundry list of sub-milestone changes (typos, lint nits, renames, missing aria-labels, stale comments) where doing them one milestone at a time is absurd overhead. Each item must be a checkable done-condition. Pass {slug, items:[{id,condition,files}]} as args — the punch-list skill produces it. Independent items run in parallel; same-file items are grouped so they never collide. Lands as one chore PR with one batch pin (the chore-lane gate).',
  phases: [
    { title: 'Plan', detail: 'group items by file so parallel fixes never collide' },
    { title: 'Fix', detail: 'one worktree-isolated subagent per group — make the change, self-check, return a diff' },
    { title: 'Assemble', detail: 'apply the diffs onto one chore branch, verify combined, write the batch pin, open the PR' },
  ],
}

const FIX_SCHEMA = {
  type: 'object',
  required: ['status', 'diff', 'note'],
  properties: {
    status: { type: 'string', enum: ['done', 'failed', 'skipped'] },
    diff: { type: 'string', description: 'unified diff of the change (git diff vs HEAD); empty if failed/skipped' },
    touchedFiles: { type: 'array', items: { type: 'string' } },
    note: { type: 'string', description: 'one line: what changed, or why it failed/was skipped' },
  },
}

const ASSEMBLE_SCHEMA = {
  type: 'object',
  required: ['branch', 'applied', 'dropped', 'checks'],
  properties: {
    branch: { type: 'string' },
    pr: { type: 'string', description: 'PR number or url, or "not-opened" with the reason' },
    recordSha: { type: 'string', description: 'short sha the batch pin references (the combined-code tip)' },
    applied: { type: 'array', items: { type: 'string' }, description: 'item ids that landed' },
    dropped: { type: 'array', items: { type: 'string' }, description: 'item ids dropped, each with the reason' },
    checks: { type: 'string', description: 'result of the combined typecheck/lint/test on the chore branch' },
  },
}

phase('Plan')
// Accept {slug, items:[...]} — tolerate a JSON-encoded string or a bare items array.
let input = args
if (typeof input === 'string') { try { input = JSON.parse(input) } catch { input = {} } }
if (Array.isArray(input)) input = { items: input }
const items = (input && input.items) || []
const slug = (input && input.slug) || 'punch-list'
if (!items.length) return { report: 'No punch-list items provided. Pass {slug, items:[{id,condition,files}]}.' }

// Group by file overlap: items sharing any file go in one group (serialized into one subagent),
// so parallel groups never write the same file. Independent groups parallelize.
function groupByFile(list) {
  const groups = []
  for (const it of list) {
    const files = new Set(it.files || [])
    let g = groups.find(grp => [...files].some(f => grp.files.has(f)))
    if (!g) { g = { items: [], files: new Set() }; groups.push(g) }
    g.items.push(it)
    for (const f of files) g.files.add(f)
  }
  return groups.map((g, i) => ({ groupId: i, items: g.items, files: [...g.files] }))
}
const groups = groupByFile(items)
log(`${items.length} item(s) in ${groups.length} non-colliding group(s)`)

phase('Fix')
const fixed = await parallel(groups.map(g => () =>
  agent(
    `You are resolving ${g.items.length} tiny change(s) in an ISOLATED git worktree. Touch ONLY these files: ${JSON.stringify(g.files)}.\n` +
    `For each item, make exactly the change its done-condition states — nothing more (no drive-by refactors, no scope creep):\n` +
    g.items.map(it => `  - [${it.id}] ${it.condition}`).join('\n') + `\n\n` +
    `Then SELF-CHECK only what you touched (typecheck/lint the touched files; run a directly-relevant test if one exists). ` +
    `Do NOT commit. When done, return:\n` +
    `- status "done" if every change was made and the self-check is clean; "failed" if a change couldn't be made cleanly; "skipped" if the condition was already satisfied.\n` +
    `- diff: the output of \`git diff\` (working tree vs HEAD) — the patch to apply. Empty if failed/skipped.\n` +
    `- touchedFiles and a one-line note.\n` +
    `If any item in the group can't be done cleanly, set status "failed" and explain — a half-applied group is worse than a dropped one.`,
    { label: `fix:g${g.groupId}`, phase: 'Fix', schema: FIX_SCHEMA, isolation: 'worktree' }
  ).then(r => (r ? { groupId: g.groupId, ids: g.items.map(i => i.id), files: g.files, ...r } : null))
))

const ok = fixed.filter(Boolean).filter(r => r.status === 'done' && r.diff && r.diff.trim())
const notApplied = fixed.filter(Boolean).filter(r => r.status !== 'done' || !(r.diff && r.diff.trim()))
log(`${ok.length}/${groups.length} group(s) produced a clean diff`)
if (!ok.length) {
  return { slug, applied: [], dropped: fixed.filter(Boolean).map(r => ({ ids: r.ids, status: r.status, note: r.note })),
           report: 'No item produced a clean change — nothing to assemble.' }
}

phase('Assemble')
const assembled = await agent(
  `Assemble a single chore PR from the diffs below. Steps, exactly:\n` +
  `1. From up-to-date \`main\`: \`git checkout -b chore/${slug}\`.\n` +
  `2. For EACH group's diff in order, apply it and commit on its own: write the diff to a temp file and \`git apply\` it (the groups touch disjoint files, so applies never conflict), then \`git commit -m "chore(${slug}): <ids>"\`. If a diff fails to apply cleanly, DROP that group (record it in dropped) and continue — never force it.\n` +
  `3. Run the COMBINED checks on the branch (typecheck + lint + test). Capture the result in \`checks\`. If they fail, stop before writing any pin and report — do not open a PR over red checks.\n` +
  `4. If checks pass: capture \`git rev-parse --short HEAD\` as recordSha (the combined-code tip). Write \`specs/chores/${slug}.md\` listing every applied item + its done-condition + this line (get the date from \`date +%Y-%m-%d\`):\n` +
  `   \`verified: clean at <recordSha>, <date>, via punch-list (evidence in PR #<n>)\`\n` +
  `   then \`git add specs/chores/${slug}.md && git commit -m "verify(chore/${slug}): batch record"\`. The record commit is now the tip; the pin references HEAD^ (the code) — exactly what the chore-lane gate checks.\n` +
  `5. Push and open ONE PR titled \`chore: ${slug}\` (base main). Quote the applied items + the combined-check result in the body. Do NOT merge — the user merges.\n` +
  `HARD LIMITS: touch no code beyond applying the given diffs; never commit to main; one batch pin for the whole set.\n\n` +
  `Groups + diffs (in order):\n${JSON.stringify(ok.map(r => ({ ids: r.ids, files: r.files, diff: r.diff })), null, 2)}\n\n` +
  `Already not-applied (carry into dropped with their notes): ${JSON.stringify(notApplied.map(r => ({ ids: r.ids, status: r.status, note: r.note })))}`,
  { label: 'assemble-chore-pr', phase: 'Assemble', schema: ASSEMBLE_SCHEMA }
)

return {
  slug,
  branch: assembled && assembled.branch,
  pr: assembled && assembled.pr,
  applied: (assembled && assembled.applied) || [],
  dropped: (assembled && assembled.dropped) || notApplied.map(r => `${r.ids}: ${r.note}`),
  checks: assembled && assembled.checks,
  note: 'One chore PR with one batch pin (specs/chores/' + slug + '.md). Dropped items are not failures — re-run them or route a stubborn one to spec-change. You merge.',
}
