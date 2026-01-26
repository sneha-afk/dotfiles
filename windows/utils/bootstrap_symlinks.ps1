<#
.SYNOPSIS
    Manage dotfile symlinks

.DESCRIPTION
    Creates and manages symbolic links for dotfiles across the system.
    Supports dry-run mode and removal-only operation.

.PARAMETER DryRun
    Preview changes without executing

.PARAMETER Remove
    Remove symlinks without recreating
#>
[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Remove
)

#region Configuration

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$DotHomeDir = Join-Path $RepoRoot "dot-home"
$DotConfigDir = Join-Path $RepoRoot "dot-config"
$WindowsDir = Join-Path $RepoRoot "windows"
$ProfileDir = Split-Path $PROFILE -Parent

$ProfileSourceDir = Join-Path $WindowsDir "profile"

#endregion

#region Symlink Rules

$Symlinks = @(
    # Files
    @{ Path = "$HOME\.wslconfig"; Target = "$WindowsDir\.wslconfig" }
    @{ Path = "$HOME\_vimrc"; Target = "$DotHomeDir\.vimrc" }
    @{ Path = "$HOME\.gitconfig"; Target = "$DotHomeDir\.gitconfig" }
    @{ Path = "$HOME\.wezterm.lua"; Target = "$DotHomeDir\.wezterm.lua" }
    @{ Path = "$HOME\.ripgreprc"; Target = "$DotHomeDir\.ripgreprc" }
    @{ Path = "$PROFILE"; Target = "$ProfileSourceDir\Microsoft.PowerShell_profile.ps1" }

    # Folders
    @{ Path = "$env:LOCALAPPDATA\nvim"; Target = "$DotConfigDir\nvim" }
    @{ Path = "$HOME\scripts"; Target = "$RepoRoot\scripts" }
    @{ Path = "$HOME\.config\fastfetch"; Target = "$DotConfigDir\fastfetch" }
    @{ Path = "$ProfileDir\Modules\helpers"; Target = "$ProfileSourceDir\Modules\helpers" }
)

#endregion

#region Functions

function Remove-SafeSymlink {
    param([string]$Path)

    if (-not (Test-Path $Path)) { return }

    $item = Get-Item -Force $Path
    if ($item.LinkType -ne "SymbolicLink") {
        Write-Host "Skipping non-symlink: $Path" -ForegroundColor DarkYellow
        return
    }

    if ($DryRun) {
        Write-Host "[DRY] Remove: $Path" -ForegroundColor Yellow
    }
    else {
        Remove-Item $Path -Force -Recurse
        Write-Host "Removed: $Path" -ForegroundColor Yellow
    }
}

function New-SafeSymlink {
    param([string]$Path, [string]$Target)

    if (-not (Test-Path $Target)) {
        Write-Warning "Target not found: $Target"
        return
    }

    $parent = Split-Path $Path -Parent
    if ($parent -and -not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    if ($DryRun) {
        Write-Host "[DRY] Link: $Path -> $Target" -ForegroundColor DarkCyan
    }
    else {
        New-Item -ItemType SymbolicLink -Path $Path -Target $Target -Force -ErrorAction Stop | Out-Null
        Write-Host "Linked: $Path -> $Target" -ForegroundColor Green
    }
}

#endregion

#region Execution

Write-Host "$(if ($DryRun) { '[DRY RUN] ' })$(if ($Remove) { 'Removing' } else { 'Resetting' }) symlinks..." -ForegroundColor Cyan

foreach ($link in $Symlinks) {
    Remove-SafeSymlink -Path $link.Path
    if (-not $Remove) {
        New-SafeSymlink -Path $link.Path -Target $link.Target
    }
}

Write-Host "Done." -ForegroundColor Cyan

#endregion
