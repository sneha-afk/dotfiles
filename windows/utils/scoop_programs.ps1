# windows/utils/scoop_programs.ps1

function Install-Scoop {
    param([switch]$Force)

    if ((Test-CommandExists "scoop") -and (-not $Force)) {
        Write-Host "Scoop already installed, performing updates" -ForegroundColor Green
        scoop update
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
        "coreutils"
        "gcc"           # Includes g++
        "make"
        "ripgrep"
        "fd"
        "fastfetch"
    )

    Write-Host "Installing packages: $($packages -join ', ')"
    scoop update

    # Can't pass in an array directly, so loop
    foreach ($pkg in $packages) {
        scoop install $pkg
    }
    Write-Host "Packages installed successfully." -ForegroundColor Green

    if ($packages -contains "gcc") { New-GlobalClangd }
}

function New-GlobalClangd {
    <#
    .SYNOPSIS
        Generates a global .clangd file in the user's home directory.
    #>

    $homeDir = $env:USERPROFILE
    if (-not $homeDir) { $homeDir = $HOME }

    $clangdPath = Join-Path $homeDir ".clangd"

    $gccPath = ""
    try {
        $gccPath = scoop prefix gcc
    } catch {
        Write-Host "Scoop GCC not found, skipping gcc-toolchain."
    }

    $content = "CompileFlags:`n  Add:`n"
    if ($gccPath) {
        $content += "    - --gcc-toolchain=$gccPath`n"
        $content += "    - -target`n"
        $content += "    - x86_64-w64-mingw32`n"
    }

    Set-Content -Path $clangdPath -Value $content -Encoding UTF8
    Write-Host "Global .clangd generated at $clangdPath"
}

