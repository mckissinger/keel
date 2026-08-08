# Chore batch — release 1.26.0

Minor release surfacing everything merged since the 1.25.0 release commit (#219) to the installed
runtime — the consult-verb change (plan #220, implementation #221, the milestone carrying its own
verified pin at ae1e969). Installed plugins report `1.25.0`; the version must move before
`claude plugin update` can pick these up. (The version string, not a git tag, is what plugin
update consumes — tagging lapsed after `v1.22.0`.)

## Applied items

- **plugin-version-1.26.0** — `.claude-plugin/plugin.json` `version` bumped `1.25.0` → `1.26.0`
  (minor: one new skill and a broadened consult capability, no removals, no breaking changes;
  skill count 31 → 32; agent count unchanged at 2). Since 1.25.0:
  - **consult-verb** (#220 plan, #221 implementation): new `skills/consult/SKILL.md` — the
    attended consult verb owning the consult **mechanism** (distill one judgment question into a
    brief of question + viable options + relevant paths, dispatch `agents/oracle.md`, report
    recommendation + rationale + disposition), with a worked brief, attended semantics (no cap;
    `uncertain` and `reframed-as-authorization` halt nothing; decision tail offers a `decisions/`
    record and never auto-writes), and model-invocability (no `disable-model-invocation`).
    `agents/oracle.md` generalized so no sentence presumes a mode-only dispatcher — its
    `name`/`tools`/`disallowedTools`/`model`/`effort` frontmatter lines, report shape, three
    dispositions, one-question rule, read-only rules, and anchored refusal sentence all
    unchanged. `skills/auto/SKILL.md`'s consult contract changed in exactly two ways: the
    mechanism-owner citation sentence, and the mode-gated bullet's now-false attended closing
    clause (every policy clause and all four judgment-oracle anchors intact).
    `skills/debug/SKILL.md` gained one pointer (undiscriminated competing root causes are a
    consultable judgment question). `references/model-routing.md`: `consult` in the default list,
    plus the drift repair — `arm-auto-merge` and `prep-auto-merge` gained table rows and the
    coverage-audit count moved 29 → 32, so every skill on disk is again covered by the table or
    the list. Anchor set `scripts/skill-anchors/consult-verb.txt`; one builder uncertainty under
    `specs/uncertainties/consult-verb/`.
  - Guard/hook semantics deltas since `1.25.0`, for the record: none — no guard script, gate,
    preflight, or never-auto list changed (#221's no-gate-change invariant, verified in its pin).
    The only skill frontmatter change is the new `consult` skill's own (which pins no `model:`
    or `effort:`, per its default-list routing placement).
  `.claude-plugin/marketplace.json` carries no `version` field, so it is unchanged.

## Combined checks

`claude plugin validate --strict .`, `bash scripts/check-neutral.sh`, `bash scripts/check-plan.sh`,
`bash scripts/check-skill-frontmatter.sh`, `bash scripts/check-skill-anchors.sh`, plus the script
self-tests. The released content itself landed verified with #221 (its milestone pin) and is
unaffected by a version-string change.
