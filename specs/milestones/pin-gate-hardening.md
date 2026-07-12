# Milestone — pin-gate-hardening

Change context: `specs/changes/pin-gate-hardening.md`. One milestone; edits
`scripts/check-verified-pin.sh` + its test, `scripts/check-plan.sh` + its test, adds
`scripts/repin.sh` + test, and updates the re-pin prose at three sites in two skills to
point at the canonical script. No hooks, gates
weakened, or templates moved. Integration seam: `merge-guard.sh` consults the gate
unchanged (same CLI contract: `BASE_REF=<ref> check-verified-pin.sh [HEAD_REF]`, exit
0/non-0); the pin-line format in `references/milestones-and-verification.md` §5 is
unchanged — only the *parsing* of it hardens.

## Done-conditions

- [auto] **Backtick-aware caveat scan.** The gate's pending/unverified/"to be verified"
  caveat check strips backticked spans from the `verified:` line before matching, and is
  otherwise unchanged (whole-line, same words): a pin whose method text carries a
  backticked domain term (e.g. `` via e2e over the `pending-leads` suite ``) passes; a
  bare trailing caveat (`… via verifier — pending the runtime walk`) still fails — the
  existing anti-pattern test case is byte-identical and still passes; and the caveat
  failure message tells the author that a domain term containing a caveat word must be
  backticked. Covered by new cases in `scripts/check-verified-pin.test.sh` alongside the
  untouched existing case.
- [auto] **First-match SHA parse.** The pinned SHA is extracted from the **first**
  ` at <hex>,` occurrence on the line, never the last: a pin line carrying a
  carry-forward clause that mentions a second SHA later on the line parses to the first
  SHA. A line with no ` at <sha>,` shape still fails with the no-parseable-sha message.
  Covered by new cases in `scripts/check-verified-pin.test.sh`.
- [auto] **Best-effort base-ref freshness.** When `BASE_REF` names a remote-tracking ref
  (`origin/<branch>`), the gate refreshes it via fetch before computing the diff; when
  the fetch cannot run (no remote, offline), it emits a warning on stderr and proceeds
  with the local ref — never a hard failure from the fetch itself, and all existing
  fail-closed behavior (unresolvable refs, no merge base) is unchanged. Covered by new
  cases in `scripts/check-verified-pin.test.sh`: a `file://`-remote repo whose base
  branch moved remotely passes/fails against the *refreshed* ref; the same repo with the
  remote deleted warns and proceeds.
- [auto] **Canonical repin script.** `scripts/repin.sh <milestone-spec> [note]` exists
  (canonical in keel's `scripts/`, copied into projects like the pin gate — never
  re-authored from prose) and, run on a milestone branch whose code tip moved past the
  pin: (a) refuses a dirty working tree; (b) refuses a spec with no `verified:` line;
  (c) rewrites the pin line to
  `verified: <verdict> at <new-sha>, <today>, via <method> (<evidence>) — carried forward from <old-sha>[: <note>]`
  where `<new-sha>` is the pre-commit HEAD, replacing (never accumulating) any prior
  carry-forward clause; (d) commits the spec edit as its own plan-only commit; and
  (e) asserts before exiting 0 that `git rev-parse --short HEAD^` equals the new pinned
  SHA, that the gate's own extraction parses the committed line to that SHA, and that
  the working tree is clean — any failed postcondition exits non-zero naming the
  failure. Covered by new `scripts/repin.test.sh` (happy path, repeated re-pin replaces
  the clause, dirty-tree refusal, missing-line refusal, postcondition failure is
  non-zero).
- [auto] **check-plan.sh parses identically.** `scripts/check-plan.sh`'s chore-batch
  pin-line validation uses the same first-match ` at <hex>,` extraction and the same
  backtick-stripped caveat scan as the gate — the two shipped scripts never disagree
  about one line. Covered by new cases in `scripts/check-plan.test.sh` (backticked
  domain word passes; bare trailing caveat fails; carry-forward second SHA parses to the
  first).
- [auto] **Prose points at the canonical script.** The re-pin instructions in
  `skills/land-feature/SKILL.md` (the cascade and the diamond finish) and
  `skills/spec-foundation/SKILL.md` (the conflict-forced-rebase bullet) name
  `scripts/repin.sh` as the mechanism (each file greps for `repin.sh`), neither
  prescribes a hand-edit + amend flow anywhere, and each site **retains its "re-run the
  suite green" precondition** adjacent to the pointer (the script mechanizes the
  edit+commit+assert only — `repin.sh`'s usage header states that re-running the suites
  first is the caller's job, and the script invokes no test command).
- [auto] **Distribution owned.** `scripts/repin.sh` appears in the explicit
  copy-into-project lists: `skills/spec-foundation/SKILL.md`'s repo-setup copy list
  (alongside `check-verified-pin.sh` + `check-plan.sh`) and `skills/adopt/SKILL.md`'s
  copy instruction (each file greps for `repin.sh` in its copy context).
- [auto] **§5's caveat sentence matches the shipped behavior.** The caveat-rule sentence
  in `references/milestones-and-verification.md` §5 (currently "CI now rejects a
  `verified:` line whose verdict text contains …") is updated to state the actual rule:
  the scan is whole-line minus backticked spans, and a domain term containing a caveat
  word is written backticked — so the declared spec and the shipped scripts agree about
  what fails.
- [auto] **Repo checks green.** `claude plugin validate --strict .`,
  `scripts/check-neutral.sh`, `scripts/check-plan.sh`, `scripts/check-skill-frontmatter.sh`,
  `scripts/check-skill-anchors.sh`, and every `scripts/*.test.sh` pass on the branch.

## verification

verifier subagent against this file's done-conditions (all `[auto]`; no UI, no runtime
surface — the scripts' committed self-tests carry the behavioral assertions).

verified: clean at a97c6d0, 2026-07-12, via verifier subagent against this spec's done-conditions — all 11 script self-tests + 5 repo checks run green by the verifier (evidence in PR #104)
