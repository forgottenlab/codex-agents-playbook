[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Run each validation script in a child PowerShell process.
# This guarantees that $LASTEXITCODE is defined by a native process.
$PowerShellExecutable = (Get-Process -Id $PID -ErrorAction Stop).Path

$Checks = @(
    'Test-PowerShellSyntax.ps1'
    'Test-PublicSafety.ps1'
    'Test-InstructionArtifacts.ps1'
    'Test-Workflows.ps1'
)

foreach ($Check in $Checks) {
    $CheckPath = Join-Path $PSScriptRoot $Check
    Write-Host "Running $Check ..."

    & $PowerShellExecutable `
        -NoLogo `
        -NoProfile `
        -NonInteractive `
        -File $CheckPath

    $ExitCode = $LASTEXITCODE

    if ($ExitCode -ne 0) {
        [Console]::Error.WriteLine(
            "Repository validation failed in $Check with exit code $ExitCode."
        )
        exit $ExitCode
    }
}

Write-Host 'Repository validation passed.'
