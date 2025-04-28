# ==============================
# Unix-like Aliases
# ==============================
Set-Alias df Get-PSDrive
Set-Alias la Get-ChildItem -Force
Set-Alias less Get-Content

# ==============================
# Custom Functions
# ==============================
function home {
    Set-Location $HOME
}

function Reload-Profile {
    . $PROFILE
    Write-Host "Profile reloaded." -ForegroundColor Green
}

# Taken from https://github.com/CrazyWolf13/unix-pwsh/blob/main/functions.ps1

function which($name) {
    Get-Command $name | Select-Object -ExpandProperty Definition
}

function ll { Get-ChildItem -Path $pwd -File }
function df { get-volume }

function touch {
    param([string]$file)
    if (Test-Path $file) {
        Set-ItemProperty -Path $file -Name LastWriteTime -Value (Get-Date)
    } else {
        New-Item -Path $file -ItemType File
    }
}

function grep {
    param (
        [string]$regex,
        [string]$dir
    )
    process {
        if ($dir) {
            Get-ChildItem -Path $dir -Recurse -File | Select-String -Pattern $regex
        } else {     # Use if piped input is provided
            $input | Select-String -Pattern $regex
        }
    }
}

# ==============================
# Prompt
# ==============================
function Get-GitStatusForPrompt {
    # Fast path: return immediately if not in a git repo
    if (-not (Test-Path .git) -and 
        -not (git rev-parse --is-inside-work-tree 2>$null)) {
        return $null
    }

    try {
        # Get branch name
        $branch = git symbolic-ref --short HEAD 2>$null
        if (-not $branch) { return $null }

        # Check repo status with one git command
        $statusFlags = git status --porcelain 2>$null | Select-Object -First 1
        
        # Add indicator if dirty
        $status = ""
        if ($statusFlags) { $status = " *" }
        
        return "$branch$status"
    }
    catch {
        return $null
    }
}

function prompt {
    $dir = (Get-Item -Path .).Name
    $gitInfo = Get-GitStatusForPrompt
    
    $Reset  = "$([char]0x1b)[0m"
    $Bold   = "$([char]0x1b)[1m"
    $Blue   = "$([char]0x1b)[34m"
    $Green  = "$([char]0x1b)[32m"
    $Yellow = "$([char]0x1b)[33m"
    $Gray   = "$([char]0x1b)[90m"
    $Red    = "$([char]0x1b)[31m"

    $user_host = "$Blue$env:USERNAME@$env:COMPUTERNAME$Reset"
    $dir_part = "$Gray[$Green$dir$Gray"

    if ($gitInfo) {
        # Extract branch and status
        if ($gitInfo.Contains("*")) {
            $branch = $gitInfo.Replace(" *", "")
            $dir_part += " $Gray($Yellow$branch$Red*$Gray)"
        } else {
            $dir_part += " $Gray($Yellow$gitInfo$Gray)"
        }
    }
    $dir_part += "]$Reset"

    "$Bold$user_host $dir_part`nPS $ $Reset"
}

# ==============================
# PSReadLine Configuration
# https://github.com/PowerShell/PSReadLine
# ==============================
if (Get-Module -ListAvailable PSReadLine) {
    Import-Module PSReadLine

    # Predictive typing: stores history
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -HistorySavePath "$HOME/.psreadline_history"

    # Tab to cycle through options
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

    # Unix-like shortcuts
    Set-PSReadLineKeyHandler -Key Ctrl+l -Function ClearScreen
    Set-PSReadLineKeyHandler -Key Ctrl+a -Function BeginningOfLine
    Set-PSReadLineKeyHandler -Key Ctrl+e -Function EndOfLine
    Set-PSReadLineKeyHandler -Key Ctrl+u -Function BackwardDeleteLine

    Set-PSReadLineOption -Colors @{
        Command   = 'Green'
        Parameter = 'Blue'
        String    = 'Yellow'
        Number    = 'Magenta'
    }
}
else {
    Write-Host "PSReadLine is not installed. Skipping PSReadLine configurations." -ForegroundColor Yellow
}
