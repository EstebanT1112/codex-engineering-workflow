# Getting Started

This guide explains what a new user needs, what the package installs, and how to use the workflow with a software repository in Codex Desktop.

This is an independent community project. It is not affiliated with, sponsored by, or endorsed by OpenAI.

It is maintained as a free, non-commercial community resource to help people use Codex for structured software-engineering work. The project does not sell access to Codex or provide a paid service. This purpose statement does not restrict the permissions granted by the MIT and applicable third-party licenses.

## What this project is

Codex Engineering Workflow is a configuration and skill package for Codex Desktop. It gives Codex a consistent engineering process for repository work:

```text
request
  -> repository discovery
  -> acceptance criteria and risk
  -> minimal skill selection
  -> implementation
  -> diff review
  -> deterministic verification
  -> correction when needed
  -> delivery report
```

It does not install or run a multi-agent framework, model server, background service, deployment system, or replacement for the target repository's own tests.

## Account and software requirements

Before installing the workflow, the user needs:

- a supported Windows installation that can run the current ChatGPT desktop app;
- the ChatGPT desktop app with access to Codex;
- a ChatGPT account on a plan that currently includes Codex;
- Windows PowerShell 5.1 or PowerShell 7; and
- permission to write to the user's Codex configuration and personal skill directories.

When Codex Desktop is signed in with ChatGPT, this workflow does not require an OpenAI API key. Codex availability and usage limits depend on the user's current ChatGPT plan and workspace settings; consult the [current OpenAI Codex plan documentation](https://help.openai.com/en/articles/11369540) before installation.

Using this package does not change the terms, privacy controls, or data-handling settings of the user's ChatGPT account or organization. Users remain responsible for having permission to provide repository content to Codex and for following their organization's policies.

A GitHub account is not required to download a public release as a ZIP file. Git is required only when cloning the repository or using Git features in a target project.

The user must separately install the tools required by the repository they want Codex to change, such as Git, Node.js, Python, a package manager, Docker, or a database runtime. This package does not install project dependencies or development toolchains.

## Download the package

Prefer the latest published version from the repository's **Releases** page. Download the source ZIP and extract it to a local directory.

Alternatively, clone the repository:

```powershell
git clone <repository-url>
cd codex-engineering-workflow
```

Run every installation command from the extracted or cloned repository root.

## Preview the installation

Open PowerShell in the package directory and run the read-only preflight:

```powershell
.\scripts\Install-CodexDesktopWorkflow.ps1 -DryRun
```

A successful preflight reports:

```json
{
  "status": "DRY_RUN_PASS"
}
```

The preflight verifies package hashes and catalogs, detects existing targets, lists the skills that would be installed, reports identical skills already present, and identifies available optional capabilities. It does not modify the user's profile.

If it reports a conflict, resolve that conflict before installing. The installer deliberately has no force or overwrite mode.

## Install the workflow

After a successful preflight, run:

```powershell
.\scripts\Install-CodexDesktopWorkflow.ps1
```

A successful installation reports `"status": "PASS"` and the path to its rollback manifest. Keep that path. Open a new Codex Desktop task after installation so Codex refreshes its skill catalog.

## What gets installed

The installer writes the global engineering agreement to:

```text
~/.codex/AGENTS.md
```

This agreement defines stable behavior for repository work, including single-writer ownership, repository discovery, proportional planning, review, verification, approval gates, and user control of commits and pushes by default.

It also copies 21 bundled skills to:

```text
~/.agents/skills/<skill-name>/
```

The installed skills cover the main engineering lifecycle plus focused work such as intent clarification, TDD, debugging, migrations, API contracts, backend development, Postgres and Supabase, React, React Native, UI, accessibility, security, testing, branding, and shadcn/ui.

`imagegen` is treated as a Codex system capability and is not duplicated in the personal skills directory. The 13 capabilities marked `optional_if_available` in `manifests/capabilities.json` are not installed by this package. Codex may select one only when it is already available in the user's environment and its trigger matches the task.

The installer does not install:

- Codex Desktop or ChatGPT;
- API keys or credentials;
- Git, Node.js, Python, Docker, databases, or package managers;
- dependencies for the user's target repository;
- Gemini, Microsoft Agent Framework, or another external agent runtime; or
- the optional capabilities declared in the catalog.

## Existing configuration and conflicts

The installer preserves existing configuration rather than combining or replacing it silently.

- A different non-empty `~/.codex/AGENTS.md` causes `GLOBAL_AGENTS_CONFLICT`.
- A different existing skill directory with the same name causes `SKILL_TARGET_CONFLICT`.
- An identical global agreement or skill is preserved and reported as already present.

Review [INSTALLATION.md](INSTALLATION.md) for exact conflict, recovery, and rollback behavior.

## Use it with a project

Open Codex Desktop, select the local repository you want to change, and create a new Codex task. No special runtime or command is required. A normal request can be enough:

```text
Implement the order-status filter. Preserve the existing filters, add meaningful tests, and verify the build.
```

For a more structured request, copy [TASK_REQUEST.template.md](../templates/TASK_REQUEST.template.md). Describe the desired outcome, observable acceptance criteria, constraints, relevant context, and expected verification. The user normally does not need to choose skills or prescribe an implementation.

The main workflow can also be activated explicitly:

```text
$engineering-task-workflow Implement password recovery using the repository's existing patterns.
```

## How skill selection works

Codex selects the smallest useful skill set from the task intent, actual repository stack, current workflow stage, risk, and catalog rules. It reads skill metadata first and loads full instructions only for selected skills.

Examples:

| Task signal | Likely selection |
|---|---|
| Behavior change with regression risk | Main workflow and TDD |
| Non-trivial bug | Main workflow and systematic debugging |
| Schema or data migration | Main workflow and database migrations |
| React web implementation | Main workflow and React patterns |
| REST API design | Main workflow and API design |
| Postgres schema, SQL, or RLS | Main workflow, migrations, and Supabase/Postgres guidance |
| Significant web UI work | Main workflow and frontend UI engineering |
| React Native or Expo | Main workflow and React Native patterns |
| Existing shadcn/ui repository | Main workflow and shadcn |

Repository-specific instructions and already-installed compatible skills can refine this route. Codex does not load every skill for every task.

## User responsibilities and approvals

The user should provide at least:

- the outcome they want;
- the repository or area involved;
- behavior that must remain unchanged; and
- evidence that would demonstrate completion.

Codex can perform reversible repository work implied by the request. Explicit authorization is still required before push, merge, deployment, destructive or breaking migration application, production data changes, secret rotation, force operations, or another irreversible external mutation. Credentials and sensitive production data must never be pasted into a task.

## Uninstall or restore

Use the manifest path returned by the successful installation:

```powershell
.\scripts\Restore-CodexDesktopWorkflow.ps1 `
  -ManifestPath '.\.local-backups\<installation-id>\install-manifest.json'
```

Rollback verifies the installed hashes and file sets before removing anything. If installed content was changed after installation, it stops instead of deleting those changes. Keep the downloaded package and its `.local-backups` directory until the installation is no longer needed or its rollback information has been safely retained.
