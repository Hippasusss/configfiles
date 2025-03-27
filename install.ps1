
#WINGET
$installArray = @("Neovim.Neovim", "cmake", "nodejs", "python3", "Microsoft.WindowsTerminal", "Microsoft.PowerShell",  "Microsoft.VisualStudio.2022.Community", "Cockos.REAPER", "Git.Git", "JanDeDobbeleer.OhMyPosh", "fzf", "BurntSushi.ripgrep.MSVC", "sharkdp.bat", "sharkdp.fd")

foreach($install in $installArray)
{
    Write-Output "installing: $install" 
    winget install -h --accept-package-agreements	--accept-source-agreements $install
    [console]::beep(100,100)
    Write-Output " " 
}

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

#LINKS
Write-Output "Creating Symlinks" 
python .\createSymlinks.py
