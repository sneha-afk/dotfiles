# dotfiles

## Setup
After cloning the repo, setting up symlinks in the home directory can be done for ease:

```bash
# Run from the repository root
ln -sf "$(pwd)/.config/nvim" "$HOME/.config/nvim"
ln -sf "$(pwd)/.vimrc" "$HOME/.vimrc"
ln -sf "$(pwd)/.bashrc" "$HOME/.bashrc"
```

And for Powershell:
```powershell
New-Item -ItemType SymbolicLink
    -Path  $PROFILE
    -Target "path\dotfiles\Microsoft.PowerShell_profile.ps1"

New-Item -ItemType SymbolicLink
    -Path "$HOME\_vimrc"
    -Target "path\dotfiles\.vimrc"
```

See info about Neovim at its [README](./.config/nvim/README.md)
