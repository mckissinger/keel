# Chore batch — packaging

Punch-list batch: plugin packaging metadata, CI plugin validation, and skill-frontmatter hygiene (`when_to_use` split, invocation guards, tool allowlists).

## Applied items

- **plugin-version** — `.claude-plugin/plugin.json` carries `displayName`, `version: 1.0.0`, `homepage`, `repository`, `license: MIT`, and `keywords`; existing name/description/author preserved.
- **marketplace-strict** — `.claude-plugin/marketplace.json` plugin entry carries `category: development` and `tags` alongside `strict: true`.
- **ci-validate** — CI installs the Claude Code CLI and runs `claude plugin validate --strict .` as a workflow step after the neutrality guards.
- **readme-version** — README v1 note states the semver policy: versions start at 1.0.0 via plugin.json's `version` field, releases ship on version-bump release tags, not every merge to main.
- **land-feature-hygiene** — land-feature frontmatter splits `when_to_use` out of `description`, sets `disable-model-invocation: true`, and Boundaries gains the external-repo agent-authorship disclosure rule.
- **kickoff-hygiene** — kickoff frontmatter splits `when_to_use` out of `description` and sets `disable-model-invocation: true`.
- **adopt-hygiene** — adopt frontmatter splits `when_to_use` out of `description` (including the contained-product case) and sets `disable-model-invocation: true`.
- **verify-milestone-hygiene** — verify-milestone frontmatter gains `when_to_use`, `arguments: [milestone]`, and a git-scoped `allowed-tools` list; Dispatch step 1 references `$milestone`.
- **implement-milestone-hygiene** — implement-milestone frontmatter gains `when_to_use` and a git-scoped `allowed-tools` list; body gains the injected git-ground-truth preamble (`!`-command branch/status) backing the Branch-first rule.
- **desc-interview** — interview frontmatter splits `when_to_use` out of `description` using block scalars.
- **desc-spec-foundation** — spec-foundation frontmatter splits `when_to_use` out of `description`.
- **desc-spec-feature** — spec-feature frontmatter splits `when_to_use` out of `description`.
- **desc-spec-change** — spec-change frontmatter splits `when_to_use` out of `description`.
- **desc-implement-feature** — implement-feature frontmatter gains a `when_to_use` line delimiting it from implement-milestone / verify-milestone / land-feature.
- **desc-review-feature** — review-feature frontmatter splits `when_to_use` out of `description`.
- **desc-app-design-directions** — app-design-directions frontmatter splits `when_to_use` (once-per-app / redesign triggers) out of `description`.
- **desc-provision** — provision frontmatter splits `when_to_use` out of `description`, adding the not-a-milestone framing.
- **desc-punch-list** — punch-list frontmatter splits `when_to_use` (the sub-milestone lane) out of `description`.
- **desc-debug** — debug frontmatter splits `when_to_use` out of `description`.
- **pin-evidence-forms** — milestones-and-verification runtime-walk bullet gains the optional richer-evidence sentence (scripted browser video + session transcript link, accompanying — never replacing — the pin's evidence).

## Combined checks

`bash scripts/check-verified-pin.test.sh` (9 passed), `bash scripts/check-neutral.test.sh` (12 passed), `bash scripts/check-neutral.sh` (PASS), `claude plugin validate --strict .` (validation passed) — all green on the combined branch.

verified: clean at a15f304, 2026-07-01, via punch-list (evidence in PR #39)
