# Change — Bootstrap window for the verified-pin gate

**Grain:** one change → one milestone (`spec-change`). **No-UI** (gate script + docs change to
keel itself). **Stacked on:** nothing (targets `main`).

## Why (the gap)

The verified-pin gate has a bootstrap paradox: **keel's own prescribed foundation work cannot
pass the gate keel tells the project to install.** `check-verified-pin.sh` classifies
everything outside `specs/**` + `design/**` as code, and a code PR must touch a milestone or
chore spec carrying a valid pin — which cannot exist before the first milestone does. Three
PR shapes hit the wall, all pre-first-milestone:

1. **The foundation PR** (`spec-foundation` Repo setup: specs + CI workflow + the copied pin
   script + CLAUDE.md). GitHub runs a workflow added *in* the PR against that PR, so the gate
   fails the very PR that installs it. **Hit live** in a real keel-managed project
   (v0.1.0-era); the user worked around it with a workflow-layer exemption.
2. **The design-gate workbench PR** — kickoff step 3 requires the workbench (real code, a
   styleguide route) committed to `main`, while kickoff's ground rules forbid the agent
   committing to main — so it arrives as a code PR touching no milestone spec.
3. **The scaffold PR** — the app skeleton itself, landing during the same window.

Shapes 2 and 3 rule out a path-list carve-out: keel is stack-neutral and cannot enumerate
what a scaffold or a workbench touches.

## The mechanic

A **bootstrap window**, judged from tree state, not paths: the gate exempts a PR when **no
file matching `specs/milestones/**.md` or `specs/chores/**.md` exists** — at **both** the
tip of `BASE_REF` **and** at `HEAD_REF` — printing an explicit bootstrap-window pass message
for auditability. The window closes permanently the moment the first milestone or chore spec
lands on the base branch; after that, behavior is byte-identical to today.

*(Amended during build: the plan judged the base end at the merge-base. The pre-pin security
review reproduced a HIGH bypass — root a branch at a pre-first-spec commit and the merge-base
predates the spec, re-entering the window post-bootstrap. The base **tip** is outside any
branch author's control, so the window is judged there.)*

Judging both ends is load-bearing:

- **Base-tip side (deletion-proof and root-proof):** once the base branch carries a milestone
  spec, no PR re-enters the window — not by deleting specs at HEAD, not by rooting the branch
  at a pre-first-spec commit.
- **HEAD side:** a code PR that itself adds the first milestone spec is validated by the
  normal pinned path, not exempted.
- **Fail-safe:** an unresolvable ref fails the gate closed via explicit `rev-parse --verify`
  guards before any diff (the first verification caught that the diff's failure hides inside
  a process substitution and read as "no changes — pass"). `has_specs` reads tree entries
  with path-quoting disabled so an unusual spec filename still closes the window (the
  review's second finding).

**Why exempting the whole window is safe:** everything pre-first-milestone is attended by
design — kickoff, the design-system gate, and provision all run with the user present, every
PR still gets human review + merge, and branch protection stands. The gate's subject is
milestone code; before the first milestone there is none.

**Rejected:** the path-list carve-out (exempt only named process paths). Narrower on paper,
but not stack-neutral, and it leaves shapes 2 and 3 failing — the same wall rediscovered one
PR later.

## Scope

`scripts/check-verified-pin.sh` (the canonical copy-into-project script — its header
self-documentation updates too), new cases in `scripts/check-verified-pin.test.sh`, and ≤2
sentences in `skills/spec-foundation/SKILL.md` Repo setup. Existing test assertions are not
edited or deleted. This loosens the gate itself — a hard invariant — so adversarial review
runs pre-pin.
