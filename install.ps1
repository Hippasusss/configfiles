
$installArray = @("vim.vim", "Neovim.Neovim", "cmake", "nodejs", "python3", "Microsoft.WindowsTerminal", "Microsoft.PowerShell", "Microsoft.PowerToys", "Microsoft.VisualStudio.2022.Community", "Cockos.REAPER", "Git.Git", "JanDeDobbeleer.OhMyPosh -s winget", "fzf", "BurntSushi.ripgrep.MSVC", "sharkdp.bat")

foreach($install in $installArray)
{
    Write-Output "installing: $install" 
    winget install -h --accept-package-agreements	--accept-source-agreements $install
    [console]::beep(100,100)
    Write-Output " " 
}

Install-Module -Name CompletionPredictor -Repository PSGallery
Import-Module -Name CompletionPredictor
Set-PSReadLineOption -PredictionSource Plugin

python .\createSymlinks.py
