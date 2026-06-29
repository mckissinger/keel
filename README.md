# keel

**Foundation-first autonomous build workflow for Claude Code.**

> Status: **work in progress.** v1 is being assembled — see `Build sequence` below.

keel is a Claude Code plugin — a set of skills, agents, and a workflow for building
software autonomously. You stand up a durable foundation once, then build feature by
feature; every milestone is gated by independent verification and a **commit-pinned
record** before it can merge. The methodology is **stack-neutral**: each project derives
its own verification profile from its actual stack, so keel works the same for a web app,
a mobile app, a backend, or a CLI.

## How it works — the grain ladder

```
App        kickoff (greenfield) / adopt (brownfield)
            → interview → spec-foundation → app-design-directions* → provision
Feature    spec-feature → implement-feature → [you merge] → land-feature → review-feature
Milestone  implement-milestone → verify-milestone   (+ verify-all-milestones sweep)
Change     spec-change → implement-milestone → verify-milestone
Cross-cut  debug · provision (miniature)
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

## Install

_TBD once published — `claude plugin marketplace add mckissinger/keel`._

## License

MIT — see [LICENSE](./LICENSE). The interaction-craft guidance adapts principles from
Emil Kowalski's design-engineering philosophy ([animations.dev](https://animations.dev/)),
rewritten in our own words and attributed.
