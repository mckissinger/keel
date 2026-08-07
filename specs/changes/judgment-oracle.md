# Change — judgment-oracle: Fable-5 consults for judgment questions under an active autonomy mode

**For:** keel runs under an active autonomy mode (`auto:feature` / `auto:run` / genesis Phase 2),
where a would-be *judgment* ask today either halts the run or resolves to whatever default the
build model takes silently-but-ledgered. **Enables:** the orchestrating session consulting a
dedicated read-only **oracle** agent on `claude-fable-5` — a distilled, single-question dispatch —
so ambiguity gets decorrelated frontier judgment instead of a coin-flip default, while every
authorization question stays exactly the stop-point it is today.

## Why this, why now (the record)

The two-model policy (`decisions/2026-07-25-two-model-routing.md`, `references/model-routing.md`)
already rests on **decorrelation**: Opus 5 builds, Fable 5 verifies, because a same-model check is
weakest against exactly the errors the builder is prone to. But that decorrelated judgment is
applied only *after* the work exists — at verification. Mid-run, under a mode, the ledger contract
(`skills/auto/SKILL.md` step 5) converts every would-be ask into a recorded deferral: the run takes
a default and the user adjudicates at the debrief. For *authorization* asks that is exactly right.
For *judgment* asks — an ambiguous spec sentence, two viable implementation approaches, a test
failure with competing plausible fixes — it means the decision is made by the build model alone, at
the moment it is most invested in its own current path.

This change extends the decorrelation principle to that mid-run moment: the same "different,
at-least-as-capable model" logic that justifies the Fable-5 verifier justifies a Fable-5 consult
*before* the default is taken, on the narrow class of questions where better judgment (not more
authority) is what's missing.

## The boundary (the part that must not blur)

Two kinds of would-be asks exist under a mode, and only one is consultable:

- **Judgment — "which / how / why" — consultable.** The spec underdetermines a choice; multiple
  approaches are viable; a reasonable reviewer could pick differently. The oracle recommends, the
  run proceeds on the recommendation, and the consult is ledgered for debrief adjudication.
- **Authorization — "may I" — never consultable.** Any authorization-shaped ask: merge authority
  outside the sanctioned `--auto` path, scope widening, deferring an acceptance gate, and anything
  the never-auto list names (`decisions/2026-07-genesis-envelope.md` §(c), by reference — the list
  lives there alone). A more capable model consulted by the agent is still the agent — routing an
  authorization question to the oracle would launder the permission. These remain stop-points with
  step-7 semantics unchanged: halt and surface, never route around.

The disposition semantics are decidable, not vibes: **`answered` is the only disposition on which
the run proceeds** — and only on a decision it was already entitled to take as a ledgered default.
`reframed-as-authorization` means the item was always a stop-point: the run halts per step 7 (the
oracle polices its side of the line by refusing to answer authorization-shaped dispatches).
`uncertain` also **halts the run attended**: the orchestrator consulted because the default was not
confidently takeable, and a Fable-5 uncertain verdict confirms the ambiguity is beyond unattended
resolution — proceeding on the shaky default the consult was meant to replace is exactly the
failure mode this change exists to remove. A consult can therefore convert a would-be default into
a halt (conservative, always legal), but **a consult never converts a stop-point into forward
motion**.

## Shape of the change (one milestone)

- **New agent `agents/oracle.md`** — mirrors the verifier's posture: read-only tools (it may read
  the repo to ground its answer — the user chose grounded over brief-only), `claude-fable-5`,
  effort `high`, one distilled question per dispatch, returning recommendation + rationale + a
  disposition in {`answered`, `uncertain`, `reframed-as-authorization`}.
- **The consult contract, owned in `skills/auto/SKILL.md`** (specified once, like the ledger
  contract): mode-gated, judgment-only, dispatched from the **orchestrating** session — the seam
  where would-be asks already surface and where the ledger is written; build subagents never
  dispatch the oracle themselves (they surface the question at the build→orchestrator handoff, and
  the orchestrator consults and re-dispatches with the answer). Every consult is a file-per-entry
  ledger record carrying the feature it belongs to (so the cap is derivable from the records),
  capped at **5 consults per feature** — the would-be 6th is itself a stop-point (that volume is
  the signal the spec was too ambiguous to run unattended).
- **The referenced-by half:** `skills/implement-feature/SKILL.md` — the session actually
  orchestrating build subagents under a mode — has its stop-points / notify-and-continue taxonomy
  reconciled with the contract: a surfaced judgment question routes to the consult contract (cited,
  never restated — the ledger-contract citation pattern), and the contract's two attended halts
  (`uncertain`, cap-exceeded) read as stop-points, not notify-and-continue, from the skill's letter
  alone. Attended-run semantics unchanged.
- **Routing row** in `references/model-routing.md` for the oracle, under the decorrelation
  rationale, plus the coverage-audit sentence updated so the agent is not treated by omission.
- **Anchor set** `scripts/skill-anchors/judgment-oracle.txt` pinning the load-bearing boundary
  sentences so a later reword cannot silently drop them.

**Explicitly out of scope:** no guard script changes (`merge-guard.sh`, `check-auto-preflight.sh`,
`guard-branch-rules.sh` untouched), no gate added or removed, no never-auto-list edit, no change to
the ledger contract's existing semantics — the consult is an *input* to a ledgered default, never a
new authority. Decision record: `decisions/2026-08-07-judgment-oracle.md`.
