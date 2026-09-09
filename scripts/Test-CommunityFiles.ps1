[CmdletBinding()]
param(
    [string]$PackageRoot = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($PackageRoot)) {
    $PackageRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
}

$package = [System.IO.Path]::GetFullPath($PackageRoot)
$checks = [ordered]@{}
$failures = New-Object System.Collections.Generic.List[string]

function Add-Check([string]$Name, [bool]$Passed, [string]$Failure) {
    $checks[$Name] = $Passed
    if (-not $Passed) { $failures.Add($Failure) }
}

$paths = @(
    'CONTRIBUTING.md', 'SECURITY.md', 'CODE_OF_CONDUCT.md', 'CHANGELOG.md',
    'docs/END_TO_END_EXAMPLE.md',
    'docs/RELEASE_NOTES_0.2.1.md',
    'manifests/release.json',
    'templates/TASK_REQUEST.template.md',
    '.editorconfig', '.gitattributes', '.github/PULL_REQUEST_TEMPLATE.md',
    '.github/ISSUE_TEMPLATE/bug_report.yml', '.github/ISSUE_TEMPLATE/feature_request.yml',
    '.github/ISSUE_TEMPLATE/config.yml'
)
$missing = @($paths | Where-Object { -not (Test-Path -LiteralPath (Join-Path $package $_) -PathType Leaf) })
Add-Check 'required_community_files_present' ($missing.Count -eq 0) ("Missing community files: " + ($missing -join ', '))

$formFailures = New-Object System.Collections.Generic.List[string]
$allowedTypes = @('checkboxes', 'dropdown', 'input', 'markdown', 'textarea')
foreach ($relative in @('.github/ISSUE_TEMPLATE/bug_report.yml', '.github/ISSUE_TEMPLATE/feature_request.yml')) {
    $content = [System.IO.File]::ReadAllText((Join-Path $package $relative))
    foreach ($key in @('name', 'description', 'body')) {
        if ($content -notmatch "(?m)^$key`:\s*\S+") { $formFailures.Add("$relative missing top-level $key") }
    }
    if ($content -match '(?m)^\s*- type:\s*$') { $formFailures.Add("$relative has an empty input type") }
    $types = @([regex]::Matches($content, '(?m)^\s*- type:\s*(?<value>\S+)') | ForEach-Object { $_.Groups['value'].Value })
    if ($types.Count -eq 0 -or @($types | Where-Object { $allowedTypes -notcontains $_ }).Count -gt 0) { $formFailures.Add("$relative has invalid input types") }
    $ids = @([regex]::Matches($content, '(?m)^\s+id:\s*(?<value>[A-Za-z0-9_-]+)\s*$') | ForEach-Object { $_.Groups['value'].Value })
    if (@($ids | Select-Object -Unique).Count -ne $ids.Count) { $formFailures.Add("$relative has duplicate ids") }
}
Add-Check 'github_issue_forms_structurally_valid' ($formFailures.Count -eq 0) ($formFailures -join '; ')

$config = [System.IO.File]::ReadAllText((Join-Path $package '.github/ISSUE_TEMPLATE/config.yml'))
Add-Check 'blank_issues_disabled' ($config -match '(?m)^blank_issues_enabled:\s*false\s*$') 'Issue-template chooser does not disable blank public issues.'

$pullRequest = [System.IO.File]::ReadAllText((Join-Path $package '.github/PULL_REQUEST_TEMPLATE.md'))
Add-Check 'pull_request_template_requires_evidence' ($pullRequest.Contains('## Verification') -and $pullRequest.Contains('Update-DistributionLock.ps1') -and $pullRequest.Contains('No credentials')) 'Pull request template lacks verification, lock, or privacy checks.'

