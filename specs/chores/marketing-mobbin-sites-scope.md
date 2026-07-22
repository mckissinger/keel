# Chore batch — marketing-mobbin-sites-scope

Punch-list batch: a single prose-only doc scope-tightening in the marketing-site skill's reference-research reference — make explicit that every marketing reference pull targets the website / marketing-page corpus and never the mobile-app corpus, including how the known paid MCP instance (Mobbin) splits Sites vs. Apps and how to scope to Sites only while keeping the MCP a soft dependency.

## Applied items

- **mobbin-sites-scope** — `skills/marketing-site/references/reference-research.md` now carries a "Corpus scoping — website pages only, never the mobile-app corpus" paragraph after the paid-MCP soft-dependency note: it directs marketing pulls to the website corpus, prefers a website-section verb (no platform axis), scopes any platform argument to `web`, names Mobbin's Sites/Apps split as the 2026-07 instance, and states the scoping is mode-disclosing (falls back down the ladder and records the actual mode rather than reaching into the mobile-app corpus).
  - Done-condition: the reference names the website / marketing-page corpus as the only target, excludes the mobile-app corpus, and describes scoping a platform argument to `web` (Mobbin Sites only) as a mode-disclosing, soft-dependency behavior.

## Combined checks

`bash scripts/check-neutral.test.sh` (17 passed), `check-plan.test.sh`, `check-skill-frontmatter.test.sh`, `check-skill-anchors.test.sh`, `check-verified-pin.test.sh`, `session-bootstrap.test.sh`, `merge-guard.test.sh`, `guard-branch-rules.test.sh`, `attended-marker-parity.test.sh`, `check-auto-preflight.test.sh`, `repin.test.sh` — all PASS; repo lints `check-neutral.sh` (PASS — no retained stack/command language), `check-plan.sh` (PASS — 68 milestone + 28 chore specs well-formed), `check-skill-frontmatter.sh` (PASS — 29 skill files), `check-skill-anchors.sh` (PASS — 62 anchors across 10 feature files) — all PASS. All green on the combined branch.

verified: clean at cfc08c1, 2026-07-21, via punch-list (evidence in PR #169)
