---
name: punch-list
description: Resolve a batch of tiny, independent changes in one pass — gather a laundry list (typos, lint nits, renames, missing aria-labels, stale comments, dep bumps), turn each into a checkable done-condition, then fan out one focused subagent per item and land a single verified chore PR.
when_to_use: The sub-milestone lane — for changes too small to each warrant their own milestone. NOT for anything needing design, a new surface, or cross-item reasoning (that's spec-change or a feature).
---

# Punch List

The batch lane for the laundry list — many tiny, mostly-independent changes that are each below a milestone, where doing them one `spec-change` at a time is absurd overhead. It works by converting a *spread-out* task into **N focused tasks**: the intake (this skill, attended) scopes the list; the `punch-list` workflow fans out one isolated subagent per item and assembles a single verified **chore PR**. The chore-lane gate lets the whole batch land under **one pin** instead of one-per-change.

## When this — vs spec-change / a feature

- **Punch-list** — several trivial, independently-stated changes (a typo at `x.ts:12`, a missing `aria-label` on the submit button, a stale comment, a `lucide` → the design icon swap, a dep bump). Each is checkable on its own and touches little.
- **Not punch-list** — anything that needs **design**, adds a **new surface**, or requires **cross-item reasoning** (item B only makes sense after item A). One substantial change → `spec-change`. A coherent body of work → a feature. The intake **routes these out** rather than forcing them into the batch.
- This is the same rule `debug` routes by after diagnosis: no design/spec judgment → a punch-list item; a spec'd done-condition or any design decision → `spec-change`.

## The pass

### 1. Gather the list

Pull items from wherever they live: your dictation, a `TODO.md` / `FIXME` scan, lint/typecheck output, review comments, an issue label. Cast a wide net first.

### 2. Turn each item into a checkable done-condition — the scope-discipline guard

Every item must become a **specific, checkable condition** naming **what changes and where**: `"<file:line> — <current> → <desired>"`. If you can't write that, the item isn't a punch-list item:

- Too vague ("clean up the utils") → either sharpen it into concrete conditions or drop it.
- Needs judgment/design/a new surface, or depends on another item → **route to `spec-change` / a feature**, don't smuggle it into the batch.

Capture each item's **target files** (for collision grouping) and tag it `[auto]` (most chores — lint/typo/rename) or `[runtime]` (a UI tweak that must be rendered to confirm).

### 3. Confirm the list — before launching

Present the scoped list (conditions + files + what you routed out) and **get the user's sign-off** (the confirm-before-author gate). Don't fan out work on an unconfirmed list.

### 4. Launch the workflow

Run the saved workflow `punch-list` with `{ slug, items: [{ id, condition, files }] }`. It:
- groups items by file so parallel fixes never collide,
- runs one **worktree-isolated** subagent per group (make exactly the change, self-check, return a diff — no scope creep), each **dispatched with an explicit `model: sonnet` arg at `low`/`medium` effort** — the executor tier for mechanical batch work, per `${CLAUDE_PLUGIN_ROOT}/references/model-routing.md` (the per-invocation dispatch arg, top of the resolution order),
- assembles the diffs onto one `chore/<slug>` branch, runs the **combined** checks, writes `specs/chores/<slug>.md` with **one batch pin**, and opens a single `chore` PR.

`[runtime]` items can't be confirmed by the parallel sweep (shared local services) unless the profile's Q13 isolation contract is proven (per `references/profile-interface.md`) — otherwise verify those serially via the runtime walk, the same rule as everywhere else, before the batch pin stands.

## Output + boundaries

- **One `chore` PR**, per-item commits, one batch pin — reviewable item-by-item, lands as one merge. **You merge.**
- **Dropped items are not failures** — an item the workflow couldn't apply cleanly is reported, not half-done; re-run it or route a stubborn one to `spec-change`.
- **No drive-bys.** The batch contains exactly the confirmed items; "while I was in there" changes are scope creep — capture them as new items, don't bundle them.

## Under an active autonomy mode

Under `keel:auto run` (per `decisions/2026-07-autonomy-modes.md`), the step-3 confirm gate becomes a **ledgered default**: record the scoped list (conditions + files + what was routed out) to the run ledger per `keel:auto`'s ledger contract and launch; the user adjudicates at the debrief. The scope-discipline guard and the batch-pin gate are unchanged.

## Where this sits

```
spec-change   one change → one milestone
punch-list    many tiny independent changes → one chore PR (one batch pin)   ← here
```
