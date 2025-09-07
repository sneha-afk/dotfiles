# windows/utils/scoop_programs.ps1

function Install-Scoop {
    param([switch]$Force)

    if ((Test-CommandExists "scoop") -and (-not $Force)) {
        Write-Host "Scoop already installed" -ForegroundColor Green
        return
    }

    try {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-RestMethod -Uri "https://get.scoop.sh" | Invoke-Expression

        Write-Host "Scoop installation complete." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to install Scoop: $_"
    }
}

function Bootstrap-ScoopPrograms {
    <#
    .NOTES
        Assumes Scoop is already installed and on PATH.
    #>

    $packages = @(
        "gcc"
        "make"
        "ripgrep"
        "fastfetch"
        "7zip"
    )

    Write-Host "Installing packages: $($packages -join ', ')"
    scoop install $packages
}
