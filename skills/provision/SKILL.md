---
name: provision
description: Execute environment setup for a project from its spec's environment contract — CLI logins, dev-resource provisioning, keys into Vercel env, permission allowlist seeding, dry-run — ending only when the preflight passes. Run attended, at the end of the kickoff sitting after spec-foundation + the design-system gate, or in miniature when a later feature adds a new service.
---

# Provision

Set up the project environment from the environment contract in `specs/01-architecture.md`. This is attended setup, not a milestone: its purpose is to drain every would-be mid-run stall — logins, keys, permission prompts — while Michael is at the keyboard. Don't end the sitting until the preflight passes.

## The pass

1. **Read the environment contract.** Every step below derives from it. If a service in play isn't in the contract, update the contract first (and `decisions.md` if the addition is material) — never provision off-spec.

   **Provision every decided service in the contract now — including ones first consumed by later milestones.** Michael's /goal runs span multiple milestones unattended, so a service first needed mid-run has no attended launch moment; it must already exist. Defer only two things, marked as such in the contract: services not yet decided (a TBD row — provisioning one converts an open decision into an accident), and secrets that can only be derived at runtime (e.g. `stripe listen --print-secret` — record the derivation command instead).

2. **CLI logins first.** `supabase login`, `stripe login`, `vercel login`, `gh auth login` as needed — have Michael run interactive/browser flows with the `! <command>` prefix. Credentials stored per-tool mean later runs never handle raw secrets.

3. **Provision dev resources.** Vercel Marketplace integrations via `vercel:bootstrap` where available (they auto-inject env vars); otherwise create dev-dedicated resources via CLI — the dev Supabase project, Stripe test fixtures. Manual keys (e.g. a spend-capped Anthropic key) go into Vercel env, then `vercel env pull .env.local`. Vercel env is the source of truth; `.env.local` is a derived copy.

4. **Seed the project allowlist from the contract.** Generate or update `.claude/settings.json` (committed) with allow rules for each contracted service's dev-loop commands:
   - Supabase → `Bash(supabase db *)`, `Bash(supabase migration *)`, `Bash(supabase functions *)`, `Bash(supabase gen *)`, `Bash(supabase secrets set *)`
   - Stripe → `Bash(stripe listen *)`, `Bash(stripe trigger *)`, `Bash(stripe products *)`, `Bash(stripe prices *)`
   - MCP tools a run will use get their own entries (e.g. `mcp__trigger__deploy`).
   - Spend commands backed by a spend-capped key (evals, paid API calls) get allowlisted so milestone acceptance gates don't block mid-run — `Bash(pnpm eval:*)`, `Bash(tsx scripts/eval*)`. Safe only because the key is capped (see step 5).

   **Never allowlist:** resource creation (`supabase projects create`, `vercel integration add`, `vercel domains *`), prod deploys, live-mode anything, `gh repo create`, `gh api`, secrets management beyond the contract, tunnels (`ngrok`, `cloudflared`), or machine-level installs. Those prompts are deliberate checkpoints, and they cluster at sittings where Michael is present anyway.

   The allowlist is safe only because the environment holds test-mode credentials — it and the spec's test-key rule are a paired system. Never widen one without re-checking the other.

5. **Pre-authorize bounded spend — the cap is the authorization.** Some milestones' done-conditions need a real-resource action that costs money (an accuracy-gate eval calling the live Anthropic API, a paid API call). In an unattended multi-milestone run these become *unsatisfiable mid-run* if they require per-use human permission — the run either blocks or defers the gate and stacks later work on unverified code (a real failure: see [[fable5-acceptance-gates-stop-not-defer]]). Drain that at kickoff exactly like a credential. The mechanism: provision a **spend-capped** dev key (the Anthropic key gets a hard dollar ceiling in the console), then allowlist the command that spends against it (`Bash(pnpm eval:*)`, `Bash(tsx scripts/eval*)`, etc.). The cap bounds the worst case including a runaway loop; within it, the action runs unattended without a permission wall. Stop treating capped-key spend as gated — it's pre-authorized by the cap, the same way test-mode Stripe keys let payment flows run. Size the cap to expected run cost × a small multiple, recorded in the contract.

6. **Bake the known-flake mitigations into config, not into people's heads.** Recurring environment flakes get their mitigation written into the project's config/test setup at provisioning, so a run never rediscovers them. The standing ones: **single local Supabase stack at a time** (concurrent stacks exhaust the Kong gateway and throw intermittent 502s) and **serial local test runs** (`--workers=1` in the Playwright/test config for anything that touches a shared local stack). A mitigation that lives only in a `verified:` caveat or an agent's memory will be re-hit every run — encode it where the run will actually obey it (test config, preflight, allowlisted command flags). Add new recurring flakes here as they're identified rather than re-explaining them per milestone. **Pin tool-setup action versions in CI — never `@latest` / `version: latest`** for a setup action that resolves a release over the network (e.g. `supabase/setup-cli`): the resolve hits the GitHub API, which rate-limits and fails the job spuriously with a red that looks like a code failure (a Crelaunch PR build died on `Failed to resolve latest Supabase CLI release: rate limit exceeded` and needed a manual re-run).

7. **Finish on a green preflight — one cheap read-only command per contracted service** (`stripe products list --limit 1`, `supabase projects list`, `vercel env ls`). This single step does three jobs: proves each credential is live, surfaces any permission prompt a future run would hit (allowlist it on the spot, attended), and confirms every var in the contract exists (names, never values). These are CLI-level checks needing no app code, which is why they work even for services no milestone has touched yet. **Prefer a minimal real call over a no-spend dry-run when the goal is proving credentials work** — a no-spend mode validates harness logic but not that the key is live; one cheap real call (a single eval packet, not all ten) catches a rotted key for one token's cost. **Verify the repo guardrails are live, not assumed** — `gh api repos/<owner>/<repo>/branches/main/protection` must return 200 with require-a-PR + the CI status check required (configure it attended on the spot if it 404s); branch protection is what makes "the agent never commits to main / nothing autonomous crosses go-live" *enforced* rather than asserted, and the project CLAUDE.md must not claim it until this check passes (a Crelaunch run asserted it project-wide while `main` was actually unprotected). A green preflight is the exit condition of the sitting.

## Later additions

A service that becomes *decided* after kickoff (a TBD row resolved, or a new contract entry) gets this same pass in miniature at the next attended moment — a run launch — never mid-run. Before any multi-milestone run, the preflight covers every service any milestone in the run's scope consumes, not just the first.
