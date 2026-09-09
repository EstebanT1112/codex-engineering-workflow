# Contributing

Thank you for improving Codex Engineering Workflow. Changes should keep the package small, auditable, and safe to install.

## Before making a change

1. Read `README.md`, `global/AGENTS.md`, and the relevant skill or script.
2. Check `manifests/capabilities.json`, `manifests/skill-catalog.json`, and `manifests/provenance.json` before changing availability, routing, or redistributed material.
3. Keep one clear objective per pull request and preserve unrelated behavior.
4. Do not add credentials, personal paths, installation backups, generated logs, or private repository details.

## Skills and dependencies

- Add a skill only for a demonstrated workflow gap.
- Give every skill a narrow trigger and a clear condition for when it should not run.
- Prefer repository-native tools and avoid dependencies that the current behavior does not require.
- Record copied or adapted material with an immutable upstream commit, license, local license file, and treatment in `manifests/provenance.json`.
- Do not auto-update upstream skills. Review each update as a dependency change.

## Validation

Run these commands from the repository root:

```powershell
.\scripts\Update-DistributionLock.ps1
.\scripts\Test-RoutingCatalog.ps1
.\scripts\Test-Provenance.ps1
.\scripts\Test-PublicDistribution.ps1
.\scripts\Test-InstallationLifecycle.ps1
```

`Update-DistributionLock.ps1` must run after every intentional public-file change. Do not edit `manifests/distribution.lock.json` by hand.

The checks must pass in Windows PowerShell 5.1 and PowerShell 7 when a change touches installation, rollback, manifests, hashing, or CI behavior.

## Pull requests

Describe the concrete problem and resulting behavior. Include:

- the trigger or user journey affected;
- why the selected scope is sufficient;
- relevant compatibility or security considerations;
- commands run and their actual results;
- any check that was skipped or unavailable.

Do not claim a release, deployment, or production-readiness result without evidence for that exact target.

## Contribution license

By submitting a contribution, you agree to license your contribution under the MIT License used by this project. Changes to third-party material remain subject to the applicable upstream license and must preserve its required copyright, attribution, modification, and notice terms.

Only submit material that you have the right to contribute. If a contribution copies or adapts external material, disclose the source and license in the pull request and update the repository's provenance records.
