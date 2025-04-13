# dotfiles

## Setup
Using GNU `stow` at the root of this repo:
```bash
make
# `make delete` to remove all 
```

Manually setting up symlinks:
```bash
ln -sf "$(pwd)/dot-config/nvim" "$HOME/.config/nvim"
ln -sf "$(pwd)/dot-vim/.vimrc" "$HOME/.vimrc"
ln -sf "$(pwd)/dot-bash/.bashrc" "$HOME/.bashrc"
```

And for Powershell:
```powershell
New-Item -ItemType SymbolicLink `
    -Path  $PROFILE `
    -Target "path\dotfiles\Microsoft.PowerShell_profile.ps1"

New-Item -ItemType SymbolicLink `
    -Path "$HOME\_vimrc" `
    -Target "path\dotfiles\.vimrc"
```

See info about Neovim at its [README](./.config/nvim/README.md)
