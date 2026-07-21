# Change — provision-hardening

One milestone, prose-only across two files (`references/profile-interface.md`,
`skills/provision/SKILL.md`), plus one committed anchor file. From the 2026-07-18 harvest
(`specs/reviews/2026-07-18-harvest.md` D2 + D4, and the capped-key sliver trimmed from D3).
Harvest grain was `spec-change` for each; they collapse into **one** unit because both land in
the same two files and are the same class of fix — *make a remembered precondition an executable,
recorded contract instead of a thing a run is trusted to remember*.

## Why (the defect)

The environment the runtime ladder rests on is under-specified in two adjacent ways, and both
re-bit the corpus repeatedly:

- **The environment target is never classified — local vs hosted, and which port (D2).** Four
  instances of one missing capability, *classify and validate the environment's target before
  anything runs against it*: a copied `.env.local` carrying **hosted** keys run silently against a
  **local** stack (Jarvis); port collisions across concurrent projects the user escalated himself
  (*"select a new standard port for this project we will use moving forward to not clash with
  other projects"*); build-time env inlining that ate a whole verify session and left **four**
  chore specs behind (BidLevel); and un-provisioned-vs-broken confusion at kickoff. The substrate
  contract (Q12) already records *the healthy local substrate* and asserts *"ports owned by this
  project's stack"* — but it never records **which target** an env points at, and it gives **no
  derivation rule** for the port block it tells the project to own (so every project re-invents
  one, and they collide).

- **Fragile runtime gates need committed preflight scripts, not written-down steps (D4).** Relay's
  mobile Release crash was the **fifth** recurrence of a *documented* gotcha; all five were written
  down and every one still re-bit, because *"there's no single script that exports everything,
  preflights the preconditions, and fails loud"* — the proposed `scripts/mobile-walk.sh` was never
  written. Same class: a datastore reset before the suite; a build-artifact clean before prod
  walks; a mandatory blank-key prefix whose omission spends money. Every one is a remembered step
  that should be an **executable, committed preflight**. Provision step 6 already says *"encode it
  where the run will actually obey it… a mitigation that lives only in an agent's memory will be
  re-hit every run"* — but nothing makes the project **declare** which gates are fragile or **commit
  the script**, so the encode-it rule has no teeth.

Jarvis landed a rule worth promoting **verbatim**: derive the port from the **project name** (it
landed on 24685). Two properties beat any specific number — *effectively-random* (no
`/etc/services` claim) and *derivable* (any project gets its own, with no registry, and it never
drifts between machines or checkouts) — and the band sits **below 49152**, where the OS begins
allocating ephemeral outbound ports, so it can never be transiently taken. And Jarvis's committed
test-setup pattern — read the running stack's **status**, map names to the architecture contract,
swallow non-zero when no stack is up — is the shape that makes a suite independent of `.env.local`.

## Decisions taken

- **The name-derived port rule is promoted VERBATIM into the profile (Q12).** It becomes the
  concrete derivation method for Q12's existing *"unique port block / project identity"* part —
  which today says *"collision-free against the user's other projects"* but never says **how**. The
  promoted sentence is pinned by a **positive skill-anchor** (`scripts/skill-anchors/provision-hardening.txt`)
  so a later reword can't silently drop it. Paired **dual-update caveat** recorded: changing the
  port requires updating **both** the local stack config (needs a restart) **and** the hosted
  dashboard if the env points there.

- **Environment-target classification joins Q12's health check.** Q12 records how to tell, from
  the env file / config, whether it targets the **local substrate** or a **hosted backend** (the
  local stack's URL/port signature vs the hosted dashboard URL), and the substrate health check —
  which already asserts *"ports owned by this project's stack"* — gains one assertion: the running
  config's target **matches the expected substrate**, so hosted keys against a local stack (or the
  reverse) is a **named, checkable** condition, not a silent mis-point. A `⚠` scar generalizes the
  copied-`.env.local` incident. This extends the existing *ports/identity* part rather than adding a
  new provision-finalized artifact — so the `spec-foundation` / `adopt` derivation-list
  enumerations need no change (see below).

- **Test setup derives config from the running substrate, never `.env.local`.** A clause lands
  beside Q12's existing direct-read ban (*"sessions never read `.env*` directly"*): committed test
  setup obtains its config from the running substrate's **status** (mapped to the architecture
  contract, swallowing non-zero when no stack is up), **never** from `.env.local` — the actor is
  different (test code, not the session) so it is a distinct rule, and a copied `.env.local`
  carrying the wrong target is exactly what it prevents.

