# Chore batch — prune-direction-archetypes

Delete the six named direction archetypes (Terminal/Operator, Ledger/Institution, Instrument
Panel, Workshop, Editorial System, Calm Default) from `app-design-directions`' Phase 1 reference.
Owner-observed evidence: mockup portfolios came out similar **across different apps** — the
signature of menu anchoring, corroborated by the diversity-collapse literature (named example
lists anchor generation and collapse semantic diversity even at high temperature). The menu was
a compensates-for-weakness mechanism per `decisions/2026-07-01-model-capability-ledger.md`;
frontier models with a real Phase 0 brief derive distinct directions without it. Everything that
*checks* distinctness stays untouched: the axes-of-variation table, the ≥3-axes distinctness
test, the grayscale test, the anti-slop gate, the signature element, the tradeoff line, and the
domain-derivation section.

## Applied items

- **prune-archetype-menu** — `skills/app-design-directions/references/direction-recipes.md`:
  the "Direction archetypes for product UI" section (the 6 named skeletons) replaced by a
  "Portfolio composition" section that keeps the portfolio rules (span density, span warm/cool,
  ≥1 domain-derived direction, one honest risk, the incumbent direction on redesigns), states
  that directions are derived fresh from the brief and the axes with **no menu of named looks**,
  and names why (a named list anchors every app toward the same portfolio). Axes table, tests,
  domain-derivation, signature-element, and tradeoff sections unchanged.
- **skill-table-row** — `skills/app-design-directions/SKILL.md` reference-table row for
  `direction-recipes.md` updated ("direction archetypes" → "portfolio composition, domain
  derivation"). No other SKILL.md prose touched; Phase 3.5's *screen archetypes* (layout
  patterns) are a distinct concept and untouched.

## Combined checks

`claude plugin validate --strict .`, `bash scripts/check-neutral.sh`, `bash scripts/check-plan.sh`,
`bash scripts/check-skill-frontmatter.sh`, `bash scripts/check-skill-anchors.sh`.

## verification

fresh-context verifier subagent against this file + the diff: the branch changes exactly two
content files (`direction-recipes.md`, `SKILL.md`) plus this chore spec; the six named archetypes
appear nowhere in the repo after the change; the axes table, distinctness test, grayscale test,
anti-slop gate, signature element, tradeoff line, and domain-derivation sections are byte-unchanged;
the portfolio rules survive in the replacement section; SKILL.md's change is the one table row;
screen-archetype prose untouched. All five combined checks green. No gate/guard/hook touched →
no `/security-review`.
verified: clean at a87c996, 2026-07-22, via fresh-context keel:verifier subagent — exactly 3 files changed; the six archetype names survive only in this chore spec's own deletion record (disclosed, not skill content); the axes table, ≥3-axes distinctness rule, grayscale test, anti-slop pass, signature element, tradeoff line, and domain-derivation sections byte-unchanged outside the single deletion hunk; the Portfolio composition replacement carries all five portfolio rules + the no-menu statement with anchoring rationale; SKILL.md diff is the one table row with screen-archetype prose untouched; all 5 combined checks green (33 chore specs, 29 skills, 62 anchors) + plugin validate --strict.
