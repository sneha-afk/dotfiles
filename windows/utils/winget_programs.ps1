# windows/utils/winget_programs.ps1

function Bootstrap-WingetPrograms {
    <#
    .NOTES
        Requires Windows 10+ with winget installed.
        Installing an already installed app will update it.
    #>

    $packages = @(
        "Git.Git",
        "Neovim.Neovim",
        "Vim.Vim",
        "Python.Python",
        "Microsoft.PowerToys"
    )

    foreach ($pkg in $packages) {
        Write-Host "Installing/updating $pkg..." -ForegroundColor Yellow
        try {
            winget install --id $pkg --silent --accept-package-agreements --accept-source-agreements
            Write-Host "  SUCCESS $pkg" -ForegroundColor Green
        } catch {
            $errorMsg = $_.Exception.Message
            Write-Warning "Failed to install/update $pkg`: $errorMsg"
        }
    }
}