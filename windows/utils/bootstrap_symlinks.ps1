<#
.SYNOPSIS
    Manage dotfile symlinks

.PARAMETER DryRun
    Preview changes without executing

.PARAMETER Remove
    Remove symlinks without recreating

.EXAMPLE
    Reset-Symlinks             # Recreate all symlinks
    Reset-Symlinks -DryRun     # Preview changes
    Reset-Symlinks -Remove     # Remove all symlinks
#>

$script:UtilsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$bootstrapHelpersPath = Join-Path $script:UtilsDir "bootstrap_helpers.ps1"
if (Test-Path $bootstrapHelpersPath) {
    . $bootstrapHelpersPath
    Fix-ProfilePath
}

$Dirs = Get-BootstrapDirs

$DotfilesProfile = $Dirs.ProfileDir
$DotHomeDir = Join-Path $Dirs.RepoDir "dot-home"
$DotConfigDir = Join-Path $Dirs.RepoDir "dot-config"
$HomeConfigDir = Join-Path $env:UserProfile ".config"

$AppDataLocal = $env:LOCALAPPDATA
$AppDataRoaming = [System.Environment]::GetFolderPath("ApplicationData")

$PROFILE = "$env:UserProfile\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
$ProfileDir = Split-Path $PROFILE -Parent


# ========================[ Region: Symlink Rules ]=========================
#region Symlinks
# Define every file/folder symlink here. One entry = one symlink.
# No recursion or tree expansion — folder entries link the whole folder.

$Symlinks = @(
    # ---- File links ----
    @{ Path = Join-Path $HOME ".wslconfig"; Target = Join-Path $Dirs.WindowsDir ".wslconfig" }
    @{ Path = Join-Path $HOME "_vimrc"; Target = Join-Path $DotHomeDir ".vimrc" }
    @{ Path = Join-Path $HOME ".gitconfig"; Target = Join-Path $DotHomeDir ".gitconfig" }
    @{ Path = Join-Path $HOME ".wezterm.lua"; Target = Join-Path $DotHomeDir ".wezterm.lua" }

    # ---- Folder links ----
    @{ Path = Join-Path $AppDataLocal   "nvim"; Target = Join-Path $DotConfigDir "nvim" }
    @{ Path = Join-Path $AppDataRoaming "alacritty"; Target = Join-Path $DotConfigDir "alacritty" }
    @{ Path = Join-Path $HOME "scripts"; Target = Join-Path $Dirs.WindowsDir "scripts" }
    @{ Path = Join-Path $HomeConfigDir "fastfetch" ; Target = Join-Path $DotConfigDir "fastfetch" }
)

# Symlink all files inside dotfiles\windows\profile (recursive)
Get-ChildItem -Path $DotfilesProfile -Recurse -File | ForEach-Object {
    $relativePath = $_.FullName.Substring($DotfilesProfile.Length).TrimStart('\', '/')
    $symlinks += @{
        Path   = Join-Path $ProfileDir $relativePath
        Target = $_.FullName
    }
}

#endregion

# ========================[ Region: Helpers ]=========================
#region Helpers
function Resolve-SymlinkTarget {
    param([string]$Target)

    try {
        return (Resolve-Path -Path $Target -ErrorAction Stop).ProviderPath
    }
    catch {
        throw "Invalid symlink target: $Target"
    }
}

function Ensure-ParentExists {
    param([string]$Path)

    $parent = Split-Path -Path $Path -Parent
    if ($parent -and -not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
}

function Remove-Symlink {
    param(
        [string]$Path,
        [switch]$DryRun
    )

    if (-not (Test-Path $Path)) { return }

    $item = Get-Item -Force $Path

    if ($item.LinkType -ne "SymbolicLink") {
        Write-Host "Skipping non-symlink: $Path" -ForegroundColor DarkYellow
        return
    }

    if ($DryRun) {
        Write-Host "[DRY] Remove: $Path" -ForegroundColor Yellow
        return
    }

    Remove-Item $Path -Force -Recurse
    Write-Host "Removed symlink: $Path" -ForegroundColor Yellow
}

function New-Symlink {
    param(
        [string]$Path,
        [string]$Target,
        [switch]$DryRun
    )

    $resolved = Resolve-SymlinkTarget $Target

    if ($DryRun) {
        Write-Host "[DRY] Link: $Path -> $resolved" -ForegroundColor DarkCyan
        return
    }

    Ensure-ParentExists $Path

    New-Item -ItemType SymbolicLink -Path $Path -Target $resolved -Force -ErrorAction Stop | Out-Null
    Write-Host "Linked: $Path -> $resolved" -ForegroundColor Green
}

function Reset-Symlinks {
    param(
        [array]$List,
        [switch]$DryRun,
        [switch]$Remove
    )

    if ($Remove) {
        Write-Host "Removing symlinks only..." -ForegroundColor Cyan
        foreach ($entry in $List) {
            Remove-Symlink -Path $entry.Path -DryRun:$DryRun
        }
        Write-Host "Done." -ForegroundColor Cyan
        return
    }

    Write-Host "Resetting symlinks..." -ForegroundColor Cyan

    foreach ($entry in $List) {
        Remove-Symlink -Path $entry.Path -DryRun:$DryRun
        New-Symlink -Path $entry.Path -Target $entry.Target -DryRun:$DryRun
    }

    Write-Host "All symlinks processed." -ForegroundColor Cyan
}
#endregion


#region Execute
Reset-Symlinks -List $Symlinks  # Add -DryRun or -Remove when calling
#endregion