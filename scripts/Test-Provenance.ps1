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
$provenance = Get-Content -LiteralPath (Join-Path $package 'manifests\provenance.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$capabilities = Get-Content -LiteralPath (Join-Path $package 'manifests\capabilities.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$lockPath = Join-Path $package 'manifests\distribution.lock.json'
$lock = Get-Content -LiteralPath $lockPath -Raw -Encoding UTF8 | ConvertFrom-Json
$release = Get-Content -LiteralPath (Join-Path $package 'manifests\release.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$notices = [System.IO.File]::ReadAllText((Join-Path $package 'THIRD_PARTY_NOTICES.md'))
$documentation = [System.IO.File]::ReadAllText((Join-Path $package 'docs\PROVENANCE.md'))
$checks = [ordered]@{}
$failures = New-Object System.Collections.Generic.List[string]

function Add-Check([string]$Name, [bool]$Passed, [string]$Failure) {
    $checks[$Name] = $Passed
    if (-not $Passed) { $failures.Add($Failure) }
}

function Test-SameSet([object[]]$Left, [object[]]$Right) {
    return @(Compare-Object @($Left | Sort-Object) @($Right | Sort-Object)).Count -eq 0
}

$sources = @($provenance.sources)
$sourceIds = @($sources | ForEach-Object { [string]$_.id })
$skillRecords = @($provenance.skills)
$skillNames = @($skillRecords | ForEach-Object { [string]$_.name })
$declaredSkills = @($capabilities.bundled_core + $capabilities.bundled_standard | ForEach-Object { [string]$_ })

Add-Check 'schemas_supported' ($provenance.schema_version -eq 1 -and $lock.schema_version -eq 3 -and $release.schema_version -eq 1) 'Unsupported provenance, lock, or release schema.'
Add-Check 'release_metadata_consistent' (
    $release.name -eq $provenance.distribution.name -and
    $release.version -eq $provenance.distribution.version -and
    $release.version -eq $lock.distribution_version -and
    $release.tag -eq ('v' + $release.version) -and
    $release.release_date -match '^\d{4}-\d{2}-\d{2}$' -and
    $release.status -eq 'RELEASE_READY' -and
    $lock.publication_status -eq 'RELEASE_READY' -and
    $release.contents.bundled_skills -eq 21 -and
    $release.contents.system_capabilities -eq 1 -and
    $release.contents.optional_capabilities -eq 13
) 'Release manifest, provenance, and distribution lock differ.'
Add-Check 'four_pinned_sources' ($sources.Count -eq 4) "Expected 4 pinned sources; found $($sources.Count)."
Add-Check 'source_ids_unique' (@($sourceIds | Select-Object -Unique).Count -eq $sourceIds.Count) 'Duplicate provenance source IDs found.'
Add-Check 'all_bundled_skills_have_provenance' (Test-SameSet $declaredSkills $skillNames) 'Bundled skills and provenance skill records differ.'
Add-Check 'skill_provenance_names_unique' (@($skillNames | Select-Object -Unique).Count -eq $skillNames.Count) 'Duplicate skill provenance records found.'

$sourceFailures = New-Object System.Collections.Generic.List[string]
foreach ($source in $sources) {
    $licensePath = Join-Path $package ([string]$source.license_file)
    if ([string]$source.commit_or_ref -notmatch '^[0-9a-f]{40}$') { $sourceFailures.Add("$($source.id): ref is not a pinned commit") }
    if (-not (Test-Path -LiteralPath $licensePath -PathType Leaf)) {
        $sourceFailures.Add("$($source.id): license file missing")
        continue
    }
    $licenseText = [System.IO.File]::ReadAllText($licensePath)
    if ($source.license -eq 'MIT' -and -not $licenseText.Contains('MIT License')) { $sourceFailures.Add("$($source.id): MIT text missing") }
    if ($source.license -eq 'Apache-2.0' -and -not $licenseText.Contains('Apache License')) { $sourceFailures.Add("$($source.id): Apache text missing") }
    foreach ($value in @([string]$source.repository, [string]$source.commit_or_ref, [string]$source.license_file)) {
        if (-not $notices.Contains($value)) { $sourceFailures.Add("$($source.id): notice missing $value") }
    }
}
Add-Check 'source_licenses_and_notices_complete' ($sourceFailures.Count -eq 0) ($sourceFailures -join '; ')

$skillFailures = New-Object System.Collections.Generic.List[string]
$lockSkillByName = @{}
foreach ($item in @($lock.skills)) { $lockSkillByName[[string]$item.name] = $item }
foreach ($record in $skillRecords) {
    $name = [string]$record.name
    if (-not $lockSkillByName.ContainsKey($name)) { $skillFailures.Add("$name absent from lock"); continue }
    $locked = $lockSkillByName[$name].provenance
    if ([string]$locked.kind -ne [string]$record.kind -or [string]$locked.source_id -ne [string]$record.source_id) {
        $skillFailures.Add("$name lock relationship differs")
    }
    if (-not $documentation.Contains($name)) { $skillFailures.Add("$name absent from provenance documentation") }
    if ($record.source_id -ne 'project' -and $sourceIds -notcontains [string]$record.source_id) { $skillFailures.Add("$name references unknown source") }
}
Add-Check 'skill_relationships_match_lock_and_docs' ($skillFailures.Count -eq 0) ($skillFailures -join '; ')

$systemImagegen = @($provenance.system_capabilities | Where-Object { $_.name -eq 'imagegen' -and $_.redistributed -eq $false })
Add-Check 'imagegen_recorded_but_not_redistributed' ($systemImagegen.Count -eq 1) 'imagegen system provenance is missing or marked redistributed.'
Add-Check 'lock_points_to_provenance_manifest' ($lock.provenance_manifest -eq 'manifests/provenance.json') 'Lock does not point to provenance.json.'

$temporaryLock = Join-Path ([System.IO.Path]::GetTempPath()) ('codex-workflow-lock-' + [guid]::NewGuid().ToString('N') + '.json')
$lockBefore = (Get-FileHash -LiteralPath $lockPath -Algorithm SHA256).Hash
try {
    $regenerated = (& (Join-Path $package 'scripts\Update-DistributionLock.ps1') -PackageRoot $package -OutputPath $temporaryLock) | ConvertFrom-Json
    $deterministic = $regenerated.status -eq 'PASS' -and ((Get-FileHash -LiteralPath $temporaryLock -Algorithm SHA256).Hash -eq $lockBefore)
}
finally {
    if (Test-Path -LiteralPath $temporaryLock) { [System.IO.File]::Delete($temporaryLock) }
}
Add-Check 'lock_regeneration_is_deterministic' $deterministic 'Regenerated lock differs from the committed lock.'
Add-Check 'regeneration_does_not_modify_current_lock' ((Get-FileHash -LiteralPath $lockPath -Algorithm SHA256).Hash -eq $lockBefore) 'Regeneration test modified the current lock.'

$status = if ($failures.Count -eq 0) { 'PASS' } else { 'FAIL' }
[pscustomobject]@{
    status = $status
    checks = $checks
    source_count = $sources.Count
    skill_provenance_count = $skillRecords.Count
    failures = @($failures)
} | ConvertTo-Json -Depth 8

if ($status -ne 'PASS') { exit 1 }
