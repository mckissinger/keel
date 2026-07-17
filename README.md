# keel

**Foundation-first autonomous build workflow for Claude Code.**

> **v1.** The methodology is distilled from real autonomous build runs and revised as it's dogfooded. keel versions with semver starting at 1.0.0 (the `version` field in plugin.json); releases ship to installed users on version bumps via release tags, not on every merge to main.

keel is a Claude Code plugin — a set of skills, agents, and a workflow for building
software autonomously. You stand up a durable foundation once, then build feature by
feature; every milestone is gated by independent verification and a **commit-pinned
record** before it can merge. The methodology is **framework-neutral by profile**: each
project derives its own verification profile from its actual stack. **Web is the proven,
tested path** (a backend, CLI, or library builds on the same spine today); **mobile is
derivable through the profile** — the seams are neutral now and get hardened when a real
mobile project runs.

## How it works — the grain ladder

```
App        kickoff (greenfield) / adopt (brownfield)
            → interview → spec-foundation → app-design-directions* → provision
Feature    spec-feature → implement-feature → [you merge] → land-feature → review-feature
Milestone  implement-milestone → verify-milestone   (+ verify-all-milestones sweep)
Change     spec-change → implement-milestone → verify-milestone
Chore      punch-list → one verified chore PR (batch pin)   ← many tiny changes at once
Marketing  marketing-site → plan PR → the milestone verbs   ← landing page or full site, usually post-app
Video      product-video → plan PR → the milestone verbs    ← how-to, onboarding, demo videos — post-app
Harden     harden → triage → grain-mapped slate + report    ← pre-launch production-readiness audit
Cross-cut  debug · status · harvest · demo · test-health · provision (miniature)
                                        * design track runs only when the deliverable has a UI
```

- **Plan globally what's expensive to change** (architecture, data model, design system,
  invariants, process); **decide locally, per feature,** what you can only judge by seeing.
- **Verified-pin gate** — a milestone's code can't merge until a fresh, independent
  verification writes a commit-pinned `verified:` record proving "verified code == merged code."
- **Three-dimension done-conditions** — logic, UX completeness, and (when there's a UI) fidelity.

## Stack-neutral verification

keel ships **no bundled stack profile**. At kickoff, each project derives its own
`specs/stack-profile.md` by reading its own config and doing web research, bounded by a
fixed **profile interface** (the questions every stack must answer to be verifiable). The
runtime-proof, design-token install, and migration scheme are profile verbs — not
hardcoded to any framework.

## What's in the plugin

**24 skills**, grouped by grain:
- **Kickoff** — `kickoff` (greenfield) / `adopt` (brownfield), `interview`, `spec-foundation`, `app-design-directions`, `provision`
- **Feature** — `spec-feature`, `implement-feature`, `land-feature`, `review-feature`
- **Milestone** — `implement-milestone`, `verify-milestone`
- **Change** — `spec-change`
- **Chore** — `punch-list` (a batch of tiny changes → one verified chore PR)
- **Marketing** — `marketing-site` (landing page or full marketing website, usually after the app is built — reads the specs + design system, screenshots the shipped app, explores variants, generates assets attended, then authors the milestones the normal pipeline builds)
- **Video** — `product-video` (product education video for a shipped app — feature how-to / knowledge-base videos, an onboarding sequence, a marketing demo reel, companion step-docs — scripts derived from the feature specs, recorded against the seeded app, narrated and brand-composited through a committed regenerable pipeline; ends on a plan PR the normal pipeline builds)
- **Hardening** — `harden` (pre-launch production-readiness audit, re-run per major release — a profile-derived, evidence-backed sweep across application security including supply chain and the AI surface, reliability + data safety, and operations + launch readiness; findings triaged attended into a grain-mapped remediation slate plus a dated go/no-go report under `specs/reviews/`)
- **Cross-cutting** — `debug`, `status` (read-only "where are we / what's next" derivation), `harvest` (transcript-mining retrospective → a proposed improvement slate; human-triggered only), `demo` (attended, gateless "show me the app, now" — boot, seed, demo card, live finding triage), `test-health` (suite-wide flakiness/efficiency audit → a grain-mapped remediation slate)
- **Autonomy** — `auto` (posture switch), `auto-merge` (attended merge toggle) — both human-triggered only

Plus the **`verifier`** agent, the **`verify-all-milestones`** + **`punch-list`** workflows, the canonical **`scripts/check-verified-pin.sh`** gate (copy into your project; its chore-lane accepts a `specs/chores/` batch pin), and shared references: the **profile interface**, the **milestone/verification rules**, and the **interaction-craft** + **motion-cookbook** craft layer.

And a **hooks layer** (`hooks/hooks.json`): a SessionStart bootstrap — re-injected after compaction — that orients every session in a keel-managed project (grain ladder + standing invariants) and stays silent everywhere else, plus PreToolUse guards: `merge-guard.sh` is the globally wired PreToolUse hook (in `hooks/hooks.json`, over merge-shaped commands), while `guard-branch-rules.sh` is skill-scoped — wired by the build skills' frontmatter, not by `hooks/hooks.json`. These hooks are a **local backstop** — project CI and branch protection remain the server-side gate, and nothing in this layer replaces them.

keel also has three **autonomy postures** — `auto:feature`, `auto:run`, and `auto:genesis` — posture levels a human explicitly triggers (never the agent), under which merge authority is delegated to the server-side required checks, plus an attended **auto-merge** toggle for merge delegation within an attended session. The scope and the trades are argued once — in [`decisions/2026-07-05-autonomy-modes-v2.md`](./decisions/2026-07-05-autonomy-modes-v2.md) and [`decisions/2026-07-genesis-envelope.md`](./decisions/2026-07-genesis-envelope.md), which supersede the original [`decisions/2026-07-autonomy-modes.md`](./decisions/2026-07-autonomy-modes.md) — not here.

Two design principles worth calling out: the **design track is optional** (it runs only when the deliverable has a UI, so keel builds CLIs/backends/libraries too), and **every interview confirms its understanding with you before authoring anything**.

## Requirements

**Claude Code ≥ 2.1.** keel relies on plugin hooks (the `SessionStart` bootstrap with a `compact` matcher and the PreToolUse guards), `disable-model-invocation` skill frontmatter, and the Workflow tool — all present from the 2.1 line. Older versions load the skills but silently drop the hooks layer and the human-triggered-only guards.

## Install

```
claude plugin marketplace add mckissinger/keel
claude plugin install keel@keel
```

(The repo is private for now; published install instructions will work once it's public.)

## License

MIT — see [LICENSE](./LICENSE). The interaction-craft guidance adapts principles from
Emil Kowalski's design-engineering philosophy ([animations.dev](https://animations.dev/)),
rewritten in our own words and attributed.
