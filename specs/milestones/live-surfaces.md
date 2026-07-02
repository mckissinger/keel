# Milestone — Live-stream / conversational surfaces

**Goal:** the craft layer can spec and verify surfaces where content arrives while the user
reads — the interaction floor gains the scroll-intent principle, the state grammar gains the
live-surface state set (plus the model-in-the-loop variant), and Phase 3.5 can name the
archetype — all additive, no existing rule weakened.

**Change:** `specs/changes/live-surfaces.md`. **No-UI** → two-dimension done-conditions.
**Depends on:** `motion-vocab-and-details` (stacked — edits the same craft-layer regions).
**Parallelizable:** n/a (single milestone).

## Done-conditions

### Logic / invariants
- [auto] `references/interaction-craft.md` gains a numbered principle **"Live surfaces: never
  move the reader against their intent"** covering, at minimum: follow-the-live-edge only
  while the reader is at it; every interaction is intent (scroll-away, text selection,
  keyboard use, link-opening stop the following); new content never moves the reading
  position (new turn near the top of the viewport; offscreen arrivals stay offscreen);
  an out-of-view affordance with jump-to-latest that resumes following; reopen at the last
  meaningful position, not the absolute bottom; layout changes (media load, expansion,
  history prepend) and interruptions (stop/retry/error) never steal the reading position.
  Platform-neutral phrasing, web examples hedged; credited to shadcn's streaming-chat rules
  consistent with the file's credit style.
- [auto] `skills/app-design-directions/references/product-ui-craft.md` state-grammar section
  gains the **live-surface state set** — streaming/in-flight (distinct from initial loading),
  arrived-out-of-view (jump-to-latest + unread boundary), held reading position across
  prepend/media-load/expand, reopen position — and the **model-in-the-loop variant**
  (token-streaming in-progress rendering, stop/regenerate/branch controls that don't move the
  transcript, expandable tool/working blocks) scoped to surfaces that front an AI.
- [auto] `skills/app-design-directions/SKILL.md` Phase 3.5 archetype enumeration includes
  **conversational/live-stream (chat, feed, live log)**; a mandatory-when-present rule
  mirroring the data-viz rule; and the note that the scroll-intent *behavior* is proven in
  the real workbench/build (per the interaction-craft principle), while the mockup shows the
  states. The ~5 archetype cap is unchanged.
- [auto] **No weakening / no contradiction:** the existing state-grammar sentence (loading/
  empty/error/partial), the throwaway/look-only framing of Phases 2–3.5, the archetype cap,
  and the data-viz mandatory rule are unchanged in the diff; the new interaction principle
  does not contradict the keyboard rule or the frequency table.

### Behavioral completeness
- [auto] Cross-references resolve: the new principle is numbered consistently with the
  existing principle list (no renumbering breakage); SKILL.md's Phase 3.5 references
  product-ui-craft.md as before; no spine files (references/milestones-and-verification.md,
  references/profile-interface.md, skills/implement-milestone, skills/spec-feature,
  skills/spec-change, skills/verify-milestone) touched vs the stack base.
- [auto] Credit placed once (shadcn's streaming-chat rules), consistent with existing credit
  style; no library or component package named un-hedged in the new prose.
- [auto] `scripts/check-neutral.sh` exits 0; `check-neutral.test.sh` and
  `check-verified-pin.test.sh` self-tests pass; `scripts/` untouched vs `main`.

## verification
verifier subagent against this file (docs greps: principle present with all intent rules,
live-surface states + AI variant present and scoped, archetype registered with
mandatory-when-present + behavior-vs-states note, no-weakening sweep) +
`scripts/check-neutral.sh` + both script self-tests. No surface/action change → no runtime
walk; no hard invariant → no `/security-review`.

verified: clean at f28c6fa, 2026-07-01, via fresh-context verifier subagent — all 7 conditions pass: principle 6 with every intent rule + shadcn credit (interaction-craft.md:116–137), live-surface state set + model-in-the-loop variant correctly scoped (product-ui-craft.md:37), archetype registered + mandatory-when-present bullet mirroring data-viz + behavior-vs-states note with ~5 cap unchanged (SKILL.md:104–107), diff vs stack base purely additive (no weakening; keyboard rule orthogonal), numbering 1–6 intact, no spine files touched, credit placed once, check-neutral PASS + 12+9 self-tests + scripts/ untouched. (evidence: verifier report in PR)
