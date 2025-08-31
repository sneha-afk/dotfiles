<#
.SYNOPSIS
  Bootstrap installer for Tectonic (Windows).
.DESCRIPTION
  Downloads Tectonic using the official bootstrap script,
  shows old version (if any), removes old binary,
  installs new one into ~/.local/bin, and reminds user to check PATH.
  Prereqs: at least a "minimal scheme" from TeX Live.
#>

$binDir = "$HOME\.local\bin"
$exe = "tectonic.exe"
$exePath = Join-Path $binDir $exe

Write-Host ">>> Preparing to install/update Tectonic..." -ForegroundColor Cyan

# Remove old installation
if (Test-Path $exePath) {
    try {
        $oldVersion = & $exePath --version
        Write-Host "Found existing Tectonic: $oldVersion" -ForegroundColor Yellow
    } catch {
        Write-Host "Found old tectonic.exe, but could not get version." -ForegroundColor Yellow
    }
    Write-Host "Removing old $exe from $binDir..." -ForegroundColor Yellow
    Remove-Item -Force $exePath
}

# https://tectonic-typesetting.github.io/en-US/install.html
Write-Host ">>> Downloading latest Tectonic bootstrap..." -ForegroundColor Cyan
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://drop-ps1.fullyjustified.net'))

# Ensure ~/.local/bin exists
if (-not (Test-Path $binDir)) {
    New-Item -ItemType Directory -Force -Path $binDir | Out-Null
    Write-Host "Created $binDir"
}

# Move new binary
if (Test-Path $exe) {
    Move-Item -Force $exe $binDir
    Write-Host ">>> Installed tectonic.exe into $binDir" -ForegroundColor Green
} else {
    Write-Host "! Could not find $exe after bootstrap install." -ForegroundColor Red
    exit 1
}

# Show new version
try {
    $newVersion = & $exePath --version
    Write-Host "Now installed: $newVersion" -ForegroundColor Green
} catch {
    Write-Host "! Could not check version of new tectonic.exe" -ForegroundColor Red
}

try {
    [Environment]::SetEnvironmentVariable('TECTONIC_CACHE_DIR', "$env:LOCALAPPDATA\TectonicProject\Tectonic", 'User')
    Write-Host ">>> Successfully set TECTONIC_CACHE_DIR to: $env:LOCALAPPDATA\TectonicProject\Tectonic" -ForegroundColor Green
}
catch {
    Write-Host "! Failed to set TECTONIC_CACHE_DIR: $($_.Exception.Message)" -ForegroundColor Red
}

# Post-install message
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "  1. Ensure $binDir is in your PATH."
Write-Host "     Example (PowerShell):`n"
Write-Host "         [Environment]::SetEnvironmentVariable('Path', `$env:Path + ';$binDir', 'User')" -ForegroundColor DarkGray
Write-Host "`n  2. Restart your terminal and run: tectonic --version"
