# ==============================
# Unix-like Aliases
# ==============================
Set-Alias ll Get-ChildItem
Set-Alias grep Select-String
Set-Alias which Get-Command
Set-Alias mkdir New-Item
Set-Alias less Get-Content
Set-Alias df Get-PSDrive

# ==============================
# Custom Prompt
# ==============================
function prompt {
    # Get the current directory name (compacted path)
    $currentDir = (Get-Item -Path .).Name

    # Get the git branch (if in a git repository)
    $gitBranch = git rev-parse --abbrev-ref HEAD 2>$null

    # Set the prompt text
    if ($gitBranch) {
        # If in a git repository, display the branch
        Write-Host "$currentDir" -NoNewline -ForegroundColor Green
        Write-Host " [$gitBranch]" -NoNewline -ForegroundColor Cyan
    } else {
        # If not in a git repository, just display the directory
        Write-Host "$currentDir" -NoNewline -ForegroundColor Green
    }

    # Add a separator and return the input prompt
    Write-Host " > " -NoNewline -ForegroundColor Gray
    return " "
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

    # Enable predictive IntelliSense based on command history
    Set-PSReadLineOption -PredictionSource History

    # Enable syntax highlighting with custom colors
    Set-PSReadLineOption -Colors @{
        "Command" = "Green"
        "Parameter" = "Blue"
        "String" = "Yellow"
        "Number" = "Magenta"
        "Operator" = "Cyan"
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

    # Enable Emacs key bindings (Unix-like editing)
    Set-PSReadLineOption -EditMode Emacs

    # Enable multi-line editing with a continuation prompt
    Set-PSReadLineOption -ContinuationPrompt ">> "
} 
# else {
#     Write-Host "PSReadLine is not installed. Skipping PSReadLine configurations." -ForegroundColor Yellow
# }
