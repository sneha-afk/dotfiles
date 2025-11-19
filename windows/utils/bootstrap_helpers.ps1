# windows\utils\bootstrap_helpers.ps1

# ========================[ Region: Dotfile Refs ]=========================
#region Dotfiles
# We're in: windows\utils\bootstrap_helpers.ps1

$script:UtilsDir = $PSScriptRoot
$script:WindowsDir = Split-Path -Path $UtilsDir -Parent
$script:ProfileDir = Join-Path $WindowsDir "profile"
$script:RepoDir = Split-Path -Path $WindowsDir -Parent

function Get-BootstrapDirs {
    return @{
        UtilsDir   = $script:UtilsDir
        WindowsDir = $script:WindowsDir
        ProfileDir = $script:ProfileDir
        RepoDir    = $script:RepoDir
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
    }
    else {
        Start-Process wt -Verb RunAs -ArgumentList "powershell"
    }
}

function Script-Require-Admin {
    param(
        [string]$ScriptPath = $MyInvocation.ScriptName,
        [switch]$NoExit = $false
    )

    $currentPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isAdmin) {
        Write-Host "Elevating to administrator privileges..." -ForegroundColor Yellow

        Start-Process powershell.exe -Verb RunAs -ArgumentList (
            "-NoProfile",
            "-ExecutionPolicy",
            "Bypass",
            "-File",
            "`"$ScriptPath`""
        ) -Wait

        if (-not $NoExit) {
            Write-Host "Exiting non-admin session." -ForegroundColor Yellow
            exit
        }
    }

    Write-Host "Running with administrator privileges..." -ForegroundColor Green
}

function Test-CommandExists {
    param([Parameter(Mandatory)]$Command)
    $exists = $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
    return $exists
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
        $DestDir = Join-Path $env:OneDrive "Documents\WindowsPowerShell"
        $DestFile = Join-Path $DestDir "Microsoft.PowerShell_profile.ps1"

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
