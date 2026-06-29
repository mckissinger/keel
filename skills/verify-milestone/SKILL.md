---
name: verify-milestone
description: Independent verification of a completed milestone against the spec's stated verification method and ground truth. Run in a fresh session after a /goal completes, before accepting the work. Usage - /verify-milestone <milestone>.
argument-hint: <milestone>
---

# Verify milestone

Independently verify a completed milestone before its work is accepted. This runs in a fresh session, after the /goal completes — deliberately separate from the session that did the work, so no claim is taken on trust.

For sweeping many milestones at once — e.g. after a multi-milestone /goal run — use the saved workflow `verify-all-milestones` (one verifier per milestone, each in its own worktree) instead of running this skill repeatedly. It is a fast **`[auto]`-dimension** triage: the parallel verifiers can run schema/RLS/unit/logic checks and pin the milestones whose done-conditions are fully `[auto]`. It **cannot** close `[runtime]` conditions — the parallel worktrees have no browser and share one local DB/dev server, so a render/action/live walk can't run there. A milestone carrying any `[runtime]`/live condition comes back `blocked` ("runtime walk not run in the sweep"), gets **no pin**, and must be finished by a serial `/verify-milestone <slug>` (this skill, which runs the walk). Pass milestone slugs as args to re-sweep only specific ones.

## Dispatch

1. Find the milestone named in the arguments in the project's `specs/`.
2. Read its stated `verification:` line — the method and ground truth. **Dispatch accordingly; do not re-decide the method.** The spec already chose it.
   - `dynamic workflow over <source>, criteria <ref>` → run a Workflow that fans the check out over the independent units in the ground truth source, judging each unit against the cited criteria.
   - `verifier subagent against <ref>` → launch the `verifier` agent with the milestone's done-conditions and the cited spec section quoted in its prompt.
3. **If the spec is silent** on verification for this milestone, fall back to: check fans out over many independent units → dynamic workflow; single-thread check → verifier subagent. Then flag the gap — the spec should be updated to name its method.
4. **If the milestone adds/changes a route (`src/app/**`) or a server action, the `[runtime]` walk is part of the gate — run it here, in addition to the named verifier/workflow.** This session is the path that *can* (it has a browser + the local services to itself; the parallel `verify-all-milestones` sweep cannot). Stand up the local stack + dev server, sign in a **seeded test user + org** (admin-API-minted — no human/email), then for each new/changed surface: render it authenticated (assert no error boundary, no console/network errors) and drive each new server action through the UI (assert success + DB effect). Run it against **both `next dev`** and a **production build** (`next build && next start` or the branch preview). For an AI/live milestone, run the **capped-key live variant** within the pre-authorized envelope. This is the check that catches what jsdom/esbuild unit tests can't — RSC server/client-boundary and build-transform breakage. See `~/.claude/skills/spec-foundation/references/milestones-and-verification.md` §3 ("Runtime walk").

## Hard rules (regardless of mechanism)

- **Fix nothing in this session.** Verification and remediation never share a session. Discrepancies get reported, not patched.
- **Report every discrepancy with evidence**: `file:line` for code claims, record-level identification (which row, which unit, which record) for data claims. No discrepancy is reported without pointing at where it lives.
- **Anything that couldn't be checked is listed as unverified — never assumed passing.** State what blocked the check.
- **Flaky-by-construction tests are run to convergence, not once.** A test that depends on async propagation (a PostgREST schema-cache reload, eventual consistency, a pooler / plan-invalidation race) can pass a single run by luck and fail the next, so verifying it once certifies nothing. Run the invariant/harness suite (and any test with that shape) N× (≥5) and require every pass before the record is written — a Crelaunch DC5 harness-validity test was ~1/3 flaky and passed its *first* verification by luck; only re-verification surfaced it.
- **A green unit suite is not a runtime pass — render it.** Unit tests run in jsdom + esbuild; the app runs RSC + the dev/prod bundler. They disagree exactly where the worst bugs live: a Server Component passing a function as `children` to a Client Component (the unit test renders the client component standalone and passes — the real route throws), or an `export type` in a `"use server"` file (esbuild elides it; the dev transform emits a broken re-export that 500s every action in that graph). Both shipped to green pins on Crelaunch and were invisible until an authenticated render. So for any UI/action milestone, **a `clean` verdict requires the `[runtime]` walk to have run green** — never infer runtime-OK from unit-green.
- **A route/asset the build needs must be git-*tracked*, not just present on disk.** A file that's gitignored but exists locally passes every check run against the working tree (the file is right there) and then 404s on a clean CI/prod checkout — invisible to local e2e by construction. For any milestone that adds files under the framework's route root (`src/app/**`), assert nothing it needs is ignored: `git check-ignore` on the new route files, or `git status --ignored` over the route dirs. (A Crelaunch builder route lived under a `/build` segment that `.gitignore`'s `build/` pattern silently excluded — local e2e passed because the file was on disk; prod would have 404'd.)

## Verdict

End with one of:

- **Clean** — every condition verified, evidence cited.
- **Discrepancy list** — formatted so it can be pasted directly into a remediation `/goal` completion condition: each item states what the spec requires, what actually exists, and where, phrased as a checkable condition (e.g., "unit 4B base rent in output matches rent_roll.xlsx row 14 ($2,150, currently $2,510)").

