# Milestone — consult-verb: the attended consult verb owning the shared mechanism

**Goal:** any attended session can run a disciplined Fable-5 consult — one distilled judgment
question to the read-only `oracle`, with an offered decision-record tail — via a first-class
`consult` skill that owns the mechanism once, while the autonomy policy stays owned by
`skills/auto/SKILL.md`, changed only in the two permitted ways the done-conditions fix.

**Change:** `specs/changes/consult-verb.md`. **No-UI** → two-dimension done-conditions.
**Depends on:** nothing (judgment-oracle already on `main`). **Parallelizable:** no (coupled
edits to two skills + one agent + one reference + one new skill). **Routing:** reasoning-heavy —
edits consult doctrine.

## Done-conditions

### Logic / invariants

- [auto] `skills/consult/SKILL.md` exists, its frontmatter passes `check-skill-frontmatter`
  (`name: consult` equal to the directory, non-empty `description:` and `when_to_use:`), and it
  carries **no** `disable-model-invocation` key — the skill is invocable by the user
  (`/consult <question>`) and by a session on its own initiative, and its body says so.
- [auto] The skill's body owns the **mechanism**, stated as the sequence: distill **exactly one
  question** into a brief carrying the question, the viable options considered, and the relevant
  paths; dispatch `agents/oracle.md`; report the oracle's **recommendation**, **rationale**, and
  **disposition** to the user. Two-readers bar: a reader can execute the sequence from the body
  alone without opening `skills/auto/SKILL.md`.
- [auto] The skill states the **attended semantics**, decidably: **no cap** (with the stated
  rationale that the cap bounds unattended ambiguity and the attended user is the cap);
  `uncertain` → the conversation with the user continues, nothing halts;
  `reframed-as-authorization` → the question is the user's to answer directly, nothing halts —
  and it carries this boundary sentence **verbatim, on one physical line** (the anchors lint
  matches within a line): "An oracle consult is never how an authorization question gets
  answered — the oracle recommends on judgment; authorization is the human's, mode or no mode."
  (This exact string is the canonical form; the change spec quotes the same string.)
- [auto] The skill states the **ownership split**: the mechanism is owned here; the autonomy
  policy — mode-gating, the judgment-only boundary, the 5-per-feature cap, the mode's
  disposition-halt rules, the ledger records — is owned by the consult contract in
  `skills/auto/SKILL.md` and is **cited by reference, never restated**. Decidable scope of
  "never restated": the skill's prose contains no cap value (no "5" in a consult-cap context),
  no restatement of the **mode's** disposition-halt rules (the attended nothing-halts semantics
  it states above are its own, not a restatement), and no item of the never-auto list. The
  ownership-split sentence sits on one physical line (it is anchored).
- [auto] The skill states the **decision tail**: when a recommendation is adopted and the choice
  is durable, the skill **offers** to record it as a `decisions/` entry — it asks and never
  auto-writes; declining writes nothing.
