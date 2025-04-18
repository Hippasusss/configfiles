oh-my-posh init pwsh --config ~/.theme.omp.json | Invoke-Expression

Import-Module -Name CompletionPredictor

Set-PSReadLineOption -PredictionSource Plugin 
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Vi

Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadlineKeyHandler -Key Tab -Function NextSuggestion 
Set-PSReadlineKeyHandler -Key Shift+Tab -Function PreviousSuggestion 
