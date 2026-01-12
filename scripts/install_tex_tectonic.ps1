<#
.SYNOPSIS
  Bootstrap installer for Tectonic (Windows).
.DESCRIPTION
  Installs Tectonic (via Scoop if available, else bootstrap) and Pygments (via pip).
  Scoop handles PATH automatically; fallback installs into ~/.local/bin.
#>

$binDir  = "$HOME\.local\bin"
$exe     = "tectonic.exe"
$exePath = Join-Path $binDir $exe
$cache   = "$env:LOCALAPPDATA\TectonicProject\Tectonic"

Write-Host ">>> Checking for Scoop..." -ForegroundColor Cyan
$scoopInstalled = Get-Command scoop -ErrorAction SilentlyContinue

if ($scoopInstalled) {
    Write-Host ">>> Scoop found. Installing Tectonic with Scoop..." -ForegroundColor Green
    scoop install tectonic
} else {
    Write-Host ">>> Scoop not found. Installing Tectonic via bootstrap..." -ForegroundColor Yellow

    # Ensure ~/.local/bin exists
    if (-not (Test-Path $binDir)) {
        New-Item -ItemType Directory -Force -Path $binDir | Out-Null
    }

    # Remove old binary
    if (Test-Path $exePath) {
        Remove-Item -Force $exePath
    }

    # Download and run bootstrap script
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://drop-ps1.fullyjustified.net'))

    # Move binary
    if (Test-Path $exe) {
        Move-Item -Force $exe $binDir
    } else {
        Write-Host "! Failed: tectonic.exe not found after bootstrap." -ForegroundColor Red
        exit 1
    }
}

# Set cache directory
[Environment]::SetEnvironmentVariable('TECTONIC_CACHE_DIR', $cache, 'User')

# Install Pygments (always via Python)
Write-Host ">>> Installing Pygments (pip)..." -ForegroundColor Cyan
try {
    python -m pip install --user --upgrade pip
    python -m pip install --user pygments
} catch {
    Write-Host "! Failed to install Pygments" -ForegroundColor Red
}

# Confirm installs
Write-Host "`n>>> Installation complete. Versions:" -ForegroundColor Cyan
try { tectonic --version } catch { Write-Host "! Tectonic not working" -ForegroundColor Red }
try { pygmentize -V } catch { Write-Host "! Pygments not working" -ForegroundColor Red }
