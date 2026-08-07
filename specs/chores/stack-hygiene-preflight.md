# Chore batch — stack-hygiene-preflight

The keel-side remainder of 2026-08-05 harvest slate item 2 (F2), re-grained 2026-08-07: the Q13
isolation contract itself shipped 2026-07-13 (`specs/features/worktree-isolation.md`, PRs
#122–#124) — what F2's evidence still indicts on the keel side is the absence of a **machine-wide
stack-hygiene check** (five foreign Supabase stacks / 55 containers degraded suites invisibly;
40s-vs-19s variance presented as a hydration flake). Per-project Q13 adoption is consuming-repo
work, out of scope here. Owner-authorized compressed implementation (fresh-context verifier pass
+ batch pin, per the #213/#214 precedent).

## Applied items

- **q12-hygiene-bullet** — `references/profile-interface.md` Q12 gains the stack-hygiene recorded
  item: one committed command enumerating every running local-stack instance on the machine,
  classifying each as this-project's-or-foreign against the Q12 identity, reporting counts +
  identities + each foreign stack's named teardown command — reporting only, **never tearing one
  down** (foreign stacks are other projects' state; teardown is offered attended or run-noted
  unattended). The authorship-splits list adds the hygiene command to the finalized-at-provision
  set.
  - Done-condition: the Q12 bullet states the enumeration, the classification, the 55-container
    scar, and the report-never-teardown output rule; the authorship split names the command as
    provision-finalized.
- **provision-authors-it** — `skills/provision/SKILL.md` step 6's Q12-finalization list authors
  the stack-hygiene check (committed, run once green at the sitting).
  - Done-condition: step 6 names authoring + one green run of the hygiene check among the
    provision-finalized Q12 parts.
- **preflights-run-it** — `skills/implement-milestone/SKILL.md` step 1 and
  `skills/verify-milestone/SKILL.md` step 4 run the profile's hygiene check (where recorded) as
  part of the substrate preflight, with the same three-part handling rule: offer teardown
  attended, record a run-note unattended, never tear down another project's stack.
  - Done-condition: both entry preflights name the check, condition it on the profile recording
    one, and state the attended/unattended/never-teardown rule.

## Combined checks

Recorded at build time, re-run by the verifier: `bash scripts/check-neutral.sh`,
`bash scripts/check-plan.sh`, `bash scripts/check-skill-frontmatter.sh`,
`bash scripts/check-skill-anchors.sh`, plus all 13 script self-tests.

verified: clean at bb7a1f2, 2026-08-07, via fresh-context verifier subagent — three consistency findings at d23b328 remediated, all three re-checked clean (evidence in PR #215)
