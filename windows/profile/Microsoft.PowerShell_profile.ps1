# $PROFILE, user-scoped at Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1

# ========================[ Initialization ]===================================
#region Init
# $script variables are persistent across function calls
$script:IsWSL = [bool]$env:WSL_DISTRO_NAME

$pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
$script:PreferredShell = if ($pwsh) { "pwsh.exe" } else { "powershell.exe" }

# Source other profile scripts or modules
$script:ProfileDir = Split-Path -Path $PROFILE -Parent
$script:ProfileModulesDir = Join-Path $script:ProfileDir "Modules"

if ($env:PSModulePath -notlike "*$ProfileModulesDir*") {
    $env:PSModulePath = "$ProfileModulesDir;$env:PSModulePath"
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
function Edit-Profile   { Invoke-Item $PROFILE }

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

function which($name) { Get-Command $name -All | Select-Object -ExpandProperty Source }
function touch($path) { New-Item -ItemType File -Path $path -Force | Out-Null }
function open($path)  { Invoke-Item $path }

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
function .. { Set-Location .. }
function home { Set-Location $env:USERPROFILE }

# WSL aliases
Set-Alias -Name wslr -Value WSL-Restart
Set-Alias -Name wslk -Value WSL-Kill

function dotfiles { Set-Location "~\dotfiles" }
#endregion

# ========================[ Region: Editor Selection ]=========================
#region Editor
if (-not $env:EDITOR -or [string]::IsNullOrWhiteSpace($env:EDITOR)) {
    foreach ($e in 'nvim','vim','vi','code','notepad++','sublime_text','notepad') {
        if (Get-Command $e -ErrorAction SilentlyContinue) {
            $env:EDITOR = $e
            [Environment]::SetEnvironmentVariable('EDITOR', $env:EDITOR, 'User')
            break
        }
    }
}

Set-Alias vim $env:EDITOR
#endregion

# ========================[ Region: Color Config ]===========================
#region Colors
$script:Esc   = [char]27
$script:Reset = "${script:Esc}[0m"
$script:Bold  = "${script:Esc}[1m"

$script:FG = @{
    Red     = "${script:Esc}[31m"
    Green   = "${script:Esc}[32m"
    Yellow  = "${script:Esc}[33m"
    Blue    = "${script:Esc}[34m"
    Magenta = "${script:Esc}[35m"
    Cyan    = "${script:Esc}[36m"
    Gray    = "${script:Esc}[90m"
}

function Script:Color($color, $text, [switch]$BoldText) {
    $prefix = if ($BoldText) { $script:Bold } else { "" }
    return "$prefix$($script:FG[$color])$text$script:Reset"
}
#endregion

# ========================[ Region: Prompt ]===========================
#region Prompt

$script:LastGitCheck = [datetime]::MinValue
$script:GitInfo = $null

function Get-GitInfo {
    if ((Get-Date) - $script:LastGitCheck -lt [timespan]::FromSeconds(2)) {
        return $script:GitInfo
    }

    try {
        if (-not (git rev-parse --is-inside-work-tree 2>$null)) { return $null }
        $branch = git rev-parse --abbrev-ref HEAD 2>$null
        if (-not $branch) { return $null }

        git diff --quiet --ignore-submodules HEAD 2>$null; $dirty = -not $?
        $script:GitInfo = @{ Branch = $branch; Dirty = $dirty }
    } catch { $script:GitInfo = $null }

    $script:LastGitCheck = Get-Date
    return $script:GitInfo
}

function Get-VenvInfo {
    if ($env:VIRTUAL_ENV) { "($(Split-Path -Leaf $env:VIRTUAL_ENV))" }
}

function global:prompt {
    $status_indicator = if ($?) { (Color 'Green' '+') } else { (Color 'Red' '-') }

    $hostStr = "$env:USERNAME@$env:COMPUTERNAME"
    if ($script:IsWSL) { $hostStr += " (wsl)" }
    $userHost = (Color 'Blue' $hostStr)

    $cwd = (Get-Location).Path -replace [regex]::Escape($HOME), '~'
    if ([string]::IsNullOrEmpty($cwd)) { $cwd = (Get-Location).Path }
    $pathSeg = (Color 'Green' $cwd)

    $venvSeg = if ($venv = Get-VenvInfo) { " " + (Color 'Magenta' $venv) } else { "" }

    $gitSeg = ""
    if ($git = Get-GitInfo) {
        $branchColor = (Color 'Yellow' $git.Branch)
        $dirtyFlag   = if ($git.Dirty) { " " + (Color 'Red' '*') } else { "" }
        $gitSeg      = " | $branchColor$dirtyFlag "
    }

    "$userHost [$pathSeg]$gitSeg$venvSeg`nPS $status_indicator "
}
#endregion
