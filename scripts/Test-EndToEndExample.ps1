[CmdletBinding()]
param(
    [string]$PackageRoot = '',
    [string]$PythonExecutable = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($PackageRoot)) {
    $PackageRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
}

$package = [System.IO.Path]::GetFullPath($PackageRoot)
$example = Join-Path $package 'examples\order-status-filter'
$catalogPath = Join-Path $package 'manifests\skill-catalog.json'
$selectedCapabilities = @(
    'engineering-task-workflow',
    'tdd-workflow',
    'verification-before-completion'
)

foreach ($required in @(
    $catalogPath,
    (Join-Path $example 'AGENTS.md'),
    (Join-Path $example 'order_tracker\orders.py'),
    (Join-Path $example 'tests\test_orders.py')
)) {
    if (-not (Test-Path -LiteralPath $required -PathType Leaf)) {
        throw "E2E_FILE_MISSING: $required"
    }
}

$catalog = Get-Content -LiteralPath $catalogPath -Raw -Encoding UTF8 | ConvertFrom-Json
$catalogNames = @($catalog.capabilities | ForEach-Object { [string]$_.name })
$missingCapabilities = @($selectedCapabilities | Where-Object { $catalogNames -notcontains $_ })
if ($missingCapabilities.Count -gt 0) {
    throw "E2E_ROUTE_MISSING: $($missingCapabilities -join ', ')"
}

$pythonCommand = $null
$pythonPrefix = @()
if (-not [string]::IsNullOrWhiteSpace($PythonExecutable)) {
    if (-not (Test-Path -LiteralPath $PythonExecutable -PathType Leaf)) {
        throw "PYTHON_NOT_FOUND: $PythonExecutable"
    }
    $pythonCommand = [System.IO.Path]::GetFullPath($PythonExecutable)
}
else {
    $launcher = Get-Command py -ErrorAction SilentlyContinue
    if ($null -ne $launcher) {
        $pythonCommand = $launcher.Source
        $pythonPrefix = @('-3')
    }
    else {
        $launcher = Get-Command python -ErrorAction SilentlyContinue
        if ($null -ne $launcher) { $pythonCommand = $launcher.Source }
    }
}

if ([string]::IsNullOrWhiteSpace([string]$pythonCommand)) {
    throw 'PYTHON_NOT_FOUND: install Python 3.11 or newer, or pass -PythonExecutable.'
}

$arguments = @($pythonPrefix + @('-m', 'unittest', 'discover', '-s', 'tests', '-v'))
$captureId = [guid]::NewGuid().ToString('N')
$stdoutPath = Join-Path ([System.IO.Path]::GetTempPath()) ("codex-e2e-$captureId.stdout.log")
$stderrPath = Join-Path ([System.IO.Path]::GetTempPath()) ("codex-e2e-$captureId.stderr.log")
$previousBytecodeSetting = $env:PYTHONDONTWRITEBYTECODE
$env:PYTHONDONTWRITEBYTECODE = '1'
try {
    $process = Start-Process -FilePath $pythonCommand -ArgumentList $arguments -WorkingDirectory $example -Wait -PassThru -NoNewWindow -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath
    $testExitCode = $process.ExitCode
    $testOutput = @(
        if (Test-Path -LiteralPath $stdoutPath) { [System.IO.File]::ReadAllText($stdoutPath) }
        if (Test-Path -LiteralPath $stderrPath) { [System.IO.File]::ReadAllText($stderrPath) }
    ) -join ''
    $testOutput = $testOutput.Trim()
}
finally {
    $env:PYTHONDONTWRITEBYTECODE = $previousBytecodeSetting
    if (Test-Path -LiteralPath $stdoutPath) { [System.IO.File]::Delete($stdoutPath) }
    if (Test-Path -LiteralPath $stderrPath) { [System.IO.File]::Delete($stderrPath) }
}

$passedTests = @([regex]::Matches($testOutput, '(?m)^test_.+\.\.\. ok\s*$')).Count
$status = if ($testExitCode -eq 0 -and $passedTests -eq 4 -and $testOutput -match '(?m)^OK\s*$') { 'PASS' } else { 'FAIL' }

[pscustomobject]@{
    status = $status
    example = 'order-status-filter'
    task_type = 'FEATURE'
    risk = 'LOW'
    selected_capabilities = $selectedCapabilities
    route_valid = ($missingCapabilities.Count -eq 0)
    tests_passed = $passedTests
    test_exit_code = $testExitCode
    output = $testOutput
} | ConvertTo-Json -Depth 6

if ($status -ne 'PASS') { exit 1 }
