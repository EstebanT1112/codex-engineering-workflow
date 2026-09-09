# Skill Provenance

The distribution treats skills as versioned dependencies and never auto-updates them. `manifests/provenance.json` is the machine-readable source of truth for ownership, relationships, pinned commits, and license files. Every physical skill and payload file is recorded with exact hashes in `manifests/distribution.lock.json`; selection metadata is maintained separately in `manifests/skill-catalog.json`.

| Skill | Classification | Source | Audited ref | Treatment |
|---|---|---|---|---|
| `engineering-task-workflow` | Bundled core | This project | `0.1.0-dev` | Original |
| `intent-driven-development` | Bundled core | `affaan-m/ECC` | `11813f968cc0087b2793470a4082b754688bf168` | Reviewed copy |
| `verification-before-completion` | Bundled core | `obra/superpowers` | `b36e0829c6d0140e93cfef2ca599b1b07d4a7797` | Reviewed copy |
| `tdd-workflow` | Bundled core | `affaan-m/ECC` | `11813f968cc0087b2793470a4082b754688bf168` | Adapted |
| `systematic-debugging` | Bundled core | `obra/superpowers` | `b36e0829c6d0140e93cfef2ca599b1b07d4a7797` | Adapted |
| `database-migrations` | Bundled core | `affaan-m/ECC` | `11813f968cc0087b2793470a4082b754688bf168` | Adapted |
| `react-patterns` | Bundled core | `affaan-m/ECC` | `11813f968cc0087b2793470a4082b754688bf168` | Adapted |
| `error-handling` | Bundled core | `affaan-m/ECC` | `11813f968cc0087b2793470a4082b754688bf168` | Reviewed copy |
| `api-design` | Bundled standard | `affaan-m/ECC` | `11813f968cc0087b2793470a4082b754688bf168` | Reviewed copy |
| `contract-first` | Bundled standard | `affaan-m/ECC` | `11813f968cc0087b2793470a4082b754688bf168` | Reviewed copy |
| `backend-patterns` | Bundled standard | `affaan-m/ECC` | `11813f968cc0087b2793470a4082b754688bf168` | Reviewed copy |
| `supabase-postgres-best-practices` | Bundled standard | `supabase/agent-skills` | `8331f910845103c08d51f6ca1d86ebb7d1f745e3` | Reviewed copy plus Codex metadata |
| `frontend-ui-engineering` | Bundled standard | This project | `0.1.0-dev` | Original compact workflow |
| `frontend-design` | Bundled standard | This project | `0.1.0-dev` | Original Codex-specific adaptation |
| `fixing-accessibility` | Bundled standard | This project | `0.1.0-dev` | Original compact workflow |
| `react-testing` | Bundled standard | `affaan-m/ECC` | `11813f968cc0087b2793470a4082b754688bf168` | Adapted to remove unavailable cross-dependencies |
| `security-best-practices` | Bundled standard | `openai/skills` | `49f948faa9258a0c61caceaf225e179651397431` | Adapted to the autonomous engineering workflow |
| `brand` | Bundled standard | This project | `0.1.0-dev` | Original compact workflow |
| `ui-ux-pro-max` | Bundled standard | This project | `0.1.0-dev` | Original compact workflow |
| `react-native-patterns` | Bundled standard | `affaan-m/ECC` | `11813f968cc0087b2793470a4082b754688bf168` | Adapted for detected repository dependencies |
| `shadcn` | Bundled standard | This project | `0.1.0-dev` | Original Codex-compatible workflow |
| `imagegen` | System-provided | Codex Desktop system skill | Runtime version | Referenced, not redistributed or duplicated |

The optional capabilities in `manifests/capabilities.json` are not redistributed. Their installation and licenses remain independent. Updating any pinned source requires a fresh review, license check, lock regeneration, and distribution verification.

## License files

The project license is stored at `LICENSE`. Canonical local copies for redistributed third-party material are stored under `LICENSES/` and referenced by `manifests/provenance.json`:

- `LICENSES/ECC-MIT.txt`
- `LICENSES/SUPERPOWERS-MIT.txt`
- `LICENSES/SUPABASE-MIT.txt`
- `LICENSES/OPENAI-SECURITY-APACHE-2.0.txt`

## Updating the lock

After an intentional payload, provenance, or license change, run:

```powershell
.\scripts\Update-DistributionLock.ps1
.\scripts\Test-Provenance.ps1
.\scripts\Test-PublicDistribution.ps1
```

The lock generator reads only public manifests and files. It preserves the version and publication status declared in `provenance.json` and produces deterministic output on Windows PowerShell 5.1 and PowerShell 7.
