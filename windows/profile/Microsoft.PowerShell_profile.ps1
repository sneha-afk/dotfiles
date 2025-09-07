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

# Source other profile scripts or modules
$script:ProfileDir = Split-Path -Path $PROFILE -Parent
$script:ProfileModulesDir = Join-Path $script:ProfileDir "Modules"

if ($env:PSModulePath -notlike "*$ProfileModulesDir*") {
    $env:PSModulePath = "$ProfileModulesDir;$env:PSModulePath"
}

function Test-CommandExists-Cache {
    param([Parameter(Mandatory)]$Command)
    if ($script:CommandCache.ContainsKey($Command)) { return $script:CommandCache[$Command] }
    $exists = $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
    $script:CommandCache[$Command] = $exists
    return $exists
}

Register-EngineEvent PowerShell.OnIdle -SupportEvent -Action {
    if (-not $global:__PROFILE_HELPERS_LOADED) {
        $global:__PROFILE_HELPERS_LOADED = $true
        Import-Module helpers -DisableNameChecking
    }
}

#endregion

# ========================[ Region: Utility Functions ]========================
#region Utilities

function Reload-Profile { . $PROFILE }
function Edit-Profile { $PROFILE | Invoke-Item }

function mkcd {
    param([Parameter(Mandatory)][string]$Path)
    New-Item -ItemType Directory -Path $Path -ErrorAction SilentlyContinue | Out-Null
    Set-Location $Path
}

# Measure word/line/char (like wc)
function wc {
    if ($args) { Get-Content @args | Measure-Object -Line -Word -Character }
    else       { $input       | Measure-Object -Line -Word -Character }
}
#endregion

# ========================[ Region: Aliases ]==================================
#region Aliases
# Source the aliases file if it exists
$aliasesFile = "$HOME\.aliases.ps1"
if (Test-Path $aliasesFile) { . $aliasesFile}

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
#endregion

# ========================[ Region: Editor Selection ]=========================
#region Editor
if (-not $script:EditorCache) {
    $script:EditorCache = foreach ($e in 'nvim','pvim','vim','vi','code','notepad++','sublime_text') {
        if (Test-CommandExists-Cache $e) { $e; break }
    }
    if (-not $script:EditorCache) { $script:EditorCache = 'notepad' }
}
$env:EDITOR = $script:EditorCache
Set-Alias vim $script:EditorCache
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
