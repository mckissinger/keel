# Walk note — the security-review action's per-PR cache can mask a failed scan (2026-08-02)

Observed while proving the `required-checks-live` gate on scratch PR #194:

1. The first `security-review` run **failed** (empty `ANTHROPIC_API_KEY`) — but the action saved its
   per-PR cache (`claudecode-<repo>-pr-<n>-<sha>`) *before* failing.
2. Every subsequent run on that PR — including after the secret was fixed, and even on a **new
   commit** (the `restore-keys: ...-pr-<n>-` prefix matches any SHA on the PR) — restored that cache
   and **skipped the scan entirely** (`claudecode-scan: skipped`), reporting a green check that
   reviewed nothing.
3. The genuine pass required deleting the PR's action caches
   (`gh api -X DELETE "repos/{owner}/{repo}/actions/caches?key=<key>"`), after which the rerun showed
   `Cache not found` and `claudecode-scan: success`.

**Operational rule this implies:** when a `security-review` run on a PR fails for an
environmental reason (missing/wrong key, quota), do not trust a subsequent green on that PR until the
PR's `claudecode-*` caches are deleted or the log shows `claudecode-scan` actually executed. A hollow
cache-skip pass is indistinguishable from a real pass at the check-run level.

Relevant to the `required-checks-doctrine` milestone's template-contract recipe: worth carrying this
caveat alongside the recorded default implementation.
