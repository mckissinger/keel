# Change — consult-verb: the attended consult verb, one mechanism under two policies

**For:** any attended keel session — the user, or the session itself — facing a genuine judgment
question: the spec (or the situation) underdetermines a choice among viable alternatives, and a
decorrelated frontier read would beat deciding alone. The user has been running this pattern
off-the-cuff ("consult Fable 5") across debugging, design decisions, and spec ambiguity, and it
demonstrably helps; today no verb owns it — `judgment-oracle` (1.25.0) mechanized only the
unattended case. **Enables:** a first-class `consult` verb that owns the consult *mechanism*,
usable attended without any mode, while every autonomy *policy* clause stays exactly where
1.25.0 put it.

## The shape: mechanism vs policy (the part that must not blur)

The consult mechanism is one thing regardless of context: distill **exactly one question** into a
brief (the question, the viable options considered, the relevant paths), dispatch the read-only
`agents/oracle.md` (`claude-fable-5` at `high`), and take back a recommendation + rationale + a
disposition in {`answered`, `uncertain`, `reframed-as-authorization`}. That mechanism moves into
the new `skills/consult/SKILL.md` and is owned there once.

The autonomy policy is a different thing and does not move: mode-gating, the
judgment-vs-authorization boundary, the 5-per-feature cap, the disposition halts, and the ledger
records all stay in `skills/auto/SKILL.md`'s consult contract, every policy clause unchanged (its
anchored sentences are pinned by `scripts/skill-anchors/judgment-oracle.txt` and must keep
passing). The contract changes in exactly two ways: it gains one citation sentence naming
`skills/consult` as the mechanism owner — the ledger-contract citation pattern, applied to this
seam — and the mode-gated bullet's closing clause ("an attended session just asks the user"),
which this verb makes false, is updated to route attended sessions to `skills/consult`.

Attended semantics differ from the mode's on purpose, and the skill states them:

- **No cap.** The user is present; the cap exists to bound unattended ambiguity, and an attended
  session has no such exposure.
- **`uncertain` halts nothing** — the conversation with the user simply continues, which is what
  was already happening.
- **`reframed-as-authorization` halts nothing** — attended, the question is simply the user's to
  answer directly. The framing survives, in the canonical boundary sentence the skill carries
  verbatim (the milestone fixes the exact string): "An oracle consult is never how an
  authorization question gets answered — the oracle recommends on judgment; authorization is the
  human's, mode or no mode."
- **Model-invocable.** Unlike `auto`, the skill carries no `disable-model-invocation`: a session
  may consult on its own initiative when it hits a real judgment question, and the user may invoke
  `/consult <question>` directly. Consulting grants nothing, mutates nothing, and spends nothing
  but tokens, so self-invocation carries none of the risks that make `auto` human-triggered.
- **Decision tail.** When a recommendation is adopted and the choice is durable (architectural,
  doctrinal, hard to reverse), the skill *offers* to record it as a `decisions/` entry — it asks,
  never auto-writes. This is the upgrade over the off-the-cuff habit: the forced brief distills
  the question, and the record survives the transcript.
- **One worked brief.** The skill carries a concrete example brief (question + options + paths,
  dispatch-ready) so a first-time invoker calibrates on a real shape, not only the abstract
  sequence — the same worked-example discipline the autonomy contract used for its boundary.

## Ancillary edits (each confined)

- **`agents/oracle.md`** — generalized so **no sentence presumes a mode-only dispatcher**: the
  opening framing, the frontmatter `description:`, the "ledgered default" framing, the
  "orchestrator" wording, the refusal rule's halt sentence, and the closing
  disposition-handling attribution each cover both postures (mode → `skills/auto/SKILL.md`'s
  contract; attended → `skills/consult`). Frozen: the frontmatter's
  name/tools/disallowedTools/model/effort lines, the report shape, the three dispositions, the
  one-question rule, the read-only rules, and the anchored refusal sentence.
- **`skills/auto/SKILL.md`** — two changes only: the added mechanism-owner citation sentence,
  and the mode-gated bullet's closing clause ("an attended session just asks the user" — false
  once the verb exists) updated to route attended sessions to `skills/consult`. Every policy
  clause and all four judgment-oracle anchors unchanged.
- **`skills/debug/SKILL.md`** — one pointer sentence: competing plausible root-cause hypotheses
  that the evidence does not discriminate are a consultable judgment question (cite
  `skills/consult`, never restate).
- **`references/model-routing.md`** — `consult` joins the default-rule list (`inherit`, `high`),
  and the run-discovered drift is repaired: the coverage-audit sentence says 29 skills while
  `ls skills/` shows 31 (and will show 32) — `arm-auto-merge` and `prep-auto-merge` are in
  neither the table nor the default list. Both get **table rows** ("skill frontmatter (effort
  only)", `inherit`, `high` — they pin `effort: high` in frontmatter, and every effort-pinning
  skill has a row, so the placement preserves the file's row-vs-list pattern) and the count is
  corrected to 32, so the audit claim is true again rather than newly false.
- **Anchor set** `scripts/skill-anchors/consult-verb.txt` pinning the attended-boundary
  sentence, the ownership-split sentence, and the added citation sentence in
  `skills/auto/SKILL.md` (file-per-feature; no existing anchor file edited).

**Explicitly out of scope:** no guard/gate/preflight change, no never-auto-list edit, no change to
the autonomy consult contract beyond its two permitted changes (the added citation sentence and
the mode-gated bullet's updated closing clause), no rename of
the `oracle` agent (agents are role nouns, skills are verbs — `verify-milestone`/`verifier` is the
precedent `consult`/`oracle` mirrors). Decision record: `decisions/2026-08-07-consult-verb.md`.
