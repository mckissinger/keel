# Chore batch — CI cache + suite-growth watchdog

The mechanical subset of the 2026-08-16 harness-efficiency review's slate
(`specs/reviews/2026-08-16-harness-efficiency.md`, T1c/T3c): the two items small and
independent enough for the chore lane. Intake routed out the plan-only-PR fast path
(touches the canonical pin-gate script's classification and narrows the security-review
compensating control — a design decision, headed to `spec-change`) and dropped the
effort-routing item as already fixed by the 2026-08-05 harvest amendment.

## Applied items

- **pl-1 — CI npm cache** (`.github/workflows/ci.yml`): the `guards` job caches `~/.npm`
  (`actions/cache@v4`) before the Claude CLI install, keyed per-OS + per-run with a
  `restore-keys` prefix fallback — every run restores the most recent cache and saves a
  fresh one, so the cache tracks the CLI's latest version instead of pinning a stale
  tarball. The install step itself is unchanged; the adjacent comment was extended to
  document the key strategy.
- **pl-2 — suite-growth trend probe** (`skills/test-health/SKILL.md`): the probes section
  gains "Duration growth vs the prior audit" — compare each suite's duration against the
  previous dated audit note under `specs/reviews/`; growth past **1.5×** since the last
  audit is a finding even while still inside the Q12 budget (budgets catch breaches; the
  probe catches the trend — the 2026-08-16 review found suites growing 3–7× in one month
  with every individual reading in-budget). First audit in a project records the baseline.

## Combined checks

`bash scripts/check-neutral.sh`, `check-skill-frontmatter.sh`, `check-skill-anchors.sh`,
`check-plan.sh`, their four self-tests, and `claude plugin validate --strict .` — all green
at the pinned SHA.

verified: clean at 7ebf6fe, 2026-08-16, via fresh-context verifier subagent — both conditions confirmed with line evidence (cache step ci.yml:101–106 before the unchanged install step; probe SKILL.md:26–31 with prior-audit comparison, 1.5× threshold, and baseline sentence; frontmatter untouched), diff vs origin/main is exactly the two files in two per-item commits, 4 check scripts + 4 self-tests (64 assertions, 0 failed) + plugin validate green at this SHA. One noted non-blocking deviation: the pre-existing ci.yml comment above the install step was extended to document the cache-key strategy.
