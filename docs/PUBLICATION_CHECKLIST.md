# Publication Checklist

## Completed in the public distribution candidate

- Project MIT license added.
- ECC and Superpowers notices preserved.
- Skill provenance and audited refs documented.
- Runtime files copied into a separate directory.
- Personal installation backups excluded.
- Public installer reads `global/` and `skills/` directly.
- Local rollback state moved to `.local-backups/` and ignored by Git.
- Public README contains installation, usage, scope, approvals, verification, and rollback.
- Personal paths and installation IDs are prohibited by validation.
- Eight self-contained core skills are bundled.
- Eight core skills, thirteen standard skills, one system-provided capability, and thirteen optional capabilities are declared separately.
- All 35 active capabilities have explicit trigger, guard, stage, availability, and overlap metadata.
- Deterministic Windows CI workflow added.
- Local package validation covers manifests, skills, links, licenses, privacy, credentials, and PowerShell syntax.
- Installation and rollback are exercised on both Windows PowerShell 5.1 and PowerShell 7 in CI.
- Installer preflight verifies the locked payload, reports system and optional capabilities, preserves identical existing skills, and rejects drift before writing.
- Rollback manifest version 2 records distribution identity and removes only content created by its installation.
- Four third-party licenses are stored separately, all 21 bundled skills have machine-readable provenance, and the complete payload lock can be regenerated deterministically.
- Public contribution, security, conduct, and changelog documents are included.
- Bug-report, feature-request, and pull-request templates are included.
- Editor and Git text rules preserve UTF-8 and LF endings, including PowerShell scripts covered by the distribution lock.
- A dependency-free Python feature records routing, RED/GREEN evidence, diff review, and reproducible deterministic verification.
- Release `0.2.1` has a machine-readable manifest and a dated changelog section.
- The first GitHub-hosted validation passed for release-ready metadata commit `a959ae1`.
- GitHub release notes for version `0.2.1` are prepared in `docs/RELEASE_NOTES_0.2.1.md`.
- A reusable request template explains how to give Codex objectives, acceptance criteria, constraints, verification needs, and approval boundaries.

## Required before publishing

- Confirm that the exact commit tagged `v0.2.1` has a passing GitHub-hosted validation.
- Review repository description, topics, and final GitHub release notes.

## Optional after the first release

- Package the reusable skills as a Codex plugin.
- Add cross-platform installation.
- Add more repository fixtures and routing evaluations.
- Add a short terminal recording or animated demo.
