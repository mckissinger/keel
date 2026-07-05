# 2026-07-05 — Autonomy modes v2: the strategic record

The strategic decision the `auto-hardening` and `auto-genesis` feature plans (PRs #76, #77)
implement. This entry is the **why**; the two feature specs
(`specs/features/auto-hardening.md`, `specs/features/auto-genesis.md`) and the genesis envelope
(`decisions/2026-07-genesis-envelope.md`, authored in genesis m1) are the **what**. It amends
`2026-07-autonomy-modes.md` **by reference** — that entry remains the doctrine; this one records
the redesign of the mode *surface* over it.

## The decision

keel's autonomy surface is **two postures, hardened, plus one new** — not a proliferation:

1. **`auto:feature` / `auto:run`** (existing) — kept as-is in shape, hardened to close the four
   gaps the ShipLog dogfood surfaced (see `auto-hardening`).
2. **`auto:genesis`** (new) — idea → one attended approval → unattended product (see
   `auto-genesis`).

**Explicitly rejected as a mode:** a separate "kickoff-then-run" mode. It changes no gate and no
delegation — it is attended `kickoff` followed by an invocation of the existing `auto:run`. That
is a **handoff-seam improvement** (the charter seam in `auto-hardening-m2-seams`), not a posture.
Also rejected for now: a supervised-per-feature-stop mode (that is `auto:feature` used per
feature — a usage pattern) and a refinement-consumer mode (a scope argument to `auto:run`). The
governing principle: **a mode must change which gates exist or where the human's judgment sits;
if it doesn't, it's a usage pattern or a seam, and naming it is ceremony.**

## What holds across every mode (the non-negotiables)

Two research passes on 2026-07-05 — an external landscape scan (~18 agentic-coding systems,
practitioner postmortems) and an internal distillation (keel doctrine + the ShipLog dogfood
ledgers + saas-factory's decision log) — converged on the same invariants, which no mode may
dilute:

- **Two human gates stay attended in all modes: skeleton/spec approval, and design/taste
  judgment.** The external evidence: agents fail on ambiguity and scope change, not execution
  (Cognition's Devin 2025 review); and the "70% problem" — unattended idea-to-app systems
  reliably ship thin features and unusable design (Lovable/Bolt/v0). The internal evidence: every
  recorded keel/saas-factory quality failure was a *taste* failure a green pipeline sailed past
  (saas-factory D63 re-added a design gate after removing it; x-big-proj's
  `product-autopilot-scope` judged F1–F8 "not a real product"; the `craft-elevation` decision).
  These two gates are keel's moat over vibe-coders — genesis's approval artifact is therefore
  **visual, not prose-only** (D63's lesson), and `review-feature` runs in every posture.
- **The verified-pin gate, independent fresh-context verification, and the never-auto list are
  untouched.** Delegation is to server-side required checks, never to agent judgment
  (`2026-07-autonomy-modes.md` §e). genesis's doctrine envelope widens only *bootstrap*
  actions (repo create, protection config, seeding) behind the human's skeleton approval — never
  the merge-authority or go-live gates.
- **Reversibility, not permission prompts, is what makes autonomy safe.** The 2026 industry shift
  (Claude Code Auto mode, Cursor Auto-review, Codex, OpenHands) replaced per-action approval with
  classifier/verifier-mediated execution + checkpoints. keel already has this shape — the
  independent verifier is the machine approver, and every unattended change lands as a
  pin-gated, unmergeable-without-checks PR.
- **Higher autonomy is gated on done-condition precision, not user bravado.** The Ralph-loop
  lesson: fresh-context loops drift exactly where "done" is vague. keel's `[auto]`/`[runtime]`/
  `[attended]` tags are the drift-detector; a milestone that is mostly `[runtime]`/`[attended]`
  is not eligible for unattended building.

## Why genesis, and why now

The provisioning chicken-and-egg (the auto-preflight demands artifacts only attended provisioning
produced) **dissolves** once the bootstrap *produces* those artifacts and the environment
amortizes the credentials: standing capped sandbox keys already live at
`~/.config/keel/sandbox.env` (sourced by the shell, names-only to any session). So per-project
setup reduces to scriptable, no-judgment actions once the doctrine envelope authorizes them —
which the human's skeleton approval does, the same command-vs-authority split as the attended-
merge toggle (`2026-07-04-attended-auto-merge.md`). genesis is the saas-factory ambition ("pitch
an idea → validated spec with you in the loop → autonomous build") rebuilt on keel's verification
spine instead of a bespoke control plane — the line saas-factory's own record shows it stalled
on (drowned in factory-infrastructure engineering; "green but partial" builds).

## Evidence base (dogfood, on record)

The `auto-hardening` gaps are not speculative — the 2026-07-03 ShipLog `auto:run` ledgered each:
`allow_auto_merge` false → hand-merge (entry 002); a fresh verifier bounced green work assuming a
local stack when the project ran hosted (entry 005); the `mode-file-binding-ttl` deferral records
the marker-persistence risk. One doctrine tension surfaced and is left conscious, not papered
over: the owner's mid-run correction (ShipLog ledger 003) asked for "agent reviews and merges
itself on green" — *more* agent involvement than §e sanctions. Resolution: keep §e; `gh pr merge
--auto` on green checks delivers the same outcome (no tap) with authority on the checks, not the
agent. The attended-merge toggle already fixed the actual annoyance.

## Consciously deferred

- **A fork-based template repo** (`genesis-template-repo`, authored in genesis m1) — build the
  contract and dogfood generate-from-scratch first, then freeze the proven output.
- **More modes** (supervised-stop, refinement-consumer) — usage patterns, revisit if real.
- **Mode-file run-binding** — the TTL half is resolved by `auto-hardening`; binding a marker to a
  specific run stays parked in `mode-file-binding-ttl`.

## Sequencing

`auto-hardening` (#76) lands before `auto-genesis` (#77): genesis's guard milestone edits the
same scripts and its mode file depends on hardening's TTL contract, preflight check (d), and the
`check-skill-anchors.sh` lint. Each feature builds in fresh sessions per keel, milestone by
milestone, behind the verified-pin gate.
