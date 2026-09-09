# Codex Engineering Workflow

A skill-routed engineering workflow for using Codex Desktop as the single implementation owner of a software task.

Give Codex a feature, bug, refactor, migration, security task, UI change, review, or release-preparation request. The workflow guides Codex through repository discovery, acceptance criteria, risk classification, skill selection, implementation, diff review, deterministic verification, correction, and delivery.

## Status

Version `0.2.0` is the current public release candidate. Package validation, installation, rollback, and the end-to-end example pass locally on Windows PowerShell. Publication remains gated on a passing GitHub-hosted CI run for the release commit. The project and redistributed upstream material are MIT-licensed with attribution preserved in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## Core model

```text
Codex Desktop
      │
      ├── global/AGENTS.md
      │     stable ownership, approval, and verification rules
      │
      ├── engineering-task-workflow
      │     lifecycle, risk, routing, review, and delivery
      │
      ├── specialist skills
      │     TDD, debugging, migrations, React, and error handling
      │
      └── repository AGENTS.md
            project commands, architecture, and local constraints
```

The fundamental rule is:

```text
ONE TASK = ONE WRITE OWNER
WRITE OWNER = CODEX
```

Implementation is never treated as completion by itself. Codex reviews the current diff, runs the relevant repository checks, corrects findings, and evaluates acceptance criteria before reporting `DONE`.

## Included capabilities

| Skill | Purpose |
|---|---|
| `engineering-task-workflow` | Main request-to-delivery engineering lifecycle |
| `intent-driven-development` | Observable scope and acceptance criteria for ambiguous or high-impact work |
| `verification-before-completion` | Fresh evidence gate before any completion claim |
| `tdd-workflow` | Test-first development when a focused test provides useful evidence |
| `systematic-debugging` | Reproduction, falsifiable hypotheses, and root-cause fixes |
| `database-migrations` | Compatibility, rollout, backfill, rollback, and migration verification |
| `react-patterns` | React web components, hooks, state, effects, and rendering boundaries |
| `error-handling` | Typed errors, retries, circuit breakers, and safe user-facing failures |
| `api-design` | REST resources, status codes, pagination, errors, and versioning |
| `contract-first` | Machine-checkable contracts shared by providers and consumers |
| `backend-patterns` | Node.js, Express, and Next.js backend patterns |
| `supabase-postgres-best-practices` | Current Postgres schema, query, RLS, locking, and connection guidance |
| `frontend-ui-engineering` | Complete, responsive, accessible UI implementation |
| `frontend-design` | Intentional visual direction for new interfaces and redesigns |
| `fixing-accessibility` | Focused web accessibility audits and repairs |
| `react-testing` | Behavior-focused React component and hook tests |
| `security-best-practices` | Explicit Python, JavaScript/TypeScript, and Go security reviews |
| `brand` | Brand voice and visual identity work when explicitly required |
| `ui-ux-pro-max` | High-impact UX journeys, critique, and product design decisions |
| `react-native-patterns` | React Native and Expo implementation using the repository's actual stack |
| `shadcn` | Controlled work in repositories that already use shadcn/ui |
| `imagegen` | Raster asset generation through the system skill supplied by Codex Desktop |

Codex loads skill metadata first and reads full instructions only when a skill is selected. The main workflow chooses the smallest useful set based on task intent, repository stack, current stage, and risk.

The complete trigger, guard, stage, availability, companion, overlap, and exclusion rules are documented in [SKILL_CATALOG.md](docs/SKILL_CATALOG.md) and represented for automated validation in [skill-catalog.json](manifests/skill-catalog.json).

The installer includes 21 skill directories: eight core workflow skills and thirteen standard specialist skills. `imagegen` is the twenty-second included capability and is supplied by Codex Desktop itself; the installer deliberately avoids creating a duplicate personal skill with the same name.

