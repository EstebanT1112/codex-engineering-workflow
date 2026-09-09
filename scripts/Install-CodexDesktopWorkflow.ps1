[CmdletBinding()]
param(
    [string]$PackageRoot = '',
    [string]$CodexConfigRoot = (Join-Path $env:USERPROFILE '.codex'),
    [string]$PersonalSkillsRoot = (Join-Path $env:USERPROFILE '.agents\skills'),
    [string]$BackupStorageRoot = '',
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($PackageRoot)) {
    $PackageRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
}

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

function Write-Utf8NoBom([string]$Path, [string]$Content) {
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $encoding)
}

function Get-RelativeFileInventory([string]$Directory) {
    $base = (Get-FullPath $Directory) + [System.IO.Path]::DirectorySeparatorChar
    return @(
        Get-ChildItem -LiteralPath $Directory -Recurse -File | Sort-Object FullName | ForEach-Object {
            [pscustomobject]@{
                path = $_.FullName.Substring($base.Length).Replace('\', '/')
                bytes = $_.Length
                sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
            }
        }
    )
}

function Test-DirectoryExact([string]$Left, [string]$Right) {
    $leftFiles = @(Get-RelativeFileInventory $Left)
    $rightFiles = @(Get-RelativeFileInventory $Right)
    if ($leftFiles.Count -ne $rightFiles.Count) { return $false }
    for ($index = 0; $index -lt $leftFiles.Count; $index++) {
        if ($leftFiles[$index].path -ne $rightFiles[$index].path -or
            $leftFiles[$index].bytes -ne $rightFiles[$index].bytes -or
            $leftFiles[$index].sha256 -ne $rightFiles[$index].sha256) {
            return $false
        }
    }
    return $true
}

function Get-RelativePath([string]$BasePath, [string]$FullPath) {
    $baseUri = New-Object System.Uri(($BasePath.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar))
    $fileUri = New-Object System.Uri($FullPath)
    return [System.Uri]::UnescapeDataString($baseUri.MakeRelativeUri($fileUri).ToString()).Replace('\', '/')
}

function Test-PackageIntegrity([string]$Root) {
    $capabilityPath = Join-Path $Root 'manifests\capabilities.json'
    $catalogPath = Join-Path $Root 'manifests\skill-catalog.json'
    $lockPath = Join-Path $Root 'manifests\distribution.lock.json'
    foreach ($required in @($capabilityPath, $catalogPath, $lockPath)) {
        if (-not (Test-Path -LiteralPath $required -PathType Leaf)) { throw "PACKAGE_MANIFEST_MISSING: $required" }
    }

    try {
        $capabilities = Get-Content -LiteralPath $capabilityPath -Raw -Encoding UTF8 | ConvertFrom-Json
        $catalog = Get-Content -LiteralPath $catalogPath -Raw -Encoding UTF8 | ConvertFrom-Json
        $lock = Get-Content -LiteralPath $lockPath -Raw -Encoding UTF8 | ConvertFrom-Json
    }
    catch { throw "PACKAGE_MANIFEST_INVALID: $($_.Exception.Message)" }

    if ($capabilities.schema_version -ne 3 -or $catalog.schema_version -ne 1 -or $lock.schema_version -ne 3) {
        throw 'PACKAGE_SCHEMA_UNSUPPORTED'
    }

    $declaredSkills = @($capabilities.bundled_core + $capabilities.bundled_standard | ForEach-Object { [string]$_ } | Sort-Object)
    $folderSkills = @(Get-ChildItem -LiteralPath (Join-Path $Root 'skills') -Directory | ForEach-Object { $_.Name } | Sort-Object)
    $lockedSkills = @($lock.skills | ForEach-Object { [string]$_.name } | Sort-Object)
    if (@(Compare-Object $declaredSkills $folderSkills).Count -ne 0 -or @(Compare-Object $declaredSkills $lockedSkills).Count -ne 0) {
        throw 'PACKAGE_SKILL_SET_MISMATCH'
    }

    $declaredCapabilities = @($capabilities.bundled_core + $capabilities.bundled_standard + $capabilities.system_provided + $capabilities.optional_if_available | ForEach-Object { [string]$_ } | Sort-Object)
    $catalogCapabilities = @($catalog.capabilities | ForEach-Object { [string]$_.name } | Sort-Object)
    if (@(Compare-Object $declaredCapabilities $catalogCapabilities).Count -ne 0) { throw 'PACKAGE_CATALOG_MISMATCH' }

    $manifested = @($lock.files | ForEach-Object { [string]$_.path } | Sort-Object)
    $actual = @(Get-ChildItem -LiteralPath $Root -File -Recurse -Force | Where-Object {
        $relative = Get-RelativePath $Root $_.FullName
        $relative -ne 'manifests/distribution.lock.json' -and
        $relative -notmatch '(^|/)\.local-backups(/|$)' -and
        $relative -notmatch '(^|/)\.git(/|$)' -and
        $relative -notmatch '(^|/)__pycache__(/|$)' -and
        $relative -notmatch '\.py[cod]$' -and
        $relative -notmatch '^(work|tmp)/' -and
        $relative -notmatch '\.log$'
    } | ForEach-Object { Get-RelativePath $Root $_.FullName } | Sort-Object)
    if (@(Compare-Object $manifested $actual).Count -ne 0) { throw 'PACKAGE_FILE_SET_MISMATCH' }

    foreach ($entry in @($lock.files)) {
        $path = Join-Path $Root ([string]$entry.path)
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "PACKAGE_FILE_MISSING: $($entry.path)" }
        $file = Get-Item -LiteralPath $path
        $hash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($file.Length -ne [long]$entry.bytes -or $hash -ne ([string]$entry.sha256).ToLowerInvariant()) {
            throw "PACKAGE_HASH_MISMATCH: $($entry.path)"
        }
    }

    return [pscustomobject]@{
        capabilities = $capabilities
        catalog = $catalog
        lock = $lock
        lock_sha256 = (Get-FileHash -LiteralPath $lockPath -Algorithm SHA256).Hash
    }
}

function Copy-DirectoryExact([string]$Source, [string]$Target) {
    New-Item -ItemType Directory -Path $Target -Force | Out-Null
    $sourceBase = (Get-FullPath $Source) + [System.IO.Path]::DirectorySeparatorChar
    foreach ($directory in Get-ChildItem -LiteralPath $Source -Recurse -Directory | Sort-Object FullName) {
        $relative = $directory.FullName.Substring($sourceBase.Length)
        New-Item -ItemType Directory -Path (Join-Path $Target $relative) -Force | Out-Null
    }
    foreach ($file in Get-ChildItem -LiteralPath $Source -Recurse -File | Sort-Object FullName) {
        $relative = $file.FullName.Substring($sourceBase.Length)
        $destination = Join-Path $Target $relative
        $parent = Split-Path -Parent $destination
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
        Copy-Item -LiteralPath $file.FullName -Destination $destination
    }
}

function Remove-SafeDirectory([string]$Path, [string]$AllowedRoot) {
    Assert-ChildPath $Path $AllowedRoot
    if (Test-Path -LiteralPath $Path) {
        Remove-Item -LiteralPath $Path -Recurse -Force
    }
}

$package = Get-FullPath $PackageRoot
$codexRoot = Get-FullPath $CodexConfigRoot
$skillsRoot = Get-FullPath $PersonalSkillsRoot
$backupStorage = if ([string]::IsNullOrWhiteSpace($BackupStorageRoot)) {
    Get-FullPath (Join-Path $package '.local-backups')
} else {
    Get-FullPath $BackupStorageRoot
}
$sourceGlobal = Join-Path $package 'global\AGENTS.md'
$sourceSkills = Join-Path $package 'skills'
$targetGlobal = Join-Path $codexRoot 'AGENTS.md'

if (-not (Test-Path -LiteralPath $sourceGlobal -PathType Leaf)) { throw 'SOURCE_GLOBAL_MISSING' }
if (-not (Test-Path -LiteralPath $sourceSkills -PathType Container)) { throw 'SOURCE_SKILLS_MISSING' }

$integrity = Test-PackageIntegrity $package
$capabilities = $integrity.capabilities

$skillSources = @(Get-ChildItem -LiteralPath $sourceSkills -Directory | Sort-Object Name)
if ($skillSources.Count -eq 0) { throw 'NO_STAGED_SKILLS' }

$globalExisted = Test-Path -LiteralPath $targetGlobal -PathType Leaf
$globalIdentical = $false
if ($globalExisted) {
    $currentGlobal = [System.IO.File]::ReadAllText($targetGlobal)
    $sourceGlobalContent = [System.IO.File]::ReadAllText($sourceGlobal)
    $globalIdentical = $currentGlobal -eq $sourceGlobalContent
    if ($currentGlobal.Length -gt 0 -and $currentGlobal -ne $sourceGlobalContent) {
        throw 'GLOBAL_AGENTS_CONFLICT'
    }
}

$targets = @()
$alreadyPresentSkills = @()
foreach ($source in $skillSources) {
    $target = Join-Path $skillsRoot $source.Name
    Assert-ChildPath $target $skillsRoot
    if (Test-Path -LiteralPath $target) {
        if (-not (Test-Path -LiteralPath $target -PathType Container) -or -not (Test-DirectoryExact $source.FullName $target)) {
            throw "SKILL_TARGET_CONFLICT: $($source.Name)"
        }
        $alreadyPresentSkills += $source.Name
    }
    else {
        $targets += [pscustomobject]@{ name = $source.Name; source = $source.FullName; target = $target }
    }
}

$optionalAvailable = @($capabilities.optional_if_available | Where-Object { Test-Path -LiteralPath (Join-Path $skillsRoot ([string]$_)) -PathType Container } | ForEach-Object { [string]$_ })
$optionalMissing = @($capabilities.optional_if_available | Where-Object { $optionalAvailable -notcontains [string]$_ } | ForEach-Object { [string]$_ })
$systemCapabilities = @($capabilities.system_provided | ForEach-Object {
    $name = [string]$_
    $systemPath = Join-Path $codexRoot ("skills\.system\$name\SKILL.md")
    [pscustomobject]@{
        name = $name
        state = if (Test-Path -LiteralPath $systemPath -PathType Leaf) { 'DETECTED' } else { 'MANAGED_BY_CODEX_DESKTOP_NOT_DETECTED_AT_STANDARD_PATH' }
        path = if (Test-Path -LiteralPath $systemPath -PathType Leaf) { $systemPath } else { $null }
    }
})

$plan = [pscustomobject]@{
    status = if ($DryRun) { 'DRY_RUN_PASS' } else { 'READY' }
    package_integrity = 'PASS'
    distribution_version = $integrity.lock.distribution_version
    global_target = $targetGlobal
    global_existing_state = if ($globalIdentical) { 'ALREADY_PRESENT_IDENTICAL' } elseif ($globalExisted) { 'EXISTS_SAFE_TO_BACKUP' } else { 'ABSENT' }
    skill_targets = @($targets | ForEach-Object { $_.target })
    skills_to_install = @($targets | ForEach-Object { $_.name })
    skills_already_present = @($alreadyPresentSkills)
    system_capabilities = @($systemCapabilities)
    optional_capabilities_available = @($optionalAvailable)
    optional_capabilities_missing = @($optionalMissing)
}
if ($DryRun) {
    $plan | ConvertTo-Json -Depth 5
    return
}

$installId = (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssfffZ')
$backupRoot = Join-Path $backupStorage $installId
Assert-ChildPath $backupRoot $backupStorage
$backupGlobal = Join-Path $backupRoot 'AGENTS.md.before'
$manifestPath = Join-Path $backupRoot 'install-manifest.json'
$createdSkillTargets = New-Object System.Collections.Generic.List[string]
$globalWritten = $false

try {
    New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
    if (-not $globalIdentical) {
        if ($globalExisted) { Copy-Item -LiteralPath $targetGlobal -Destination $backupGlobal }
        New-Item -ItemType Directory -Path $codexRoot -Force | Out-Null
        Copy-Item -LiteralPath $sourceGlobal -Destination $targetGlobal -Force
        $globalWritten = $true
    }

    New-Item -ItemType Directory -Path $skillsRoot -Force | Out-Null
    $installedSkills = @()
    foreach ($entry in $targets) {
        $createdSkillTargets.Add($entry.target)
        Copy-DirectoryExact $entry.source $entry.target
        $installedSkills += [pscustomobject]@{
            name = $entry.name
            target = $entry.target
            files = @(Get-RelativeFileInventory $entry.target)
        }
    }

    $manifest = [ordered]@{
        manifest_version = 2
        installation_id = $installId
        installed_at_utc = (Get-Date).ToUniversalTime().ToString('o')
        distribution_version = $integrity.lock.distribution_version
        distribution_lock_sha256 = $integrity.lock_sha256
        package_root = $package
        codex_config_root = $codexRoot
        personal_skills_root = $skillsRoot
        backup_storage_root = $backupStorage
        global = [ordered]@{
            target = $targetGlobal
            existed_before = $globalExisted
            changed_by_install = $globalWritten
            backup = if ($globalWritten -and $globalExisted) { $backupGlobal } else { $null }
            installed_sha256 = (Get-FileHash -LiteralPath $targetGlobal -Algorithm SHA256).Hash
        }
        skills = $installedSkills
        skills_already_present = @($alreadyPresentSkills)
        system_capabilities = @($systemCapabilities)
        optional_capabilities_available = @($optionalAvailable)
    }
    Write-Utf8NoBom $manifestPath ($manifest | ConvertTo-Json -Depth 8)

    [pscustomobject]@{
        status = 'PASS'
        installation_id = $installId
        manifest = $manifestPath
        global_target = $targetGlobal
        skills_installed = @($installedSkills | ForEach-Object { $_.name })
        skills_already_present = @($alreadyPresentSkills)
        system_capabilities = @($systemCapabilities)
        optional_capabilities_available = @($optionalAvailable)
        optional_capabilities_missing = @($optionalMissing)
        restart_required_for_discovery = $true
    } | ConvertTo-Json -Depth 5
}
catch {
    foreach ($created in $createdSkillTargets) { Remove-SafeDirectory $created $skillsRoot }
    if ($globalWritten) {
        if ($globalExisted -and (Test-Path -LiteralPath $backupGlobal -PathType Leaf)) {
            Copy-Item -LiteralPath $backupGlobal -Destination $targetGlobal -Force
        }
        elseif (Test-Path -LiteralPath $targetGlobal -PathType Leaf) {
            Assert-ChildPath $targetGlobal $codexRoot
            Remove-Item -LiteralPath $targetGlobal -Force
        }
    }
    try { Remove-SafeDirectory $backupRoot $backupStorage } catch { }
    throw
}
