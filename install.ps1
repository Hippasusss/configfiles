
#WINGET
$installArray = @("vim.vim", "Neovim.Neovim", "cmake", "nodejs", "python3", "Microsoft.WindowsTerminal", "Microsoft.PowerShell", "Microsoft.PowerToys", "Microsoft.VisualStudio.2022.Community", "Cockos.REAPER", "Git.Git", "JanDeDobbeleer.OhMyPosh", "fzf", "BurntSushi.ripgrep.MSVC", "sharkdp.bat")

foreach($install in $installArray)
{
    Write-Output "installing: $install" 
    winget install -h --accept-package-agreements	--accept-source-agreements $install
    [console]::beep(100,100)
    Write-Output " " 
}

#NVIM PLUG
iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
    ni "$(@($env:XDG_DATA_HOME, $env:LOCALAPPDATA)[$null -eq $env:XDG_DATA_HOME])/nvim-data/site/autoload/plug.vim" -Force

#VIM PLUG
iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
    ni $HOME/vimfiles/autoload/plug.vim -Force

#PS CompletionPredictor
Install-Module -Name CompletionPredictor -Repository PSGallery -Force
Import-Module -Name CompletionPredictor
Set-PSReadLineOption -PredictionSource Plugin

#FONT
$FontList = Get-ChildItem -Path ".\\Meslo\*" -Include ('*.fon','*.otf','*.ttc','*.ttf')

foreach ($Font in $FontList) {
        Write-Host 'Installing font -' $Font.BaseName
        Copy-Item $Font "C:\Windows\Fonts"
        New-ItemProperty -Name $Font.BaseName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $Font.name         
}

#LINKS
python .\createSymlinks.py
