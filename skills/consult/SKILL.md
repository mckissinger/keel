---
name: consult
description: Consult the read-only oracle (claude-fable-5) on ONE judgment question — a choice the spec or situation underdetermines, where several options are viable and a reasonable reviewer could pick differently. Distills the question into a brief (question + viable options + relevant paths), dispatches agents/oracle.md, and reports its recommendation, rationale, and disposition. Decorrelated judgment, not authority — it recommends; it decides nothing and changes nothing.
when_to_use: Any time a genuine judgment question comes up and a second, decorrelated read would beat deciding alone — competing plausible root causes in a debug loop, two viable schema or API shapes, an ambiguous spec sentence, a design trade-off with real consequences either way. Invocable by the user (`/consult <question>`) and by a session on its own initiative. NOT for questions the spec already answers, not for routine style picks, and never as the way an authorization question gets answered.
---

# Consult

Ask a decorrelated frontier model one well-formed judgment question and get back a recommendation you can act on. This skill owns the consult **mechanism**; it is used attended, by you or by a session that has hit a real fork in the road.

Why it exists: keel's two-model policy rests on decorrelation (`references/model-routing.md`) — a check that shares the builder's blind spots is weak exactly where it matters. The `verifier` applies that after work exists. A consult applies it *before* a choice is made, on the narrow class of question where better judgment, not more authority, is what's missing.

## What is consultable

A **judgment** question: the spec or situation underdetermines a choice, several options are genuinely viable, and a reasonable reviewer could pick differently. If the spec already answers it, or one path is obviously right, or it is a routine style pick — don't consult, just decide.

An oracle consult is never how an authorization question gets answered — the oracle recommends on judgment; authorization is the human's, mode or no mode.

## The mechanism (owned here)

1. **Distill exactly one question.** One dispatch, one question. If you have three, consult on the one that actually blocks you, or run three dispatches — never bundle them into one brief.
2. **Write the brief.** Three parts, always: the **question**; the **viable options** you considered (with what each costs and buys); the **relevant paths** — the spec sentence, the files, the code the question turns on, so the oracle can ground its answer instead of guessing.
3. **Dispatch `agents/oracle.md`** with that brief. It is read-only (`claude-fable-5`, effort `high`) — it reads the repo to ground the answer and mutates nothing.
4. **Report back**: the oracle's **recommendation**, its **rationale**, and its **disposition** — one of `answered`, `uncertain`, `reframed-as-authorization`. Report the disposition as given; never launder an `uncertain` into a confident answer.

### A worked brief

> **Question.** The spec says "store the item's history" without saying whether history is a separate table keyed by item id, or an append-only JSON column on the item row. Which shape?
>
> **Viable options.** (a) Separate `item_history` table — clean queries over time ranges, real foreign keys, costs a join on every detail read. (b) Append-only column on `items` — single-read detail page, no join, but history is unqueryable in aggregate and the row grows without bound.
>
> **Relevant paths.** `specs/features/inventory.md` §3 (the ambiguous sentence), `db/schema.sql:40-70` (the existing `items` table), `app/items/detail` (the only current reader).

## Attended semantics

This skill runs attended — you are present — so it carries none of the halt choreography an unattended run needs:

- **No cap.** The per-feature consult cap exists to bound *unattended* ambiguity, where nobody is watching the volume. Attended, you are the cap: consult as often as the questions are real.
- **`uncertain` halts nothing.** It means the oracle could not confidently pick either — useful information. The conversation with you simply continues, usually toward getting whatever would resolve it.
- **`reframed-as-authorization` halts nothing.** It means the question was a "may I", so it is simply yours to answer directly — no consult needed, and none was ever going to substitute.
- **The decision tail.** When you adopt a recommendation and the choice is durable — architectural, doctrinal, hard to reverse — this skill **offers** to record it as a `decisions/` entry so the reasoning outlives the transcript. It asks; it never writes one on its own, and declining writes nothing.

## What this skill does not own

The mechanism is owned here; the **autonomy policy** is not. Mode-gating, the judgment-only boundary as a run rule, the per-feature cap, the mode's disposition-halt rules, and the ledger records all belong to the consult contract in `skills/auto/SKILL.md` — cited here by reference, never restated. Under an active mode, that contract governs; this skill's attended semantics above do not apply there.

## Boundaries

- **A consult recommends; it never decides and never authorizes.** Adopting a recommendation is your call (or, under a mode, the contract's) — the oracle's report is an input.
- **Read-only, always.** The oracle mutates nothing. A consult costs tokens and nothing else.
- **One question per dispatch.** A bundled brief gets a worse answer to every part of it.
