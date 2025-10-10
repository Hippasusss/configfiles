oh-my-posh init pwsh --config ~/.theme.omp.json | Invoke-Expression

Import-Module -Name CompletionPredictor

Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -PredictionSource Plugin  
Set-PSReadLineOption -EditMode Vi

Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadlineKeyHandler -Key Tab -Function NextSuggestion 
Set-PSReadlineKeyHandler -Key Shift+Tab -Function PreviousSuggestion 

Invoke-Expression (& { (zoxide init powershell | Out-String) })

New-Alias -Name ai -Value aichat
New-Alias -Name lz -Value lazygit 
New-Alias -Name touch -Value New-Item


function ff {
    param([string]$Path = ".")
    $basePath = Resolve-Path $Path
    $selection = fd -t d -H --base-directory $basePath | fzf
    if ($selection) {
        Set-Location (Join-Path $basePath $selection)
    }
}

function ffz {
    param([string]$Path = ".")
    $basePath = Resolve-Path $Path
    $selection = fd -t d -H --base-directory $basePath | fzf
    if ($selection) {
        z (Join-Path $basePath $selection)
    }
}

function fff {
    param(
        [string]$Path = ".",
        [switch]$sl
    )
    $basePath = Resolve-Path $Path
    $selection = fd -t f -t d -H --base-directory $basePath | fzf
    if ($selection) {
        $fullPath = Join-Path $basePath $selection
        if (Test-Path $fullPath -PathType Container) {
            if ($sl) {
                Set-Location $fullPath
            }
        } else {
            if ($sl) {
                Set-Location (Split-Path $fullPath -Parent)
                nvim (Split-Path $fullPath -Leaf)
            } else {
                nvim $fullPath
            }
        }
    }
}