$contributing = [System.IO.File]::ReadAllText((Join-Path $package 'CONTRIBUTING.md'))
$security = [System.IO.File]::ReadAllText((Join-Path $package 'SECURITY.md'))
$conduct = [System.IO.File]::ReadAllText((Join-Path $package 'CODE_OF_CONDUCT.md'))
$changelog = [System.IO.File]::ReadAllText((Join-Path $package 'CHANGELOG.md'))
$endToEnd = [System.IO.File]::ReadAllText((Join-Path $package 'docs/END_TO_END_EXAMPLE.md'))
$releaseNotes = [System.IO.File]::ReadAllText((Join-Path $package 'docs/RELEASE_NOTES_0.2.1.md'))
$taskTemplate = [System.IO.File]::ReadAllText((Join-Path $package 'templates/TASK_REQUEST.template.md'))
Add-Check 'contribution_workflow_is_actionable' ($contributing.Contains('Test-InstallationLifecycle.ps1') -and $contributing.Contains('manifests/provenance.json')) 'Contribution guide lacks validation or provenance instructions.'
Add-Check 'contribution_license_is_explicit' ($contributing.Contains('By submitting a contribution, you agree to license your contribution under the MIT License') -and $contributing.Contains('third-party material remain subject to the applicable upstream license')) 'Contribution guide lacks explicit inbound licensing terms.'
Add-Check 'security_reporting_is_private' ($security.Contains('private vulnerability reporting') -and $security.Contains('Do not open a public issue')) 'Security policy does not provide a private-reporting boundary.'
Add-Check 'conduct_enforcement_defined' ($conduct.Contains('## Reporting and enforcement') -and $conduct.Contains('Maintainers may')) 'Code of conduct lacks reporting or enforcement.'
Add-Check 'changelog_has_unreleased_section' ($changelog.Contains('## Unreleased') -and $changelog.Contains('### Added')) 'Changelog lacks an Unreleased section.'
Add-Check 'changelog_has_current_release' ($changelog.Contains('## [0.2.1] - 2026-09-09')) 'Changelog lacks the dated 0.2.1 release section.'
Add-Check 'end_to_end_example_is_reproducible' ($endToEnd.Contains('Test-EndToEndExample.ps1') -and $endToEnd.Contains('TypeError: list_orders()') -and $endToEnd.Contains('tests_passed: 4')) 'End-to-end documentation lacks routing, RED, or reproducible verification evidence.'
Add-Check 'release_notes_are_actionable' ($releaseNotes.Contains('# Codex Engineering Workflow v0.2.1') -and $releaseNotes.Contains('Install-CodexDesktopWorkflow.ps1 -DryRun') -and $releaseNotes.Contains('## Requirements and scope') -and $releaseNotes.Contains('## License and attribution')) 'Release notes lack version, installation, scope, or attribution.'
Add-Check 'task_request_template_is_actionable' ($taskTemplate.Contains('## Short request') -and $taskTemplate.Contains('## Detailed request') -and $taskTemplate.Contains('## Acceptance criteria') -and $taskTemplate.Contains('## Verification') -and $taskTemplate.Contains('## Feature example') -and $taskTemplate.Contains('## Bug example') -and $taskTemplate.Contains('Never include passwords')) 'Task request template lacks required guidance, examples, or credential boundary.'

$editorConfig = [System.IO.File]::ReadAllText((Join-Path $package '.editorconfig'))
$attributes = [System.IO.File]::ReadAllText((Join-Path $package '.gitattributes'))
Add-Check 'text_policy_preserves_hashes' ($editorConfig -match '(?m)^end_of_line = lf$' -and $attributes -match '(?m)^\*\.ps1 text eol=lf$' -and $attributes -match '(?m)^\*\.json text eol=lf$') 'Editor or Git line-ending policy can alter locked files.'

$placeholderHits = New-Object System.Collections.Generic.List[string]
foreach ($relative in @('CONTRIBUTING.md', 'SECURITY.md', 'CODE_OF_CONDUCT.md', 'CHANGELOG.md')) {
    $content = [System.IO.File]::ReadAllText((Join-Path $package $relative))
    if ($content -match '(?i:TODO|TBD|contact@example\.com|your[- ]repository|your[- ]email)') { $placeholderHits.Add($relative) }
}
Add-Check 'no_public_placeholders' ($placeholderHits.Count -eq 0) ("Placeholders found in: " + ($placeholderHits -join ', '))

$status = if ($failures.Count -eq 0) { 'PASS' } else { 'FAIL' }
[pscustomobject]@{
    status = $status
    checks = $checks
    issue_form_count = 2
    failures = @($failures)
} | ConvertTo-Json -Depth 8

if ($status -ne 'PASS') { exit 1 }
