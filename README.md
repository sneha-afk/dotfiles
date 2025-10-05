# dotfiles

## 📁 Info

* Shell configs: `dot-bash/`, `dot-zsh/`
* Neovim: [`dot-config/nvim`](./dot-config/nvim)
* PowerShell: `windows\profile\Microsoft.PowerShell_profile.ps1`
* WSL: `windows\.wslconfig`
* Windows Terminal with [Geist Mono](https://vercel.com/font)
    * Built in: Segoe UI Emoji
    * Optionally: [Symbols Nerd Font Mono](https://www.nerdfonts.com/font-downloads)
    * In the Font face: `Geist  Mono, Segoe UI Emoji, Symbols Nerd Font Mono`

##  Setup
## 🐧 Unix
### ✅ Recommended: GNU `stow`

```bash
sudo apt-get install git make stow
make         # Boostrap symlinks, installs, etc.
```
- `make delete` to remove all symlinks
- `make dry-run` to preview changes without applying them

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

```powershell
.\windows\bootstrap.ps1
```

Setting up symlinks requires admin, which should automatically happen in the bootstrap. If not,
run the boostrap in an elevated shell:
```powershell
Start-Process wt -Verb RunAs -ArgumentList "powershell -NoProfile -ExecutionPolicy Bypass -File `"$PWD\windows\bootstrap.ps1`""
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

### On `$PROFILE`

The default `$PROFILE` is located in OneDrive, and this is *deeply* integrated within the registry. While this is
fine for just keeping some light configuration files, installing any modules or adding to the config
unncessarily pollutes OneDrive, and is not portable. We can forward to the real `$PROFILE` that will
be stored in user-level Documents.

> Do NOT attempt to change the registry entries related to OneDrive.. been there done that.

A light script that sets `$PROFILE` to `Documents\WindowsPowerShell` is copied to OneDrive in bootstrap.ps1`:
```powershell
Copy-Item -Path ".\windows\utils\fix_profile_path.ps1" -Destination (Join-Path $env:OneDrive "Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1") -Force
```
