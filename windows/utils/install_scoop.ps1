# windows/scripts/install_scoop.ps1

if (Get-Command scoop -ErrorAction SilentlyContinue) {
    Write-Host "Scoop already installed, performing updates" -ForegroundColor Green
    scoop update
    return
}

try {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod -Uri "https://get.scoop.sh" | Invoke-Expression

    Write-Host "Scoop installation complete." -ForegroundColor Green
} catch {
    Write-Error "Failed to install Scoop: $_"
}
