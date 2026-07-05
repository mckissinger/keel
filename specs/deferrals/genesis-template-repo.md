# A fork-based genesis template repo

**Parked 2026-07-05** by `auto-genesis-m1-doctrine`, at the point the template contract
(`references/template-contract.md`) was committed. Genesis v1 bootstraps by
**generating from scratch** against that contract; a pre-built template repo the bootstrap
would **fork** instead is deferred to a later session.

**What it would buy.** A fork-based bootstrap is **faster and pre-proven**: instead of
generating tier-1 scaffold (the CI workflow, `.claude/settings.json`, the `specs/` scaffold,
branch-protection wiring) fresh on every run and re-clearing the preflight each time, genesis
would `gh repo create --template` from a repo whose tier-1 already passes
`scripts/check-auto-preflight.sh` by construction. Less to generate, a known-green starting
point, and a smaller surface for a generation bug to slip a broken gate past the preflight.

**Why deferred, not built now.** The right order is **contract first, template second.** The
committed contract in `references/template-contract.md` is the specification a template repo
would have to satisfy — freezing a template before the contract is dogfooded would freeze
whatever the first guess produced, defects and all. So v1 **generates from scratch**, we
**dogfood** that path on a real genesis run, and only then do we **freeze the proven
generated output as the template** — capturing an artifact we have actually watched clear the
preflight and reach a preview deploy, rather than one assembled speculatively.

**The change when built.** Freeze the first successful genesis run's generated tier-1 scaffold
into a private template repo; switch the bootstrap's tier-1 step from generate to
`gh repo create --template`; keep tier-2 (the prunable per-project stack) generated per the
approved skeleton as it is in v1. The contract stays the source of truth — the template is
just a pre-satisfied instance of it.

**Reopen condition.** The **first successful genesis dogfood run** — an idea taken through the
approval gate to a preview-deployed product with the preflight cleared. That run's generated
scaffold is the template's seed; until such a run exists, there is nothing proven to freeze,
and this stays parked.
