# Continuous Integration

The public distribution is validated by `.github/workflows/validate.yml` on pushes to `main`, pull requests, and manual runs.

The workflow runs on a GitHub-hosted Windows runner and checks:

- the exact payload and every SHA-256 recorded in `manifests/distribution.lock.json`;
- the complete routing catalog, availability mapping, trigger/guard fields, overlap rules, and excluded-route boundary;
- license files, pinned source relationships, provenance coverage, and deterministic lock regeneration;
- public community documents, GitHub templates, privacy placeholders, and line-ending policy;
- the bundled skill catalog and each `SKILL.md` frontmatter;
- local Markdown links and PowerShell syntax;
- project licensing, third-party notices, and provenance;
- exclusion of local backup state, personal markers, and credential-shaped values;
- clean installation, conflict refusal, tamper-safe rollback, and fixture cleanup;
- the reproducible Python feature example and its selected route;
- compatibility of the lifecycle scripts with Windows PowerShell 5.1 and PowerShell 7.

The workflow grants the GitHub token only read access to repository contents. Checkout is pinned to the full commit for `actions/checkout` v6.0.2 and does not persist credentials.

Run the same checks locally from the repository root:

```powershell
.\scripts\Test-PublicDistribution.ps1
.\scripts\Test-EndToEndExample.ps1
.\scripts\Test-InstallationLifecycle.ps1
```

All commands must return JSON with `"status": "PASS"`. A local pass validates the files on disk; the publication gate also requires the first GitHub-hosted workflow run to pass after the repository is pushed.

The installation lifecycle creates its disposable fixture under the operating system temporary directory by default. Use `-WorkRoot` only when a different short writable location is required; keeping the fixture outside a deeply nested checkout avoids the legacy 260-character path limit in Windows PowerShell 5.1.
