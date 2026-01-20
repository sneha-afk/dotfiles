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
        Write-Host "Restarting action as administrator..." -ForegroundColor Yellow
        $encodedCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($Action.ToString()))
        Start-Process wt -Verb RunAs -ArgumentList "$script:PreferredShell -NoProfile -NoExit -EncodedCommand $encodedCommand"
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

function To-WSLPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$WinPath
    )
    process {
        (wsl.exe wslpath -a "`"$WinPath`"").Trim()
    }
}

Set-Alias -Name wslr -Value WSL-Restart
Set-Alias -Name wslk -Value WSL-Kill

#endregion

#region Neovim

$script:NvimPaths = @{
    Config = Join-Path $env:LOCALAPPDATA "nvim"
    Data   = Join-Path $env:LOCALAPPDATA "nvim-data"
}

$script:NvimPaths.Lazy = Join-Path $script:NvimPaths.Data "lazy"
$script:NvimPaths.Mason = Join-Path $script:NvimPaths.Data "mason"
$script:NvimPaths.TreeSitter = Join-Path $script:NvimPaths.Data "site\parser"
$script:NvimPaths.Cache = Join-Path $script:NvimPaths.Data "cache"
$script:NvimPaths.Swap = Join-Path $script:NvimPaths.Data "swap"
$script:NvimPaths.Shada = Join-Path $script:NvimPaths.Data "shada"

Set-Alias vim nvim
Set-Alias nvide neovide

function Enter-NvimConfig {
    Set-Location $script:NvimPaths.Config
}

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

    if ($PSCmdlet.ShouldProcess($script:NvimPaths.Shada, "Clear shada files")) {
        Remove-Item -Path "$($script:NvimPaths.Shada)\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Neovim shada files cleared." -ForegroundColor Green
    }
}

function Start-NvimServer {
    nvim --headless --listen localhost:6666
}

function Reset-Nvim {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param()

    if ($PSCmdlet.ShouldProcess($script:NvimPaths.Data, "Remove all Neovim data")) {
        Remove-Item -Path $script:NvimPaths.Data -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Neovim has been completely reset." -ForegroundColor Green
    }
}

function Get-NvimSize {
    function Get-FolderSize($path) {
        if (Test-Path $path) {
            (Get-ChildItem -Path $path -Recurse -Force -File -ErrorAction SilentlyContinue |
            Measure-Object -Property Length -Sum).Sum
        }
        else { 0 }
    }

    function Format-Size($bytes) {
        if ($bytes -ge 1MB) { "{0:N1} MB" -f ($bytes / 1MB) }
        elseif ($bytes -ge 1KB) { "{0:N1} KB" -f ($bytes / 1KB) }
        else { "$bytes B" }
    }

    $sizes = @{
        'Config Files' = Get-FolderSize $script:NvimPaths.Config
        'Plugins'      = Get-FolderSize $script:NvimPaths.Lazy
        'LSPs'         = Get-FolderSize $script:NvimPaths.Mason
        'Treesitters'  = Get-FolderSize $script:NvimPaths.TreeSitter
        'Cache'        = Get-FolderSize $script:NvimPaths.Cache
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
        [string[]]$Files
    )

    $rgAvailable = Get-Command rg -ErrorAction SilentlyContinue

    if ($rgAvailable) {
        $args = @($Pattern) + $Files
        & rg @args
    }
    else {
        $searchPath = if ($Files) { $Files } else { "." }
        Get-ChildItem -Path $searchPath -Recurse -File | Select-String -Pattern $Pattern
    }
}

function Update-All {
    $commands = @(
        @{
            Name    = 'Scoop'
            Check   = 'scoop'
            Command = { scoop update --all }
        }
        @{
            Name    = 'Winget'
            Check   = 'winget'
            Command = { winget upgrade --all --accept-source-agreements --accept-package-agreements }
        }
        @{
            Name    = 'uv'
            Check   = 'uv'
            Command = { uv self update }
        }
    )

    foreach ($cmd in $commands) {
        if (Get-Command $cmd.Check -ErrorAction SilentlyContinue) {
            Write-Host "Updating $($cmd.Name)..." -ForegroundColor Cyan
            & $cmd.Command
        }
        else {
            Write-Host "$($cmd.Name) is not installed. Skipping." -ForegroundColor Yellow
        }
    }
}

function Expand-Archive {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript({ Test-Path $_ })]
        [string]$Path
    )

    process {
        $extension = [IO.Path]::GetExtension($Path).ToLower()
        $destination = Split-Path $Path -Parent

        switch -Regex ($Path) {
            '\.tar\.gz$' { tar -xzf $Path; break }
            '\.zip$' { Microsoft.PowerShell.Archive\Expand-Archive $Path -DestinationPath $destination; break }
            '\.tar$' { tar -xf $Path; break }
            '\.7z$' { 7z x $Path; break }
            default { Write-Warning "Unsupported archive type: $extension" }
        }
    }
}

Set-Alias extract Expand-Archive
Set-Alias unzip Expand-Archive

function Enter-Repo {
    $repoPath = Join-Path $HOME "Repositories"

    if (-not (Test-Path $repoPath)) {
        Write-Warning "Repository directory not found: $repoPath"
        return
    }

    $repos = Get-ChildItem -Path $repoPath -Directory
    if (-not $repos) {
        Write-Warning "No repositories found in $repoPath"
        return
    }

    $selection = $repos | fzf --prompt "Repo> "
    if ($selection) { Set-Location $selection.FullName }
}

#endregion

#region Exports

Export-ModuleMember -Function @(
    'Require-Admin'
    'Neovide-WSL', 'To-WSLPath', 'WSL-Restart', 'WSL-Kill'
    'Enter-NvimConfig', 'Remove-NvimSwap', 'Remove-NvimShada', 'Start-NvimServer', 'Start-Leetcode', 'Reset-Nvim', 'Get-NvimSize'
    'Search', 'Update-All', 'Expand-Archive', 'Enter-Repo'
) -Alias @(
    'wslr', 'wslk', 'vim', 'nvide', 'extract', 'unzip'
)

#endregion
