Write-Output "Symbolic links require an admin shell to perform."
Write-Output "If the following commands fail, open up an admin shell:"
Write-Output "`tStart-Process wt -Verb RunAs"

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "! This script is not running with Administrator privileges. Symlinks may fail."
}

#region Helpers
function Create-Symlink {
    param (
        [string]$Path,
        [string]$Target
    )

    try {
        $ResolvedTarget = Resolve-Path -Path $Target
        New-Item -ItemType SymbolicLink -Path $Path -Target $ResolvedTarget -Force | Out-Null
        Write-Output "+ Linked: $Path -> $ResolvedTarget"
    } catch {
        Write-Warning "- Failed to link: $Path -> $Target. Error: $_"
    }
}
#endregion

#region Directories
$LocalAppData = $env:LOCALAPPDATA
$RoamingAppData = [System.Environment]::GetFolderPath("ApplicationData")
$ScriptDir = $PSScriptRoot  # Script directory (i.e., repo\windows)
#endregion

#region Symlinks
Create-Symlink -Path $PROFILE `
    -Target (Join-Path $ScriptDir "Microsoft.PowerShell_profile.ps1")

Create-Symlink -Path (Join-Path $HOME ".wslconfig") `
    -Target (Join-Path $ScriptDir ".wslconfig")

Create-Symlink -Path (Join-Path $HOME "_vimrc") `
    -Target (Join-Path $ScriptDir "..\dot-home\.vimrc")

Create-Symlink -Path (Join-Path $LocalAppData "nvim") `
    -Target (Join-Path $ScriptDir "..\dot-config\nvim")

Create-Symlink -Path (Join-Path $RoamingAppData "neovide") `
    -Target (Join-Path $ScriptDir "..\dot-config\neovide")
#endregion
