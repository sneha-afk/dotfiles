# windows/profile/Modules/helpers/helpers.psm1
# When adding new things, remember to export them at the bottom

# ========================[ Region: Admin & Elevated ]=========================
#region Admin

if (-not $script:PreferredShell) {
    $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
    $script:PreferredShell = if ($pwsh) { "pwsh.exe" } else { "powershell.exe" }
}

# Use like: Require-Admin { <scriptblock> }
function Require-Admin {
    param(
        [Parameter(Mandatory)]
        [scriptblock]$Action
    )

    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
               ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if ($isAdmin) {
        & $Action
    } else {
        Write-Host "Restarting action as administrator..." -ForegroundColor Yellow
        Start-Process wt -Verb RunAs -ArgumentList "powershell -NoProfile -NoExit -Command `"& { $Action }`""
    }
}

#endregion

# ========================[ Region: WSL Helpers ]==============================
#region WSL
function WSL-Restart {
    Write-Host "Shutting down WSL..." -ForegroundColor Yellow
    wsl --shutdown
    Start-Sleep 2
    Write-Host "Starting WSL..." -ForegroundColor Green
    wsl --status
}

function WSL-Kill {
    Require-Admin {
        Get-Process wslservice -ErrorAction SilentlyContinue | Stop-Process -Force
        Write-Host "WSL service stopped" -ForegroundColor Green
    }
}

Set-Alias -Name wslr -Value WSL-Restart
Set-Alias -Name wslk -Value WSL-Kill

function Neovide-WSL { Start-Process neovide.exe --server localhost:6666 }

function To-WSLPath {
    param([Parameter(Mandatory)][string]$WinPath)
    wsl.exe wslpath -a "`"$WinPath`"" | ForEach-Object { $_.Trim() }
}
#endregion

# ========================[ Region: Neovim Helpers ]=========================
#region Neovim
if (Get-Command nvim -ErrorAction SilentlyContinue) {
    $nvimConfig = "$env:LOCALAPPDATA\nvim"
    $nvimData   = "$env:LOCALAPPDATA\nvim-data"
    $nvimLazy   = "$nvimData\lazy"
    $nvimMason  = "$nvimData\mason"
    $nvimTS     = "$nvimLazy\nvim-treesitter\parser"
    $nvimCache  = "$nvimData\cache"
    $nvimSwap   = "$nvimData\swap"
    $nvimShada  = "$nvimData\shada"

    Set-Alias vim nvim
    Set-Alias nvide neovide

    function Enter-NvimConfig { Set-Location $nvimConfig }

    function Remove-NvimSwap {
        if (Test-Path $nvimSwap) {
            Remove-Item -Recurse -Force "$nvimSwap\*" -ErrorAction SilentlyContinue
            Write-Host "Neovim swap files cleared." -ForegroundColor Green
        }
    }

    function Remove-NvimShada {
        if (Test-Path $nvimShada) {
            Remove-Item -Recurse -Force "$nvimShada\*" -ErrorAction SilentlyContinue
            Write-Host "Neovim shada files cleared." -ForegroundColor Green
        }
    }

    function Start-NvimServer { nvim --headless --listen localhost:6666 }

    function Start-Leetcode { nvim leetcode.nvim }

    function Reset-Nvim {
        if (Test-Path $nvimData) { Remove-Item -Recurse -Force $nvimData -ErrorAction SilentlyContinue }
        Write-Host "Neovim has been completely reset (folders removed)." -ForegroundColor Green
    }

    function Get-NvimSize {
        function Get-FolderSizeBytes($path) {
            if (Test-Path $path) {
                $files = Get-ChildItem -Recurse -Force -File -ErrorAction SilentlyContinue $path
                return ($files | Measure-Object -Property Length -Sum).Sum
            } else {
                return 0
            }
        }

        function Format-Size($bytes) {
            if ($bytes -ge 1MB) { return "{0:N1} MB" -f ($bytes / 1MB) }
            else { return "{0:N1} KB" -f ($bytes / 1KB) }
        }

        $config_b = Get-FolderSizeBytes $nvimConfig
        $lazy_b   = Get-FolderSizeBytes $nvimLazy
        $mason_b  = Get-FolderSizeBytes $nvimMason
        $ts_b     = Get-FolderSizeBytes $nvimTS
        $cache_b  = Get-FolderSizeBytes $nvimCache

        $total_b = $config_b + $lazy_b + $mason_b + $ts_b + $cache_b

        Write-Host "Config Files: $(Format-Size $config_b)"
        Write-Host "Plugins:      $(Format-Size $lazy_b)"
        Write-Host "LSPs:         $(Format-Size $mason_b)"
        Write-Host "Treesitters:  $(Format-Size $ts_b)"
        Write-Host "Cache:        $(Format-Size $cache_b)`n"
        Write-Host "Total:        $(Format-Size $total_b)"
    }
}
#endregion

# ========================[ Utilities ]=========================
#region Utilities
function Search {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Pattern,

        [Parameter(Position=1, ValueFromRemainingArguments=$true)]
        [string[]]$Files
    )

    if ($Pattern -eq "") {
        Write-Host "Usage: Search <pattern> [files...]"
        Write-Host "Search for pattern in files using rg/Select-String fallback"
        return
    }

    $searchPath = if ($Files.Count -gt 0) { $Files } else { "." }

    $excludePatterns = @(
        '!.git', '!.svn', '!.hg', '!CVS',

        '!.vscode-server', '!.vscode/extensions', '!.idea', '!.vs', '!*.swp', '!*.swo',

        '!node_modules', '!.npm', '!.yarn', '!bower_components',
        '!.cargo', '!target/', '!Cargo.lock',
        '!__pycache__', '!*.pyc', '!venv', '!.venv', '!.python-version',
        '!.mvn', '!target/', '!gradle/', '!.gradle',
        '!.nuget', '!packages/', '!bin/', '!obj/',
        '!_build/', '!.elixir_ls/', '!deps/',

        '!env', '!.env', '!.env.*', '!local.env',

        '!.cache', '!cache/', '!tmp/', '!temp/', '!*.tmp', '!*.temp',

        '!Thumbs.db', '!.DS_Store', '!*.lnk',
        '!*AppData/*', '!*ntuser*',

        '!*.log', '!logs/'
    )

    if (Get-Command rg -ErrorAction SilentlyContinue) {
        $rgArgs = @(
            "--smart-case",
            "--hidden",
            "--follow",
            "--no-heading",
            "--line-number"
        )

        foreach ($pattern in $excludePatterns) {
            $rgArgs += "--glob"
            $rgArgs += $pattern
        }

        $rgArgs += $Pattern
        $rgArgs += $searchPath

        rg @rgArgs
    }
    else {
        $psExclude = $excludePatterns | Where-Object { $_ -match '^!(.+)$' } | ForEach-Object {
            $matches[1] -replace '^\.', '*' -replace '/$', '*'
        }

        Get-ChildItem -Path $searchPath -Recurse -File | Where-Object {
            $filePath = $_.FullName
            $shouldInclude = $true
            foreach ($pattern in $psExclude) {
                if ($filePath -like "*$pattern*") {
                    $shouldInclude = $false
                    break
                }
            }
            $shouldInclude
        } | Select-String -Pattern $Pattern
    }
}

