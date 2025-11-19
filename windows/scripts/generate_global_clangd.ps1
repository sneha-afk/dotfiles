# windows/scripts/generate_global_clangd.ps1

$homeDir = $env:USERPROFILE
if (-not $homeDir) { $homeDir = $HOME }

$clangdPath = Join-Path $homeDir ".clangd"

function Get-GccPrefix {
    try {
        $gccExe = (where.exe gcc 2>$null)[0]
        if ($gccExe) {
            $binDir = Split-Path $gccExe -Parent
            $prefix = Split-Path $binDir -Parent
            if (Test-Path $prefix) {
                return $prefix
            }
        }
    } catch {}

    # Fallback: try Scoop GCC
    try {
        $scoopPrefix = scoop prefix gcc 2>$null
        if ($scoopPrefix -and (Test-Path $scoopPrefix)) {
            return $scoopPrefix
        }
    } catch {}

    return ""
}


$gccPath = Get-GccPrefix
Write-Host "Using GCC path: $gccPath"
if (-not $gccPath) {
    Write-Host "GCC not found in PATH, skipping gcc-toolchain."
}

$content = "CompileFlags:`n  Add:`n"
if ($gccPath) {
    $content += "    - --gcc-toolchain=$gccPath`n"
    $content += "    - -target`n"
    $content += "    - x86_64-w64-mingw32`n"
}

Set-Content -Path $clangdPath -Value $content -Encoding UTF8
Write-Host "Global .clangd generated at $clangdPath"
