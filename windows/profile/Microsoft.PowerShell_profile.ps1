# $PROFILE, user-scoped at Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1

# ========================[ Initialization ]===================================
#region Init
$script:IsWSL = [bool]$env:WSL_DISTRO_NAME
$pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
$script:PreferredShell = if ($pwsh) { "pwsh.exe" } else { "powershell.exe" }

# Setup module paths
$global:ProfileModulesDir = Join-Path (Split-Path $PROFILE -Parent) "Modules"

if ($env:PSModulePath -notlike "*$global:ProfileModulesDir*") {
    $env:PSModulePath = "$global:ProfileModulesDir;$env:PSModulePath"
}

# Load modules on idle to speed up initial shell launch
Register-EngineEvent PowerShell.OnIdle -SupportEvent -Action {
    if ($global:__PROFILE_HELPERS_LOADED) { return }
    $global:__PROFILE_HELPERS_LOADED = $true

    if (-not (Test-Path $global:ProfileModulesDir)) { return }

    # Import folder modules
    Get-ChildItem -Path $global:ProfileModulesDir -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        try { Import-Module $_.Name -DisableNameChecking -ErrorAction Stop }
        catch { Write-Host "Failed to load module $($_.Name): $($_.Exception.Message)" -ForegroundColor Red }
    }

    # Import standalone .psm1 files
    Get-ChildItem -Path $global:ProfileModulesDir -File -Filter *.psm1 -ErrorAction SilentlyContinue | ForEach-Object {
        try { Import-Module $_.FullName -DisableNameChecking -ErrorAction Stop }
        catch { Write-Host "Failed to load module $($_.Name): $($_.Exception.Message)" -ForegroundColor Red }
    }
}

# Launch elevated shell (admin/sudo)
function Admin {
    param([string[]]$Command)
    $argList = if ($Command) { "$script:PreferredShell -NoExit -Command $($Command -join ' ')" } else { $script:PreferredShell }
    Start-Process wt -Verb RunAs -ArgumentList $argList
}
Set-Alias su Admin
Set-Alias sudo Admin

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

# Don't overshadow GNU coreutils if installed
if (-not (Get-Command wc -ErrorAction SilentlyContinue)) {
    function wc {
        if ($args) { Get-Content @args | Measure-Object -Line -Word -Character }
        else { $input | Measure-Object -Line -Word -Character }
    }
}

if (-not (Get-Command touch -ErrorAction SilentlyContinue)) {
    function touch($path) { New-Item -ItemType File -Path $path -Force | Out-Null }
}

# 'open' conflicts with browser open command on some systems
if (-not (Get-Command open -ErrorAction SilentlyContinue)) {
    Set-Alias open Invoke-Item
}

if (-not (Get-Command time -ErrorAction SilentlyContinue)) {
    function time {
        param(
            [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
            [string[]]$Command
        )

        $scriptBlock = [scriptblock]::Create(($Command -join ' '))
        $result = Measure-Command { & $scriptBlock }

        Write-Host ("real  {0:N3}s" -f $result.TotalSeconds)
    }
}

# Export like Bash 'export NAME=value'; on PowerShell it is '$env:NAME = "value"'
function Export {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Assignment
    )

    # Split into NAME and VALUE
    if ($Assignment -match '^(?<name>[^=]+)=(?<value>.*)$') {
        $name  = $matches['name'].Trim()
        $value = $matches['value'].Trim()

        # Remove optional surrounding quotes
        if ($value -match '^"(.*)"$') {
            $value = $matches[1]
        } elseif ($value -match "^'(.*)'$") {
            $value = $matches[1]
        }

        # Expand $env:VAR or other PowerShell variables inside
        $expanded = (Invoke-Expression "`"$value`"")

        # Set environment variable
        Set-Item -Path "Env:$name" -Value $expanded
    }
    else { Write-Error "Usage: export NAME=value" }
}

# Usage: Copy bash command -> Run 'cfb' -> Paste
function ConvertFrom-BashCommand {
    $clip = Get-Clipboard -Raw
    $backtick = [char]96
    $converted = $clip -replace '\\\s*[\r]?\n\s*', "$backtick "
    $converted | Set-Clipboard
    Write-Host "Converted bash line continuations to PowerShell backticks. Paste again." -ForegroundColor Green
}
Set-Alias -Name cfb -Value ConvertFrom-BashCommand

# Usage: Alt+V to paste with automatic conversion
# Converts \ to ` and preserves line breaks with indentation for readability
Set-PSReadLineKeyHandler -Chord 'Alt+v' -ScriptBlock {
    $clip = Get-Clipboard -Raw
    $backtick = [char]96
    # Replace backslash + newline with backtick + newline + 2 spaces
    $converted = $clip -replace '\\\s*[\r]?\n\s*', "$backtick`n  "
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($converted)
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
function .. { Set-Location .. }
function home { Set-Location $env:USERPROFILE }
Set-Alias which Get-Command

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

function Script:Color($color, $text) { return "$($script:FG[$color])$text$script:Reset" }
#endregion

# ========================[ Region: Prompt ]===========================
#region Prompt

function Get-GitInfo {
    try {
        if (-not (git rev-parse --is-inside-work-tree 2>$null)) { return $null }

        $branch = git rev-parse --abbrev-ref HEAD 2>$null
        if (-not $branch) { return $null }

        git diff --quiet --ignore-submodules HEAD 2>$null
        $dirty = -not $?

        return @{ Branch = $branch; Dirty = $dirty }
    } catch {
        return $null
    }
}

function global:prompt {
    $status_indicator = if ($?) { (Color 'Green' '+') } else { (Color 'Red' '-') }

    $hostStr = "$env:USERNAME@$env:COMPUTERNAME"
    if ($script:IsWSL) { $hostStr += " (wsl)" }
    $userHost = (Color 'Blue' $hostStr)

    $cwd = (Get-Location).Path -replace [regex]::Escape($HOME), '~'
    if ([string]::IsNullOrEmpty($cwd)) { $cwd = (Get-Location).Path }
    $pathSeg = (Color 'Green' $cwd)

    $gitSeg = ""
    if ($git = Get-GitInfo) {
        $branchColor = (Color 'Yellow' $git.Branch)
        $dirtyFlag   = if ($git.Dirty) { " " + (Color 'Red' '*') } else { "" }
        $gitSeg      = " | $branchColor$dirtyFlag "
    }

    "$userHost [$pathSeg]$gitSeg`nPS $status_indicator "
}
#endregion
