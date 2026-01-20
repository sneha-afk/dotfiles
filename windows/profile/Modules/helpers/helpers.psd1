@{
    RootModule        = 'helpers.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'a3dac1d9-bd0a-4dd1-a661-c30c7563a171'
    Author            = 'Sneha De'
    Description       = 'PowerShell utilities for WSL, Neovim, and general workflow automation'

    PowerShellVersion = '5.1'

    FunctionsToExport = @(
        'Require-Admin'
        'Neovide-WSL'
        'To-WSLPath'
        'WSL-Restart'
        'WSL-Kill'
        'Enter-NvimConfig'
        'Remove-NvimSwap'
        'Remove-NvimShada'
        'Start-NvimServer'
        'Start-Leetcode'
        'Reset-Nvim'
        'Get-NvimSize'
        'Search'
        'Update-All'
        'Expand-Archive'
        'Enter-Repo'
    )

    CmdletsToExport   = @()
    VariablesToExport = @()

    AliasesToExport   = @(
        'wslr'
        'wslk'
        'vim'
        'nvide'
        'extract'
        'unzip'
    )
}