# dotfiles

## Setup
### `stow`
Using GNU `stow` at the root of this repo:
```bash
make          # Symlink all configurations
make delete   # Remove all symlinks (cleanup)
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
    -Target "$(Resolve-Path ".\Microsoft.PowerShell_profile.ps1")" `
    -Force

New-Item -ItemType SymbolicLink `
    -Path "$HOME\_vimrc" `
    -Target "$(Resolve-Path ".\dot-vim\.vimrc")" `
    -Force

New-Item -ItemType SymbolicLink `
    -Path "$env:LOCALAPPDATA\nvim" `
    -Target "$(Resolve-Path ".\dot-config\nvim")" `
    -Force
```

## Info
See [Neovim README](./dot-config/nvim/README.md) for more on that.

Test `stow` without changes:
```bash
make dry-run
```

Check existing symlinks:
```bash
find ~ -maxdepth 1 -type l -ls | grep dotfiles
```
