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
    # Get the current directory (compacted path)
    $currentDir = (Get-Item -Path .).Name

    # Get the git branch (if in a git repository)
    try {
        $gitBranch = git rev-parse --abbrev-ref HEAD 2>$null
    } catch {
        $gitBranch = $null
    }

    # Set the prompt text
    Write-Host "$env:USERNAME@$env:COMPUTERNAME " -NoNewline -ForegroundColor DarkBlue
    Write-Host "[" -NoNewline -ForegroundColor Gray
    Write-Host "$currentDir" -NoNewline -ForegroundColor Green
    if ($gitBranch) {
        Write-Host " (" -NoNewline -ForegroundColor Gray
        Write-Host "$gitBranch" -NoNewline -ForegroundColor Cyan
        Write-Host ")" -NoNewline -ForegroundColor Gray
    }
    Write-Host "] " -NoNewline -ForegroundColor Gray
    return "> "
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
    # Import the PSReadLine module
    Import-Module PSReadLine

    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineKeyHandler -Key Tab -Function Complete

    Set-PSReadLineOption -Colors @{
        "Command" = "Green"
        "Parameter" = "Blue"
        "String" = "Yellow"
        "Number" = "Magenta"
        "Operator" = "Cyan"
        "Variable" = "DarkCyan"
        "Member" = "DarkGray"
    }

    # Enable menu-style tab completion
    Set-PSReadLineOption -ShowToolTips
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

    # Bind Ctrl+l to clear the screen (Unix-like behavior)
    Set-PSReadLineKeyHandler -Key Ctrl+l -Function ClearScreen

    # Enable persistent command history
    Set-PSReadLineOption -HistorySavePath "$HOME/.psreadline_history"

    # Enable reverse history search (Ctrl+r)
    Set-PSReadLineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory

    # Enable multi-line editing with a continuation prompt
    Set-PSReadLineOption -ContinuationPrompt ">> "
}
else {
    Write-Host "PSReadLine is not installed. Skipping PSReadLine configurations." -ForegroundColor Yellow
}