function Update-All {
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "Updating Scoop and all installed packages..." -ForegroundColor Cyan
        scoop update --all
    } else {
        Write-Host "Scoop is not installed. Skipping Scoop update." -ForegroundColor Yellow
    }

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "Updating Winget packages..." -ForegroundColor Cyan
        winget upgrade --all --accept-source-agreements --accept-package-agreements
    } else {
        Write-Host "Winget is not installed. Skipping Winget update." -ForegroundColor Yellow
    }

    if (Get-Command uv -ErrorAction SilentlyContinue) {
        uv self update
    }
}

function unzip {
    param([string]$file)
    if (-not (Test-Path $file)) { Write-Host "File not found: $file" -ForegroundColor Red; return }
    switch -Regex ($file) {
        '\.tar\.gz$' { tar -xzf $file; break }
        '\.zip$'     { Expand-Archive $file -DestinationPath (Split-Path $file -Parent); break }
        '\.tar$'     { tar -xf $file; break }
        '\.7z$'      { 7z x $file; break }
        default      { Write-Host "Unsupported archive type." -ForegroundColor Yellow }
    }
}
Set-Alias extract unzip

#endregion

# ========================[ Exports ]=========================
#region Exports
Export-ModuleMember -Function `
    Require-Admin, `
    Neovide-WSL, To-WSLPath, WSL-Restart, WSL-Kill, `
    Enter-NvimConfig, Remove-NvimSwap, Remove-NvimShada, Start-NvimServer, Start-Leetcode, Reset-Nvim, Get-NvimSize, `
    Search, Update-All, unzip `
    -Alias wslr, wslk, vim, nvide, extract
#endregion
