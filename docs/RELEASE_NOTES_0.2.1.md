# Codex Engineering Workflow v0.2.1

Version 0.2.1 improves onboarding and clarifies the licensing and affiliation boundaries of the public distribution. Workflow behavior, bundled capability counts, and installer targets remain unchanged from 0.2.0.

This is an independent community project. It is not affiliated with, sponsored by, or endorsed by OpenAI.

## Changes

- Added a getting-started guide covering account requirements, download, installation contents, first use, conflicts, approvals, and rollback.
- Clarified that original project material is MIT-licensed while redistributed material retains its original MIT or Apache-2.0 license.
- Added visible modification notices to the five Apache-2.0 files that differ from the pinned OpenAI source.
- Added machine-readable modified-file provenance and deterministic validation for those notices.
- Added trademark and no-affiliation disclosures.
- Documented the project's free, non-commercial community purpose without restricting the permissions granted by its open-source licenses.
- Added explicit inbound licensing terms for contributions.

## Install

Run the preflight from the repository root:

```powershell
.\scripts\Install-CodexDesktopWorkflow.ps1 -DryRun
```

If it returns `DRY_RUN_PASS`, install:

```powershell
.\scripts\Install-CodexDesktopWorkflow.ps1
```

Open a new Codex Desktop task after installation so the application refreshes its skill catalog.

## Requirements and scope

- Codex Desktop
- Windows PowerShell 5.1 or PowerShell 7
- Windows installation workflow

No API key, Docker environment, multi-agent runtime, or external model worker is required. `imagegen` is supplied by Codex Desktop and is not redistributed. Optional capabilities are used only when they are already installed.

## Verification

The release commit must pass `.github/workflows/validate.yml`. The workflow validates payload hashes, routing, provenance, community files, the end-to-end example, and installation and rollback on both supported PowerShell versions.

## License and attribution

Original project material is MIT-licensed. Redistributed upstream material retains its original MIT or Apache-2.0 license and attribution as documented in `THIRD_PARTY_NOTICES.md`, `LICENSES/`, and `manifests/provenance.json`.
