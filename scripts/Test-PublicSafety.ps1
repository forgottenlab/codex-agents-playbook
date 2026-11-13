[CmdletBinding()]
param(
    [string]$Path,
    [string]$SettingsPath,
    [AllowEmptyString()] [string]$Content
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $PSScriptRoot
$ScanContent = $PSBoundParameters.ContainsKey('Content')
if ([string]::IsNullOrWhiteSpace($Path)) {
    $Path = $RepoRoot
}

if (-not $ScanContent -and -not (Test-Path -LiteralPath $Path)) {
    throw "Safety-scan path does not exist: $Path"
}

if ([string]::IsNullOrWhiteSpace($SettingsPath)) {
    $Candidate = Join-Path $RepoRoot '.local\user-settings.psd1'
    if (Test-Path -LiteralPath $Candidate -PathType Leaf) {
        $SettingsPath = $Candidate
    }
}

# Keep this value as an array even when the scan target is one file.
$Files = @(
    if ($ScanContent) { [pscustomobject]@{ FullName = '<candidate>' } }
    elseif (Test-Path -LiteralPath $Path -PathType Leaf) {
        Get-Item -LiteralPath $Path
    }
    elseif (Test-Path -LiteralPath $Path -PathType Container) {
        Get-ChildItem -LiteralPath $Path -Recurse -File |
            Where-Object {
                $_.FullName -notmatch '[\\/]\.git([\\/]|$)' -and
                $_.FullName -notmatch '[\\/]\.local([\\/]|$)' -and
                $_.FullName -notmatch '[\\/]\.ai([\\/]|$)' -and
                $_.Extension -notin @(
                    '.zip', '.7z', '.rar',
                    '.png', '.jpg', '.jpeg', '.gif', '.webp', '.ico',
                    '.pdf', '.exe', '.dll', '.pdb'
                )
            }
    }
    else {
        throw "Safety-scan path is neither a file nor a directory: $Path"
    }
)

if ($Files.Count -eq 0) {
    throw "No eligible files were found under: $Path"
}

$PrivateLiterals = @()

if (-not [string]::IsNullOrWhiteSpace($SettingsPath)) {
    if (-not (Test-Path -LiteralPath $SettingsPath -PathType Leaf)) {
        throw "Settings file not found: $SettingsPath"
    }

    $Settings = Import-PowerShellDataFile -LiteralPath $SettingsPath

    foreach ($Name in @(
        'WorkspaceRoot',
        'ProjectsDir',
        'AutomationsDir',
        'SandboxDir',
        'ArchivedDir',
        'TemplatesDir'
    )) {
        if ($Settings.ContainsKey($Name)) {
            $Value = [string]$Settings[$Name]
            if (-not [string]::IsNullOrWhiteSpace($Value)) {
                $PrivateLiterals += [pscustomobject]@{
                    Name  = $Name
                    Value = $Value
                }
            }
        }
    }

    if (-not [string]::IsNullOrWhiteSpace($env:USERPROFILE)) {
        $PrivateLiterals += [pscustomobject]@{
            Name  = 'UserProfile'
            Value = $env:USERPROFILE
        }
    }
}

$SecretPatterns = [ordered]@{
    'Private key block'          = '-----BEGIN (?:OPENSSH |RSA |EC |DSA )?PRIVATE KEY-----'
    'GitHub token'               = '(?:ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9]{30,}'
    'GitHub fine-grained token'  = 'github_pat_[A-Za-z0-9_]{40,}'
    'OpenAI-style key'           = '\bsk-(?:proj-)?[A-Za-z0-9_-]{20,}\b'
    'AWS access key'             = '\bAKIA[0-9A-Z]{16}\b'
    'Credential in URL'          = 'https?://[^\s/:]+:[^\s/@]+@'
}

$Findings = [System.Collections.Generic.List[object]]::new()

foreach ($File in $Files) {
    if (-not $ScanContent) { [string]$Content = Get-Content -LiteralPath $File.FullName -Raw -ErrorAction Stop }

    foreach ($Private in $PrivateLiterals) {
        if (
            -not [string]::IsNullOrWhiteSpace($Private.Value) -and
            $Content.IndexOf(
                $Private.Value,
                [System.StringComparison]::OrdinalIgnoreCase
            ) -ge 0
        ) {
            $Findings.Add([pscustomobject]@{
                File = $File.FullName
                Type = "Configured private value: $($Private.Name)"
            })
        }
    }

    foreach ($Pattern in $SecretPatterns.GetEnumerator()) {
        if (
            [regex]::IsMatch(
                $Content,
                $Pattern.Value,
                [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
            )
        ) {
            $Findings.Add([pscustomobject]@{
                File = $File.FullName
                Type = $Pattern.Key
            })
        }
    }
}

if ($Findings.Count -gt 0) {
    [Console]::Error.WriteLine(
        'Public-safety scan failed. Sensitive values are intentionally not printed.'
    )
    $Findings |
        Sort-Object File, Type -Unique |
        Format-Table -AutoSize
    throw 'Public-safety validation failed; sensitive values were not printed.'
}

Write-Host "Public-safety scan passed for $($Files.Count) file(s)."