- **The profile declares its fragile gates, and provision commits their preflight scripts (D4).**
  Q12 gains a **fragile-gate → committed-preflight-script** declaration: every runtime gate with a
  remembered precondition (an env export, a reset/clean step, a required key-prefix) names a
  **committed, executable preflight script** that sets up the precondition, **asserts** it, and
  **fails loud** — and the profile lists each fragile gate → its script path. The declaration
  **accretes like the signature table**: a newly discovered fragile gate adds its script and its
  row. Provision (step 6, which already bakes mitigations into config) **authors the scripts for
  the gates surfaced when it proves the ladder** (step 7) and records them in the profile's
  declaration. A `⚠` scar generalizes Relay's fifth recurrence.

- **Home held to the two stated files.** All Q12 additions are facet extensions of parts the
  derivation lists already enumerate (the port rule and target classification extend
  *ports/identity*; the fragile-gate **scripts** are provision-authored artifacts like the
  mitigations of step 6, **not** derivation placeholders — the derivation lists enumerate
  provision-finalized *placeholders*, and a preflight script is authored, never placeheld). So
  `skills/spec-foundation/SKILL.md` and `skills/adopt/SKILL.md` are **not** touched — a deliberate
  call recorded here for the adversarial plan pass (contrast `env-check-preflight`, which *did*
  touch both because the env name-check command was a genuinely new provision-finalized placeholder).

- **Stack-neutral throughout.** The port rule references the OS ephemeral-port band (an
  OS-mechanics fact, like Q12's existing web-reference examples) and hardcodes no framework;
  `check-neutral.sh` still passes.

## Deliberately not in scope

- **Capped-key provisioning (the D3 sliver) is ALREADY a provision step — no work.** The harvest
  digested a corpus pattern (Parcelint drained mid-run credential halts at kickoff with a
  hard-dollar-capped key + an allowlisted spend command) and recommended *"promote from a recorded
  learning to a provision STEP."* That promotion **already happened** — provision **step 5**
  (*"Pre-authorize bounded spend — the cap is the authorization"*, landed in commit #1) provisions a
  spend-capped dev key, allowlists the command that spends against it, bounds the worst case
  including a runaway loop, keeps the key value out of chat, and sizes the cap to run-cost × a small
  multiple recorded in the contract; step 4 allowlists the spend command *"Safe only because the
  key is capped (see step 5)."* The paired system is complete. Authoring a milestone for it would
  produce done-conditions already satisfiable by existing text — the false-pin anti-pattern
  (`references/milestones-and-verification.md` §1). **Flagged for the reviewer** in case a further
  strengthening was intended beyond the already-landed step.

- **The other D3 sub-items stay held for a second occurrence** (each single-instance, per the
  harvest's own note): the Google-console step-by-step checklist, OAuth-app ownership reporting,
  branch-protection read-modify-write, MCP/connector authorization in the preflight, and
  `provision`'s mid-project re-invocability. Not this unit.

## Milestone

`specs/milestones/provision-hardening.md` — edits `references/profile-interface.md` (Q12:
name-derived port rule + dual-update caveat, environment-target classification in the health check,
test-setup config-source clause, fragile-gate preflight-script declaration) and
`skills/provision/SKILL.md` (step 6: apply the name-derivation, record target classification +
dual-update caveat, author the fragile-gate preflight scripts). Adds
`scripts/skill-anchors/provision-hardening.txt` pinning the promoted port rule verbatim. No
scripts, gates, hooks, templates, or other skills move.
