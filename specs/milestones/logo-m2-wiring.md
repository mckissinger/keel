# Milestone — logo-m2-wiring

Feature context: `specs/features/logo.md`. Second of two; surfaces `logo` in the
ladder and banners, lands the routing seam into `marketing-site`, adds the routing
fixtures, and records the deferral. Depends on m1 (the routing sentence and fixtures
cite m1's skill). Every edit to a shared file in this wave is owned here alone. The
`marketing-site` edit is one sentence — its scope is unchanged. Neutrality caution
as m1.

## Done-conditions

- [auto] **Ladder wiring.** `README.md`'s grain-ladder code block gains a new `Logo`
  row in the style of the existing `Marketing`/`Video` rows (aligned columns, no
  colon: `Logo       logo → plan PR (kit + integration milestone)`-shaped), the
  skills list gains a new `- **Logo** —` grain bullet parallel to the existing
  `- **Video** —` bullet (one verb's worth of description: SVG-direct logo kit —
  lockups × colorways, favicon/PWA set, usage sheet — via attended art direction),
  **and the skill count reads 29** — no stale count text survives anywhere in the
  file; both orientation-banner copies in `scripts/session-bootstrap.sh` gain a
  `- Logo:` line in the banners' existing colon style (matching their
  `- Marketing:`/`- Video:` lines; `logo` is not human-trigger marked); and
  `scripts/session-bootstrap.test.sh` gains an assertion that the emitted banner
  names `logo`, with the full suite still passing.
- [auto] **The marketing-site seam lands.** `skills/marketing-site/SKILL.md` gains
  one sentence: when the product repo carries a committed logo kit
  (`design/brand/`, authored by `logo`), Discover consumes it — the header mark,
  favicon, and `og:image` derive from the kit rather than being improvised. One
  sentence; the skill's scope is otherwise unchanged and the file is otherwise
  byte-identical to `main`.
- [auto] **Boundary fixtures exist for the suite.** New file-per-entry fixtures
  under `scripts/skill-eval/fixtures/` (`g7-*.json`) cover at least: a prompt that
  should fire `logo` ("design a logo for my product" / brand-mark shaped), a
  `logo`-vs-`marketing-site` boundary case (a landing page that needs a logo —
  expected `marketing-site`, the kit consumed downstream), and a
  `logo`-vs-`app-design-directions` boundary case (deciding the app's visual
  design system — expected `app-design-directions`) — each in the existing fixture
  shape (`{prompt, expected, boundary}`), each valid JSON under the directory the
  eval harness discovers fixtures from, with the eval self-tests still passing.
- [auto] **The deferral is recorded.** `specs/deferrals/logo-brand-collateral.md`
  (brand collateral beyond the mark — decks, cards, banners, a guidelines site)
  exists in the deferrals ledger's format with an explicit risk/trigger note.
- [auto] **Repo checks green.** `claude plugin validate --strict .`,
  `scripts/check-neutral.sh`, `scripts/check-plan.sh`,
  `scripts/check-skill-frontmatter.sh`, `scripts/check-skill-anchors.sh`, and every
  `scripts/*.test.sh` pass on the branch.

## verification

verifier subagent against this file's done-conditions (all `[auto]`; the milestone is
wiring, fixtures, and a ledger entry, closable by reading the named files, diffing
the one-sentence seam against `main`, and running the named checks — including the
session-bootstrap and skill-eval self-tests).

verified: clean at 2f0dff0, 2026-07-18, via verifier subagent against this spec's done-conditions — all 5 conditions evidenced with file:line, seam strictly one added sentence vs main, scope exactly the 8 owned files, plugin validate + 4 repo checks + 11 script self-tests + eval self-tests green (evidence in PR #154) — carried forward from d740ae4: clean rebase onto main after #153 squash; tree byte-identical, suites re-run green