- [auto] `skills/auto/SKILL.md`'s consult contract changes in **exactly two decidable ways and
  no other**: (1) it gains **one added sentence on its own new physical line**, citing
  `skills/consult` as the mechanism owner; (2) the mode-gated
  bullet's closing clause "an attended session just asks the user" — false once this milestone
  lands — is updated to route attended sessions to `skills/consult` (e.g. "an attended session
  consults via `skills/consult`, or just asks the user"). Diff granularity, stated: `git diff`
  for the file vs the merge base shows added lines for (1) plus **exactly one** modified line
  (the mode-gated bullet) for (2), and **no other removed or modified lines**; all four
  judgment-oracle anchors (`scripts/skill-anchors/judgment-oracle.txt`) still pass (the reworded
  clause is not among the anchored strings).
- [auto] `agents/oracle.md` is generalized so **no sentence in the file presumes a mode-only
  dispatcher**: the opening framing covers a session — attended, or an autonomy-mode
  orchestrator; the frontmatter `description:` no longer says the agent is for autonomy-mode
  runs only; the "ledgered default" framing, the "orchestrator" wording in the dispatch rules,
  the refusal rule's halt sentence, and the closing disposition-handling attribution each cover
  both postures (under a mode → the contract in `skills/auto/SKILL.md`; attended →
  `skills/consult`). Frozen through the edit, decidably: the frontmatter's `name`, `tools`,
  `disallowedTools`, `model`, and `effort` lines are byte-unchanged; the three disposition
  values, the report shape (recommendation / rationale / disposition), the one-question rule,
  the read-only rules, and the anchored sentence "You return the disposition
  `reframed-as-authorization`, with the reframing stated" are all still present.
- [auto] `skills/debug/SKILL.md` carries **one pointer sentence** stating that competing
  plausible root-cause hypotheses the evidence does not discriminate are a consultable judgment
  question, citing `skills/consult` by reference; the diff for that file is confined to that
  addition.
- [auto] `references/model-routing.md`: `consult` appears in the default-rule list; the
  run-discovered drift is repaired — `arm-auto-merge` and `prep-auto-merge` each get a **table
  row** (mechanism "skill frontmatter (effort only)", model `inherit`, effort `high` — the
  table-row placement is deliberate: both pin `effort: high` in frontmatter, and every other
  effort-pinning skill has a row, so the file's row-vs-list pattern is preserved) — and the
  coverage-audit sentence's count equals the actual `ls skills/` count (32), so every skill on
  disk is in the table or the list, verifiable by enumeration.
- [auto] **No-gate-change invariant:** `git diff` for this milestone shows no edits to
  `scripts/merge-guard.sh`, `scripts/check-auto-preflight.sh`, `scripts/guard-branch-rules.sh`,
  `scripts/check-verified-pin.sh`, `decisions/2026-07-genesis-envelope.md`, or
  `agents/verifier.md`.

### Behavioral completeness

- [auto] The skill carries **one worked brief** — a concrete judgment question with its options
  and paths, formatted as a dispatchable brief — so a first-time invoker has a calibration
  anchor, not only the abstract sequence. Verifiable: the worked brief is present in the prose.
- [auto] `scripts/skill-anchors/consult-verb.txt` exists (file-per-feature — no existing anchor
  file edited) and pins, verbatim in their named files, at least: the skill's verbatim boundary
  sentence above, the skill's ownership-split sentence (policy owned by `skills/auto/SKILL.md`,
  cited never restated), and the added citation sentence in `skills/auto/SKILL.md` (each pinned
  string sitting on one physical line in its file — the lint matches within a line);
  `scripts/check-skill-anchors.sh` passes.
- [auto] All pre-existing self-tests pass with no regression (`check-verified-pin`, `check-plan`,
  `check-skill-frontmatter`, `check-skill-anchors`, `check-neutral`); `claude plugin validate
  --strict .` passes.

## Verification

`verification: verifier subagent against this file's done-conditions (read the new skill, the
edited prose, and the agent file; run the self-test suite and the anchors lint; run the
no-gate-change and confinement diff checks against the milestone branch's merge base).`

verified: clean at ae1e969, 2026-08-07, via fresh-context verifier subagent against this file's done-conditions — all 13 conditions VERIFIED with file:line evidence: new consult skill (frontmatter valid, no disable-model-invocation, mechanism sequence executable from the body alone, worked brief, attended semantics, boundary sentence character-identical to the spec's canonical string on one physical line, no-restatement scope confirmed by targeted greps), oracle generalized at all six named sites with the five frozen frontmatter lines byte-unchanged and the anchored refusal sentence intact, auto contract changed in exactly the two permitted ways (3 added / 1 modified line; the mode-gated bullet's opening byte-identical, only its closing clause differs) with all four judgment-oracle anchors still passing, debug pointer confined, routing enumeration proving all 32 skills covered with 0 in neither list and 0 in both, no-gate-change diff clean over the six protected files, new anchor file pinning all three required sentences (independently grep -F confirmed). Two first-pass findings (auto bullet opening over-narrowed beyond the permitted clause at fddb95a; ownership-split anchor pinned a fragment excluding the policy enumeration) remediated at ae1e969 and re-checked closed. check-plan, check-skill-frontmatter, check-skill-anchors (85 anchors / 14 files), check-neutral, claude plugin validate --strict, and all 13 script self-tests (486 assertions, 0 failed) green; check-verified-pin red only in the documented pre-pin state, resolved by this record's commit. No [runtime] conditions (no-UI, prose-only) → no walk; no /security-review (no guard or gate file touched). One builder uncertainty surfaced, not adjudicated: specs/uncertainties/consult-verb/consult-effort-pin.md. (evidence: verifier report in PR)
