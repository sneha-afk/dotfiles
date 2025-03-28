# ==============================
# Unix-like Aliases
# ==============================
Set-Alias df Get-PSDrive
Set-Alias grep Select-String
Set-Alias la Get-ChildItem -Force
Set-Alias less Get-Content
Set-Alias ll Get-ChildItem
Set-Alias which Get-Command

# ==============================
# Custom Prompt
# ==============================
function prompt {
    $dir = (Get-Item -Path .).Name
    $branch = git branch --show-current 2>$null

    $Reset  = "$([char]0x1b)[0m"
    $Bold   = "$([char]0x1b)[1m"
    $Blue   = "$([char]0x1b)[34m"
    $Green  = "$([char]0x1b)[32m"
    $Yellow = "$([char]0x1b)[33m"
    $Gray   = "$([char]0x1b)[90m"

    $user_host = "$Blue$env:USERNAME@$env:COMPUTERNAME$Reset"
    $dir_part = "$Gray[$Green$dir$Gray"

    if ($branch) {
        $dir_part += " $Gray($Yellow$branch$Gray)"
    }
    $dir_part += "]$Reset"

    "$Bold$user_host $dir_part`nPS $ $Reset"
}

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
