# Change — land-feature-wave-contract: the wave-scripting contract the choreography implies but never states

**Provenance:** the 2026-07-29 transcript mining of cre-list "CRELaunch" (`land-feature` on a six-milestone
stacked wave, automated by a project-authored `scripts/merge-stack.sh`).

## The defect

`land-feature` encodes the stacked-merge choreography but says nothing about what a project-authored
script automating that choreography must and must not do. cre-list's `merge-stack.sh` — a faithful
automation of the prose — produced two failures the prose never warns against:

1. **Prefix invocation deleted a live base.** The script deletes all listed head branches once its
   *argument list* is merged. Invoked with a single PR ("let's do one at a time" — advice the session
   itself gave), it deleted a branch an open descendant was based on, which **closed the child PR
   unrecoverably** (`gh pr reopen` fails when the base is gone); the PR had to be recreated. The skill's
   own step 2 states the retarget-before-delete rule for manual merges, but a script's deletion scope is
   its argument list — the contract that the arguments must equal the *full remaining open stack* (or
   that deletion be decoupled entirely) exists nowhere.
2. **A poll window shorter than CI read green PRs as failed.** The script's check-wait polled ~12
   minutes against e2e shards that take ~25–28; every stacked PR reported `✗ timed out waiting for
   checks` while actually green — a false failure signal at the highest-stakes step, recurring per PR.

## The fix

One prose subsection in `skills/land-feature/SKILL.md` — the **wave-scripting contract**: a script that
automates the wave must refuse prefix invocation (arguments must equal the full remaining open stack,
derivable from `gh pr list` by base-chain) **or** decouple branch deletion into an explicit post-wave
step; and its check-wait must report an exhausted window as *"still pending — re-check"*, never as
failure, with the window sized to the project's observed CI duration. No script ships — keel stays
stack-neutral; the contract governs whatever a project authors.

Fans into **one milestone**: `specs/milestones/land-feature-wave-contract.md`.
