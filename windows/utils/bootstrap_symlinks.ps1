# windows/utils/symlinks.ps1

#region Directories
$script:ScriptDir           = $PSScriptRoot
$script:WindowsDir          = Split-Path -Path $ScriptDir -Parent
$script:RepoDir             = Split-Path -Path $WindowsDir -Parent

$script:UtilsDir            = Join-Path $WindowsDir "utils"
$script:DotfilesProfile     = Join-Path $WindowsDir "profile"
$script:DotfilesModulesDir  = Join-Path $DotfilesProfile "Modules"
$script:ScriptsDir          = Join-Path $WindowsDir "scripts"

$script:AppDataLocal        = $env:LOCALAPPDATA
$script:AppDataRoaming      = [System.Environment]::GetFolderPath("ApplicationData")

. (Join-Path $script:UtilsDir "bootstrap_helpers.ps1")
Fix-ProfilePath

$PROFILE = "$env:UserProfile\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
$script:ProfileDir          = Split-Path -Path $PROFILE -Parent
$script:ProfileModulesDir   = Join-Path $ProfileDir "Modules"

#endregion

#region Symlinks
$symlinks = @()

# Symlink all files inside dotfiles\windows\profile (recursive)
$ProfileFiles = Get-ChildItem -Path $DotfilesProfile -Recurse -File
foreach ($file in $ProfileFiles) {
    $relativePath = $file.FullName.Substring($DotfilesProfile.Length).TrimStart('\','/')
    $symlinks += @{
        Path   = Join-Path $ProfileDir $relativePath
        Target = $file.FullName
    }
}

# Additional symlinks
$symlinks += @(
    @{
        Path   = Join-Path $env:UserProfile ".wslconfig"
        Target = Join-Path $WindowsDir ".wslconfig"
    },
    @{
        Path   = Join-Path $HOME "_vimrc"
        Target = Join-Path $RepoDir "dot-home\.vimrc"
    },
    @{
        Path   = Join-Path $AppDataLocal "nvim"
        Target = Join-Path $RepoDir "dot-config\nvim"
    },
    @{
        Path   = Join-Path $AppDataRoaming "alacritty"
        Target = Join-Path $RepoDir "dot-config\alacritty"
    },
    @{
        Path   = Join-Path $HOME "scripts"
        Target = $ScriptsDir
    }
)

Reset-Symlinks -Links $symlinks
Write-Host "All symlinks processed." -ForegroundColor Cyan
#endregion
