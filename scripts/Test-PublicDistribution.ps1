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
$failures = New-Object System.Collections.Generic.List[string]
$checks = [ordered]@{}

function Add-Check {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][bool]$Passed,
        [string]$Failure
    )
    $checks[$Name] = $Passed
    if (-not $Passed) {
        if ([string]::IsNullOrWhiteSpace($Failure)) { $Failure = $Name }
        $failures.Add($Failure)
    }
}

function Get-RelativePath {
    param([string]$BasePath, [string]$FullPath)
    $baseUri = New-Object System.Uri(($BasePath.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar))
    $fileUri = New-Object System.Uri($FullPath)
    return [System.Uri]::UnescapeDataString($baseUri.MakeRelativeUri($fileUri).ToString()).Replace('\', '/')
}

function Test-MarkdownLinks {
    param([System.IO.FileInfo[]]$Files)
    $broken = New-Object System.Collections.Generic.List[string]
    foreach ($file in $Files) {
        $content = [System.IO.File]::ReadAllText($file.FullName)
        $matches = [regex]::Matches($content, '!??\[[^\]]*\]\(([^)]+)\)')
        foreach ($match in $matches) {
            $target = $match.Groups[1].Value.Trim()
            if ($target.StartsWith('<') -and $target.EndsWith('>')) { $target = $target.Substring(1, $target.Length - 2) }
            if ($target -match '^(?i:https?://|mailto:|#)') { continue }
            $target = ($target -split '#', 2)[0]
            if ([string]::IsNullOrWhiteSpace($target)) { continue }
            $resolved = [System.IO.Path]::GetFullPath((Join-Path $file.DirectoryName ([System.Uri]::UnescapeDataString($target))))
            if (-not (Test-Path -LiteralPath $resolved)) {
                $broken.Add("$(Get-RelativePath -BasePath $package -FullPath $file.FullName) -> $target")
            }
        }
    }
    return @($broken)
}

$requiredPaths = @(
    'README.md',
    'LICENSE',
    'THIRD_PARTY_NOTICES.md',
    'CONTRIBUTING.md',
    'SECURITY.md',
    'CODE_OF_CONDUCT.md',
    'CHANGELOG.md',
    '.editorconfig',
    '.gitattributes',
    '.github/ISSUE_TEMPLATE/bug_report.yml',
    '.github/ISSUE_TEMPLATE/feature_request.yml',
    '.github/ISSUE_TEMPLATE/config.yml',
    '.github/PULL_REQUEST_TEMPLATE.md',
    'global/AGENTS.md',
    'manifests/capabilities.json',
    'manifests/distribution.lock.json',
    'manifests/provenance.json',
    'manifests/release.json',
    'manifests/skill-catalog.json',
    'docs/SKILL_CATALOG.md',
    'templates/TASK_REQUEST.template.md',
    'scripts/Test-RoutingCatalog.ps1',
    'scripts/Test-Provenance.ps1',
    'scripts/Test-CommunityFiles.ps1',
    'scripts/Update-DistributionLock.ps1',
    'LICENSES/ECC-MIT.txt',
    'LICENSES/SUPERPOWERS-MIT.txt',
    'LICENSES/SUPABASE-MIT.txt',
    'LICENSES/OPENAI-SECURITY-APACHE-2.0.txt'
)
$missingRequired = @($requiredPaths | Where-Object { -not (Test-Path -LiteralPath (Join-Path $package $_)) })
Add-Check -Name 'required_files_present' -Passed ($missingRequired.Count -eq 0) -Failure ("Missing required files: " + ($missingRequired -join ', '))

try {
    $capabilities = Get-Content -LiteralPath (Join-Path $package 'manifests/capabilities.json') -Raw | ConvertFrom-Json
    $lock = Get-Content -LiteralPath (Join-Path $package 'manifests/distribution.lock.json') -Raw | ConvertFrom-Json
    $provenanceManifest = Get-Content -LiteralPath (Join-Path $package 'manifests/provenance.json') -Raw | ConvertFrom-Json
    $releaseManifest = Get-Content -LiteralPath (Join-Path $package 'manifests/release.json') -Raw | ConvertFrom-Json
    $routingCatalog = Get-Content -LiteralPath (Join-Path $package 'manifests/skill-catalog.json') -Raw | ConvertFrom-Json
    Add-Check -Name 'manifests_parse' -Passed $true
} catch {
    Add-Check -Name 'manifests_parse' -Passed $false -Failure $_.Exception.Message
    [pscustomobject]@{ status = 'FAIL'; checks = $checks; failures = @($failures) } | ConvertTo-Json -Depth 8
    exit 1
}

$core = @($capabilities.bundled_core | ForEach-Object { [string]$_ })
$standard = @($capabilities.bundled_standard | ForEach-Object { [string]$_ })
$systemProvided = @($capabilities.system_provided | ForEach-Object { [string]$_ })
$bundled = @($core + $standard)
$optional = @($capabilities.optional_if_available | ForEach-Object { [string]$_ })
$pending = @($capabilities.pending_adaptation | ForEach-Object { [string]$_ })
$skillFolders = @(Get-ChildItem -LiteralPath (Join-Path $package 'skills') -Directory | ForEach-Object { $_.Name } | Sort-Object)
$lockedSkills = @($lock.skills | ForEach-Object { [string]$_.name } | Sort-Object)
$bundledSorted = @($bundled | Sort-Object)
$allCapabilities = @($bundled + $systemProvided + $optional + $pending)
$catalogedCapabilities = @($routingCatalog.capabilities | ForEach-Object { [string]$_.name })

Add-Check -Name 'eight_core_skills_declared' -Passed ($core.Count -eq 8) -Failure "Expected 8 bundled core skills; found $($core.Count)."
Add-Check -Name 'thirteen_standard_skills_declared' -Passed ($standard.Count -eq 13) -Failure "Expected 13 bundled standard skills; found $($standard.Count)."
Add-Check -Name 'one_system_capability_declared' -Passed ($systemProvided.Count -eq 1 -and $systemProvided[0] -eq 'imagegen') -Failure 'Expected imagegen as the single system-provided capability.'
Add-Check -Name 'thirteen_optional_capabilities_declared' -Passed ($optional.Count -eq 13) -Failure "Expected 13 optional capabilities; found $($optional.Count)."
Add-Check -Name 'no_pending_adaptations' -Passed ($pending.Count -eq 0) -Failure "Expected no pending adaptations; found $($pending.Count)."
Add-Check -Name 'skill_names_unique' -Passed (@($bundled | Select-Object -Unique).Count -eq $bundled.Count) -Failure 'Duplicate bundled skill names found.'
Add-Check -Name 'capability_categories_disjoint' -Passed (@($allCapabilities | Select-Object -Unique).Count -eq $allCapabilities.Count) -Failure 'A capability appears in more than one category.'
Add-Check -Name 'routing_catalog_matches_capabilities' -Passed (@(Compare-Object @($allCapabilities | Sort-Object) @($catalogedCapabilities | Sort-Object)).Count -eq 0) -Failure 'skill-catalog.json does not cover the declared capabilities exactly.'
Add-Check -Name 'provenance_covers_bundled_skills' -Passed (@(Compare-Object $bundledSorted @($provenanceManifest.skills | ForEach-Object { [string]$_.name } | Sort-Object)).Count -eq 0) -Failure 'provenance.json does not cover bundled skills exactly.'
Add-Check -Name 'release_manifest_matches_distribution' -Passed ($releaseManifest.schema_version -eq 1 -and $releaseManifest.version -eq $lock.distribution_version -and $releaseManifest.name -eq $provenanceManifest.distribution.name) -Failure 'release.json does not match the locked distribution.'
Add-Check -Name 'skill_folders_match_capabilities' -Passed (@(Compare-Object $bundledSorted $skillFolders).Count -eq 0) -Failure 'Skill folders differ from capabilities.json.'
Add-Check -Name 'skill_lock_matches_capabilities' -Passed (@(Compare-Object $bundledSorted $lockedSkills).Count -eq 0) -Failure 'Locked skills differ from capabilities.json.'

$frontmatterFailures = New-Object System.Collections.Generic.List[string]
$skillFiles = @(Get-ChildItem -LiteralPath (Join-Path $package 'skills') -Filter 'SKILL.md' -File -Recurse)
foreach ($skillFile in $skillFiles) {
    $content = [System.IO.File]::ReadAllText($skillFile.FullName)
    $frontmatter = [regex]::Match($content, '\A---\r?\n(?<body>.*?)\r?\n---(?:\r?\n|$)', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if (-not $frontmatter.Success) {
        $frontmatterFailures.Add("$($skillFile.Directory.Name): missing YAML frontmatter")
        continue
    }
    $body = $frontmatter.Groups['body'].Value
    $nameMatch = [regex]::Match($body, '(?m)^name:\s*["'']?(?<value>[^"''\r\n]+)')
    $descriptionMatch = [regex]::Match($body, '(?m)^description:\s*(?<value>.+)$')
    if (-not $nameMatch.Success -or $nameMatch.Groups['value'].Value.Trim() -ne $skillFile.Directory.Name) {
        $frontmatterFailures.Add("$($skillFile.Directory.Name): name does not match folder")
    }
    if (-not $descriptionMatch.Success -or [string]::IsNullOrWhiteSpace($descriptionMatch.Groups['value'].Value)) {
        $frontmatterFailures.Add("$($skillFile.Directory.Name): description is missing")
    }
}
Add-Check -Name 'skill_frontmatter_valid' -Passed ($frontmatterFailures.Count -eq 0) -Failure ($frontmatterFailures -join '; ')

$markdownFiles = @(
    Get-ChildItem -LiteralPath $package -Filter '*.md' -File
    Get-ChildItem -LiteralPath (Join-Path $package 'docs') -Filter '*.md' -File
    Get-ChildItem -LiteralPath (Join-Path $package '.github') -Filter '*.md' -File -Recurse
) + $skillFiles
$brokenLinks = @(Test-MarkdownLinks -Files $markdownFiles)
Add-Check -Name 'markdown_links_resolve' -Passed ($brokenLinks.Count -eq 0) -Failure ("Broken links: " + ($brokenLinks -join '; '))

$parseFailures = New-Object System.Collections.Generic.List[string]
foreach ($script in @(Get-ChildItem -LiteralPath (Join-Path $package 'scripts') -Filter '*.ps1' -File)) {
    $tokens = $null
    $parseErrors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile($script.FullName, [ref]$tokens, [ref]$parseErrors)
    if (@($parseErrors).Count -gt 0) { $parseFailures.Add("$($script.Name): $($parseErrors[0].Message)") }
}
Add-Check -Name 'powershell_syntax_valid' -Passed ($parseFailures.Count -eq 0) -Failure ($parseFailures -join '; ')

$manifested = @($lock.files | ForEach-Object { [string]$_.path } | Sort-Object)
$actualFiles = @(Get-ChildItem -LiteralPath $package -File -Recurse -Force | Where-Object {
    $relative = Get-RelativePath -BasePath $package -FullPath $_.FullName
    $relative -ne 'manifests/distribution.lock.json' -and
    $relative -notmatch '(^|/)\.local-backups(/|$)' -and
    $relative -notmatch '(^|/)\.git(/|$)' -and
    $relative -notmatch '(^|/)__pycache__(/|$)' -and
    $relative -notmatch '\.py[cod]$' -and
    $relative -notmatch '^(work|tmp)/' -and
    $relative -notmatch '\.log$'
} | ForEach-Object { Get-RelativePath -BasePath $package -FullPath $_.FullName } | Sort-Object)
Add-Check -Name 'manifest_file_set_exact' -Passed (@(Compare-Object $manifested $actualFiles).Count -eq 0) -Failure 'distribution.lock.json does not describe the exact public payload.'

$hashFailures = New-Object System.Collections.Generic.List[string]
foreach ($entry in @($lock.files)) {
    $path = Join-Path $package ([string]$entry.path)
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        $hashFailures.Add("$($entry.path): missing")
        continue
    }
    $file = Get-Item -LiteralPath $path
    $hash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($file.Length -ne [long]$entry.bytes -or $hash -ne ([string]$entry.sha256).ToLowerInvariant()) {
        $hashFailures.Add("$($entry.path): size or SHA-256 mismatch")
    }
}
Add-Check -Name 'manifest_hashes_match' -Passed ($hashFailures.Count -eq 0) -Failure ($hashFailures -join '; ')

$license = [System.IO.File]::ReadAllText((Join-Path $package 'LICENSE'))
$notices = [System.IO.File]::ReadAllText((Join-Path $package 'THIRD_PARTY_NOTICES.md'))
$provenance = [System.IO.File]::ReadAllText((Join-Path $package 'docs/PROVENANCE.md'))
Add-Check -Name 'project_license_present' -Passed ($license.Contains('MIT License') -and $license.Contains('Codex Engineering Workflow contributors')) -Failure 'Project MIT license or holder is missing.'
Add-Check -Name 'upstream_notices_present' -Passed ($notices.Contains('Copyright (c) 2026 Affaan Mustafa') -and $notices.Contains('Copyright (c) 2025 Jesse Vincent') -and $notices.Contains('Copyright (c) 2026 Supabase') -and $notices.Contains('OpenAI Skills')) -Failure 'Required upstream notices are missing.'
$externalSkills = @('intent-driven-development', 'verification-before-completion', 'tdd-workflow', 'systematic-debugging', 'database-migrations', 'react-patterns', 'error-handling', 'api-design', 'contract-first', 'backend-patterns', 'supabase-postgres-best-practices', 'react-testing', 'security-best-practices', 'react-native-patterns')
Add-Check -Name 'external_skills_attributed' -Passed (@($externalSkills | Where-Object { -not $notices.Contains($_) }).Count -eq 0) -Failure 'One or more redistributed skills are absent from THIRD_PARTY_NOTICES.md.'
Add-Check -Name 'all_skills_in_provenance' -Passed (@($bundled | Where-Object { -not $provenance.Contains($_) }).Count -eq 0) -Failure 'One or more bundled skills are absent from PROVENANCE.md.'

$contributing = [System.IO.File]::ReadAllText((Join-Path $package 'CONTRIBUTING.md'))
$securityPolicy = [System.IO.File]::ReadAllText((Join-Path $package 'SECURITY.md'))
$changelog = [System.IO.File]::ReadAllText((Join-Path $package 'CHANGELOG.md'))
$attributes = [System.IO.File]::ReadAllText((Join-Path $package '.gitattributes'))
Add-Check -Name 'public_community_files_complete' -Passed ($contributing.Contains('Update-DistributionLock.ps1') -and $securityPolicy.Contains('private vulnerability reporting') -and $changelog.Contains('## Unreleased')) -Failure 'A public community document is missing its required contract.'
Add-Check -Name 'git_preserves_locked_line_endings' -Passed ($attributes -match '(?m)^\*\.ps1 text eol=lf$' -and $attributes -match '(?m)^\*\.json text eol=lf$') -Failure '.gitattributes does not preserve LF endings for locked scripts and manifests.'

$gitignore = [System.IO.File]::ReadAllText((Join-Path $package '.gitignore'))
Add-Check -Name 'python_cache_ignored' -Passed ($gitignore.Contains('__pycache__/') -and $gitignore.Contains('*.py[cod]')) -Failure 'Python runtime caches are not ignored.'
Add-Check -Name 'local_backups_ignored' -Passed ($gitignore -match '(?m)^\.local-backups/$') -Failure '.local-backups/ is not ignored.'

$scanFiles = @(Get-ChildItem -LiteralPath $package -File -Recurse -Force | Where-Object {
    $relative = Get-RelativePath -BasePath $package -FullPath $_.FullName
    $relative -notmatch '(^|/)\.git(/|$)' -and
    $relative -notmatch '(^|/)\.local-backups(/|$)' -and
    $relative -notmatch '(^|/)__pycache__(/|$)' -and
    $relative -notmatch '\.py[cod]$'
})
$privacyPatterns = @(
    ('est' + 'eb'),
    ('agentic-engineering-' + 'orchestrator'),
    ('installation-' + 'backups'),
    ('prompt-maestro-cierre-' + 'definitivo')
)
$credentialPatterns = @(
    ('sk-' + 'proj-[A-Za-z0-9_-]{20,}'),
    ('AIza' + '[A-Za-z0-9_-]{20,}'),
    ('gh' + '[pousr]_[A-Za-z0-9]{20,}'),
    ('-----BEGIN ' + '(RSA |EC |OPENSSH )?PRIVATE KEY-----')
)
$privacyHits = New-Object System.Collections.Generic.List[string]
$credentialHits = New-Object System.Collections.Generic.List[string]
foreach ($file in $scanFiles) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    foreach ($pattern in $privacyPatterns) {
        if ($content -match $pattern) { $privacyHits.Add((Get-RelativePath -BasePath $package -FullPath $file.FullName)); break }
    }
    foreach ($pattern in $credentialPatterns) {
        if ($content -match $pattern) { $credentialHits.Add((Get-RelativePath -BasePath $package -FullPath $file.FullName)); break }
    }
}
Add-Check -Name 'privacy_scan_clear' -Passed ($privacyHits.Count -eq 0) -Failure ("Private markers found in: " + (($privacyHits | Select-Object -Unique) -join ', '))
Add-Check -Name 'credential_scan_clear' -Passed ($credentialHits.Count -eq 0) -Failure ("Credential patterns found in: " + (($credentialHits | Select-Object -Unique) -join ', '))

$status = if ($failures.Count -eq 0) { 'PASS' } else { 'FAIL' }
[pscustomobject]@{
    status = $status
    checks = $checks
    bundled_skill_count = $bundled.Count
    system_capability_count = $systemProvided.Count
    optional_capability_count = $optional.Count
    pending_adaptation_count = $pending.Count
    manifested_file_count = $manifested.Count
    failures = @($failures)
} | ConvertTo-Json -Depth 8

if ($status -ne 'PASS') { exit 1 }
