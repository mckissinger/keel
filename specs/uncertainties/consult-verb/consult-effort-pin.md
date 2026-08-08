# Uncertain choice — `consult` pins no `effort:` in its frontmatter

**The choice made:** `skills/consult/SKILL.md` carries no `effort:` key, and `consult` sits in
`references/model-routing.md`'s default-rule list (`inherit`, `high`). A parenthetical in the
reference states the omission is deliberate and notes the judgment itself runs at the `oracle`
agent's own pinned `claude-fable-5`/`high`.

**Viable alternative(s):** pin `effort: high` in the skill's frontmatter and give `consult` a
table row instead — the shape `arm-auto-merge` and `prep-auto-merge` take in this same milestone,
and the shape every other effort-pinning skill takes.

**Why it's uncertain:** the milestone's done-condition says `consult` "appears in the default-rule
list", and the same condition's rationale for the two drifted skills is that effort-pinning skills
belong in the table — so the two clauses only stay consistent if `consult` pins nothing. The
consequence is real rather than cosmetic: without a pin, the orchestrating skill inherits session
effort, which can be lower than `high`, and it is the orchestrating side that decides whether a
question is genuinely consultable and how well the brief is distilled — a weak brief gets a weak
answer no matter how strong the oracle is. A reviewer could reasonably prefer the pin (and a table
row), treating the spec's list placement as the looser of the two clauses.
