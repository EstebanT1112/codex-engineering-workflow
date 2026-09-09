# Changelog

This file records user-visible changes to Codex Engineering Workflow.

## Unreleased

## [0.2.1] - 2026-09-09

### Added

- A getting-started guide covering account requirements, installation contents, first use, conflicts, approvals, and rollback.

### Changed

- Clarified that redistributed material retains its original MIT or Apache-2.0 license.
- Added explicit Apache-2.0 modification notices, an independent-project trademark disclaimer, and contribution licensing terms.
- Documented the project's free, non-commercial community purpose while preserving all permissions granted by its open-source licenses.

## [0.2.0] - 2026-09-09

### Added

- A Codex Desktop engineering agreement covering ownership, autonomy, risk, approvals, review, and verification.
- Eight core and thirteen standard installable skills.
- `imagegen` integration as a Codex system capability.
- Thirteen optional capabilities that may be routed only when already installed.
- A structured catalog with triggers, guards, stages, companions, overlap rules, and excluded automatic routes.
- A conservative installer with package-integrity preflight, conflict detection, identical-skill preservation, and exact rollback manifests.
- Machine-readable provenance for four pinned upstream sources and all redistributed skills.
- Separate third-party license files and deterministic SHA-256 lock regeneration.
- Windows CI for PowerShell 7 and Windows PowerShell 5.1.
- A reproducible end-to-end Python feature with routing, RED/GREEN, review, and verification evidence.
- A reusable task-request template with short, detailed, feature, and bug formats.

### Security

- Package drift, credentials, private markers, unsafe overwrite attempts, and modified-installation rollback are rejected by deterministic checks.
