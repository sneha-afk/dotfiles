# $PROFILE, user-scoped at Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1

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

    # Folder modules and .psm1 files
    Get-ChildItem $global:ProfileModulesDir -EA Silent | Where-Object {
        $_.PSIsContainer -or $_.Extension -eq '.psm1'
    } | ForEach-Object {
        try { Import-Module $_.FullName -DisableNameChecking -EA Stop }
        catch { Write-Host "Failed to load $($_.Name): $_" -ForegroundColor Red }
    }
}

Register-EngineEvent PowerShell.OnIdle -SupportEvent -Action {
    if (Test-Path variable:__GIT_AVAILABLE) { return }
    $ExecutionContext.SessionState.PSVariable.Set(
        '__GIT_AVAILABLE',
        [bool](Get-Command git -EA Silent)
    )
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

#region Utilities

function Reload-Profile { . $PROFILE }
function Edit-Profile { Invoke-Item $PROFILE }
function mkcd($Path) { New-Item -Type Directory $Path -EA Silent | Out-Null; Set-Location $Path }

# Unix-like commands (only if not already present)
if (-not (Get-Command wc -EA Silent)) {
    function wc { ($args ? (Get-Content @args) : $input) | Measure-Object -Line -Word -Character }
}
if (-not (Get-Command touch -EA Silent)) {
    function touch($path) { New-Item -Type File $path -Force | Out-Null }
}
if (-not (Get-Command open -EA Silent)) {
    Set-Alias open Invoke-Item
}
if (-not (Get-Command time -EA Silent)) {
    function time {
        param([Parameter(Mandatory, ValueFromRemainingArguments)][string[]]$Command)
        $result = Measure-Command { & ([scriptblock]::Create(($Command -join ' '))) }
        Write-Host ("real  {0:N3}s" -f $result.TotalSeconds)
    }
}

# Export like Bash 'export NAME=value'; on PowerShell it is '$env:NAME = "value"'
function Export($Assignment) {
    if ($Assignment -match '^(?<name>[^=]+)=(?<value>.*)$') {
        $name = $matches['name'].Trim()
        $value = $matches['value'].Trim() -replace '^["'']|["'']$'
        Set-Item "Env:$name" -Value (Invoke-Expression "`"$value`"")
    }
    else {
        Write-Error "Usage: export NAME=value"
    }
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
if (Test-Path $aliasesFile) { . $aliasesFile }

# Prefer Set-Alias to avoid function wrapping when possible
Set-Alias ll Get-ChildItem
Set-Alias grep Select-String
Set-Alias which Get-Command

function la { Get-ChildItem -Force }
function .. { Set-Location .. }
function home { Set-Location $env:USERPROFILE }
function dotfiles { Set-Location "~\dotfiles" }

if (Test-Path "$HOME\.ripgreprc") { $env:RIPGREP_CONFIG_PATH = "$HOME\.ripgreprc" }

#endregion

#region Editor
if (-not $env:EDITOR -or [string]::IsNullOrWhiteSpace($env:EDITOR)) {
    foreach ($e in 'nvim', 'vim', 'vi', 'code', 'notepad++', 'sublime_text', 'notepad') {
        if (Get-Command $e -ErrorAction SilentlyContinue) {
            $env:EDITOR = $e
            [Environment]::SetEnvironmentVariable('EDITOR', $env:EDITOR, 'User')
            break
        }
    }
}
#endregion

#endregion

#region Prompt
# Config: $PROMPT_USE_CUSTOM, $PROMPT_SHOW_GIT_STATUS, $PROMPT_PREPEND
if (-not (Test-Path variable:PROMPT_USE_CUSTOM)) { $global:PROMPT_USE_CUSTOM = $true }
if (-not (Test-Path variable:PROMPT_SHOW_GIT_STATUS)) { $global:PROMPT_SHOW_GIT_STATUS = $true }
if (-not (Test-Path variable:PROMPT_PREPEND)) { $global:PROMPT_PREPEND = "" }

if (-not $PROMPT_USE_CUSTOM) { return }

function Color($name, $text) {
    $fg = $PSStyle.Foreground
    switch ($name) {
        'Red' { "$($fg.Red)$text$($PSStyle.Reset)" }
        'Green' { "$($fg.Green)$text$($PSStyle.Reset)" }
        'Yellow' { "$($fg.Yellow)$text$($PSStyle.Reset)" }
        'Blue' { "$($fg.Blue)$text$($PSStyle.Reset)" }
        default { $text }
    }
}

function Get-GitInfo {
    try {
        git rev-parse --is-inside-work-tree *> $null
        if (-not $?) { return $null }

        $branch = git symbolic-ref --quiet --short HEAD 2>$null
        if (-not $?) {
            $branch = git rev-parse --short HEAD 2>$null
            if (-not $?) { return $null }
        }

        $dirty = $false
        if ($global:PROMPT_SHOW_GIT_STATUS) {
            $output = git status --porcelain --untracked-files=no --ignore-submodules=dirty 2>$null
            if (-not [string]::IsNullOrEmpty($output)) { $dirty = $true }
        }

        @{
            Branch = $branch.Trim()
            Dirty  = $dirty
        }
    }
    catch {
        return $null
    }
}

function global:prompt {
    $ok = $?
    $status = if ($ok) { Color Green '+' } else { Color Red '-' }

    $hostStr = "$env:USERNAME@$env:COMPUTERNAME"
    if ($script:IsWSL) { $hostStr += " (wsl)" }

    $cwd = $PWD.ProviderPath
    if ($cwd.StartsWith($HOME)) { $cwd = '~' + $cwd.Substring($HOME.Length) }

    $gitSeg = ""
    $git = Get-GitInfo
    if ($git) {
        $dirtyFlag = if ($git.Dirty) { " $(Color Red '*')" } else { "" }
        $gitSeg = " | $(Color Yellow $git.Branch)$dirtyFlag "
    }

    "$(Color Blue $hostStr) [$(Color Green $cwd)]$gitSeg`nPS $status "
}
#endregion
