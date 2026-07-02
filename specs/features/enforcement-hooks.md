# Feature — Enforcement hooks: keel's invariants become mechanism

**Grain:** one feature → three milestones (`spec-feature`). **No-UI** (plugin hooks + shell
scripts + docs). Signed off 2026-07-01.

## Definition

keel's two behavioral-only invariants — *skill activation* (a session must know keel's verbs
exist) and *agent-side merge/branch restraint* (never merge, never commit to main, pin gates
the merge) — are enforced today entirely by prose that must survive context pressure and
compaction. This feature ships them as **plugin hooks**: a SessionStart bootstrap that makes
keel self-activate in keel-managed projects, PreToolUse guards that turn the merge rules into
harness decisions, and distribution seeding so every collaborator session has keel at all.
Hooks are a **local backstop**: project CI and branch protection remain the server-side
truth; nothing here replaces them.

## Interview outcome (resolved decisions)

- **Bootstrap fires in keel-managed projects only** (user decision): the SessionStart script
  probes for keel markers (a `specs/` dir with milestone/foundation files, or a project
  CLAUDE.md that names the verified-pin process) and exits silently — output nothing —
  everywhere else. Also registers the `compact` matcher so the bootstrap re-injects after
  compaction (the documented re-injection mechanism; PostCompact cannot inject).
- **Merge guards answer `ask` by default, `deny` on gate failure**: per-merge human approval
  becomes a harness prompt; a failing `check-verified-pin.sh` becomes a deny-with-reason.
  When the repo has no gate script or `gh` context, the guard degrades to plain `ask` — it
  never blocks a merge the human explicitly approves, and never silently allows one.
- **Skill-scoped branch guards** ride implement-milestone / implement-feature (commit-on-main
  and merge attempts exit 2) — the local-only-project gap, where provision is a no-op and no
  branch protection exists.
- **No hooks on `agents/verifier.md`** — docs state hooks/mcpServers/permissionMode are
  ignored for plugin-shipped agents.
- **`check-neutral.sh` learns to scan `hooks/`** (it currently scans only `*.md`/`*.js`;
  shipped hook scripts must meet the same neutrality bar).
- **Composition is tested, not assumed** (the research critic's finding): a dedicated
  milestone proves the guards don't fight land-feature's own merge flow, the pin write, or
  the newly shipped `disable-model-invocation` flags.
- **Parked with deferral entries in this plan PR:** verifier `memory: project`,
  `context: fork` on verify-milestone, and trigger evals — each gated on an untested platform
  interaction, recorded in `specs/deferrals/`.

## Milestones (build order)

| # | Milestone | What |
|---|---|---|
| 1 | `hooks-m1-bootstrap` | hooks/hooks.json + plugin.json registration; SessionStart (incl. compact matcher) keel-marker-gated bootstrap; check-neutral scans hooks/ |
| 2 | `hooks-m2-guards` | PreToolUse merge guard (ask/deny via the project's pin gate); skill-scoped branch guards; self-tests for both scripts |
| 3 | `hooks-m3-distribution-composition` | provision/adopt marketplace seeding; backstop docs (README, land-feature, §5); live composition walk |

Milestone 2 depends on 1 (hooks.json exists); 3 depends on 1+2 (composition tests the shipped
whole). No parallel build.

## Seams

- `scripts/check-verified-pin.sh` — the merge guard *invokes* the project's copy; it never
  re-implements gate logic (one owner).
- `skills/provision/SKILL.md` step 4 and `skills/adopt/SKILL.md` — own the committed
  settings.json; seeding extends them in place.
- `skills/land-feature/SKILL.md` — its merge choreography now runs *through* the guard's
  `ask`; the composition milestone proves the flow still lands.
