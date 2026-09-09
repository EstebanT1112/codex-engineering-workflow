# Verification and delivery

Read this reference before claiming that repository engineering work is complete.

## Build the verification set

Derive checks from:

- acceptance criteria;
- changed file types and components;
- repository scripts and CI configuration;
- applicable `AGENTS.md` instructions;
- risk level and failure modes;
- migration, API, UI, security, or release surfaces touched.

Prefer the smallest set that provides credible evidence. A broad suite is justified by blast radius or repository policy, not by habit.

## Evidence hierarchy

1. Repository-native tests exercising the changed behavior.
2. Typecheck, lint, build, schema validation, or static analysis appropriate to the change.
3. Runtime, browser, device, database, or integration evidence when static checks cannot prove the criterion.
4. Diff and targeted code inspection for scope and invariants.
5. Model reasoning as interpretation of evidence, never as a substitute for it.

## Rules for commands

- Use the project's existing package manager and pinned tools.
- Do not install a verifier merely to complete a checklist without justification.
- Do not use autofix during verification unless implementation explicitly requires and reviews the resulting edits.
- Keep commands non-destructive and within granted permissions.
- Capture the exit status and useful output.
- When output is too large, retain the failing command, error, affected target, and enough context to reproduce it.
- Treat skipped, unavailable, timed-out, or credential-blocked checks as distinct from PASS.

## Corrections

After any correction:

- inspect the current diff;
- rerun the failed check;
- rerun checks whose evidence the changed files invalidate;
- reevaluate affected acceptance criteria;
- repeat focused review if the correction changes a security, data, or public contract boundary.

## Delivery gate

Before DONE, confirm:

- every acceptance criterion has evidence or an explicit limitation;
- the changed-file set is known and contains no accidental scope;
- required tests/checks ran against the latest relevant state;
- no blocking finding remains;
- no claim implies a deploy, migration application, commit, push, or external effect that was not performed;
- user-owned changes and requested exclusions remain intact;
- the final response names any material uncertainty.

## Final response contract

Lead with the result. Then provide only what helps assess or use it:

- **Changed:** important files or behavior.
- **Verified:** commands or observable checks and their results.
- **Limitations:** missing evidence, environment blockers, or risks that remain.
- **Next action:** only when the user must approve or perform something.

Use clickable absolute file links in Codex Desktop when referring to local deliverables. Summarize routine checks rather than pasting full logs.

## Claims

Allowed:

- “The targeted tests passed” when the named command exited successfully on the current state.
- “The implementation is complete within the verified local scope” when the delivery gate passes.
- “The migration file passes static checks; application to a database was not tested” when that is the evidence boundary.

Disallowed:

- “All tests pass” after running only a subset without saying so.
- “Production ready” without operational evidence.
- “Migration validated” when no suitable database exercised it.
- “Security approved” based only on self-review.
- “Deployed”, “pushed”, or “committed” when only preparation occurred.
