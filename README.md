# dotfiles
## 📁 structure
| Area           | Location / Notes                                           |
| -------------- | ---------------------------------------------------------- |
| **Shells**     | `dot-bash/`, `pswh`   |
| **PowerShell** | `windows\profile\Microsoft.PowerShell_profile.ps1`         |
| **Neovim**     | `dot-config/nvim` — see its [README.md](./dot-config/nvim/) |
| **WSL**        | `windows\.wslconfig`, `dot-home/.wsl_env`                  |
| **Terminals**  | [WezTerm](https://wezterm.org/)          |
| **Fonts**      | [Geist Mono](https://vercel.com/font), Segoe UI Emoji (built-in), optional [Symbols Nerd Font Mono](https://www.nerdfonts.com/font-downloads) |

Other helpful files in `dot-config -> .config` and `dot-home -> ~/*`.

<details>
<summary>💻 my hardware</summary>

- **Laptop**: ThinkPad X1 Carbon Gen 10 (2022)
  - Intel Core i7-1260P (12th Gen)
  - Intel Iris Xe Graphics
- **OS**: Windows 11 Pro with WSL2 (Ubuntu)
- **Monitor**: Dell U2723QE

---
</details>

## ⚙️ Setup

### ⭐ Recommended: `trovl` for symlinks

Use [trovl](https://github.com/sneha-afk/trovl) (my project :>) for simple, declarative symlink management across all platforms:

```bash
# Install trovl (using Go)
go install github.com/sneha-afk/trovl@latest

# Apply manifest: must be run from the root of this repo
# Can add --overwrite and/or --backup
trovl apply trovl-manifest.json

# Preview changes
trovl apply trovl-manifest.json --dry-run
```

Also see [manual installation methods](https://github.com/sneha-afk/trovl/blob/main/docs/install.md).

The manifest file (`trovl-manifest.json`) is located at the root of this repo.

---

### 🐧 Linux

```bash
sudo apt-get install git make curl tar
make trovl       # Installs trovl and applies manifest
make eget        # Installs binary tools (lazygit, tree-sitter, ripgrep, fd, nvim, etc.)
```

<details>
<summary>Symlinks: Using GNU Stow</summary>

```bash
make install-home    # Bootstrap home (~/*) symlinks
make install-config  # Bootstrap config (~/.config) symlinks
make zsh             # Bootstrap Zsh config
make delete          # Remove all symlinks
make dry-run         # Preview symlink changes without applying
```

</details>

<details>
<summary>Manual Symlinks</summary>

```bash
ln -sf "$(pwd)/dot-config/nvim" "$HOME/.config/nvim"
ln -sf "$(pwd)/dot-vim/.vimrc" "$HOME/.vimrc"
ln -sf "$(pwd)/dot-bash/.bashrc" "$HOME/.bashrc"
```
</details>

#### shell prompt customization

The shell environment files have some customization options.

Set these in the `.bashrc` or `.zshrc` **before** the prompt script is sourced:

| Variable | Default | Description |
| --- | --- | --- |
| `_PROMPT_USE_CUSTOM` | `true` | Set to `false` to revert to the default system prompt. |
| `_PROMPT_SHOW_GIT_STATUS` | `true` | Set to `false` to skip heavy `git diff` checks (Branch name only). |
| (`.bashrc`) `_PROMPT_USE_GIT_PROMPT_SCRIPT` | `true` | Set to `false` to fallback to the basic status |
| `_PROMPT_PREPEND` | `""` | Optional text/prefix to add to the start of the prompt. |

To prevent terminal lag, the prompt only reads the branch name from `.git/HEAD` by default. If `_PROMPT_SHOW_GIT_STATUS` is enabled, it performs the extra I/O required to show staged (`+`) or unstaged (`*`) indicators. Turn this off as needed.

---

### 🪟 Windows

The bootstrap script goes through installing from `winget`, `scoop`, and symlinks (if not using `trovl`):

```powershell
.\windows\bootstrap.ps1
# Skip components: -SkipScoop, -SkipWinget, -SkipSymlinks, etc.
```

Getting packages through manifests:
```powershell
winget import -i .\windows\winget_packages.json
scoop import .\windows\scoopfile.json
```

<details>
<summary>Run with elevated permissions</summary>

If bootstrap fails, run in elevated PowerShell (auto-elevation within the script should handle this):

```powershell
Start-Process wt -Verb RunAs -ArgumentList `
  "powershell -NoProfile -ExecutionPolicy Bypass -File `"$PWD\windows\bootstrap.ps1`""
```
</details>

<details>
<summary>Manual Symlinks</summary>

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
</details>

#### ⚠️ On `$PROFILE`

The default `$PROFILE` path resolves inside OneDrive, which leads to:
* Unwanted OneDrive pollution when modules or profile-related files are created
* Reduced portability across machines
* Ongoing background sync overhead for files that don't need it

<details>
<summary>Solution: relocate the PowerShell profile</summary>

Redirect `$PROFILE` to a local path under `Documents\WindowsPowerShell` (and the equivalent directory for `pwsh`).

A small utility script is used to redefine `$PROFILE`. This script is copied into the standard
`Documents` directory and sourced automatically. As a result, **only this single profile file remains in OneDrive**, while the actual working profile lives locally.

```powershell
Copy-Item -Path ".\windows\utils\fix_profile_path.ps1" `
          -Destination (Join-Path $env:OneDrive "Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1") `
          -Force
```
</details>

> Do **not** attempt to change the registry entries related to OneDrive... been there done that.
