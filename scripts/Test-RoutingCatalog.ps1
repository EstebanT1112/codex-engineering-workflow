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
$capabilities = Get-Content -LiteralPath (Join-Path $package 'manifests/capabilities.json') -Raw | ConvertFrom-Json
$catalog = Get-Content -LiteralPath (Join-Path $package 'manifests/skill-catalog.json') -Raw | ConvertFrom-Json
$checks = [ordered]@{}
$failures = New-Object System.Collections.Generic.List[string]

function Add-Check {
    param([string]$Name, [bool]$Passed, [string]$Failure)
    $checks[$Name] = $Passed
    if (-not $Passed) { $failures.Add($Failure) }
}

function Test-SameSet {
    param([object[]]$Left, [object[]]$Right)
    return @(Compare-Object @($Left | Sort-Object) @($Right | Sort-Object)).Count -eq 0
}

$core = @($capabilities.bundled_core | ForEach-Object { [string]$_ })
$standard = @($capabilities.bundled_standard | ForEach-Object { [string]$_ })
$system = @($capabilities.system_provided | ForEach-Object { [string]$_ })
$optional = @($capabilities.optional_if_available | ForEach-Object { [string]$_ })
$declared = @($core + $standard + $system + $optional)
$entries = @($catalog.capabilities)
$catalogNames = @($entries | ForEach-Object { [string]$_.name })
$excluded = @($catalog.excluded_routes | ForEach-Object { [string]$_.name })

Add-Check 'schema_versions_supported' ($capabilities.schema_version -eq 3 -and $catalog.schema_version -eq 1) 'Unsupported catalog schema version.'
Add-Check 'catalog_path_declared' ($capabilities.catalog_manifest -eq 'manifests/skill-catalog.json') 'capabilities.json does not point to the routing catalog.'
Add-Check 'all_declared_capabilities_cataloged' (Test-SameSet $declared $catalogNames) 'Catalog entries do not exactly match declared capabilities.'
Add-Check 'thirty_five_capabilities_cataloged' ($entries.Count -eq 35) "Expected 35 catalog entries; found $($entries.Count)."
Add-Check 'catalog_names_unique' (@($catalogNames | Select-Object -Unique).Count -eq $catalogNames.Count) 'Duplicate capability names found.'
Add-Check 'excluded_names_unique' (@($excluded | Select-Object -Unique).Count -eq $excluded.Count) 'Duplicate excluded route names found.'
Add-Check 'excluded_disjoint_from_active' (@($excluded | Where-Object { $catalogNames -contains $_ }).Count -eq 0) 'An excluded route also appears in the active catalog.'

$validAvailability = @('BUNDLED_CORE', 'BUNDLED_STANDARD', 'SYSTEM_PROVIDED', 'OPTIONAL_IF_AVAILABLE')
$validClasses = @('CORE', 'STANDARD', 'ON_DEMAND', 'PROJECT_SPECIFIC')
$validStages = @('ANALYZE', 'PLAN', 'IMPLEMENT', 'REVIEW', 'VERIFY', 'DELIVER')
$entryFailures = New-Object System.Collections.Generic.List[string]
foreach ($entry in $entries) {
    $name = [string]$entry.name
    if ($validAvailability -notcontains [string]$entry.availability) { $entryFailures.Add("$name invalid availability") }
    if ($validClasses -notcontains [string]$entry.classification) { $entryFailures.Add("$name invalid classification") }
    if (@($entry.stages).Count -eq 0 -or @($entry.stages | Where-Object { $validStages -notcontains [string]$_ }).Count -gt 0) { $entryFailures.Add("$name invalid stages") }
    if ([string]::IsNullOrWhiteSpace([string]$entry.trigger)) { $entryFailures.Add("$name missing trigger") }
    if ([string]::IsNullOrWhiteSpace([string]$entry.guard)) { $entryFailures.Add("$name missing guard") }
    foreach ($companion in @($entry.companions)) {
        if ($catalogNames -notcontains [string]$companion) { $entryFailures.Add("$name unknown companion $companion") }
    }
}
Add-Check 'catalog_entries_well_formed' ($entryFailures.Count -eq 0) ($entryFailures -join '; ')

$availabilityFailures = New-Object System.Collections.Generic.List[string]
foreach ($entry in $entries) {
    $expected = if ($core -contains $entry.name) { 'BUNDLED_CORE' }
        elseif ($standard -contains $entry.name) { 'BUNDLED_STANDARD' }
        elseif ($system -contains $entry.name) { 'SYSTEM_PROVIDED' }
        elseif ($optional -contains $entry.name) { 'OPTIONAL_IF_AVAILABLE' }
        else { 'UNKNOWN' }
    if ($entry.availability -ne $expected) { $availabilityFailures.Add("$($entry.name): expected $expected") }
}
Add-Check 'availability_matches_capability_manifest' ($availabilityFailures.Count -eq 0) ($availabilityFailures -join '; ')

$overlapRules = @($catalog.overlap_rules)
$overlapIds = @($overlapRules | ForEach-Object { [string]$_.id })
Add-Check 'eight_overlap_rules_declared' ($overlapRules.Count -eq 8) "Expected 8 overlap rules; found $($overlapRules.Count)."
Add-Check 'overlap_rule_ids_unique' (@($overlapIds | Select-Object -Unique).Count -eq $overlapIds.Count) 'Duplicate overlap rule IDs found.'
Add-Check 'overlap_rules_nonempty' (@($overlapRules | Where-Object { [string]::IsNullOrWhiteSpace([string]$_.rule) }).Count -eq 0) 'An overlap rule is empty.'
Add-Check 'core_routing_invariants_present' (($catalogNames -contains 'engineering-task-workflow') -and ($catalogNames -contains 'verification-before-completion') -and ($catalogNames -contains 'systematic-debugging')) 'A core routing invariant is missing.'
Add-Check 'imagegen_is_system_provided' ((@($entries | Where-Object { $_.name -eq 'imagegen' -and $_.availability -eq 'SYSTEM_PROVIDED' }).Count) -eq 1) 'imagegen must be exactly one system-provided capability.'
Add-Check 'no_pending_adaptations' (@($capabilities.pending_adaptation).Count -eq 0) 'Pending adaptations remain.'

$status = if ($failures.Count -eq 0) { 'PASS' } else { 'FAIL' }
[pscustomobject]@{
    status = $status
    checks = $checks
    cataloged_capability_count = $entries.Count
    overlap_rule_count = $overlapRules.Count
    excluded_route_count = $excluded.Count
    failures = @($failures)
} | ConvertTo-Json -Depth 8

if ($status -ne 'PASS') { exit 1 }
