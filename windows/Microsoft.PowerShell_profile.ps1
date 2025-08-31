# ========================[ Initialization ]===================================
#region Init
# $script variables are persistent across function calls
if (-not $script:CommandCache) { $script:CommandCache = @{} }

if (-not $script:GitCache) { $script:GitCache = @{} }
if (-not $script:VenvCache) { $script:VenvCache = if ($env:VIRTUAL_ENV) { Split-Path -Leaf $env:VIRTUAL_ENV } else { $null } }
if (-not $script:IsWSL) { $script:IsWSL = [bool]$env:WSL_DISTRO_NAME }

if (-not $script:PreferredShell) {
    $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
    $script:PreferredShell = if ($pwsh) { "pwsh.exe" } else { "powershell.exe" }
}
#endregion

# ========================[ Region: Admin & Elevated ]=========================
#region Admin
function Admin {
    param([string[]]$Command)

    if ($Command) {
        $argList = $Command -join ' '
        Start-Process wt -Verb RunAs -ArgumentList "$script:PreferredShell -NoExit -Command $argList"
    } else {
        Start-Process wt -Verb RunAs -ArgumentList $script:PreferredShell
    }
}
Set-Alias su Admin

function Require-Admin {
    param([string]$FunctionName)

    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
               ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isAdmin) {
        Write-Host "Restarting '$FunctionName' as administrator..." -ForegroundColor Yellow
        Start-Process $script:PreferredShell -Verb RunAs -ArgumentList "-NoExit", "-Command `"& { $FunctionName }`""
        return
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
    Require-Admin $MyInvocation.MyCommand.Name

    Get-Process wslservice -ErrorAction SilentlyContinue | Stop-Process -Force
    Write-Host "WSL service stopped" -ForegroundColor Green
}

function Neovide-WSL {
    Start-Process neovide.exe --server localhost:6666
}

function To-WSLPath {
    param([Parameter(Mandatory)][string]$WinPath)
    wsl.exe wslpath -a "`"$WinPath`"" | ForEach-Object { $_.Trim() }
}
#endregion

# ========================[ Region: Utility Functions ]========================
#region Utilities
function Test-CommandExists {
    param([Parameter(Mandatory)]$Command)
    if ($script:CommandCache.ContainsKey($Command)) { return $script:CommandCache[$Command] }
    $exists = $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
    $script:CommandCache[$Command] = $exists
    return $exists
}

function Edit-Profile { $PROFILE | Invoke-Item }

function mkcd {
    param([Parameter(Mandatory)][string]$Path)
    New-Item -ItemType Directory -Path $Path -ErrorAction SilentlyContinue | Out-Null
    Set-Location $Path
}

function Reload-Profile { . $PROFILE }

# Measure word/line/char (like wc)
function wc {
    if ($args) { Get-Content @args | Measure-Object -Line -Word -Character }
    else       { $input       | Measure-Object -Line -Word -Character }
}
#endregion