Thirteen additional capabilities remain optional: `make-interfaces-feel-better`, `react-performance`, `vite-patterns`, `accessibility`, `motion-ui`, `browser-qa`, `e2e-testing`, `click-path-audit`, `production-audit`, `architecture-decision-records`, `living-docs-governance`, `inherit-legacy-style`, and `codebase-onboarding`. The router may use one only when it is already installed, its trigger matches, and it materially improves the current stage. The machine-readable grouping is in [capabilities.json](manifests/capabilities.json).

## Requirements

- Codex Desktop
- Windows PowerShell 5.1 or PowerShell 7
- Permission to write to the user's Codex instructions and personal skills directories

No API key, multi-agent runtime, Docker environment, or external model worker is required.

## Install

Open PowerShell in the repository root and run the preflight:

```powershell
.\scripts\Install-CodexDesktopWorkflow.ps1 -DryRun
```

If it returns `DRY_RUN_PASS`, install:

```powershell
.\scripts\Install-CodexDesktopWorkflow.ps1
```

The preflight performs no writes. It verifies the complete package against `distribution.lock.json`, validates the catalog and bundled skill set, detects target conflicts, reports identical skills that can be preserved, lists optional capabilities already present, and reports whether the standard Codex system path contains `imagegen`.

The installer targets:

```text
~/.codex/AGENTS.md
~/.agents/skills/<skill>/
```

It refuses to overwrite a different non-empty global `AGENTS.md` or merge a different existing skill directory. An identical existing skill is preserved and recorded as already present; rollback never removes it. A successful installation stores an exact version-2 rollback manifest under `.local-backups/`, which is excluded from Git.

If a previous release installed different copies of these skills, restore that installation with its manifest before installing the new release. The installer has no force or overwrite mode.

Open a new Codex Desktop task after installation so Codex refreshes its skill catalog.

## Use

Ordinary use does not require a special command:

```text
Implement the order-status filter. Preserve existing filters, add meaningful tests, and verify the build.
```

For explicit activation:

```text
$engineering-task-workflow Implement password recovery using the repository's existing patterns.
```

Typical routing examples:

| Task signal | Likely route |
|---|---|
| Behavior change with regression risk | `engineering-task-workflow` + `tdd-workflow` |
| Non-trivial bug | `engineering-task-workflow` + `systematic-debugging` |
| Schema or data migration | `engineering-task-workflow` + `database-migrations` |
| React web implementation | `engineering-task-workflow` + `react-patterns` |
| Error contract or retry behavior | `engineering-task-workflow` + `error-handling` |
| REST contract design | `engineering-task-workflow` + `api-design` |
| Postgres schema, SQL, or RLS | `engineering-task-workflow` + `database-migrations` + `supabase-postgres-best-practices` |
| Significant web UI implementation | `engineering-task-workflow` + `frontend-ui-engineering` |
| React Native or Expo | `engineering-task-workflow` + `react-native-patterns` |
| Existing shadcn/ui project | `engineering-task-workflow` + `shadcn` |

Repository-specific skills already installed in the user's environment may also be selected when their descriptions and constraints match the task.

## Workflow

```text
ANALYZED
   ↓
PLANNED
   ↓
IMPLEMENTING
   ↓
REVIEWING
   ↓
VERIFYING ←→ CORRECTING
   ↓
DELIVERY_GATE
   ↓
DONE
```

Risk is classified as `LOW`, `MEDIUM`, `HIGH`, or `CRITICAL`. Authentication, authorization, payments, public contracts, migrations, production data, secrets, and destructive operations increase planning, review, verification, and approval requirements.

## Project instructions

The global contract does not hardcode stack commands. Codex discovers them from repository instructions, manifests, task runners, CI, and maintained documentation.

A repository does not need its own `AGENTS.md`, but stable non-obvious commands and boundaries can be recorded using [PROJECT_AGENTS.template.md](templates/PROJECT_AGENTS.template.md). The discovery procedure is documented in [PROJECT_DISCOVERY.md](templates/PROJECT_DISCOVERY.md).

