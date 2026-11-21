[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)] [string]$TargetDirectory,
    [Parameter(Mandatory)] [ValidatePattern('^[0-9a-f]{32}$')] [string]$Batch
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'GrokInstaller.psm1')
Restore-GrokStrict @PSBoundParameters
