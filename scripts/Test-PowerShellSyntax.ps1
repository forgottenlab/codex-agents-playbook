[CmdletBinding()]
param(
    [string]$Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($Path)) {
    $Path = Join-Path $RepoRoot 'scripts'
}

if (-not (Test-Path -LiteralPath $Path)) {
    throw "Validation path does not exist: $Path"
}

# Wrap the complete conditional expression in @(...).
# PowerShell unwraps pipeline output assigned from an if expression, so placing
# @() only inside each branch does not guarantee an array for a single file.
$Files = @(
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        Get-Item -LiteralPath $Path
    }
    elseif (Test-Path -LiteralPath $Path -PathType Container) {
        Get-ChildItem -LiteralPath $Path -Filter '*.ps1' -File -Recurse
    }
    else {
        throw "Validation path is neither a file nor a directory: $Path"
    }
)

if ($Files.Count -eq 0) {
    throw "No PowerShell scripts were found under: $Path"
}

$Findings = [System.Collections.Generic.List[object]]::new()

foreach ($File in $Files) {
    $Tokens = $null
    $ParseErrors = $null

    [System.Management.Automation.Language.Parser]::ParseFile(
        $File.FullName,
        [ref]$Tokens,
        [ref]$ParseErrors
    ) | Out-Null

    foreach ($ParseError in @($ParseErrors)) {
        $Findings.Add([pscustomobject]@{
            File    = $File.FullName
            Line    = $ParseError.Extent.StartLineNumber
            Column  = $ParseError.Extent.StartColumnNumber
            Message = $ParseError.Message
        })
    }
}

if ($Findings.Count -gt 0) {
    [Console]::Error.WriteLine('PowerShell syntax validation failed.')
    $Findings |
        Sort-Object File, Line, Column |
        Format-Table -AutoSize
    exit 1
}

Write-Host "PowerShell syntax validation passed for $($Files.Count) file(s)."
