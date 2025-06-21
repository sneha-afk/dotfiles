# ======= PROMPT =======
function Get-GitStatusForPrompt {
    # Fast path: return immediately if not in a git repo
    if (-not (Test-Path .git) -and
        -not (git rev-parse --is-inside-work-tree 2>$null)) {
        return $null
    }

    try {
        $branch = git symbolic-ref --short HEAD 2>$null
        if (-not $branch) { return $null }
        
        $isDirty = git status --porcelain 2>$null | Select-Object -First 1
        return if ($isDirty) { "$branch *" } else { $branch }
    } catch { return $null }
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

    $user_host = "${Blue}sneha@$env:COMPUTERNAME$Reset"
    $dir_part = "$Gray[$Green$dir$Gray"

    if ($gitInfo) {
        if ($gitInfo.Contains("*")) {
            $branch = $gitInfo.Replace(" *", "")
            $dir_part += " $Gray($Yellow$branch$Red*$Gray)"
        } else {
            $dir_part += " $Gray($Yellow$gitInfo$Gray)"
        }
    }
    $dir_part += "]$Reset"

    $venv = $env:VIRTUAL_ENV
    if ($venv) {
        $venvName = Split-Path -Leaf $venv
        $dir_part += " $Gray($Blue$venvName$Gray)"
    }

    "$Bold$user_host $dir_part`nPS $ $Reset"
}


# ======= ALIASES =======
# File operations  
function mkdir { New-Item -ItemType Directory @args }
function rmdir { Remove-Item -Recurse @args }
function mv { Move-Item @args }
function cp { Copy-Item @args }
function touch { New-Item -ItemType File @args }

# File content
function cat { Get-Content @args }
function head { Get-Content @args | Select-Object -First 10 }
function tail { Get-Content @args | Select-Object -Last 10 }
function grep { Select-String @args }
function find { Get-ChildItem -Recurse -Name @args }
function wc { 
    if ($args) { Get-Content @args | Measure-Object -Line -Word -Character }
    else { $input | Measure-Object -Line -Word -Character }
}

# Process management
function ps { Get-Process @args }
function kill { Stop-Process @args }
function killall { Get-Process -Name $args[0] | Stop-Process }

# System infoping 
function free { 
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    [PSCustomObject]@{
        "Total(GB)" = [math]::Round($os.TotalVisibleMemorySize/1MB,1)
        "Free(GB)" = [math]::Round($os.FreePhysicalMemory/1MB,1)
    }
}
function uptime { 
    $boot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    $up = (Get-Date) - $boot
    "up $($up.Days)d $($up.Hours)h $($up.Minutes)m"
}

# Network
function ping { Test-NetConnection @args }

# Archives
function tar { 
    switch ($args[0]) {
        "-xzf" { Expand-Archive $args[1] -DestinationPath . }
        "-czf" { Compress-Archive $args[2] -DestinationPath $args[1] }
        default { "Usage: tar -xzf <archive> or tar -czf <archive> <files>" }
    }
}
function zip { Compress-Archive @args }

# Text processing
function sort { $input | Sort-Object }
function uniq { $input | Sort-Object | Get-Unique }

# Git shortcuts
function gst { git status }
function gco { git checkout @args }
function gaa { git add . }
function gcm { git commit -m @args }
function gp { git push }
function gl { git log --oneline -10 }

function mkcd { param([string]$dir); New-Item -ItemType Directory -Path $dir -ErrorAction SilentlyContinue; Set-Location $dir }
function env { Get-ChildItem env: }
function path { $env:PATH -split ';' }

function wsl-restart {
    wsl.exe --shutdown
    wsl.exe
}

function nvim-connect { neovide.exe --server localhost:6666 }

function Admin { Start-Process powershell -Verb runas }

# ============= HELPERS
# Thanks to https://github.com/ChrisTitusTech/powershell-profile/

function Test-CommandExists {
    param($command)
    $exists = $null -ne (Get-Command $command -ErrorAction SilentlyContinue)
    return $exists
}

# Editor Configuration
$EDITOR = if (Test-CommandExists nvim) { 'nvim' }
          elseif (Test-CommandExists pvim) { 'pvim' }
          elseif (Test-CommandExists vim) { 'vim' }
          elseif (Test-CommandExists vi) { 'vi' }
          elseif (Test-CommandExists code) { 'code' }
          elseif (Test-CommandExists notepad++) { 'notepad++' }
          elseif (Test-CommandExists sublime_text) { 'sublime_text' }
          else { 'notepad' }
Set-Alias -Name vim -Value $EDITOR

function ff($name) {
    Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Output "$($_.FullName)"
    }
}

# System Utilities
function admin {
    if ($args.Count -gt 0) {
        $argList = $args -join ' '
        Start-Process wt -Verb runAs -ArgumentList "pwsh.exe -NoExit -Command $argList"
    } else {
        Start-Process wt -Verb runAs
    }
}

# Set UNIX-like aliases for the admin command, so sudo <command> will run the command with elevated rights.
Set-Alias -Name su -Value admin

function Reload-Profile {
    & $profile
}

function unzip ($file) {
    Write-Output("Extracting", $file, "to", $pwd)
    $fullFile = Get-ChildItem -Path $pwd -Filter $file | ForEach-Object { $_.FullName }
    Expand-Archive -Path $fullFile -DestinationPath $pwd
}

function grep($regex, $dir) {
    if ( $dir ) {
        Get-ChildItem $dir | select-string $regex
        return
    }
    $input | select-string $regex
}

function df {
    get-volume
}

function sed($file, $find, $replace) {
    (Get-Content $file).replace("$find", $replace) | Set-Content $file
}

function which($name) {
    Get-Command $name | Select-Object -ExpandProperty Definition
}

function export($name, $value) {
    set-item -force -path "env:$name" -value $value;
}

function pkill($name) {
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}

function pgrep($name) {
    Get-Process $name
}

function head {
  param($Path, $n = 10)
  Get-Content $Path -Head $n
}

function tail {
  param($Path, $n = 10, [switch]$f = $false)
  Get-Content $Path -Tail $n -Wait:$f
}

function la { Get-ChildItem | Format-Table -AutoSize }
function ll { Get-ChildItem -Force | Format-Table -AutoSize }


# ==============================
# PSReadLine Configuration
# https://github.com/PowerShell/PSReadLine
# ==============================
# if (Get-Module -ListAvailable PSReadLine) {
#     Import-Module PSReadLine

#     # Predictive typing: stores history
#     Set-PSReadLineOption -PredictionSource History
#     Set-PSReadLineOption -HistorySavePath "$HOME/.psreadline_history"

#     # Tab to cycle through options
#     Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

#     # Unix-like shortcuts
#     Set-PSReadLineKeyHandler -Key Ctrl+l -Function ClearScreen
#     Set-PSReadLineKeyHandler -Key Ctrl+a -Function BeginningOfLine
#     Set-PSReadLineKeyHandler -Key Ctrl+e -Function EndOfLine
#     Set-PSReadLineKeyHandler -Key Ctrl+u -Function BackwardDeleteLine

#     Set-PSReadLineOption -Colors @{
#         Command   = 'Green'
#         Parameter = 'Blue'
#         String    = 'Yellow'
#         Number    = 'Magenta'
#     }
# }
# else {
#     Write-Host "PSReadLine is not installed. Skipping PSReadLine configurations." -ForegroundColor Yellow
# }

