[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$RepositoryUrl = 'https://github.com/forgottenlab/codex-agents-playbook.git',
    [string]$Destination = (Join-Path $env:USERPROFILE 'codex-agents-playbook'),

    [ValidateSet('minimal', 'standard', 'strict')]
    [string]$Profile = 'standard',

    [string]$WorkspaceRoot,
    [string]$GitHubUsername,
    [string]$PreferredLanguage = 'Simplified Chinese',
    [switch]$InstallGlobal
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'Git is required but was not found in PATH.'
}

if (Test-Path -LiteralPath (Join-Path $Destination '.git') -PathType Container) {
    if ($PSCmdlet.ShouldProcess($Destination, 'Update repository with git pull --ff-only')) {
        & git -C $Destination pull --ff-only
        if ($LASTEXITCODE -ne 0) { throw 'git pull --ff-only failed.' }
    }
}
elseif (Test-Path -LiteralPath $Destination) {
    throw "Destination exists but is not a Git repository: $Destination"
}
else {
    if ($PSCmdlet.ShouldProcess($Destination, "Clone $RepositoryUrl")) {
        & git clone --depth 1 $RepositoryUrl $Destination
        if ($LASTEXITCODE -ne 0) { throw 'git clone failed.' }
    }
}

if ($WhatIfPreference) {
    Write-Host 'WhatIf: repository operation preview completed; initializer was not executed.'
    return
}

$Initializer = Join-Path $Destination 'scripts\Initialize-LocalWorkspace.ps1'
if (-not (Test-Path -LiteralPath $Initializer -PathType Leaf)) {
    throw "Initializer not found after clone: $Initializer"
}

$Arguments = @{
    Profile           = $Profile
    PreferredLanguage = $PreferredLanguage
    InstallGlobal     = $InstallGlobal
}
if (-not [string]::IsNullOrWhiteSpace($WorkspaceRoot)) { $Arguments.WorkspaceRoot = $WorkspaceRoot }
if (-not [string]::IsNullOrWhiteSpace($GitHubUsername)) { $Arguments.GitHubUsername = $GitHubUsername }

# The installer is executed from the visible cloned working tree, not from a pipe-to-shell download.
& $Initializer @Arguments
