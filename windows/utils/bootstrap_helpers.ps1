# windows\utils\bootstrap_helpers.ps1

# ========================[ Region: Dotfile Refs ]=========================
#region Dotfiles
# We're in: windows\utils\bootstrap_helpers.ps1

$script:UtilsDir          = $PSScriptRoot
$script:WindowsDir        = Split-Path -Path $UtilsDir -Parent
$script:ProfileDir        = Join-Path $WindowsDir "profile"
$script:RepoDir           = Split-Path -Path $WindowsDir -Parent

function Get-BootstrapDirs {
    return @{
        UtilsDir    = $script:UtilsDir
        WindowsDir  = $script:WindowsDir
        ProfileDir  = $script:ProfileDir
        RepoDir     = $script:RepoDir
    }
}
#endregion


# ========================[ Region: Admin & Elevated ]=========================
# Copied from main helpers module to avoid circular dependency
#region Admin

function Bootstrap-Admin {
    param([string[]]$Command)

    if ($Command) {
        $argList = $Command -join ' '
        Start-Process wt -Verb RunAs -ArgumentList "powershell -NoExit -Command $argList"
    } else {
        Start-Process wt -Verb RunAs -ArgumentList "powershell"
    }
}

function Bootstrap-Require-Admin {
    param(
        [Parameter(Mandatory)]
        [scriptblock]$Action
    )

    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
               ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if ($isAdmin) {
        & $Action
    } else {
        Write-Host "Restarting action as administrator..." -ForegroundColor Yellow
        Start-Process wt -Verb RunAs -ArgumentList "powershell -NoProfile -NoExit -Command `"& { $Action }`""
    }
}

function Test-CommandExists {
    param([Parameter(Mandatory)]$Command)
    $exists = $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
    return $exists
}

#endregion

# ========================[ Region: Symlinks ]=========================
#region Symlinks
function Create-Symlink {
    param (
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Target
    )

    try {
        $ResolvedTarget = Resolve-Path -Path $Target -ErrorAction Stop
        New-Item -ItemType SymbolicLink -Path $Path -Target $ResolvedTarget -Force | Out-Null
        Write-Host "Linked: $Path -> $ResolvedTarget" -ForegroundColor Green
    } catch {
        Write-Host "Failed to create symlink: $Path → $Target`n  Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Remove-Symlink {
    param (
        [Parameter(Mandatory = $true)][string]$Path
    )

    try {
        if (Test-Path $Path) {
            $Item = Get-Item -Path $Path -Force
            if ($Item.LinkType -eq 'SymbolicLink') {
                Remove-Item -Path $Path -Force -Recurse
                Write-Host "Removed symlink: $Path" -ForegroundColor Yellow
            } else {
                Write-Host "Not a symlink, skipped: $Path" -ForegroundColor DarkYellow
            }
        } else {
            Write-Host "Path does not exist, skipped: $Path" -ForegroundColor DarkYellow
        }
    } catch {
        Write-Host "Failed to remove symlink: $Path`n  Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Reset-Symlinks {
    param (
        [Parameter(Mandatory = $true)]
        [array]$Links
    )

    Write-Host "Resetting symbolic links..." -ForegroundColor Cyan
    foreach ($Link in $Links) {
        if (-not ($Link.ContainsKey('Path') -and $Link.ContainsKey('Target'))) {
            Write-Host "Skipping invalid link entry" -ForegroundColor DarkYellow
            continue
        }

        Remove-Symlink -Path $Link.Path
        Create-Symlink -Path $Link.Path -Target $Link.Target
    }
}
#endregion


function Write-LogInfo($msg) { Write-Host "INFO: $msg" -ForegroundColor Cyan }
function Write-LogSuccess($msg) { Write-Host "SUCCESS: $msg" -ForegroundColor Green }
function Write-LogWarning($msg) { Write-Host "WARN: $msg" -ForegroundColor Yellow }
function Write-LogError($msg) { Write-Host "ERROR: $msg" -ForegroundColor Red }
function Write-LogSection($msg) {
    Write-Host "`n" -NoNewline
    Write-Host " $msg " -ForegroundColor Black -BackgroundColor Magenta
}

function Fix-ProfilePath {
    if ($PROFILE -like "*OneDrive*") {
        $ProfileFix = Join-Path $script:UtilsDir "fix_profile_path.ps1"
        $DestDir    = Join-Path $env:OneDrive "Documents\WindowsPowerShell"
        $DestFile   = Join-Path $DestDir "Microsoft.PowerShell_profile.ps1"

        # Make sure destination directory exists
        if (-not (Test-Path $DestDir)) {
            New-Item -Path $DestDir -ItemType Directory -Force | Out-Null
        }

        Unblock-File -Path $ProfileFix
        Copy-Item -Path $ProfileFix -Destination $DestFile -Force

        Write-LogInfo "Copied fix_profile_path.ps1 to OneDrive profile location to point to user-level profile."
        $PROFILE = "$env:UserProfile\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    }
}
