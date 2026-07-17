# Milestone — growth-m3-run-growth-wiring

Feature context: `specs/features/growth.md`. Third of three; adds the `run-growth`
skill, then wires the Growth grain into the plugin: README ladder/list/count, both
session-bootstrap banners + test assertion, one routing sentence in
`skills/marketing-site/SKILL.md`, a new anchors file, skill-eval boundary fixtures,
and the three deferral entries. Requires m1 + m2 on the branch history (the skill
cites the doctrine and names m2's templates). Integration seams: the
session-bootstrap banner is covered by `scripts/session-bootstrap.test.sh` (stays
green, gains an assertion); `marketing-site`'s Discover movement gains one consuming
sentence and its scope does not change; the anchors file is **new**
(file-per-feature — never edit an existing anchor file); fixtures are file-per-entry
JSON. Neutrality caution for the builder: skill prose names no vendor as required
(hedged examples only); no dogfood projects or real brands; the banner lines must
stay clear of the neutrality denylist.

## Done-conditions

- [auto] **The skill exists, well-formed and human-triggered only.**
  `skills/run-growth/SKILL.md` has valid frontmatter (`name: run-growth`, a
  `description`, a `when_to_use`, **and `disable-model-invocation: true`**) and
  passes `scripts/check-skill-frontmatter.sh`. The body states why it is
  human-triggered only (it is the verb that executes sends/posts after approval —
  it must never fire because a session inferred it should; scheduled prep sessions
  invoke it explicitly by name). The `when_to_use` states it runs **in the
  growth-ops repo** over campaigns `spec-campaign` authored, and disambiguates from
  `gtm` and `spec-campaign`.
- [auto] **The cycle contract is encoded in order, gates included.** The skill body
  states one cycle as an ordered contract: (1) **readback** — pull outcomes from the
  provider APIs via the committed readback script (m2's template, named), append to
  the ledger, flag staleness against the campaign's pinned product-repo references;
  (2) **stop-condition check** — any breached campaign is paused immediately by the
  readback script itself (m2's template owns the pause — the doctrine's one
  always-allowed unattended write, cited) and flagged; (3) **prep** — signal gathering, source-ladder enrichment with the
  verification gate, and drafting, landing queue files and a **cycle brief**;
  (4) **the attended approval gate** — the user reviews the brief and queues;
  approval writes an approval record; edits and kills need no record; (5) **push** —
  only through the committed push script (m2's template, named), which refuses
  without the approval record; (6) **dispatch record** — a file-per-entry ledger
  entry with counts and evidence pointers closes the cycle. Reply handling is
  always attended: replies surface in the brief with drafted responses, and no
  response sends without approval.
- [auto] **The two run modes are encoded.** The skill body distinguishes: the
  **attended sitting** (all six steps in one session) and the **unattended prep
  run** (steps 1–3 only — a scheduled session stops after the brief and
  notifies; steps 4–6 wait for a human), and states that an unattended run
  breaching any gate degrades to paused/waiting, never to sent — with the
  standing-envelope classes (doctrine, cited) as the only exception, and spend
  under an active autonomy mode remaining a planned stop point unless the run's
  pre-authorized envelope covers it.
- [auto] **Ladder wiring.** `README.md`'s grain ladder gains a `Growth:` line naming
  `gtm → spec-campaign → run-growth`, the skills list gains a Growth bullet naming
  all three verbs, **and the skill count reads 27** (run-discovered correction: a
  `harden` verb landed on `main` after the plan PR, so 26 existing + `run-growth`
  = 27) — no stale count text survives anywhere in the file; both orientation-banner copies in
  `scripts/session-bootstrap.sh` carry the same Growth line (with `run-growth`
  marked human-triggered alongside the existing autonomy verbs); and
  `scripts/session-bootstrap.test.sh` gains an assertion that the emitted banner
  names the Growth grain, with the full suite still passing.
- [auto] **The routing seam lands.** `skills/marketing-site/SKILL.md`'s Discover
  movement gains one sentence: when the product repo carries `specs/gtm/`
  (positioning authored by `gtm`), the brief consumes it rather than re-interviewing
  positioning — one sentence; the skill's scope is otherwise unchanged and the file
  is otherwise byte-identical to `main`.
- [auto] **The queue invariant is anchored.** `scripts/skill-anchors/growth.txt`
  exists (new file, file-per-feature) and pins the doctrine's queue-invariant
  sentence verbatim from `references/growth-operations.md`, and
  `scripts/check-skill-anchors.sh` passes with it.
- [auto] **Boundary fixtures exist for the suite.** New file-per-entry fixtures under
  `scripts/skill-eval/fixtures/` cover at least: a prompt that should fire `gtm`
  (positioning for a product), a prompt that should fire `spec-campaign` (author a
  campaign), a prompt that must fire **neither** `run-growth` nor any growth verb by
  inference (an operate-the-loop phrasing — expected `none`, run-growth being
  human-triggered), and one `marketing-site`-vs-`gtm` boundary case — each in the
  existing fixture shape (`{prompt, expected, boundary}`, with `expected` a verb
  name or `none`), each a valid-JSON file under the directory the eval harness
  discovers fixtures from.
- [auto] **The deferrals are recorded.** `specs/deferrals/growth-status.md` (the
  read-only derivation verb; folds into the cycle brief until operation proves the
  need), `specs/deferrals/growth-ads-templates.md` (paid-ads channel templates; note
  the platform-API asymmetry as of 2026-07), and `specs/deferrals/growth-sms.md`
  (SMS channel; additionally gated on an attended compliance decision) each exist
  in the deferrals ledger's format with an explicit risk/trigger note.
- [auto] **Repo checks green.** `claude plugin validate --strict .`,
  `scripts/check-neutral.sh`, `scripts/check-plan.sh`,
  `scripts/check-skill-frontmatter.sh`, `scripts/check-skill-anchors.sh`, and every
  `scripts/*.test.sh` pass on the branch.

## verification

verifier subagent against this file's done-conditions (all `[auto]`; the milestone is
prose, wiring, fixtures, and ledger entries, closable by reading the named files and
running the named checks — including the session-bootstrap and skill-eval self-tests).
