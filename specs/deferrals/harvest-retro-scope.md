# Deferral — what `harvest retro` sweeps

**Status:** open. **Opened:** 2026-07-20, during `harvest-source-resolution`.

## The question

Default-scope harvest enumerates every transcript directory above the watermark (step 0 of
`skills/harvest/SKILL.md`). `retro` scope must sweep **one project's own sessions** instead —
but nothing yet defines which directories belong to the project a `retro` run is standing in.

## Why it is deferred rather than answered

**Name-matching is precisely what broke.** The defect this change fixes is that directory-name
lookup silently loses a project when its checkout moves. Any `retro` rule of the form "match
directories whose name contains the project slug" reintroduces it in a narrower scope.

And no cheap rule exists: CRE Launch's two transcript directories
(`-Users-michaelkissinger-cre-launch`, `-Users-michaelkissinger-Dev-Projects-cre-list`) share
**no discriminating substring**. Three successive drafts of the milestone each sank a CRITICAL
on a guessed answer here — a fixed source count that measurement falsified, then an undefined
notion of "belonging," then a singular "its own project's directory" that the two-directory case
disproves.

The user has never run a `retro`. Guessing a rule with no instance to check it against is how
the previous three guesses failed.

## Closing condition

**The first genuine `retro` run.** That run asks the user for its bound rather than inferring
one, and what the user answers — plus what the real directory layout looks like for that
project — is the evidence a rule can finally be written against. Until then `retro` enters the
ladder at step 1 (the human-input recipe) and its sweep set is supplied, not derived.
