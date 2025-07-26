# dotfiles

## 📁 Info

* Shell configs: `dot-bash/`, `dot-zsh/`
* Neovim: [`dot-config/nvim`](./dot-config/nvim/README.md)
* PowerShell: `windows\Microsoft.PowerShell_profile.ps1`
* WSL: `windows\.wslconfig`
* Windows Terminal with [Geist Mono](https://vercel.com/font)

##  Setup
## 🐧 Unix
### ✅ Recommended: GNU `stow`

```bash
make         # Symlink all configs
make delete  # Remove all symlinks
make dry-run # Preview changes without applying them
```

### 🔗 Manual

Without `stow`, create symlinks with `ln -sf <src/target> <dst/real>`:

```bash
ln -sf "$(pwd)/dot-config/nvim" "$HOME/.config/nvim"
ln -sf "$(pwd)/dot-vim/.vimrc" "$HOME/.vimrc"
ln -sf "$(pwd)/dot-bash/.bashrc" "$HOME/.bashrc"
```

---

## 🪟 Windows
### ✅ Recommended: PowerShell Script

[`install_windows.ps1`](./windows/install_windows.ps1) should be run in an **elevated PowerShell**:

```bash
make windows
```

which expands to:

```powershell
Start-Process wt -Verb RunAs
Unblock-File -Path .\install_windows.ps1
.\install_windows.ps1
```


### 🔗 Manual

```powershell
New-Item -ItemType SymbolicLink `
  -Path $PROFILE `
  -Target "$(Resolve-Path .\windows\Microsoft.PowerShell_profile.ps1)" `
  -Force

New-Item -ItemType SymbolicLink `
  -Path "$env:USERPROFILE\.wslconfig" `
  -Target "$(Resolve-Path .\windows\.wslconfig)" `
  -Force

New-Item -ItemType SymbolicLink `
  -Path "$HOME\_vimrc" `
  -Target "$(Resolve-Path .\dot-home\.vimrc)" `
  -Force

New-Item -ItemType SymbolicLink `
  -Path "$env:LOCALAPPDATA\nvim" `
  -Target "$(Resolve-Path .\dot-config\nvim)" `
  -Force
```
