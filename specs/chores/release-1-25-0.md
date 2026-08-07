# Chore batch — release 1.25.0

Minor release surfacing everything merged since the 1.24.0 release commit (#216) to the
installed runtime — the judgment-oracle feature (plan #217, implementation #218, the milestone
carrying its own verified pin at 308b33d). Installed plugins report `1.24.0`; the version must
move before `claude plugin update` can pick these up. (The version string, not a git tag, is
what plugin update consumes — tagging lapsed after `v1.22.0`.)

## Applied items

- **plugin-version-1.25.0** — `.claude-plugin/plugin.json` `version` bumped `1.24.0` → `1.25.0`
  (minor: one new agent and new autonomy-doctrine capability, no removals, no breaking changes;
  skill count stays 31; agent count 1 → 2). Since 1.24.0:
  - **judgment-oracle** (#217 plan, #218 implementation): new read-only `agents/oracle.md`
    (`claude-fable-5` at `high`, verifier-mirroring posture) — under an active autonomy mode the
    orchestrating session may consult it on *judgment* questions (spec-underdetermined choices
    among viable alternatives) before taking a ledgered default; authorization-shaped asks stay
    never-consultable stop-points. Consult contract owned in `skills/auto/SKILL.md` (mode-gated,
    orchestrator-only dispatch, decidable three-value disposition handling, 5-per-feature cap,
    file-per-entry ledger records adjudicated at the debrief); `skills/implement-feature/SKILL.md`
    stop-point taxonomy reconciled (`uncertain` + cap-exceeded are stop-points); oracle row +
    coverage-audit update in `references/model-routing.md`; anchor set
    `scripts/skill-anchors/judgment-oracle.txt`; one builder uncertainty recorded under
    `specs/uncertainties/judgment-oracle/`.
  - Guard/hook semantics deltas since `1.24.0`, for the record: none — no guard script, gate,
    preflight, never-auto list, or skill frontmatter changed (#218's no-gate-change invariant,
    verified in its pin).
  `.claude-plugin/marketplace.json` carries no `version` field, so it is unchanged.

## Combined checks

`claude plugin validate --strict .`, `bash scripts/check-neutral.sh`, `bash scripts/check-plan.sh`,
`bash scripts/check-skill-frontmatter.sh`, `bash scripts/check-skill-anchors.sh`, plus the script
self-tests. The released content itself landed verified with #218 (its milestone pin) and is
unaffected by a version-string change.
