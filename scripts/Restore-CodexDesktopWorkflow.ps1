[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ManifestPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-FullPath([string]$Path) {
    return [System.IO.Path]::GetFullPath($Path).TrimEnd('\', '/')
}

function Assert-ChildPath([string]$Path, [string]$Root) {
    $fullPath = Get-FullPath $Path
    $fullRoot = Get-FullPath $Root
    $prefix = $fullRoot + [System.IO.Path]::DirectorySeparatorChar
    if (-not $fullPath.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "PATH_OUTSIDE_ALLOWED_ROOT: $fullPath"
    }
}

function Get-RelativeFileInventory([string]$Directory) {
    $base = (Get-FullPath $Directory) + [System.IO.Path]::DirectorySeparatorChar
    return @(
        Get-ChildItem -LiteralPath $Directory -Recurse -File | Sort-Object FullName | ForEach-Object {
            [pscustomobject]@{
                path = $_.FullName.Substring($base.Length).Replace('\', '/')
                sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
            }
        }
    )
}

$resolvedManifest = Get-FullPath $ManifestPath
if (-not (Test-Path -LiteralPath $resolvedManifest -PathType Leaf)) { throw 'INSTALL_MANIFEST_MISSING' }
$manifest = Get-Content -LiteralPath $resolvedManifest -Raw -Encoding UTF8 | ConvertFrom-Json
if (@(1, 2) -notcontains [int]$manifest.manifest_version) { throw 'UNSUPPORTED_INSTALL_MANIFEST' }
$manifestDirectory = Get-FullPath (Split-Path -Parent $resolvedManifest)

$codexRoot = Get-FullPath $manifest.codex_config_root
$skillsRoot = Get-FullPath $manifest.personal_skills_root
$globalTarget = Get-FullPath $manifest.global.target
Assert-ChildPath $globalTarget $codexRoot

$globalChangedByInstall = if ($manifest.manifest_version -eq 1) { $true } else { [bool]$manifest.global.changed_by_install }
if ($globalChangedByInstall) {
    if (-not (Test-Path -LiteralPath $globalTarget -PathType Leaf)) { throw 'INSTALLED_GLOBAL_MISSING' }
    if ((Get-FileHash -LiteralPath $globalTarget -Algorithm SHA256).Hash -ne $manifest.global.installed_sha256) {
        throw 'INSTALLED_GLOBAL_MODIFIED'
    }
}

foreach ($skill in $manifest.skills) {
    $target = Get-FullPath $skill.target
    Assert-ChildPath $target $skillsRoot
    if (-not (Test-Path -LiteralPath $target -PathType Container)) { throw "INSTALLED_SKILL_MISSING: $($skill.name)" }
    $actual = @(Get-RelativeFileInventory $target)
    $expected = @($skill.files)
    if ($actual.Count -ne $expected.Count) { throw "INSTALLED_SKILL_MODIFIED: $($skill.name)" }
    for ($index = 0; $index -lt $expected.Count; $index++) {
        if ($actual[$index].path -ne $expected[$index].path -or $actual[$index].sha256 -ne $expected[$index].sha256) {
            throw "INSTALLED_SKILL_MODIFIED: $($skill.name)"
        }
    }
}

foreach ($skill in $manifest.skills) {
    $target = Get-FullPath $skill.target
    Assert-ChildPath $target $skillsRoot
    Remove-Item -LiteralPath $target -Recurse -Force
}

if ($globalChangedByInstall) {
    if ($manifest.global.existed_before) {
        $backup = Get-FullPath $manifest.global.backup
        Assert-ChildPath $backup $manifestDirectory
        if (-not (Test-Path -LiteralPath $backup -PathType Leaf)) { throw 'GLOBAL_BACKUP_MISSING' }
        Copy-Item -LiteralPath $backup -Destination $globalTarget -Force
    }
    else {
        Remove-Item -LiteralPath $globalTarget -Force
    }
}

[pscustomobject]@{
    status = 'PASS'
    restored_installation_id = $manifest.installation_id
    global_restored_to = if (-not $globalChangedByInstall) { 'UNCHANGED_PREEXISTING' } elseif ($manifest.global.existed_before) { 'PREVIOUS_FILE' } else { 'ABSENT' }
    skills_removed = @($manifest.skills | ForEach-Object { $_.name })
} | ConvertTo-Json -Depth 5
