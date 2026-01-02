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

$script:Version = "2.0.0"
$script:StartTime = Get-Date

$script:WindowsDir = $PSScriptRoot
$script:UtilsDir = Join-Path $script:WindowsDir "utils"
$script:ScriptsDir = Join-Path $script:WindowsDir "scripts"
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

function Invoke-Safe([scriptblock]$Action, [string]$Description) {
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
        Script-Require-Admin -ScriptPath (Join-Path $script:UtilsDir "bootstrap_symlinks.ps1") -NoExit
    } "Setting up symlinks"
}
#endregion

#region Winget
if (-not $SkipWinget) {
    Invoke-Safe {
        $manifestPath = Join-Path $WindowsDir "winget_packages.json"

        if (Test-Path $manifestPath) {
            Write-Host "Importing Winget packages from $manifestPath..." -ForegroundColor Yellow
            winget import `
                --import-file $manifestPath `
                --accept-package-agreements `
                --accept-source-agreements
        }
        else {
            Write-Warning "Winget manifest not found, falling back to manual package install."

            $packages = @(
                "Git.Git"
                "Neovim.Neovim"
                "Vim.Vim"
                "Python.PythonInstallManager"
                "Microsoft.PowerToys"
                "SumatraPDF.SumatraPDF"
            )

            foreach ($pkg in $packages) {
                Write-Host "Installing/updating $pkg..." -ForegroundColor Yellow
                try {
                    winget install `
                        --id $pkg `
                        --silent `
                        --accept-package-agreements `
                        --accept-source-agreements
                    Write-Host "  SUCCESS $pkg" -ForegroundColor Green
                }
                catch {
                    Write-Warning "Failed to install/update $pkg`: $($_.Exception.Message)"
                }
            }
        }
    } "Winget package installation"
}
#endregion

#region Scoop
if (-not $SkipScoop) {
    Invoke-Safe {
        . (Join-Path $ScriptsDir "install_scoop.ps1")

        $manifestPath = Join-Path $WindowsDir "scoopfile.json"

        if (Test-Path $manifestPath) {
            Write-Host "Importing Scoop packages from $manifestPath..."
            scoop import $manifestPath
        }
        else {
            Write-Warning "Scoop manifest not found, falling back to manual package install."

            $packages = @(
                "coreutils"
                "gcc"           # Includes g++
                "make"
                "ripgrep"
                "fd"
                "fastfetch"
                "tree-sitter"
            )

            Write-Host "Installing packages: $($packages -join ', ')"
            foreach ($pkg in $packages) {
                scoop install $pkg
            }
        }

        Write-Host "Updating Scoop packages and buckets..."
        scoop update

        # Only run generate_global_clangd if gcc exists in PATH
        if (Get-Command gcc -ErrorAction SilentlyContinue) {
            . (Join-Path $ScriptsDir "generate_global_clangd.ps1")
        }
    } "Scoop package installation"
}
#endregion

#region Misc
if (-not $SkipMisc) {
    Invoke-Safe {
        # astral-sh/uv for Python
        if ((Get-Command "uv" -ErrorAction SilentlyContinue) -and (-not $Force)) {
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
    "Git"      = Get-Command "git" -ErrorAction SilentlyContinue
    "Neovim"   = Get-Command "nvim" -ErrorAction SilentlyContinue
    "scoop"    = Get-Command "scoop" -ErrorAction SilentlyContinue
    "gcc"      = Get-Command "gcc" -ErrorAction SilentlyContinue
    "make"     = Get-Command "make" -ErrorAction SilentlyContinue
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
