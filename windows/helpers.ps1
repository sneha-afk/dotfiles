#region Utilities

function Create-Symlink {
    param (
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Target
    )

    try {
        $ResolvedTarget = Resolve-Path -Path $Target -ErrorAction Stop
        New-Item -ItemType SymbolicLink -Path $Path -Target $ResolvedTarget -Force | Out-Null
        Write-Output "Linked: $Path"
    } catch {
        Write-Warning "Failed to link $Path"
    }
}

function Remove-Symlink {
    param (
        [Parameter(Mandatory = $true)][string]$Path
    )

    try {
        if (Test-Path $Path) {
            $Item = Get-Item -Path $Path -Force
            if ($Item.LinkType -eq 'SymbolicLink') {
                Remove-Item -Path $Path -Force -Recurse
                Write-Output "Removed symlink: $Path"
            } else {
                Write-Warning "Not a symlink: $Path"
            }
        } else {
            Write-Warning "Path does not exist: $Path"
        }
    } catch {
        Write-Warning "Failed to remove $Path"
    }
}

function Reset-Symlinks {
    param (
        [Parameter(Mandatory = $true)]
        [array]$Links
    )

    Write-Output "Resetting symbolic links..."

    foreach ($Link in $Links) {
        if (-not ($Link.ContainsKey('Path') -and $Link.ContainsKey('Target'))) {
            Write-Warning "Skipping invalid link entry"
            continue
        }

        Remove-Symlink -Path $Link.Path
        Create-Symlink -Path $Link.Path -Target $Link.Target
    }
}

#endregion
