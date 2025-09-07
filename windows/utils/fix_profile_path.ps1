<#
.SYNOPSIS
    Fixes PowerShell profile path and reloads it.

.DESCRIPTION
    Copy this into: OneDrive\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
    The OneDrive profile is linked in the registry, so this will redirect it to the actual one.

    Copy-Item -Path ".\windows\utils\fix_profile_path.ps1" -Destination (Join-Path $env:OneDrive "Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1") -Force
#>

$PROFILE = "$env:UserProfile\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
. $PROFILE
