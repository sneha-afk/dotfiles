# windows/profile/Modules/helpers/helpers.psm1
# When adding new things, remember to export them at the bottom

#region Admin

$script:PreferredShell = if (Get-Command pwsh -ErrorAction SilentlyContinue) { "pwsh.exe" } else { "powershell.exe" }

# Usage: Require-Admin { script block }
function Require-Admin {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [scriptblock]$Action
    )

    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )

    if ($isAdmin) {
        & $Action
    }
    else {
        Write-Host "Elevating to administrator..." -ForegroundColor Yellow

        # Encode scriptblock for safe passing across process boundary
        $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($Action.ToString()))
        $args = "$script:PreferredShell -NoProfile -NoExit -EncodedCommand $encoded"

        Start-Process wt -Verb RunAs -ArgumentList $args
    }
}

#endregion

#region WSL

function WSL-Restart {
    Write-Host "Shutting down WSL..." -ForegroundColor Yellow
    wsl --shutdown
    Start-Sleep -Seconds 2
    Write-Host "Starting WSL..." -ForegroundColor Green
    wsl --status
}

function WSL-Kill {
    Require-Admin {
        Get-Process wslservice -ErrorAction SilentlyContinue | Stop-Process -Force
        Write-Host "WSL service stopped" -ForegroundColor Green
    }
}

function Neovide-WSL {
    Start-Process neovide.exe --server localhost:6666
}

function Convert-WSLPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Path
    )
    process {
        # Windows paths: drive letters (C:\) or UNC WSL mounts (\\wsl$\)
        if ($Path -match '^[A-Za-z]:\\|^\\\\wsl') {
            # Convert Windows -> WSL (e.g., C:\Users\user -> /mnt/c/Users/user)
            (wsl.exe wslpath -a "`"$Path`"").Trim()
        } else {
            # Assume POSIX path, convert WSL -> Windows
            (wsl.exe wslpath -w "`"$Path`"").Trim()
        }
    }
}

Set-Alias -Name wslr -Value WSL-Restart
Set-Alias -Name wslk -Value WSL-Kill

#endregion

#region Neovim

$script:NvimPaths = @{
    Config     = Join-Path $env:LOCALAPPDATA "nvim"
    Data       = Join-Path $env:LOCALAPPDATA "nvim-data"
    Lazy       = Join-Path $env:LOCALAPPDATA "nvim-data\lazy"
    Mason      = Join-Path $env:LOCALAPPDATA "nvim-data\mason"
    TreeSitter = Join-Path $env:LOCALAPPDATA "nvim-data\site\parser"
    Cache      = Join-Path $env:LOCALAPPDATA "nvim-data\cache"
    Swap       = Join-Path $env:LOCALAPPDATA "nvim-data\swap"
    Shada      = Join-Path $env:LOCALAPPDATA "nvim-data\shada"
}

Set-Alias nvide neovide

function Enter-NvimConfig { Set-Location $script:NvimPaths.Config }

function Remove-NvimSwap {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    if ($PSCmdlet.ShouldProcess($script:NvimPaths.Swap, "Clear swap files")) {
        Remove-Item -Path "$($script:NvimPaths.Swap)\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Neovim swap files cleared." -ForegroundColor Green
    }
}

function Remove-NvimShada {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $tmpFiles = Join-Path $script:NvimPaths.Shada "*.shada.tmp.*"
    if ($PSCmdlet.ShouldProcess($tmpFiles, "Remove stale Neovim shada temp files")) {
        Remove-Item -Path $tmpFiles -Force -ErrorAction SilentlyContinue
        Write-Host "Neovim shada temp files removed." -ForegroundColor Green
    }
}

function Start-NvimServer { nvim --headless --listen localhost:6666 }

function Reset-Nvim {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param()

    if ($PSCmdlet.ShouldProcess($script:NvimPaths.Data, "Remove all Neovim data")) {
        Remove-Item -Path $script:NvimPaths.Data -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Neovim has been completely reset." -ForegroundColor Green
    }
}

