[CmdletBinding()]
param(
    [string]$PackageRoot = '',
    [string]$WorkRoot = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($PackageRoot)) {
    $PackageRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
}

$package = [System.IO.Path]::GetFullPath($PackageRoot)
$expectedSkillCount = @(Get-ChildItem -LiteralPath (Join-Path $package 'skills') -Directory).Count
if ([string]::IsNullOrWhiteSpace($WorkRoot)) {
    $WorkRoot = Join-Path ([System.IO.Path]::GetTempPath()) 'codex-engineering-workflow-tests'
}
$work = [System.IO.Path]::GetFullPath($WorkRoot).TrimEnd('\', '/')
$fixture = Join-Path $work ('step8-install-fixture-' + [guid]::NewGuid().ToString('N'))
$fixtureFull = [System.IO.Path]::GetFullPath($fixture)
$workPrefix = $work + [System.IO.Path]::DirectorySeparatorChar
if (-not $fixtureFull.StartsWith($workPrefix, [System.StringComparison]::OrdinalIgnoreCase)) { throw 'UNSAFE_FIXTURE_PATH' }

$fakeCodex = Join-Path $fixture '.codex'
$fakeSkills = Join-Path $fixture '.agents\skills'
$fakeBackups = Join-Path $fixture 'backups'
$installScript = Join-Path $package 'scripts\Install-CodexDesktopWorkflow.ps1'
$restoreScript = Join-Path $package 'scripts\Restore-CodexDesktopWorkflow.ps1'
$utf8 = New-Object System.Text.UTF8Encoding($false)

New-Item -ItemType Directory -Path $fakeCodex -Force | Out-Null
New-Item -ItemType Directory -Path $fakeSkills -Force | Out-Null
[System.IO.File]::WriteAllText((Join-Path $fakeCodex 'AGENTS.md'), '', $utf8)
$fakeImagegen = Join-Path $fakeCodex 'skills\.system\imagegen\SKILL.md'
New-Item -ItemType Directory -Path (Split-Path -Parent $fakeImagegen) -Force | Out-Null
[System.IO.File]::WriteAllText($fakeImagegen, "---`nname: imagegen`ndescription: fixture`n---`n", $utf8)
$optionalMarker = Join-Path $fakeSkills 'make-interfaces-feel-better\SKILL.md'
New-Item -ItemType Directory -Path (Split-Path -Parent $optionalMarker) -Force | Out-Null
[System.IO.File]::WriteAllText($optionalMarker, 'pre-existing optional capability', $utf8)
$optionalHash = (Get-FileHash -LiteralPath $optionalMarker -Algorithm SHA256).Hash

$dry = (& $installScript -PackageRoot $package -CodexConfigRoot $fakeCodex -PersonalSkillsRoot $fakeSkills -BackupStorageRoot $fakeBackups -DryRun) | ConvertFrom-Json
$installed = (& $installScript -PackageRoot $package -CodexConfigRoot $fakeCodex -PersonalSkillsRoot $fakeSkills -BackupStorageRoot $fakeBackups) | ConvertFrom-Json
$expectedSkillNames = @(Get-ChildItem -LiteralPath (Join-Path $package 'skills') -Directory | ForEach-Object { $_.Name })
$installedCount = @($expectedSkillNames | Where-Object { Test-Path -LiteralPath (Join-Path $fakeSkills $_) -PathType Container }).Count
$globalMatches = (Get-FileHash -LiteralPath (Join-Path $fakeCodex 'AGENTS.md') -Algorithm SHA256).Hash -eq (Get-FileHash -LiteralPath (Join-Path $package 'global\AGENTS.md') -Algorithm SHA256).Hash
$idempotentDry = (& $installScript -PackageRoot $package -CodexConfigRoot $fakeCodex -PersonalSkillsRoot $fakeSkills -BackupStorageRoot $fakeBackups -DryRun) | ConvertFrom-Json
$restored = (& $restoreScript -ManifestPath $installed.manifest) | ConvertFrom-Json
$rollbackEmptyGlobal = (Get-Item -LiteralPath (Join-Path $fakeCodex 'AGENTS.md')).Length -eq 0
$rollbackBundledSkillsRemoved = @($expectedSkillNames | Where-Object { Test-Path -LiteralPath (Join-Path $fakeSkills $_) }).Count -eq 0
$optionalPreserved = (Test-Path -LiteralPath $optionalMarker -PathType Leaf) -and ((Get-FileHash -LiteralPath $optionalMarker -Algorithm SHA256).Hash -eq $optionalHash)

[System.IO.File]::WriteAllText((Join-Path $fakeCodex 'AGENTS.md'), 'existing custom rules', $utf8)
$globalConflict = $false
try { $null = & $installScript -PackageRoot $package -CodexConfigRoot $fakeCodex -PersonalSkillsRoot $fakeSkills -BackupStorageRoot $fakeBackups -DryRun }
catch { $globalConflict = $_.Exception.Message -match 'GLOBAL_AGENTS_CONFLICT' }
$globalConflictNoWrites = @($expectedSkillNames | Where-Object { Test-Path -LiteralPath (Join-Path $fakeSkills $_) }).Count -eq 0

[System.IO.File]::WriteAllText((Join-Path $fakeCodex 'AGENTS.md'), '', $utf8)
$conflictPath = Join-Path $fakeSkills 'tdd-workflow'
New-Item -ItemType Directory -Path $conflictPath -Force | Out-Null
$skillConflict = $false
try { $null = & $installScript -PackageRoot $package -CodexConfigRoot $fakeCodex -PersonalSkillsRoot $fakeSkills -BackupStorageRoot $fakeBackups -DryRun }
catch { $skillConflict = $_.Exception.Message -match 'SKILL_TARGET_CONFLICT' }
[System.IO.Directory]::Delete($conflictPath, $true)

$installedAgain = (& $installScript -PackageRoot $package -CodexConfigRoot $fakeCodex -PersonalSkillsRoot $fakeSkills -BackupStorageRoot $fakeBackups) | ConvertFrom-Json
$tampered = Join-Path $fakeSkills 'tdd-workflow\SKILL.md'
[System.IO.File]::AppendAllText($tampered, "`nmanual change", $utf8)
$tamperRefused = $false
try { $null = & $restoreScript -ManifestPath $installedAgain.manifest }
catch { $tamperRefused = $_.Exception.Message -match 'INSTALLED_SKILL_MODIFIED' }
$tamperPreserved = [System.IO.File]::ReadAllText($tampered).Contains('manual change')
Copy-Item -LiteralPath (Join-Path $package 'skills\tdd-workflow\SKILL.md') -Destination $tampered -Force
$restoredAgain = (& $restoreScript -ManifestPath $installedAgain.manifest) | ConvertFrom-Json
$finalStateRestored = ((Get-Item -LiteralPath (Join-Path $fakeCodex 'AGENTS.md')).Length -eq 0) -and (@($expectedSkillNames | Where-Object { Test-Path -LiteralPath (Join-Path $fakeSkills $_) }).Count -eq 0) -and (Test-Path -LiteralPath $optionalMarker -PathType Leaf)

$tamperedPackage = Join-Path $fixture 'tampered-package'
New-Item -ItemType Directory -Path $tamperedPackage -Force | Out-Null
foreach ($item in @(Get-ChildItem -LiteralPath $package -Force | Where-Object { $_.Name -notin @('.git', '.local-backups', 'work', 'tmp') })) {
    Copy-Item -LiteralPath $item.FullName -Destination $tamperedPackage -Recurse
}
[System.IO.File]::AppendAllText((Join-Path $tamperedPackage 'skills\tdd-workflow\SKILL.md'), "`ntampered", $utf8)
$integrityFailure = $false
try { $null = & (Join-Path $tamperedPackage 'scripts\Install-CodexDesktopWorkflow.ps1') -PackageRoot $tamperedPackage -CodexConfigRoot (Join-Path $fixture 'integrity-codex') -PersonalSkillsRoot (Join-Path $fixture 'integrity-skills') -BackupStorageRoot (Join-Path $fixture 'integrity-backups') -DryRun }
catch { $integrityFailure = $_.Exception.Message -match 'PACKAGE_HASH_MISMATCH' }
$integrityFailureNoWrites = (-not (Test-Path -LiteralPath (Join-Path $fixture 'integrity-skills'))) -and (-not (Test-Path -LiteralPath (Join-Path $fixture 'integrity-codex')))

$checks = [ordered]@{
    fixture_path_legacy_safe = ((Join-Path $fakeSkills 'engineering-task-workflow\references\risk-and-approvals.md').Length -lt 260)
    dry_run_pass = ($dry.status -eq 'DRY_RUN_PASS')
    dry_run_verifies_package = ($dry.package_integrity -eq 'PASS')
    dry_run_reports_twenty_one_skills = (@($dry.skills_to_install).Count -eq $expectedSkillCount)
    dry_run_detects_system_imagegen = (@($dry.system_capabilities | Where-Object { $_.name -eq 'imagegen' -and $_.state -eq 'DETECTED' }).Count -eq 1)
    dry_run_detects_optional_capability = (@($dry.optional_capabilities_available) -contains 'make-interfaces-feel-better')
    installation_pass = ($installed.status -eq 'PASS')
    manifest_version_two = ((Get-Content -LiteralPath $installed.manifest -Raw | ConvertFrom-Json).manifest_version -eq 2)
    all_packaged_skills_installed = ($installedCount -eq $expectedSkillCount)
    global_hash_matches = $globalMatches
    idempotent_dry_run_pass = ($idempotentDry.status -eq 'DRY_RUN_PASS')
    idempotent_dry_run_skips_identical_skills = (@($idempotentDry.skills_to_install).Count -eq 0 -and @($idempotentDry.skills_already_present).Count -eq $expectedSkillCount)
    idempotent_dry_run_preserves_identical_global = ($idempotentDry.global_existing_state -eq 'ALREADY_PRESENT_IDENTICAL')
    rollback_pass = ($restored.status -eq 'PASS')
    rollback_restores_empty_global = $rollbackEmptyGlobal
    rollback_removes_installed_skills = $rollbackBundledSkillsRemoved
    rollback_preserves_optional_capability = $optionalPreserved
    global_conflict_rejected_before_write = ($globalConflict -and $globalConflictNoWrites)
    skill_conflict_rejected = $skillConflict
    modified_installation_refuses_rollback = $tamperRefused
    modified_file_preserved = $tamperPreserved
    cleanup_rollback_pass = ($restoredAgain.status -eq 'PASS')
    fixture_final_state_restored = $finalStateRestored
    tampered_package_rejected_before_write = ($integrityFailure -and $integrityFailureNoWrites)
}

$status = if ($checks.Values -contains $false) { 'FAIL' } else { 'PASS' }
[System.IO.Directory]::Delete($fixture, $true)

$result = [pscustomobject]@{
    status = $status
    checks = $checks
    fixture_removed = -not (Test-Path -LiteralPath $fixture)
}
$result | ConvertTo-Json -Depth 5

if ($status -ne 'PASS') { exit 1 }
