# ========================[ Region: WSL Helpers ]==============================
#region WSL
function wsl-restart {
    wsl.exe --shutdown
    wsl.exe
}

function wsl-kill { taskkill /im wslservice.exe /f }

function nvim-wsl { neovide.exe --server localhost:6666 }

#endregion

# ========================[ Region: Admin & Elevated ]=========================
#region Admin
function admin {
    param([string[]]$Command)
    if ($Command) {
        $argList = $Command -join ' '
        Start-Process wt -Verb RunAs -ArgumentList "pwsh.exe -NoExit -Command $argList"
    } else {
        Start-Process wt -Verb RunAs
    }
}
Set-Alias su admin
#endregion

# ========================[ Region: Utility Functions ]========================
#region Utilities
function Test-CommandExists {
    param([Parameter(Mandatory)]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

# Open profile in preferred editor
function Edit-Profile { $PROFILE | Invoke-Item }

# Quick make‑and‑cd
function mkcd {
    param([Parameter(Mandatory)][string]$Path)
    New-Item -ItemType Directory -Path $Path -ErrorAction SilentlyContinue | Out-Null
    Set-Location $Path
}

# Reload profile
function Reload-Profile { . $PROFILE }

# Jump up N directories (Up 2)
function Up {
    param([int]$Levels = 1)
    $dest = (".." * $Levels) -replace '\\', '/'
    Set-Location $dest
}

function free {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    [PSCustomObject]@{
        "Total_GB" = [math]::Round($os.TotalVisibleMemorySize/1MB,1)
        "Free_GB"  = [math]::Round($os.FreePhysicalMemory/1MB,1)
    } | Format-Table
}

function uptime {
    $boot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    $up   = (Get-Date) - $boot
    "up $($up.Days)d $($up.Hours)h $($up.Minutes)m"
}

function sort { $input | Sort-Object }

function uniq { $input | Sort-Object | Get-Unique }

function tar {
    param(
        [Parameter(Position=0)][string]$Option,
        [Parameter(Position=1)][string]$Archive,
        [Parameter(Position=2)][string]$Target = '.'
    )
    switch ($Option) {
        '-xzf' { Expand-Archive -Path $Archive -DestinationPath $Target }
        '-czf' { Compress-Archive -Path $Target -DestinationPath $Archive }
        default { Write-Host 'Usage: tar -xzf <archive> | tar -czf <archive> <path>' }
    }
}

function unzip { param([Parameter(Mandatory)][string]$File) Expand-Archive -Path $File -DestinationPath $PWD }

function ff {
    param([Parameter(Mandatory)][string]$Name)
    Get-ChildItem -Recurse -Filter "*${Name}*" -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName }
}

# Measure word/line/char (like wc)
function wc {
    if ($args) { Get-Content @args | Measure-Object -Line -Word -Character }
    else       { $input       | Measure-Object -Line -Word -Character }
}
#endregion

# ========================[ Region: Aliases ]==================================
#region Aliases
# Prefer Set-Alias to avoid function wrapping when possible
Set-Alias   ll    Get-ChildItem
Set-Alias   la    Get-ChildItem
Set-Alias   grep  Select-String
Set-Alias   which Get-Command
Set-Alias   ping Test-NetConnection
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
$EDITOR = foreach ($e in 'nvim','pvim','vim','vi','code','notepad++','sublime_text') { if (Test-CommandExists $e) { $e; break } }
if (-not $EDITOR) { $EDITOR = 'notepad' }
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

function global:Color($color, $text) {
    return "$($FG[$color])$text$Reset"
}
#endregion

# ========================[ Region: Prompt ]===========================
#region Prompt
function Get-GitInfo {
    try {
        if (-not (git rev-parse --is-inside-work-tree 2>$null)) { return $null }
        $branch = git symbolic-ref --short HEAD 2>$null
        if (-not $branch) { return $null }
        $dirty  = (git status --porcelain 2>$null | Select-Object -First 1)
        return @{ Branch = $branch; Dirty = $dirty }
    } catch { return $null }
}

function global:prompt {
    $status_indicator = if ($? -eq 1) { Color 'Green' '+' } else { Color 'Red' "-" }

    $hostStr = "$env:USERNAME@$env:COMPUTERNAME"
    if ($env:WSL_DISTRO_NAME) { $hostStr += "(wsl)" }
    $userHost = Color 'Blue' $hostStr

    $cwd = Split-Path -Leaf (Get-Location)
    $pathSeg = Color 'Green' $cwd

    # Python venv
    $venvSeg = ""
    if ($env:VIRTUAL_ENV) {
        $venvName = Split-Path -Leaf $env:VIRTUAL_ENV
        $venvSeg = " " + (Color 'Magenta' $venvName)
    }

    $gitSeg = ""
    $gitSeg = ""
    $git = Get-GitInfo
    if ($git) {
        $branchColor = Color 'Yellow' $git.Branch
        $dirtyFlag = if ($git.Dirty) { Color 'Red' '*' } else { "" }
        $gitSeg = " ($branchColor$dirtyFlag)"
    }

    "$Bold$userHost [$pathSeg]$gitSeg$venvSeg`nPS $status_indicator $Reset"
}
#endregion
