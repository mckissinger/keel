# Change — Permission hygiene: make the sanctioned merge shape the reliable one

**Grain:** one change → one milestone (`spec-change`). **No-UI** (a preflight check + a
shipped allowlist artifact + prose). **Stacked on:** nothing (targets `main`).

## Why (the gap)

Two failures compound in keel-managed sessions:

1. **The sanctioned merge command isn't reliably emittable.** keel's merge-guard auto-allows
   exactly one shape — a bare `gh pr merge <ref> --auto [--method]`. Its whitelist rejects any
   chaining outright (the charset check drops `&`). So when a session emits the merge bundled
   with other commands in one shell call — `gh pr merge 5 && echo … && gh pr view 5`, the
   observed real case — `AUTO_MERGE` never sets, the guard falls back to `ask`, and under an
   active auto mode a headless run stalls on a prompt (the preflight header warns this aborts
   the run). The *same* bundle also defeats the harness's own prefix-based allowlist
   (`Bash(gh pr merge:*)` matches a call that is *only* the merge), so an approval never
   sticks and the same shape re-prompts. Two independent allowlist layers, one root cause:
   bundled emission.

2. **Agents mis-report the outcome they can't see.** A tool result that a command succeeded
   is byte-identical whether the user tapped "Allow" or it ran silently — an agent has no
   signal for whether a prompt appeared. Sessions nonetheless asserted "it merged without a
   prompt," an unobservable claim, repeatedly.

Underneath both: keel ships its **gates** as canonical scripts (copied, never re-authored)
but ships its **allowlist** as per-project prose in `provision`, framed around *contracted
services* — so keel's own process verbs (`git push` to a feature branch, `gh pr create/view`)
aren't reliably seeded, and setup completeness rides on one sitting's judgment.

## The mechanic (four placements, each at keel's own altitude)

keel's placement rule — exact invariant → a script/hook; judgment → pointer-prose; stack
specifics → the profile — decides where each piece lives:

1. **Preflight catches a bundled merge (code).** `scripts/check-auto-preflight.sh` gains a
   check that fails closed when the command inventory contains a `gh pr merge` line bundled
   with any chaining/segmenting operator or command substitution. This is an *inventory-level*
   guard; the *runtime* backstop stays the merge-guard, which already (correctly) asks on a
   bundle. Covered by `check-auto-preflight.test.sh`.
2. **A canonical git/gh process-verb allowlist baseline (shipped artifact).** keel ships its
   own process verbs as a committed baseline that `provision` and `adopt` **merge** into
   `.claude/settings.json` — coverage of the common plumbing by construction, not by
   per-project improvisation.
3. **The bare-merge rule, stated once.** The requirement to emit `gh pr merge <pr> --auto`
   un-chained lives once in `merge-guard.sh`'s header (where the whitelist is already
   defined), with a single pointer from `land-feature` and `auto` — not scattered as prose.
4. **A reporting-discipline invariant (prose).** One standing-invariant line in the
   `session-bootstrap` orientation: never assert an unobservable permission outcome — report
   only what the tool returned.

## Neutrality (stack-neutral, per `check-neutral.sh`)

keel's neutrality bar bans hardcoding the **app's stack** (framework/library/command), not
its own harness substrate — it already ships `git`, `gh`, `.claude/settings.json`,
`Bash(...)` rules, and PreToolUse hooks. So a **git/gh process-verb** baseline is squarely in
that owned register and passes the bar. The one line not to cross: the baseline names **no
stack command** — `test`/`build`/`lint` runners stay profile-derived (Q11). The baseline
artifact and the edited shipped scripts must pass `check-neutral.sh` (place the baseline
inside a directory the guard already scans, or extend its scan to reach it).

## Not weakened

The merge-guard's decision logic, its strict-auto whitelist, and the human-merge floor are
**untouched**. This makes the *already-sanctioned* shape reliably emittable and reliably
seeded; it widens nothing. No `[runtime]` "no prompt appeared" done-condition is written —
that outcome is unobservable by construction (which is precisely placement #4); the
deterministic cores are self-test-covered instead.
