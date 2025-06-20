# dotfiles

## Setup
Check existing symlinks:
```bash
find ~ -maxdepth 1 -type l -ls | grep dotfiles

Get-ChildItem -Recurse -Attributes ReparsePoint $HOME | Where-Object { $_.Target -match "dotfiles" }
```

### `stow` (recommended)
Using GNU `stow` at the root of this repo:
```bash
make          # Symlink all configurations
make delete   # Remove all symlinks (cleanup)
make dry-run # Preview changes without changes
```

### Manual Symlinks
Without `stow`, create symlinks with `ln`:
```bash
ln -sf "$(pwd)/dot-config/nvim" "$HOME/.config/nvim"
ln -sf "$(pwd)/dot-vim/.vimrc" "$HOME/.vimrc"
ln -sf "$(pwd)/dot-bash/.bashrc" "$HOME/.bashrc"
```

### PowerShell
```powershell
New-Item -ItemType SymbolicLink `
    -Path $PROFILE `
    -Target "$(Resolve-Path ".\dot-home\Microsoft.PowerShell_profile.ps1")" `
    -Force

New-Item -ItemType SymbolicLink `
    -Path "$HOME\_vimrc" `
    -Target "$(Resolve-Path ".\dot-home\.vimrc")" `
    -Force

New-Item -ItemType SymbolicLink `
    -Path "$env:LOCALAPPDATA\nvim" `
    -Target "$(Resolve-Path ".\dot-config\nvim")" `
    -Force

New-Item -ItemType SymbolicLink `
    -Path "$env:LOCALAPPDATA\..\Roaming\neovide" `
    -Target "$(Resolve-Path ".\dot-config\neovide")" `
    -Force
```

## Info
See [Neovim README](./dot-config/nvim/README.md) for more on that.
