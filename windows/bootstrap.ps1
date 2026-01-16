# windows\bootstrap.ps1

<#
.SYNOPSIS
    Bootstrap Windows development environment and essentials
.DESCRIPTION
    Installs and configures:
    - Scoop (CLI tools & Compilers)
    - Winget (GUI & Desktop Apps)
    - TROVL or Manual Symlinks (Dotfiles)
    - Astral UV (Python Management)
.LINK
    Scoop: https://scoop.sh
.LINK
    Winget packages: https://github.com/microsoft/winget-pkgs
.LINK
    Astral UV: https://github.com/astral-sh/uv
.PARAMETER SkipScoop
    Skip the installation of Scoop and its associated CLI packages.
.PARAMETER SkipWinget
    Skip the installation of Winget apps (GUI and desktop software).
.PARAMETER SkipSymlinks
    Skip the Trovl check/installation and manual symlink setup.
.PARAMETER SkipMisc
    Skip miscellaneous tools like Astral UV.
#>

[CmdletBinding()]
param(
    [switch]$SkipScoop,
    [switch]$SkipSymlinks,
    [switch]$SkipWinget,
    [switch]$SkipMisc
)

# ========================[ Script Initialization ]========================
#region Initialization

$script:StartTime = Get-Date

$script:WindowsDir = $PSScriptRoot
$script:RepoDir = Split-Path -Parent $script:WindowsDir
$script:UtilsDir = Join-Path $script:WindowsDir "utils"
$script:ScriptsDir = Join-Path $script:RepoDir "scripts"

$ErrorActionPreference = "Stop"

Write-Host "sneha-afk's windows boostrap" -ForegroundColor Magenta
Write-Host "started at $($script:StartTime.ToString('HH:mm:ss'))" -ForegroundColor Yellow

if ($PROFILE -like "*OneDrive*") {
    $ProfileFix = Join-Path $script:UtilsDir "fix_profile_path.ps1"
    $DestDirs = @(
        (Join-Path $env:OneDrive "Documents\WindowsPowerShell"),
        (Join-Path $env:OneDrive "Documents\PowerShell")
    )

    foreach ($DestDir in $DestDirs) {
        if (-not (Test-Path $DestDir)) { New-Item -Path $DestDir -ItemType Directory -Force | Out-Null }
        $DestFile = Join-Path $DestDir "Microsoft.PowerShell_profile.ps1"
        if (Test-Path $ProfileFix) {
            Unblock-File -Path $ProfileFix
            Copy-Item -Path $ProfileFix -Destination $DestFile -Force
            Write-Host "Copied profile fix to '$DestFile'" -ForegroundColor Green
        }
    }
}

#endregion

#region  Symlinks
if (-not $SkipSymlinks) {
    Write-Host "`n--- Setting up symlinks ---" -ForegroundColor Cyan
    if (!(Get-Command trovl -ErrorAction SilentlyContinue)) {
        $title = "Warning: trovl Not Found"
        $message = "trovl not found. Install it now? (Selecting 'No' runs manual, regular symlink script)"
        $choices = [System.Management.Automation.Host.ChoiceDescription[]] @(
            New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Install Trovl"
            New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Manual Symlinks"
        )

        $decision = $host.ui.PromptForChoice($title, $message, $choices, 1)

        if ($decision -eq 0) {
            Write-Host "--- Installing Trovl ---" -ForegroundColor Cyan

            curl -LO https://github.com/sneha-afk/trovl/releases/latest/download/trovl_windows_amd64.zip
            if (!(Test-Path "$env:USERPROFILE/.local/bin")) { mkdir $localBin -Force | Out-Null }
            Expand-Archive trovl_windows_amd64.zip -Destination "$env:USERPROFILE\.local\bin\" -Force

            if ($env:PATH -notlike "*$localBin*") {
                setx PATH "$env:PATH; $localBin"
                $env:PATH += "; $localBin"
            }
            Write-Host "Trovl installed to $env:USERPROFILE/.local/bin" -ForegroundColor Green

            Remove-Item trovl_windows_amd64.zip -Force
        }
        else {
            Write-Host "--- Running Manual Symlinks ---" -ForegroundColor Cyan
            & "$UtilsDir/install_symlinks.ps1"
        }
    }

    if (Get-Command trovl -ErrorAction SilentlyContinue) {
        trovl apply "$script:RepoDir/trovl-manifest.json" --overwrite
    }

}
#endregion

#region Scoop
if (-not $SkipScoop) {
    Write-Host "`n--- Starting Scoop Setup ---" -ForegroundColor Cyan
    & "$script:ScriptsDir/bootstrap_scoop.ps1"
}
#endregion

#region Winget
if (-not $SkipWinget) {
    Write-Host "`n--- Starting Winget Setup ---" -ForegroundColor Cyan
    & "$script:ScriptsDir/bootstrap_winget.ps1"
}
#endregion

#region Misc
if (-not $SkipMisc) {
    Write-Host "`n--- Installing: astral uv ---" -ForegroundColor Cyan
    if (Get-Command "uv" -ErrorAction SilentlyContinue) {
        uv self update
    }
    else {
        powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
    }
}
#endregion

#region Summary
Write-Host "`n=== Bootstrap Summary ===" -ForegroundColor Cyan
$tools = @(
    @{ Name = "git"; Cmd = { Get-Command "git" -ErrorAction SilentlyContinue } }
    @{ Name = "nvim"; Cmd = { Get-Command "nvim" -ErrorAction SilentlyContinue } }
    @{ Name = "sccop"; Cmd = { Get-Command "scoop" -ErrorAction SilentlyContinue } }
    @{ Name = "gcc"; Cmd = { Get-Command "gcc" -ErrorAction SilentlyContinue } }
    @{ Name = "make"; Cmd = { Get-Command "make" -ErrorAction SilentlyContinue } }
    @{ Name = "trovl"; Cmd = { Get-Command "trovl" -ErrorAction SilentlyContinue } }
    @{ Name = "uv"; Cmd = { Get-Command "uv" -ErrorAction SilentlyContinue } }
)

foreach ($tool in $tools) {
    $status = if (& $tool.Cmd) { "[OK]" } else { "[FAIL]" }
    $color = if ($status -eq "[OK]") { "Green" } else { "Red" }
    Write-Host "$status $($tool.Name)" -ForegroundColor $color
}

$elapsed = (Get-Date) - $script:StartTime
Write-Host ("`nBootstrap completed in {0:F1} seconds" -f $elapsed.TotalSeconds) -ForegroundColor Yellow
Write-Host "Done! Restart your shell to apply all changes." -ForegroundColor Green
#endregion
