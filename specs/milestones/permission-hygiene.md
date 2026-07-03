# Milestone — permission-hygiene: the sanctioned merge shape, reliably emittable and seeded

**Goal:** a keel-managed session reliably avoids — and never mis-reports — merge/push/PR
permission prompts: the auto-lane merge is emitted in the one shape the guard can auto-allow,
keel's own process verbs are seeded canonically at setup, the preflight catches a bundled
merge before launch, and no session claims a prompt outcome it cannot observe.

**Change:** `specs/changes/permission-hygiene.md`. **No-UI** → two-dimension done-conditions
(no fidelity). **Depends on:** nothing. **Parallelizable:** n/a (single milestone). Each
placement edits a distinct file, so no shared-file collision.

## Done-conditions

### Logic / invariants

- [auto] **Preflight rejects a bundled merge.** `scripts/check-auto-preflight.sh` fails
  closed (emits a `gap`, non-zero exit) when a non-comment line in the command inventory
  (`INVENTORY_FILE`) contains `gh pr merge` **and** any of `&&`, `||`, `;`, `|`, `$(`, or a
  backtick. The gap names the offending line and states the required bare shape. A line that
  is a bare `gh pr merge <ref> --auto [--squash|--merge|--rebase]` (no chaining, no
  substitution) does **not** trip this check. It targets `gh pr merge` specifically — the one
  command whose auto-allow bundling forfeits; other merge-shaped commands stay `ask`
  regardless and are out of scope.
- [auto] **Coverage matcher understands Claude Code's `:*` separator (run-discovered).** So
  the shipped baseline's canonical `Bash(gh pr merge:*)` rule actually covers a
  space-delimited `gh pr merge <ref> --auto` inventory shape instead of false-gapping it,
  `check-auto-preflight.sh`'s section-(a) allow-rule matcher normalizes a trailing `:*` to a
  `*` glob — the prefix semantics the harness itself uses. Existing `:*`/glob rules still
  match (the pre-existing self-test cases stay green, plus the new bare-merge coverage case).
- [auto] **The bare-merge rule is stated once, with pointers.** The requirement that the
  auto-lane merge be emitted as an un-chained `gh pr merge <pr> --auto [--method]` in its own
  Bash call (chaining forfeits the strict-auto allow to `ask`) appears as the owning
  statement in `scripts/merge-guard.sh`'s header contract, and as **one** pointer line each in
  `skills/land-feature/SKILL.md` (its "Under an active autonomy mode" section) and
  `skills/auto/SKILL.md` — neither skill restates the rule in full. (Grep: the rule's
  substance appears once at the guard; each skill carries a referencing line.)
- [auto] **A canonical git/gh process-verb allowlist baseline ships and is merged at setup.**
  keel ships a committed baseline of its **own** process verbs — git read/status/diff/log,
  branch/checkout/commit, `git push`, and `gh pr create/view/edit/checks/list` and
  `gh pr merge` — as an artifact copied/merged, never re-authored from prose (the build picks
  the home). Prefix-rule allow entries can't encode branch scope (`Bash(git push:*)` also
  matches push-to-default); that is intended and **not** widened here — push-to-default and
  the merge floor stay gated by the merge-guard hook as the backstop, so the baseline loosens
  neither. Setup merges it two ways: `skills/provision/SKILL.md`'s allowlist-seeding step
  merges the baseline **plus** the contract's per-service commands (greenfield);
  `skills/adopt/SKILL.md` merges the baseline into the repo's **inherited**
  `.claude/settings.json` and seeds **no** per-service commands (brownfield) — adopt's current
  "scoped to the seeding only" clause (adopt/SKILL.md ~:41) widens to include this
  process-verb baseline. The baseline names **no** stack command (no test/build/lint runner) —
  those stay profile-derived (Q11).
- [auto] **A reporting-discipline standing invariant.** `scripts/session-bootstrap.sh` gains
  one standing-invariant line — in **both** the mode-active and the no-mode orientation
  blocks — stating that an agent must never assert an unobservable permission outcome (a tool
  result is identical whether a prompt was approved or the command ran silently), and must
  report only what the tool returned.

### Behavioral completeness

- [auto] `scripts/check-auto-preflight.test.sh` (house idiom: throwaway fixtures, assert exit
  codes) gains cases: a bundled `gh pr merge … && …` inventory line → non-zero carrying the
  bundled-merge gap reason; a bare `gh pr merge <ref> --auto` line → the bundled-merge gap
  reason is **absent** (reason-absence — and with the git/gh baseline present in the fixture
  allowlist so the line is covered, overall exit 0); and the pre-existing preflight cases
  (inventory coverage, branch protection, env names) still pass unchanged.
- [auto] `scripts/check-neutral.sh` passes over the full corpus including the new baseline
  artifact and the edited shipped scripts (`merge-guard.sh` header, `session-bootstrap.sh`):
  no stack/command leak. The baseline names only git/gh/`.claude` tokens, which the guard
  does not treat as stack. If the baseline lives outside a directory the guard already scans,
  `check-neutral.sh`'s target list is extended to reach it (so the neutrality bar actually
  covers the shipped artifact).
- [auto] `claude plugin validate --strict .` passes, and every pre-existing self-test still
  passes: `merge-guard.test.sh`, `guard-branch-rules.test.sh`, `check-verified-pin.test.sh`,
  `session-bootstrap.test.sh`, `check-plan.test.sh`, `check-neutral.test.sh`,
  `check-auto-preflight.test.sh`.

## verification

verifier subagent against this file — the four placements checked by read/grep and by the
committed self-test (the preflight rule exercised via `check-auto-preflight.test.sh`, not
re-derived): the bundled-merge gap fires on a bundled line and is absent on the bare shape;
the bare-merge rule appears
once at the guard with one pointer per skill; the baseline artifact lists only process verbs
and no stack command and both setup skills merge it; the reporting line is present in both
`session-bootstrap` blocks — then run `check-neutral.sh`, `check-auto-preflight.test.sh`, and
the full self-test suite + `claude plugin validate --strict .` green.

**Not a hard-invariant milestone** — it adds a preflight *coverage* check and prose; the
merge-guard's decision logic, its strict-auto whitelist, and the human-merge floor are
untouched, so no new attack surface and **no `/security-review` pre-pin gate**. All
conditions are `[auto]`; there is deliberately **no `[runtime]` "prompt suppressed"
condition** — that outcome is unobservable by construction (the reporting invariant above),
so it is proven by the deterministic self-tests, not by a live "no prompt" claim.

verified: clean at ec11065, 2026-07-03, via fresh-context verifier subagent against this file — 9/9 [auto] conditions checked with file:line evidence; check-auto-preflight.test.sh 16/16 (bundled-merge + bare-merge coverage cases), merge-guard 62/62, session-bootstrap 29/29, check-neutral 17/17, check-verified-pin 17/17, check-plan 18/18, guard-branch-rules 16/16, check-neutral corpus scan PASS (baseline artifact covered), claude plugin validate --strict PASS; no [runtime] surface (methodology plugin), no /security-review precondition (merge-guard decision logic untouched) (evidence in PR #67)
