# Repository Engineering Instructions

<!--
Copy this file to the repository root as AGENTS.md only when the repository has
stable facts that Codex cannot reliably infer. Replace every bracketed prompt,
delete unused sections, and keep the result concise. Never store secrets here.
-->

## Scope

- These instructions apply to `[REPLACE: repository or subtree]`.
- `[REPLACE: one sentence describing the product or service]`
- Read nested `AGENTS.md` files before editing files under their scope.

## Required commands

Use the repository's existing environment and pinned package manager. Do not install or upgrade tools merely to run these commands.

| Purpose | Command | When required |
|---|---|---|
| Install | `[REPLACE or delete row]` | `[REPLACE]` |
| Targeted tests | `[REPLACE]` | Every behavior change with relevant tests |
| Full tests | `[REPLACE or delete row]` | `[REPLACE: risk/scope trigger]` |
| Typecheck | `[REPLACE or delete row]` | `[REPLACE]` |
| Lint | `[REPLACE or delete row]` | `[REPLACE]` |
| Build | `[REPLACE or delete row]` | `[REPLACE]` |
| Development | `[REPLACE or delete row]` | Manual use only |

If a required command is unavailable or needs credentials, report it as a limitation. Do not substitute a weaker check and call it equivalent.

## Repository map

- `[REPLACE: path]`: `[REPLACE: responsibility]`
- `[REPLACE: path]`: `[REPLACE: responsibility]`
- Architecture documentation: `[REPLACE path or delete]`
- Public contracts or schemas: `[REPLACE path or delete]`
- Database migrations: `[REPLACE path or delete]`
- Generated files: `[REPLACE paths or delete]`

## Conventions

- `[REPLACE: project-specific convention that is not obvious from nearby code]`
- Follow established patterns in the nearest maintained module when no rule is stated here.
- Keep changes focused and preserve compatibility requirements documented in `[REPLACE path or delete]`.

## Testing and acceptance

- `[REPLACE: what must be tested for this repository]`
- Add regression tests for fixed defects when they provide stable evidence.
- Use `[REPLACE: fixtures/test data policy or delete]`.
- For UI behavior, verify `[REPLACE: browser/device/accessibility requirement or delete]`.

## Data, security, and operations

- Data classification: `[REPLACE: none/local/sensitive/regulated and handling rule]`.
- Authentication and authorization boundaries: `[REPLACE paths/rules or delete]`.
- Migration policy: `[REPLACE: disposable validation, rollback, compatibility, approval rule or delete]`.
- Production access: `[REPLACE: prohibited or exact approval boundary]`.

## Files and actions to protect

- Do not edit `[REPLACE: generated, vendored, secret, or policy paths]` directly.
- Do not commit local configuration, credentials, build output, or `[REPLACE project-specific items]`.
- Preserve unrelated working-tree changes.

## Delivery

- Required documentation for behavior changes: `[REPLACE path/rule or delete]`.
- Required release notes or changelog policy: `[REPLACE or delete]`.
- Repository-specific approvals beyond the global contract: `[REPLACE or state none]`.
