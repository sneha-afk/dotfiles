# 5/31/2025: LLM-assisted script to work around issues with --wsl flag

# Problem: invoking wsl does not seem to run .profile, which is where I set PATH
# Solution: temporarily update PATH within here, or simply symlink to any folder linked in 
# .bashrc's PATH fallback (/usr/bin/nvim is one)
<# And since I put everything in dotfiles...
New-Item -ItemType SymbolicLink `
    -Path "$HOME\neovide_wsl.ps1" `
    -Target "$(Resolve-Path ".\windows\neovide_wsl_makeshift.ps1")" `
    -Force
#>


# Launch Neovim in WSL (headless mode)
$wslProcess = Start-Process -NoNewWindow -PassThru wsl -ArgumentList "-- nvim --headless --listen localhost:6666"

# Wait for server to start
# Start-Sleep -Seconds 1

try {
    Start-Process neovide -ArgumentList "--server localhost:6666" -ErrorAction Stop
    Write-Host "Neovide connected to Neovim on port 6666."
}
catch {
    Write-Host "Error: Neovide not found. Install from: https://github.com/neovide/neovide"
    Stop-Process -Id $wslProcess.Id -Force -ErrorAction SilentlyContinue
    exit 1
}
