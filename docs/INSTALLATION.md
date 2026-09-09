# Installation Contract

The installer is conservative by design. It performs a complete preflight before writing to the Codex profile.

## Preflight

`Install-CodexDesktopWorkflow.ps1 -DryRun` checks:

1. `capabilities.json`, `skill-catalog.json`, and `distribution.lock.json` parse with supported schema versions.
2. The 21 bundled skill folders exactly match the capability and lock manifests.
3. Every public payload file exists with the byte length and SHA-256 recorded in the lock.
4. The destination global instructions are absent, empty, or identical.
5. Every bundled skill destination is absent or byte-for-byte identical.
6. Optional skills are detected without being installed or changed.
7. `imagegen` is detected at the standard Codex system path when present. Its absence there is reported, not treated as an installation failure, because Codex owns system skills.

`DRY_RUN_PASS` means the package is internally consistent and the planned local writes have no detected conflict. The lock detects corruption and accidental drift; it is not a publisher signature.

## Installation behavior

- Global instructions are written only when absent or empty. An identical existing file is left untouched.
- Missing bundled skills are copied exactly.
- Identical bundled skills already present are left untouched.
- A different non-empty global file or different skill directory stops the operation before writes.
- Optional capabilities and Codex system skills are never copied, updated, or removed.
- If copying fails after writes start, every target created by that attempt is removed and the previous global file is restored.

The JSON result distinguishes `skills_installed`, `skills_already_present`, `system_capabilities`, `optional_capabilities_available`, and `optional_capabilities_missing`.

## Rollback

A successful installation writes a version-2 manifest under `.local-backups/<installation-id>/install-manifest.json`. It records the distribution version, lock hash, global-file state, exact installed skill inventories, preserved identical skills, system capability observations, and available optional skills.

Rollback verifies every file installed by that operation before removal. It removes only skills created by that installation and leaves pre-existing identical or optional skills untouched. If an installed file changed, rollback stops with `INSTALLED_SKILL_MODIFIED` or `INSTALLED_GLOBAL_MODIFIED` so user work is not deleted.

Version-1 rollback manifests from the earlier public candidate remain supported.

## Preflight failure codes

| Code | Meaning |
|---|---|
| `PACKAGE_MANIFEST_MISSING` | A required package manifest is absent. |
| `PACKAGE_MANIFEST_INVALID` | A manifest is not valid JSON. |
| `PACKAGE_SCHEMA_UNSUPPORTED` | The installer does not support one of the manifest schemas. |
| `PACKAGE_SKILL_SET_MISMATCH` | Skill folders, capability declarations, and locked skills differ. |
| `PACKAGE_CATALOG_MISMATCH` | The routing catalog does not cover the declared capabilities exactly. |
| `PACKAGE_FILE_SET_MISMATCH` | Files were added or removed without regenerating the lock. |
| `PACKAGE_FILE_MISSING` | A locked payload file is absent. |
| `PACKAGE_HASH_MISMATCH` | A payload file differs from its locked size or hash. |
| `GLOBAL_AGENTS_CONFLICT` | A different non-empty global instruction file already exists. |
| `SKILL_TARGET_CONFLICT` | A different file or directory already occupies a bundled skill target. |

Resolve a package integrity failure by obtaining a clean release. Resolve a target conflict by reviewing the existing installation and restoring or moving it deliberately; there is no automatic overwrite mode.