# ========================[ Region: Neovim Helpers ]==============================
#region Neovim
if (Get-Command nvim -ErrorAction SilentlyContinue) {
    $nvimConfig = "$env:LOCALAPPDATA\nvim"
    $nvimData   = "$env:LOCALAPPDATA\nvim-data"
    $nvimLazy   = "$nvimData\lazy"
    $nvimMason  = "$nvimData\mason"
    $nvimTS     = "$nvimLazy\nvim-treesitter\parser"
    $nvimCache  = "$nvimData\cache"
    $nvimSwap   = "$nvimData\swap"

    function nvim_goto_config {
        Set-Location $nvimConfig
    }

    function nvim_dump_swap {
        if (Test-Path $nvimSwap) {
            Remove-Item -Recurse -Force "$nvimSwap\*" -ErrorAction SilentlyContinue
            Write-Host "Neovim swap files cleared." -ForegroundColor Green
        }
    }

    function nvim_server {
        nvim --headless --listen localhost:6666
    }

    function leetcode {
        nvim leetcode.nvim
    }

     function nvim_reset {
        if (Test-Path $nvimConfig) { Remove-Item -Recurse -Force $nvimConfig -ErrorAction SilentlyContinue }
        if (Test-Path $nvimData)   { Remove-Item -Recurse -Force $nvimData   -ErrorAction SilentlyContinue }
        Write-Host "Neovim has been completely reset (folders removed)." -ForegroundColor Green
    }

    function nvim_size {
        function Get-FolderSizeBytes($path) {
            if (Test-Path $path) {
                $files = Get-ChildItem -Recurse -Force -File -ErrorAction SilentlyContinue $path
                return ($files | Measure-Object -Property Length -Sum).Sum
            } else {
                return 0
            }
        }

        function Format-Size($bytes) {
            if ($bytes -ge 1MB) {
                return "{0:N1} MB" -f ($bytes / 1MB)
            } else {
                return "{0:N1} KB" -f ($bytes / 1KB)
            }
        }

        $config_b   = Get-FolderSizeBytes $nvimConfig
        $lazy_b     = Get-FolderSizeBytes $nvimLazy
        $mason_b    = Get-FolderSizeBytes $nvimMason
        $ts_b       = Get-FolderSizeBytes $nvimTS
        $cache_b    = Get-FolderSizeBytes $nvimCache

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

# ========================[ Region: Aliases ]==================================
#region Aliases
# Prefer Set-Alias to avoid function wrapping when possible
Set-Alias   ll    Get-ChildItem
function la { Get-ChildItem -Force }
Set-Alias   grep  Select-String
Set-Alias   which Get-Command
function .. { Set-Location .. }
function home { Set-Location $env:USERPROFILE }

# WSL aliases
Set-Alias -Name wslr -Value WSL-Restart
Set-Alias -Name wslk -Value WSL-Kill

function dotfiles { Set-Location "~\dotfiles" }

# Source the aliases file if it exists
$aliasesFile = "$HOME\.aliases.ps1"
if (Test-Path $aliasesFile) { . $aliasesFile}
#endregion

# ========================[ Region: Git Shortcuts ]===========================
#region Git
function gs { git status }
function gco { git checkout @args }
function gaa { git add . }
function gcm { git commit -m @args }
function gp  { git push }
function gl  { git log --oneline -10 }
#endregion

# ========================[ Region: Editor Selection ]=========================
#region Editor
if (-not $script:EditorCache) {
    $script:EditorCache = foreach ($e in 'nvim','pvim','vim','vi','code','notepad++','sublime_text') {
        if (Test-CommandExists $e) { $e; break }
    }
    if (-not $script:EditorCache) { $script:EditorCache = 'notepad' }
}
$EDITOR = $script:EditorCache
Set-Alias vim $EDITOR
#endregion

# ========================[ Region: Color Config ]===========================
#region Colors
$global:Esc   = [char]27
$global:Reset = "${Esc}[0m"
$global:Bold  = "${Esc}[1m"

$global:FG = @{
    Red     = "${Esc}[31m"
    Green   = "${Esc}[32m"
    Yellow  = "${Esc}[33m"
    Blue    = "${Esc}[34m"
    Magenta = "${Esc}[35m"
    Cyan    = "${Esc}[36m"
    Gray    = "${Esc}[90m"
}

function global:Color($color, $text, [switch]$BoldText) {
    $prefix = if ($BoldText) { $global:Bold } else { "" }
    return "$prefix$($FG[$color])$text$Reset"
}
#endregion

# ========================[ Region: Prompt ]===========================
#region Prompt

function Get-GitInfo {
    $cwd = Get-Location
    if ($script:GitCache.ContainsKey($cwd)) { return $script:GitCache[$cwd] }

    try {
        if (-not (git rev-parse --is-inside-work-tree 2>$null)) { return $null }
        $branch = git rev-parse --abbrev-ref HEAD 2>$null
        if (-not $branch) { return $null }
        $dirty  = (git status --porcelain 2>$null | Select-Object -First 1)
        $info = @{ Branch = $branch; Dirty = $dirty }
        $script:GitCache[$cwd] = $info
        return $info
    } catch { return $null }
}

function global:prompt {
    $status_indicator = if ($? -eq $true) { (Color 'Green' '+') } else { (Color 'Red' '-') }

    $hostStr = "$env:USERNAME@$env:COMPUTERNAME"
    if ($script:IsWSL) { $hostStr += " (wsl)" }
    $userHost = (Color 'Blue' $hostStr)

    $cwd = Split-Path -Leaf (Get-Location) -ErrorAction SilentlyContinue
    if ([string]::IsNullOrEmpty($cwd)) { $cwd = (Get-Location).Path }
    $pathSeg = (Color 'Green' $cwd)

    $venvSeg = if ($script:VenvCache) { " " + (Color 'Magenta' "($script:VenvCache)") } else { "" }

    $gitSeg = ""
    $git = Get-GitInfo
    if ($git) {
        $branchColor = (Color 'Yellow' $git.Branch)
        $dirtyFlag = if ($git.Dirty) { (Color 'Red' '*') } else { "" }
        $gitSeg = " ($branchColor$dirtyFlag)"
    }

    "$userHost [$pathSeg]$gitSeg$venvSeg`nPS $status_indicator "
}
#endregion
