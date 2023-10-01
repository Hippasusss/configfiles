oh-my-posh init pwsh --config ~/.theme.omp.json | Invoke-Expression

Import-Module -Name CompletionPredictor

Set-PSReadLineOption -PredictionSource Plugin 
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Vi
