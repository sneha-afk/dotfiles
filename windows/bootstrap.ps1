# windows\bootstrap.ps1

<#
.SYNOPSIS
    Bootstrap Windows development environment.
.DESCRIPTION
    Installs and configures:
      - Scoop & packages
      - PowerShell profile and dotfile symlinks
      - Winget apps
      - Miscellaneous tools
.LINK
    Scoop: https://scoop.sh
.LINK
    Winget packages: https://github.com/microsoft/winget-pkgs
.LINK
    Astral UV: https://github.com/astral-sh/uv
#>

[CmdletBinding()]
param(
    [switch]$SkipScoop,
    [switch]$SkipSymlinks,
    [switch]$SkipWinget,
    [switch]$SkipMisc,
    [switch]$Force
)

# ========================[ Script Initialization ]========================
#region Initialization

$script:Version = "1.0.0"
$script:StartTime = Get-Date

$script:ScriptDir = $PSScriptRoot
$script:RepoDir = Split-Path -Path $ScriptDir -Parent
$script:UtilsDir = Join-Path $ScriptDir "utils"
$script:ProfileDir = Join-Path $script:RepoDir "windows\profile"

. (Join-Path $script:UtilsDir "bootstrap_helpers.ps1")
Fix-ProfilePath

$ErrorActionPreference = "Stop"
$script:ErrorCount = 0

trap {
    $script:ErrorCount++
    Write-LogError "Unhandled error: $_"
    Write-LogError "At line: $($_.InvocationInfo.ScriptLineNumber)"

    if ($script:ErrorCount -gt 5) {
        Write-LogError "Too many errors encountered. Aborting bootstrap."
        exit 1
    }

    continue
}

function Invoke-Safe([scriptblock]$Action, [string]$Description, [switch]$Admin) {
    Write-LogSection $Description
    try {
        & $Action
        Write-LogSuccess "$Description completed"
    } catch {
        Write-LogError "$Description failed: $_"
        $script:ErrorCount++
    }
}

Write-LogSection "sneha-afk's Windows Bootstrap v$script:Version"
Write-LogInfo "Started at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

#endregion

#region Symlinks
if (-not $SkipSymlinks) {
    Invoke-Safe {
        Bootstrap-Require-Admin { . (Join-Path $script:UtilsDir "bootstrap_symlinks.ps1") }
    } "Setting up symlinks" -Admin
}
#endregion

#region Winget
if (-not $SkipWinget) {
    Invoke-Safe {
        . (Join-Path $UtilsDir "winget_programs.ps1")
        Bootstrap-WingetPrograms
    } "Winget package installation"
}
#endregion

#region Scoop
if (-not $SkipScoop) {
    Invoke-Safe {
        . (Join-Path $UtilsDir "scoop_programs.ps1")
        Install-Scoop -Force:$Force
        Bootstrap-ScoopPrograms
    } "Scoop package installation"
}
#endregion

#region Misc
if (-not $SkipMisc) {
    Invoke-Safe {
        # astral-sh/uv for Python
        if ((Test-CommandExists "uv") -and (-not $Force)) {
            uv self update
        } else {
            powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
        }
    } "Miscellaneous setup"
}
#endregion

# ========================[ Cleanup & Summary ]========================
#region Cleanup
Write-LogSection "Bootstrap Summary"

# Final verification
Write-LogInfo "Running final checks..."

$toCheck = @{
    "$PROFILE" = Test-Path $PROFILE
    "Git" = Test-CommandExists "git"
    "Neovim" = Test-CommandExists "nvim"
    "scoop" = Test-CommandExists "scoop"
    "gcc" = Test-CommandExists "gcc"
    "make" = Test-CommandExists "make"
}
foreach ($check in $toCheck.GetEnumerator()) {
    if ($check.Value) {
        Write-LogSuccess "$($check.Key) is available"
    } else {
        Write-LogError "$($check.Key) is not available"
    }
}

$elapsed = (Get-Date) - $script:StartTime
Write-LogInfo "Bootstrap completed in $($elapsed.TotalSeconds.ToString('F1')) seconds"

if ($script:ErrorCount -eq 0) {
    Write-LogSuccess "Bootstrap completed successfully!"
} else {
    Write-LogWarning "Bootstrap completed with $script:ErrorCount errors"
    Write-LogInfo "Check the log above for details"
}
#endregion