## Approval gates

Codex can perform reversible repository work implied by the request. It requires explicit authorization before push, merge, deployment, destructive or breaking migration application, production data mutation, secret rotation, force operations, or another irreversible external mutation.

Commits and pushes remain with the user unless the user explicitly authorizes that concrete action.

## Verification

The workflow uses the repository's real checks, such as targeted tests, typecheck, lint, build, integration, browser/device checks, or disposable database validation. Missing tools, credentials, or permissions are reported as limitations and never converted into a false `PASS`.

Test the installation lifecycle without touching the real Codex profile:

```powershell
.\scripts\Test-InstallationLifecycle.ps1
```

Validate the complete public payload, manifests, skills, links, licensing, privacy boundary, and script syntax:

```powershell
.\scripts\Test-PublicDistribution.ps1
```

Validate capability selection metadata and overlap rules:

```powershell
.\scripts\Test-RoutingCatalog.ps1
```

Validate licenses, pinned provenance, and deterministic lock regeneration:

```powershell
.\scripts\Test-Provenance.ps1
```

Run the reproducible repository feature example:

```powershell
.\scripts\Test-EndToEndExample.ps1
```

The example follows a real feature through repository discovery, minimal skill routing, a focused RED/GREEN cycle, diff review, and deterministic verification. Its request, decisions, and evidence are recorded in [END_TO_END_EXAMPLE.md](docs/END_TO_END_EXAMPLE.md).

The GitHub Actions workflow runs these checks on Windows PowerShell 5.1 and PowerShell 7. Its scope and local commands are documented in [CI.md](docs/CI.md).

Activation and policy scenarios are listed in [ACTIVATION_CASES.md](tests/ACTIVATION_CASES.md).

## Rollback

Use the manifest path returned by the installer:

```powershell
.\scripts\Restore-CodexDesktopWorkflow.ps1 `
  -ManifestPath '.\.local-backups\<installation-id>\install-manifest.json'
```

Rollback verifies hashes and exact file sets before removal. If installed content changed after installation, rollback stops instead of deleting that work.

Detailed installer behavior, result fields, failure codes, and recovery rules are documented in [INSTALLATION.md](docs/INSTALLATION.md).

## Repository layout

```text
codex-engineering-workflow/
├── global/AGENTS.md
├── skills/
├── scripts/
├── templates/
├── tests/
├── manifests/
├── docs/
└── README.md
```

## Scope

This project is a Codex Desktop configuration and workflow package. It is not a multi-agent runtime, background service, deployment system, substitute for repository tests, or independent human review.

Security depends on the combination of instructions, skill scope, Codex permissions, the execution sandbox, repository policy, and human approval for privileged actions.

## Publication status

See [PUBLICATION_CHECKLIST.md](docs/PUBLICATION_CHECKLIST.md). Do not publish a release until the first GitHub-hosted CI run and the first end-to-end example are complete.

Release notes for version `0.2.0` are available in [RELEASE_NOTES_0.2.0.md](docs/RELEASE_NOTES_0.2.0.md).

## Contributing and support

- Read [CONTRIBUTING.md](CONTRIBUTING.md) before proposing a change.
- Report vulnerabilities through the private process in [SECURITY.md](SECURITY.md).
- Participation is governed by [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
- User-visible changes are recorded in [CHANGELOG.md](CHANGELOG.md).

GitHub issue forms are provided for reproducible bugs and focused feature requests. The pull request template requires concrete verification results and a regenerated distribution lock.

## License and provenance

Original project material is available under the [MIT License](LICENSE). Redistributed and adapted skills retain their licenses under [LICENSES](LICENSES), their notices in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md), and machine-readable pinned provenance in [provenance.json](manifests/provenance.json). The maintenance procedure is documented in [PROVENANCE.md](docs/PROVENANCE.md).