## Write the verified record — mandatory final step on a passing verdict

**Invariant milestones: no pin without a clean adversarial-review record.** For a milestone touching a hard invariant (auth/tenancy/RLS, gating, payments, data-migration), a clean `/security-review` of the milestone's diff is a **precondition of the pin**, not a follow-up — its confirmed findings must be remediated and regression-tested before the `verified:` record is written, so the pin certifies the *post-review* state. This is the same gate shape as the record itself. A Crelaunch RLS milestone pinned `verified:` and *then* a security review found a HIGH cross-tenant join — the pin had certified code that broke the milestone's own invariant. Front-load it for the same reason the record is the last step: implement → review → verify+pin, so the milestone is pinned once rather than re-pinned per late finding.

On a **Clean** verdict (or clean-with-noted-caveats), the verification is **not finished until the pinned record is written** to the milestone's spec file:

`verified: <verdict> at <short-sha>, <date>, via <method> (evidence in PR #<n>)`

- The `<short-sha>` is the HEAD you verified (`git rev-parse --short HEAD` *before* committing the record — i.e. the verified code commit); the pin is what makes the record self-invalidating. Commit the record on the milestone's branch, so the record commit becomes the tip and the pinned SHA is now `HEAD^`.
- Writing the verdict line is part of verification, not remediation — it's the only thing this session writes, and it does **not** touch code (the "fix nothing" rule still holds).
- **A discrepancy verdict writes no record** — status stays underived/failing until a remediation `/goal` clears the discrepancies and re-verification runs. Never write a `verified:` line for work that didn't pass.
- **No pin while a `[runtime]` (or required live) condition is unrun.** A verdict is `clean` only when every `[auto]` **and** `[runtime]` condition ran green (the runtime walk passed on dev + the production build; any required live call passed). An unrun `[runtime]`/live condition → verdict `blocked`, **no** record. And **the `verified:` line never contains a "pending verification" caveat** — if a check is pending, there is no pin. ("Pending the fresh /verify-milestone session" pins are the exact anti-pattern that shipped runtime-broken Crelaunch milestones; CI now rejects a `verified:` line whose verdict text contains "pending"/"unverified"/"to be verified".)
- Nuanced verdicts stay nuanced in the line ("clean except environment-skew items, see report") — never compressed to a bare checkmark.

This is the mechanism behind the **pre-PR gate**: the milestone's PR is not opened unless its spec file carries a `verified:` line whose record commit is the branch tip and whose pinned SHA equals `HEAD^` (the verified code). A passing verification that never wrote its record is the gap that shipped milestones unverified — closing it is this step's whole job.

**The gate is CI-enforced, not just procedural** — a `verified-pin` job (`scripts/check-verified-pin.sh`) fails any milestone **code** PR whose spec lacks a `verified:` line, or whose pinned `<short-sha>` **is not an ancestor of HEAD**, or where **any non-plan file changed between that SHA and HEAD** (**plan paths = `specs/**` + `design/**`**). That "verified code == merged code" rule is what you're satisfying when you write the pin as the verify session's last (plan-only) commit; it is *stronger and less brittle* than the literal `HEAD^ == SHA` — a benign plan-only merge (a ledger keep-both, a carry-forward re-pin note) no longer false-trips it, but real post-pin code drift does (and a stacked branch's post-pin merge commit, which the literal rule silently missed, now fails CI). So after you write the record, confirm `git diff --name-only <pinned-sha> HEAD` shows only plan paths — that's exactly what CI checks. (A wholly **plan-only PR** — the upfront feature `plan PR` — is exempt from the pin requirement entirely: it may add milestone specs without `verified:` lines, which are appended later in each milestone's code PR.)

## Mechanical postcondition — assert the record actually landed

Writing the `verified:` line and committing it are two steps; the gate only holds if the second happened. The **dangling-record** failure: the line is written to the file but the commit is forgotten, so it sits uncommitted in the working tree — and in a continuous (non-PR) run the next milestone's `git add -A` either silently bundles it or it surfaces later as an unexplained dirty file (this is a real Meridian M4 bug — the record was written one session, committed only a session later when staging M5 turned it up). Don't trust that you committed it; check, with commands, not memory:

- **Working tree clean for the spec** — `git status --porcelain specs/` returns nothing. A non-empty result means the record (or something else) is pending, not durable.
- **Record commit is the tip, correctly pinned** — `git rev-parse --short HEAD^` equals the `<short-sha>` written in the line just committed (writing the record advances HEAD, so the verified code is now `HEAD^`, never `HEAD`).
- **No stale/dangling record elsewhere** — scan every milestone spec's `verified:` line; flag any whose pinned SHA isn't a real ancestor commit, or (on its own branch) doesn't equal that branch's `HEAD^`. A record pointing at a SHA that later code has moved past describes an older state and must trigger re-verification — never build on top of it.

A `verified:` line you wrote but didn't durably commit — or committed but left mispinned — is the same class of bug as never verifying at all. (`verify-all-milestones.js` already writes records in stack order per branch; the same three assertions belong in any hand-run of this skill, where the bookkeeping is manual and easiest to drop.)
