---
name: demo
description: Boot the app and hand the user the keys — the attended, gateless "show me the app, now" verb. Activates the stack per the profile, seeds representative data, prints a demo card (URLs, credentials, stubbed-vs-live, drift status), then stays resident to capture and triage what the user finds.
when_to_use: Any time mid-build the user wants to see and drive the running app — "show me the app", "boot it up", "let me click around". Gateless and repeatable; it produces no verdict and gates nothing. NOT review-feature — that is the different thing: the once-per-feature aesthetic gate after a feature lands. demo is the mid-build, attended, any-time verb.
allowed-tools: Bash(git status *), Bash(git log *), Bash(git branch *), Bash(git diff *), Bash(git rev-parse *), Bash(ls *), Bash(grep *), Bash(head *), Bash(cat *)
---

# Demo

Boot the app and hand the user the keys. Demoing is the strongest bug-finder keel has —
user drives caught what verification missed (dead nav links, non-functional controls, a
deployed-schema drift 404; evidence in `specs/reviews/2026-07-12-skill-mining.md` §2) — so
this verb exists to make the demo cheap enough to run often instead of re-deriving the
boot ritual every time.

**Gateless, by design: demo produces no verdict and gates nothing, and it runs any time
mid-build.** It is attended — the user is at the keyboard, driving. It is not
`review-feature`: that is the once-per-feature aesthetic gate after a feature lands, with
a verdict and a refinement milestone behind it. Nothing waits on a demo, and a demo
confirms nothing — it *surfaces*.

## The ritual — five steps, in order

1. **Substrate health first.** Run the profile's Q12 substrate health check
   (`references/profile-interface.md`) before anything else — seconds, and it catches the
   stale-env / wrong-ports / second-stack failures that otherwise burn the sitting's first
   twenty minutes.
2. **Activate the stack per the profile.** Services up, the app/simulator booted per the
   profile's Q3 activation answer, long-running processes backgrounded where the harness
   supports it — so the session stays free to talk while the app runs.
3. **Seed representative demo data per Q5** — the profile's seeded, authenticated state
   with no human in the loop. Never live credentials: demo state is minted test state,
   every time.
4. **Print the demo card.** Before handing over, give the user one glanceable block:
   the **URL map / entry points** (every surface worth driving, with its address), the
   **test credentials**, **what is stubbed vs live** (which services are mocked, which
   calls are real), and the **local-vs-deployed drift status** — is what you're seeing
   `main`, a branch, or ahead of the deployed preview? A user who doesn't know they're
   looking at a branch files findings against the wrong reality.
5. **Stay resident.** The demo isn't over when the app boots. Capture each user finding
   **verbatim**, and triage it live into the keel grain it belongs to — a `punch-list`
   item or a `spec-change` — so findings survive the sitting. The recorded incidents all
   died in chat; live triage is the fix.

## Screenshot batching

When the profile declares a screenshot/review driver (Q8.4,
`references/profile-interface.md`), offer **batched captures of all surfaces up front**
instead of one-at-a-time round-trips — the recorded scar was ~5 round-trips per surface,
per sitting.

## Write boundary and landing

**demo authors no other verb's artifacts.** The live triage *labels* each finding with its
grain; the owning verbs (`punch-list`, `spec-change`) run in follow-up sessions — a demo
sitting that "quickly fixes" a finding has left its lane. Its one repo write, and only
when the user asks to record: a **dated findings note under `specs/reviews/`**, committed
on a branch and landed as a plan-only PR — never a commit to `main`.

The sitting ends attended, presented per the gate-presentation contract
(`references/gate-presentation.md`).

## Boundaries

- **`allowed-tools` is a grant, not a restriction** — it pre-approves the enumerated
  read-only shapes above so orientation runs promptless; the gateless/no-artifacts
  guarantee is the stated hard rule, per keel's recorded frontmatter semantics. The
  **boot and seed commands are deliberately not pre-approved**: they change state, so
  they go through the normal permission flow with the user right there — the same
  precedent as `verify-milestone`, `review-feature`, and `debug` booting a runtime.
- Model may self-invoke: "show me the app" in plain words routes here.
