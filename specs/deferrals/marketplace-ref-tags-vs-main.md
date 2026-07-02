# Marketplace ref: track a release tag vs. the default branch

**Parked 2026-07-02.** Decide whether the keel marketplace source should pin to release
**tags** (e.g. `v1.1.0`) rather than tracking the repo's default branch (`main`). Surfaced
while preparing the 1.1.0 release.

**The inconsistency.** The README v1 semver note says releases ship "on version bumps via
release tags, not on every merge to main." But the marketplace is registered as
`source: github, repo: mckissinger/keel` with **no ref pinned**, so a `/plugin marketplace
update` resolves the plugin from `main`'s latest commit — every merge to main is, in effect,
installable. The tag policy is not enforced by the plumbing; the `version` field only drives
update-*detection* (whether an update is offered), not which commit actually installs.

**Options.**
- **Pin to tags** — register the marketplace/plugin source at a tag/ref so only tagged
  releases ship. The policy becomes real; main churn stays internal until a release is cut.
- **Accept branch-tracking** — treat the `version` field purely as the update-detection
  signal; `main` is the release surface, and "not every merge ships" holds only by the
  discipline of not bumping the version between releases.

**Gate.** Needs confirmation of how a Claude Code github-marketplace source pins to a
tag/ref (platform capability — untested here), then a one-line change to the marketplace
registration (and possibly how the source is declared). Low urgency: the 1.1.0 release
installs correctly either way; this only decides the long-term release surface. Resolve
before relying on "merges to main don't reach users" as a guarantee.
