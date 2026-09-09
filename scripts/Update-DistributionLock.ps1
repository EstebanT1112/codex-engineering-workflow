[CmdletBinding()]
param(
    [string]$PackageRoot = '',
    [string]$OutputPath = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($PackageRoot)) {
    $PackageRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
}

function Get-FullPath([string]$Path) {
    return [System.IO.Path]::GetFullPath($Path).TrimEnd('\', '/')
}

function Get-RelativePath([string]$BasePath, [string]$FullPath) {
    $baseUri = New-Object System.Uri(($BasePath.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar))
    $fileUri = New-Object System.Uri($FullPath)
    return [System.Uri]::UnescapeDataString($baseUri.MakeRelativeUri($fileUri).ToString()).Replace('\', '/')
}

function New-FileEntry([string]$Path, [string]$RelativeTo) {
    $file = Get-Item -LiteralPath $Path
    return [ordered]@{
        path = Get-RelativePath $RelativeTo $file.FullName
        bytes = [long]$file.Length
        sha256 = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    }
}

function Write-Utf8NoBom([string]$Path, [string]$Content) {
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $encoding)
}

$package = Get-FullPath $PackageRoot
$output = if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    Join-Path $package 'manifests\distribution.lock.json'
} else {
    [System.IO.Path]::GetFullPath($OutputPath)
}
$provenancePath = Join-Path $package 'manifests\provenance.json'
$capabilitiesPath = Join-Path $package 'manifests\capabilities.json'

foreach ($required in @($provenancePath, $capabilitiesPath, (Join-Path $package 'LICENSE'), (Join-Path $package 'THIRD_PARTY_NOTICES.md'))) {
    if (-not (Test-Path -LiteralPath $required -PathType Leaf)) { throw "LOCK_INPUT_MISSING: $required" }
}

try {
    $provenance = Get-Content -LiteralPath $provenancePath -Raw -Encoding UTF8 | ConvertFrom-Json
    $capabilities = Get-Content -LiteralPath $capabilitiesPath -Raw -Encoding UTF8 | ConvertFrom-Json
}
catch { throw "LOCK_INPUT_INVALID: $($_.Exception.Message)" }

if ($provenance.schema_version -ne 1 -or $capabilities.schema_version -ne 3) { throw 'LOCK_INPUT_SCHEMA_UNSUPPORTED' }

$sourceById = @{}
foreach ($source in @($provenance.sources)) {
    $id = [string]$source.id
    if ([string]::IsNullOrWhiteSpace($id) -or $sourceById.ContainsKey($id)) { throw "PROVENANCE_SOURCE_ID_INVALID: $id" }
    $licensePath = Join-Path $package ([string]$source.license_file)
    if (-not (Test-Path -LiteralPath $licensePath -PathType Leaf)) { throw "PROVENANCE_LICENSE_MISSING: $($source.license_file)" }
    $sourceById[$id] = $source
}

$declaredSkills = @($capabilities.bundled_core + $capabilities.bundled_standard | ForEach-Object { [string]$_ } | Sort-Object)
$provenanceSkills = @($provenance.skills | ForEach-Object { [string]$_.name } | Sort-Object)
$folderSkills = @(Get-ChildItem -LiteralPath (Join-Path $package 'skills') -Directory | ForEach-Object { $_.Name } | Sort-Object)
if (@(Compare-Object $declaredSkills $provenanceSkills).Count -ne 0 -or @(Compare-Object $declaredSkills $folderSkills).Count -ne 0) {
    throw 'PROVENANCE_SKILL_SET_MISMATCH'
}

$skillEntries = @()
foreach ($skill in @($provenance.skills | Sort-Object name)) {
    $name = [string]$skill.name
    $skillRoot = Join-Path $package ("skills\$name")
    $sourceId = [string]$skill.source_id
    if ($sourceId -eq 'project') {
        $skillProvenance = [ordered]@{
            kind = [string]$skill.kind
            source_id = 'project'
            repository = $null
            path = $null
            commit_or_ref = $null
            license = [string]$provenance.distribution.license
            copyright = [string]$provenance.distribution.copyright
        }
    }
    else {
        if (-not $sourceById.ContainsKey($sourceId)) { throw "PROVENANCE_SOURCE_UNKNOWN: $name -> $sourceId" }
        $source = $sourceById[$sourceId]
        $skillProvenance = [ordered]@{
            kind = [string]$skill.kind
            source_id = $sourceId
            repository = [string]$source.repository
            path = if ($null -eq $skill.upstream_path) { $null } else { [string]$skill.upstream_path }
            commit_or_ref = [string]$source.commit_or_ref
            license = [string]$source.license
            copyright = if ($null -eq $source.copyright) { $null } else { [string]$source.copyright }
        }
    }
    $skillFiles = @(Get-ChildItem -LiteralPath $skillRoot -File -Recurse | Sort-Object FullName | ForEach-Object { New-FileEntry $_.FullName $skillRoot })
    $skillEntries += [ordered]@{ name = $name; provenance = $skillProvenance; files = $skillFiles }
}

$licenseEvidence = @($provenance.sources | ForEach-Object {
    [ordered]@{
        source_id = [string]$_.id
        repository = [string]$_.repository
        commit_or_ref = [string]$_.commit_or_ref
        license = [string]$_.license
        license_file = [string]$_.license_file
        copyright = if ($null -eq $_.copyright) { $null } else { [string]$_.copyright }
        license_url = [string]$_.license_url
    }
})

$payloadFiles = @(Get-ChildItem -LiteralPath $package -File -Recurse -Force | Where-Object {
    $relative = Get-RelativePath $package $_.FullName
    $relative -ne 'manifests/distribution.lock.json' -and
    $relative -notmatch '(^|/)\.local-backups(/|$)' -and
    $relative -notmatch '(^|/)\.git(/|$)' -and
    $relative -notmatch '(^|/)__pycache__(/|$)' -and
    $relative -notmatch '\.py[cod]$' -and
    $relative -notmatch '^(work|tmp)/' -and
    $relative -notmatch '\.log$'
} | Sort-Object FullName | ForEach-Object { New-FileEntry $_.FullName $package })

$lock = [ordered]@{
    schema_version = 3
    distribution_version = [string]$provenance.distribution.version
    created_at = [string]$provenance.distribution.created_at
    publication_status = [string]$provenance.distribution.publication_status
    contains_personal_installation_state = $false
    project_license = [ordered]@{
        spdx = [string]$provenance.distribution.license
        file = [string]$provenance.distribution.license_file
        copyright = [string]$provenance.distribution.copyright
    }
    provenance_manifest = 'manifests/provenance.json'
    third_party_notice = [string]$provenance.notice_file
    license_evidence = $licenseEvidence
    global_contract = 'global/AGENTS.md'
    capability_manifest = 'manifests/capabilities.json'
    routing_catalog = [string]$capabilities.catalog_manifest
    system_capabilities = @($provenance.system_capabilities)
    skills = $skillEntries
    files = $payloadFiles
}

$parent = Split-Path -Parent $output
if (-not (Test-Path -LiteralPath $parent -PathType Container)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
Write-Utf8NoBom $output (($lock | ConvertTo-Json -Depth 12 -Compress) + "`n")

[pscustomobject]@{
    status = 'PASS'
    output = $output
    distribution_version = $lock.distribution_version
    skill_count = $skillEntries.Count
    source_count = $licenseEvidence.Count
    file_count = $payloadFiles.Count
    sha256 = (Get-FileHash -LiteralPath $output -Algorithm SHA256).Hash.ToLowerInvariant()
} | ConvertTo-Json -Depth 5
