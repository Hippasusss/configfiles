
$installArray = @("vim.vim", "cmake", "nodejs", "python3", "Microsoft.WindowsTerminal", "Microsoft.PowerShell", "Microsoft.PowerToys", "Microsoft.VisualStudio.2022.Community", "Cockos.REAPER", "Git.Git", "JanDeDobbeleer.OhMyPosh -s winget", "fzf")

foreach($install in $installArray)
{
    winget install -h --accept-package-agreements	--accept-source-agreements $install
    [console]::beep(100,100)
}

Install-Module -Name CompletionPredictor -Repository PSGallery
Import-Module -Name CompletionPredictor
Set-PSReadLineOption -PredictionSource Plugin

python3 .\createSymlinks.py
