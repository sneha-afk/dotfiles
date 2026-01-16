<#
.SYNOPSIS
    Bootstrap winget package manager and essential packages.
.LINK
    https://github.com/microsoft/winget-cli
#>

$packages = @(
    "Git.Git", "vim.vim", "Neovim.Neovim", "SumatraPDF.SumatraPDF", "JesseDuffield.lazygit",
    "Obsidian.Obsidian", "Python.PythonInstallManager", "Microsoft.PowerToys"
)

foreach ($pkg in $packages) {
    Write-Host "Winget: Ensuring $pkg" -ForegroundColor Yellow
    winget install --id $pkg --silent --accept-package-agreements --accept-source-agreements
}
