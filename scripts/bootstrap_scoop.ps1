<#
.SYNOPSIS
    Bootstrap Scoop package manager and essential packages.
.LINK
    https://scoop.sh
#>

if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    try {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-RestMethod -Uri "https://get.scoop.sh" | Invoke-Expression

        Write-Host "Scoop installation complete." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to install Scoop: $_"
    }
}

scoop bucket add extras
scoop bucket add versions

$apps = @(
    "7zip", "fd", "gcc", "make", "ripgrep", "tree-sitter", "uutils-coreutils",
    "wezterm-nightly"
)

Write-Host "Installing Scoop apps..." -ForegroundColor Yellow
scoop install $apps
scoop update *
