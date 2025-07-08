# dotfiles

## Setup
Check existing symlinks:
```bash
find ~ -maxdepth 1 -type l -ls | grep dotfiles

Get-ChildItem -Recurse -Attributes ReparsePoint $HOME | Where-Object { $_.Target -match "dotfiles" }
```

### UNIX
#### `stow` (recommended)
Using GNU `stow` at the root of this repo:
```bash
make          # Symlink all configurations
make delete   # Remove all symlinks (cleanup)
make dry-run # Preview changes without changes
```

#### Manual Symlinks
Without `stow`, create symlinks with `ln -sf <src/target> <dst/real>`:
```bash
ln -sf "$(pwd)/dot-config/nvim" "$HOME/.config/nvim"
ln -sf "$(pwd)/dot-vim/.vimrc" "$HOME/.vimrc"
ln -sf "$(pwd)/dot-bash/.bashrc" "$HOME/.bashrc"
```

### Windows

#### script (recommended)

See [`install_windows.ps1`](./windows/install_windows.ps1) and run in an elevated prompt:
```powershell
Start-Process wt -Verb RunAs
Unblock-File -Path .\install_windows.ps1
.\install_windows.ps1
```

#### Manual Symlinks
```powershell
New-Item -ItemType SymbolicLink `
    -Path $PROFILE `
    -Target "$(Resolve-Path ".\windows\Microsoft.PowerShell_profile.ps1")" `
    -Force

New-Item -ItemType SymbolicLink `
    -Path "$env:USERPROFILE\.wslconfig" `
    -Target "$(Resolve-Path ".\windows\.wslconfig")" `
    -Force

New-Item -ItemType SymbolicLink `
    -Path "$HOME\_vimrc" `
    -Target "$(Resolve-Path ".\dot-home\.vimrc")" `
    -Force

New-Item -ItemType SymbolicLink `
    -Path "$env:LOCALAPPDATA\nvim" `
    -Target "$(Resolve-Path ".\dot-config\nvim")" `
    -Force
```

## Info
See [Neovim README](./dot-config/nvim/README.md) for more on that.
