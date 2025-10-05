# windows/utils/symlinks.ps1

$script:UtilsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$bootstrapHelpersPath = Join-Path $script:UtilsDir "bootstrap_helpers.ps1"
if (Test-Path $bootstrapHelpersPath) {
    . $bootstrapHelpersPath
    Fix-ProfilePath
} else {
    Write-Warning "bootstrap_helpers.ps1 not found at $bootstrapHelpersPath"
}

#region Directories

$script:Directories = Get-BootstrapDirs

$script:DotfilesProfile     = $script:Directories.ProfileDir

$script:AppDataLocal        = $env:LOCALAPPDATA
$script:AppDataRoaming      = [System.Environment]::GetFolderPath("ApplicationData")


$PROFILE = "$env:UserProfile\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
$script:ProfileDir          = Split-Path -Path $PROFILE -Parent

#endregion

#region Symlinks
$symlinks = @()

# Symlink all files inside dotfiles\windows\profile (recursive)
Get-ChildItem -Path $DotfilesProfile -Recurse -File | ForEach-Object {
    $relativePath = $_.FullName.Substring($DotfilesProfile.Length).TrimStart('\', '/')
    $symlinks += @{
        Path   = Join-Path $ProfileDir $relativePath
        Target = $_.FullName
    }
}

# Additional symlinks
$symlinks += @(
    @{
        Path   = Join-Path $env:UserProfile ".wslconfig"
        Target = Join-Path $script:Directories.WindowsDir ".wslconfig"
    },
    @{
        Path   = Join-Path $HOME "_vimrc"
        Target = Join-Path $script:Directories.RepoDir "dot-home\.vimrc"
    },
    @{
        Path   = Join-Path $HOME ".gitconfig"
        Target = Join-Path $script:Directories.RepoDir "dot-home\.gitconfig"
    },
    @{
        Path   = Join-Path $AppDataLocal "nvim"
        Target = Join-Path $script:Directories.RepoDir "dot-config\nvim"
    },
    @{
        Path   = Join-Path $AppDataRoaming "alacritty"
        Target = Join-Path $script:Directories.RepoDir "dot-config\alacritty"
    },
    @{
        Path   = Join-Path $HOME "scripts"
        Target = Join-Path $script:Directories.WindowsDir "scripts"
    }
)

Reset-Symlinks -Links $symlinks
Write-Host "All symlinks processed." -ForegroundColor Cyan
#endregion