function Get-NvimSize {
    # Disk usage breakdown for Neovim directories
    function Get-FolderSize($path) {
        if (-not (Test-Path $path)) { return 0 }
        (Get-ChildItem -Path $path -Recurse -Force -File -ErrorAction SilentlyContinue |
            Measure-Object -Property Length -Sum).Sum
    }

    function Format-Size($bytes) {
        if ($bytes -ge 1MB) { "{0:N1} MB" -f ($bytes / 1MB) }
        elseif ($bytes -ge 1KB) { "{0:N1} KB" -f ($bytes / 1KB) }
        else { "$bytes B" }
    }

    $sizes = @{
        config     = Get-FolderSize $script:NvimPaths.Config
        plugins    = Get-FolderSize $script:NvimPaths.Lazy
        lsp        = Get-FolderSize $script:NvimPaths.Mason
        treesitter = Get-FolderSize $script:NvimPaths.TreeSitter
        cache      = Get-FolderSize $script:NvimPaths.Cache
    }

    $total = ($sizes.Values | Measure-Object -Sum).Sum

    $sizes.GetEnumerator() | ForEach-Object {
        Write-Host ("{0,-13} {1}" -f ($_.Key + ':'), (Format-Size $_.Value))
    }
    Write-Host "`nTotal:        $(Format-Size $total)"
}

#endregion

#region Utilities

function Search {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Pattern,

        [Parameter(Position = 1, ValueFromRemainingArguments)]
        [string[]]$Args
    )

    if (Get-Command rg -ErrorAction SilentlyContinue) {
        & rg $Pattern @Args
    }
    else {
        $path = if ($Args) { $Args } else { "." }
        Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue |
            Select-String -Pattern $Pattern
    }
}

function Update-All {
    $updaters = @(
        @{ Name = 'scoop';  Cmd = 'scoop'; Args = 'update --all' }
        @{ Name = 'winget'; Cmd = 'winget'; Args = 'upgrade --all --accept-source-agreements --accept-package-agreements' }
        @{ Name = 'uv';     Cmd = 'uv'; Args = 'self update' }
    )

    foreach ($u in $updaters) {
        if (-not (Get-Command $u.Cmd -ErrorAction SilentlyContinue)) {
            Write-Host "$($u.Name) not installed, skipping" -ForegroundColor DarkGray
            continue
        }

        Write-Host "Updating $($u.Name)..." -ForegroundColor Cyan
        Invoke-Expression "$($u.Cmd) $($u.Args)"
    }
}

function Expand-Archive {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript({ Test-Path $_ })]

        [string]$Path,
        [string]$DestinationPath
    )

    process {
        $dest = if ($DestinationPath) { $DestinationPath } else { Split-Path $Path -Parent }

        switch -Regex ($Path) {
            '\.tar\.gz$|\.tgz$'         { tar -xzf $Path -C $dest; break }
            '\.tar\.bz2$|\.tbz2?$'      { tar -xjf $Path -C $dest; break }
            '\.tar\.xz$|\.txz$'         { tar -xJf $Path -C $dest; break }
            '\.tar$'                    { tar -xf $Path -C $dest; break }
            '\.zip$'                    { Microsoft.PowerShell.Archive\Expand-Archive $Path -DestinationPath $dest; break }
            '\.7z$'                     { 7z x $Path -o "$dest"; break }
            default                     { Write-Warning "Unsupported archive type: $([IO.Path]::GetExtension($Path))" }
        }
    }
}

Set-Alias extract Expand-Archive

function Enter-Repo {
    $repoPath = Join-Path $HOME "Repositories"
    if (-not (Test-Path $repoPath)) {
        Write-Warning "Repository directory not found: $repoPath"
        return
    }

    $selection = Get-ChildItem $repoPath -Directory -Name | fzf --prompt "Repo> " --height 60%
    if ($selection) { Set-Location (Join-Path $repoPath $selection) }
}

#endregion

#region Exports

Export-ModuleMember -Function @(
    'Require-Admin'
    'Neovide-WSL', 'To-WSLPath', 'WSL-Restart', 'WSL-Kill'
    'Enter-NvimConfig', 'Remove-NvimSwap', 'Remove-NvimShada', 'Start-NvimServer', 'Reset-Nvim', 'Get-NvimSize'
    'Search', 'Update-All', 'Expand-Archive', 'Enter-Repo'
) -Alias @(
    'wslr', 'wslk', 'nvide', 'extract'
)

#endregion
