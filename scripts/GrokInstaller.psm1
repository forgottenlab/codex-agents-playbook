Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'InstructionTools.psm1')

$Modules = @('execution','git-safety','verification','context','history','recovery','handoff')
$EntryPath = 'rules/playbook-entry.md'
$ManagedPaths = @($Modules | ForEach-Object { "playbook/modules/$_.md" }) + $EntryPath
$Stamp = '<!-- codex-agents-playbook/grok-strict v1 sha256:'

function Get-TextHash([string]$Text) {
    [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($Text)))
}

function Resolve-GrokHome([string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) { throw 'Empty Grok target directory.' }
    $Provider = $null
    $Drive = $null
    $FullPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path, [ref]$Provider, [ref]$Drive)
    if ($Provider.Name -ne 'FileSystem') { throw 'Grok requires a filesystem directory.' }
    [IO.Path]::TrimEndingDirectorySeparator([IO.Path]::GetFullPath($FullPath))
}

# Inspect ancestors too, including a home reached through a junction. A dangling
# reparse point must be treated as a conflict even when its target is absent.
function Assert-GrokPath([string]$Path, [bool]$Directory) {
    $Parent = [IO.Path]::GetDirectoryName($Path)
    if ($Parent) { Assert-GrokPath $Parent $true }
    try { $Attributes = [IO.File]::GetAttributes($Path) }
    catch [IO.FileNotFoundException] { return }
    catch [IO.DirectoryNotFoundException] { return }
    if (($Attributes -band [IO.FileAttributes]::ReparsePoint) -or
        ([bool]($Attributes -band [IO.FileAttributes]::Directory) -ne $Directory)) {
        throw "Conflicting file type or link: $Path"
    }
    if (-not $Directory -and (Get-Item -Force -LiteralPath $Path).LinkType -eq 'HardLink') {
        throw "Conflicting hard link: $Path"
    }
}

function Get-CurrentHash([string]$Path) {
    Assert-GrokPath $Path $false
    if ([IO.File]::Exists($Path)) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash }
}

function Get-GrokPackage($ProfileRoot, $Replacements) {
    $Package = [ordered]@{}
    foreach ($Relative in $ManagedPaths) {
        $Name = [IO.Path]::GetFileName($Relative)
        $Source = if ($Relative -eq $EntryPath) { "grok/strict/$Name" } else { "strict/personal-rules/$Name" }
        $Template = Get-Content -LiteralPath (Join-Path $ProfileRoot $Source) -Raw
        if ([string]::IsNullOrWhiteSpace($Template)) { throw "Empty Grok package source: $Source" }
        $Body = Convert-InstructionContent -Content $Template -Replacements $Replacements
        if ($Body -match '\{\{[^{}]+\}\}') { throw "Unresolved placeholder in $Name" }
        if ($Relative -eq $EntryPath) {
            $Routes = @([regex]::Matches($Body, '`\.\./playbook/modules/([^`]+\.md)`') | ForEach-Object { $_.Groups[1].Value })
            if (Compare-Object @($Modules | ForEach-Object { "$_.md" }) $Routes -CaseSensitive) { throw 'Invalid Grok routing table.' }
        }
        $Package[$Relative] = "$Body$Stamp$(Get-TextHash $Body) -->`n"
    }
    $Package
}

function Assert-ManagedContent([string]$Path, [string]$Hash) {
    $Text = [IO.File]::ReadAllText($Path)
    $Offset = $Text.LastIndexOf($Stamp, [StringComparison]::Ordinal)
    if ($Offset -ge 0) {
        $Body = $Text.Substring(0, $Offset)
        $Expected = "$Body$Stamp$(Get-TextHash $Body) -->`n"
        if ((Get-TextHash $Expected) -eq $Hash) { return }
    }
    throw "Conflict at $Path (unmanaged or locally edited). Preserve and reconcile it before retrying."
}

# Publish a complete file via a same-directory rename. Never truncate existing
# content in place. Only a batch of files can be partially installed.
function Set-GrokFile([string]$Path, [byte[]]$Bytes, $Before) {
    $Parent = [IO.Path]::GetDirectoryName($Path)
    Assert-GrokPath $Parent $true
    [IO.Directory]::CreateDirectory($Parent) | Out-Null
    $Temp = Join-Path $Parent ([guid]::NewGuid().ToString('N') + '.tmp')
    try {
        [IO.File]::WriteAllBytes($Temp, $Bytes)
        if ((Get-CurrentHash $Path) -ne $Before) { throw "Destination changed: $Path" }
        [IO.File]::Move($Temp, $Path, ($null -ne $Before))
    }
    finally { [IO.File]::Delete($Temp) }
}

function Enter-GrokMutex([string]$Root) {
    $Key = if ($IsWindows) { $Root.ToUpperInvariant() } else { $Root }
    $Mutex = [Threading.Mutex]::new($false, "playbook-grok-$(Get-TextHash $Key)")
    try { $Acquired = $Mutex.WaitOne(0) }
    catch [Threading.AbandonedMutexException] { $Acquired = $true }
    if (-not $Acquired) { $Mutex.Dispose(); throw "Another playbook operation is active at $Root" }
    $Mutex
}

