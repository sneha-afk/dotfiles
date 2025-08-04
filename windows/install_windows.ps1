# windows/install_windows.ps1

Write-Output "Symbolic links require an admin shell to perform."
Write-Output "If the following commands fail, open up an admin shell:"
Write-Output "`tStart-Process wt -Verb RunAs"

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "! This script is not running with Administrator privileges. Symlinks may fail."
}

#region Helpers
. "$PSScriptRoot\helpers.ps1"
#endregion

#region Directories
$ScriptDir = $PSScriptRoot                          # e.g., repo\windows
$RepoDir = Split-Path -Path $ScriptDir -Parent      # one level up, i.e., repo root
$AppDataLocal = $env:LOCALAPPDATA
$AppDataRoaming = [System.Environment]::GetFolderPath("ApplicationData")
#endregion

#region Symlinks
$symlinks = @(
    @{
        Path   = $PROFILE
        Target = Join-Path $ScriptDir "Microsoft.PowerShell_profile.ps1"
    },
    @{
        Path   = Join-Path $HOME ".wslconfig"
        Target = Join-Path $ScriptDir ".wslconfig"
    },
    @{
        Path   = Join-Path $HOME "_vimrc"
        Target = Join-Path $RepoDir "dot-home\.vimrc"
    },
    @{
        Path   = Join-Path $AppDataLocal "nvim"
        Target = Join-Path $RepoDir "dot-config\nvim"
    },
    @{
        Path   = Join-Path $AppDataRoaming "neovide"
        Target = Join-Path $RepoDir "dot-config\neovide"
    }
    @{
        Path   = Join-Path $AppDataRoaming "alacritty"
        Target = Join-Path $RepoDir "dot-config\alacritty"
    }
)

Reset-Symlinks -Links $symlinks
#endregion
