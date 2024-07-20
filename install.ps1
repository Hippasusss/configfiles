
#WINGET
$installArray = @("vim.vim", "Neovim.Neovim", "cmake", "nodejs", "python3", "Microsoft.WindowsTerminal", "Microsoft.PowerShell",  "Microsoft.VisualStudio.2022.Community", "Cockos.REAPER", "Git.Git", "JanDeDobbeleer.OhMyPosh", "fzf", "BurntSushi.ripgrep.MSVC", "sharkdp.bat")

foreach($install in $installArray)
{
    Write-Output "installing: $install" 
    winget install -h --accept-package-agreements	--accept-source-agreements $install
    [console]::beep(100,100)
    Write-Output " " 
}

#NVIM PLUG
Write-Output "installing: Nvim Plug" 
iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
    ni "$(@($env:XDG_DATA_HOME, $env:LOCALAPPDATA)[$null -eq $env:XDG_DATA_HOME])/nvim-data/site/autoload/plug.vim" -Force

#VIM PLUG
Write-Output "installing: vim Plug" 
iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
    ni $HOME/vimfiles/autoload/plug.vim -Force

#VIM BACKUP FILES
$vimBackupPath = "~\\.config\back"
if(!(Test-Path -Path $vimBackupPath))
{
    Write-Output "Creating .config\back directory" 
    New-Item -Path $vimBackupPath -ItemType Directory
}
else
{
    Write-Output ".config\back directory already exists"
}

#PS CompletionPredictor
Write-Output "Installing Powershell CompletionPredictor" 
Install-Module -Name CompletionPredictor -Repository PSGallery -Force
Import-Module -Name CompletionPredictor
Set-PSReadLineOption -PredictionSource Plugin

#FONT
Write-Output "Installing Fonts" 
$FontList = Get-ChildItem -Path ".\\Meslo\*" -Include ('*.fon','*.otf','*.ttc','*.ttf')

foreach ($Font in $FontList) {
    Write-Host 'Installing font -' $Font.BaseName
    Copy-Item $Font "C:\Windows\Fonts" -ErrorAction SilentlyContinue
    New-ItemProperty -Name $Font.BaseName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $Font.name -ErrorAction SilentlyContinue       
}

#LINKS
Write-Output "Creating Symlinks" 
python .\createSymlinks.py
