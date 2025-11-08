
# dotfiles

## 📁 structure

| Area           | Location / Notes                                           |
| -------------- | ---------------------------------------------------------- |
| **Shells**     | **`dot-bash/`**, `dot-zsh/`                                |
| **Neovim**     | `dot-config/nvim` — see its `README.md` for more info      |
| **PowerShell** | `windows\profile\Microsoft.PowerShell_profile.ps1`         |
| **WSL**        | `windows\.wslconfig`, `dot-home/.wsl_env`                  |
| **Terminals**  | Windows Terminal & [WezTerm](https://wezterm.org/)         |
| **Fonts**      | [Geist Mono](https://vercel.com/font), Segoe UI Emoji (built-in), optional [Symbols Nerd Font Mono](https://www.nerdfonts.com/font-downloads) |

Other helpful files in `dot-config -> .config` and `dot-home`.

---

## ⚙️ Setup
### 🐧 UNIX

**Recommended**: using GNU `stow`

```bash
sudo apt-get install git make stow
make         # Bootstrap symlinks, installs, etc.
make delete  # Remove all symlinks
make dry-run # Preview changes
```

<details>
<summary>Manual Symlinks</summary>

```bash
ln -sf "$(pwd)/dot-config/nvim" "$HOME/.config/nvim"
ln -sf "$(pwd)/dot-vim/.vimrc" "$HOME/.vimrc"
ln -sf "$(pwd)/dot-bash/.bashrc" "$HOME/.bashrc"
```

</details>

---

### 🪟 Windows

**Recommended**: using the bootstrap script

```powershell
.\windows\bootstrap.ps1
```

<details>
<summary>Elevated permissions for bootstrap</summary>

If the bootstrap happens to fail, start in an elevated shell

```powershell
Start-Process wt -Verb RunAs -ArgumentList "powershell -NoProfile -ExecutionPolicy Bypass -File `"$PWD\windows\bootstrap.ps1`""
```
</details>

<details>
<summary>Manual Symlinks</summary>

```powershell
# PowerShell profile
New-Item -ItemType SymbolicLink `
  -Path $PROFILE `
  -Target "$(Resolve-Path .\windows\Microsoft.PowerShell_profile.ps1)" `
  -Force

# WSL config
New-Item -ItemType SymbolicLink `
  -Path "$env:USERPROFILE\.wslconfig" `
  -Target "$(Resolve-Path .\windows\.wslconfig)" `
  -Force

# Vim / Neovim
New-Item -ItemType SymbolicLink `
  -Path "$HOME\_vimrc" `
  -Target "$(Resolve-Path .\dot-home\.vimrc)" `
  -Force

New-Item -ItemType SymbolicLink `
  -Path "$env:LOCALAPPDATA\nvim" `
  -Target "$(Resolve-Path .\dot-config\nvim)" `
  -Force
```
</details>

#### ⚠️ On `$PROFILE`

* Default `$PROFILE` points to OneDrive (deep registry integration).
* Pollutes OneDrive, reduces portability, and constant network polling

<details>
<summary>Solution: point elsewhere</summary>
Forward `$PROFILE` to `Documents\WindowsPowerShell` and pwsh's directory.

```powershell
Copy-Item -Path ".\windows\utils\fix_profile_path.ps1" `
        -Destination (Join-Path $env:OneDrive "Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1") `
        -Force
```
</details>

> ⚠️ Do **not** attempt to change the registry entries related to OneDrive.. been there done that.
