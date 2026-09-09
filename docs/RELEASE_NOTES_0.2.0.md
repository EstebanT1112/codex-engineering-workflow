# Codex Engineering Workflow v0.2.0

Version 0.2.0 is the first public release of Codex Engineering Workflow, a skill-routed process for completing repository work in Codex Desktop with one write owner and fresh verification before delivery.

## Highlights

- A request-to-delivery workflow covering repository discovery, acceptance criteria, risk, planning, implementation, review, correction, verification, and delivery.
- Twenty-one bundled engineering skills, one Codex Desktop system capability, and thirteen optional capabilities selected only when already installed and relevant.
- A machine-readable routing catalog with triggers, guards, stages, companion rules, overlap resolution, and excluded automatic routes.
- Conflict-safe installation and tamper-safe rollback for Windows PowerShell 5.1 and PowerShell 7.
- Pinned provenance, separate upstream licenses, deterministic SHA-256 payload locking, and credential and privacy scans.
- A reproducible Python feature example showing minimal routing, a RED/GREEN cycle, diff review, and deterministic verification.

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

Project code is MIT licensed. Redistributed upstream material retains its original license and attribution as documented in `THIRD_PARTY_NOTICES.md`, `LICENSES/`, and `manifests/provenance.json`.