function Install-GrokStrict {
    [CmdletBinding(SupportsShouldProcess)]
    param([string]$TargetDirectory, [string]$ProfileRoot, [System.Collections.IDictionary]$Replacements)
    $Root = Resolve-GrokHome $TargetDirectory
    $Package = Get-GrokPackage $ProfileRoot $Replacements
    $Mutex = Enter-GrokMutex $Root
    try {
        $Changes = @(foreach ($Relative in $Package.Keys) {
            $Path = Join-Path $Root $Relative
            $Before = Get-CurrentHash $Path
            $After = Get-TextHash $Package[$Relative]
            if ($Before -eq $After) { Write-Host "Unchanged $Path"; continue }
            if ($Before) { Assert-ManagedContent $Path $Before; Write-Host "Update $Path" }
            else { Write-Host "Create $Path" }
            [ordered]@{ Path = $Relative; Before = $Before; After = $After }
        })
        if ($Changes.Count -eq 0) { return }
        $Batch = [guid]::NewGuid().ToString('N')
        $Directory = Join-Path $Root "playbook/backups/$Batch"
        Assert-GrokPath $Directory $true
        if (-not $PSCmdlet.ShouldProcess($Root, "Install Grok Strict ($($Changes.Count) changed files)")) { return }
        # Prepare every backup and the complete journal before changing an instruction.
        [IO.Directory]::CreateDirectory($Directory) | Out-Null
        foreach ($Change in $Changes) {
            if ($Change.Before) {
                $Backup = Join-Path $Directory ([IO.Path]::GetFileName($Change.Path))
                [IO.File]::Copy((Join-Path $Root $Change.Path), $Backup)
                if ((Get-CurrentHash $Backup) -ne $Change.Before) { throw "Backup verification failed: $Backup" }
            }
        }
        [IO.File]::WriteAllText((Join-Path $Directory 'manifest.json'), (ConvertTo-Json -InputObject $Changes))
        Write-Host "Recovery batch: $Directory"
        foreach ($Change in $Changes) {
            $Path = Join-Path $Root $Change.Path
            try { Set-GrokFile $Path ([Text.Encoding]::UTF8.GetBytes($Package[$Change.Path])) $Change.Before }
            catch { throw "Install stopped at $Path. Run Restore-GrokAgents.ps1 -TargetDirectory `"$Root`" -Batch $Batch -WhatIf. $_" }
        }
    }
    finally { $Mutex.ReleaseMutex(); $Mutex.Dispose() }
}

function Restore-GrokStrict {
    [CmdletBinding(SupportsShouldProcess)]
    param([string]$TargetDirectory, [ValidatePattern('^[0-9a-f]{32}$')] [string]$Batch)
    $Root = Resolve-GrokHome $TargetDirectory
    $Directory = Join-Path $Root "playbook/backups/$Batch"
    $Manifest = Join-Path $Directory 'manifest.json'
    $Mutex = Enter-GrokMutex $Root
    try {
        Assert-GrokPath $Manifest $false
        $Changes = @(Get-Content -LiteralPath $Manifest -Raw | ConvertFrom-Json)
        $Seen = @{}
        $Pending = @(foreach ($Change in $Changes) {
            if ($Change.Path -cnotin $ManagedPaths -or $Seen.ContainsKey($Change.Path) -or
                $Change.After -notmatch '^[a-f0-9]{64}$' -or
                ($null -ne $Change.Before -and $Change.Before -notmatch '^[a-f0-9]{64}$')) { throw 'Invalid Grok backup manifest.' }
            $Seen[$Change.Path] = $true
            $Path = Join-Path $Root $Change.Path
            $Current = Get-CurrentHash $Path
            if ($Current -eq $Change.Before) { continue }
            if ($Current -ne $Change.After) { throw "Recovery conflict: $Path has changed since installation." }
            if ($Change.Before) {
                $Backup = Join-Path $Directory ([IO.Path]::GetFileName($Change.Path))
                if ((Get-CurrentHash $Backup) -ne $Change.Before) { throw "Invalid backup: $Backup" }
            }
            Write-Host "Restore $Path"
            $Change
        })
        if (-not $Pending.Count -or -not $PSCmdlet.ShouldProcess($Root, "Restore Grok batch $Batch")) { return }
        foreach ($Change in $Pending) {
            $Path = Join-Path $Root $Change.Path
            if ($Change.Before) {
                $Backup = Join-Path $Directory ([IO.Path]::GetFileName($Change.Path))
                Set-GrokFile $Path ([IO.File]::ReadAllBytes($Backup)) $Change.After
            } else {
                if ((Get-CurrentHash $Path) -ne $Change.After) { throw "Recovery conflict: $Path" }
                [IO.File]::Delete($Path)
            }
        }
    }
    finally { $Mutex.ReleaseMutex(); $Mutex.Dispose() }
}

Export-ModuleMember -Function Install-GrokStrict, Restore-GrokStrict
