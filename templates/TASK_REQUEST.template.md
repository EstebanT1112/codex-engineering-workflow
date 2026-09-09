# Codex Task Request Template

Use this template when asking Codex to change a repository. Copy the short version for ordinary work. Use the detailed version when the task is ambiguous, risky, spans several components, or has strict acceptance requirements.

Describe the outcome and constraints in product or engineering terms. You normally do not need to select skills or prescribe the implementation: Codex discovers the repository, chooses the smallest relevant skill set, follows local instructions, and verifies the result.

Never include passwords, API keys, tokens, private keys, production credentials, or sensitive customer data.

## Short request

```text
Objective:
[What should Codex implement, fix, change, or review?]

Expected behavior:
[What should a user or system observe when the task is complete?]

Acceptance criteria:
- [Observable requirement 1]
- [Observable requirement 2]
- [Important behavior that must remain unchanged]

Constraints:
- [Compatibility, design, dependency, performance, security, or scope constraint]
- [Files or areas that must not change, if any]

Verification:
[Relevant test, command, user journey, browser, device, or other evidence. Write "discover from the repository" when unknown.]

Complete the task through implementation, review, and verification. Preserve unrelated changes and report any concrete blocker or unavailable verification.
```

## Detailed request

Delete sections that do not apply. Unknown technical details may be left for Codex to discover from repository evidence.

```text
# Task

## Objective
[Describe one concrete outcome.]

## Context
- Repository or working directory: [path or repository name, if Codex is not already there]
- Relevant feature or area: [module, page, endpoint, service, table, or user journey]
- Business or user reason: [why this change is needed]
- References: [issue, design, screenshot, specification, or documentation]

## Current behavior
[What happens now? For a bug, include the exact symptom and when it occurs.]

## Expected behavior
[What should happen after the change?]

## Acceptance criteria
- [Observable and verifiable criterion 1]
- [Observable and verifiable criterion 2]
- [Error, empty, loading, permission, or boundary behavior]
- [Compatibility or behavior that must remain unchanged]

## Scope
In scope:
- [Required change]

Out of scope:
- [Related work that should not be included]

## Constraints
- Stack or version: [only when fixed by the project]
- Dependencies: [allowed, prohibited, or use existing dependencies only]
- Compatibility: [API, schema, browser, device, platform, or migration constraints]
- Design: [existing design system, responsive requirements, or visual reference]
- Performance: [measurable requirement, if applicable]

## Reproduction evidence for a bug
- Steps: [minimal reproducible sequence]
- Actual result: [error, incorrect output, screenshot, response, or failing command]
- Frequency: [always, intermittent, environment-specific]
- Known good state: [version, commit, environment, or "unknown"]

## Data and security
- Authentication or authorization impact: [none or describe the boundary]
- Data or schema impact: [none or describe tables, migration, backfill, or rollback needs]
- Sensitive information: [describe the category without pasting secrets or real sensitive data]
- Production access: [not required unless explicitly authorized later]

## Verification
- Required tests: [targeted, integration, E2E, migration, browser, or device]
- Required commands: [exact commands when known; otherwise ask Codex to discover them]
- Manual checks: [user journey or visual behavior]
- Completion evidence: [what Codex should report]

## Delivery and approvals
- Documentation or changelog required: [yes/no and location]
- Commit requested: [yes/no; default is no]
- Push, merge, deploy, production mutation, or destructive action: [must be authorized separately immediately before the action]

Continue autonomously through analysis, implementation, review, correction, and verification. Ask only when a material product decision or unavailable authority blocks progress.
```

## Feature example

```text
Objective:
Add an order-status filter to the orders page.

Expected behavior:
Users can select Pending, Shipped, or Cancelled and the existing order list updates without losing the current date filter.

Acceptance criteria:
- The status filter composes with the existing date filter.
- The default view continues to show all statuses.
- Empty results use the existing empty state.
- The selection survives a page refresh if other filters already do.

Constraints:
- Use the existing filter components and URL-state pattern.
- Do not add a new state library.

Verification:
Add focused behavior tests and run the repository's typecheck and build. Verify the filter interaction in the existing browser preview if available.

Complete the task through implementation, review, and verification. Preserve unrelated changes and report any concrete blocker or unavailable verification.
```

## Bug example

```text
Objective:
Fix duplicate invoice submission when the user double-clicks Save.

Current behavior:
Two POST requests can be sent before the button becomes disabled, creating duplicate invoices.

Expected behavior:
Only one submission can be active, and the user receives the existing success or error feedback.

Acceptance criteria:
- Rapid repeated clicks produce one request.
- The control remains disabled until the request settles.
- A failed request can be retried.
- Existing validation behavior remains unchanged.

Constraints:
- Find and fix the root cause in the existing form flow.
- Do not hide duplicate errors without preventing the second request.

Verification:
Reproduce the bug first, add a regression test for the interaction, run the relevant test suite, and inspect the final diff.

Complete the task through implementation, review, and verification. Preserve unrelated changes and report any concrete blocker or unavailable verification.
```

