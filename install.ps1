param(
    [switch]$SkipWinget
)

#WINGET
$installArray = @(
"Neovim.Neovim", 
"cmake",
"nodejs",
"python3",
"Microsoft.WindowsTerminal",
"Microsoft.PowerShell",
"Microsoft.VisualStudio.2022.Community",
"LLVM.LLVM",
"Cockos.REAPER",
"Git.Git",
"JanDeDobbeleer.OhMyPosh",
"fzf",
"BurntSushi.ripgrep.MSVC",
"sharkdp.bat",
"sharkdp.fd",
"JesseDuffield.lazygit",
"ajeetdsouza.zoxide"
"sigoden.aichat"
)

if (-not $SkipWinget) {
    foreach($install in $installArray) {
        Write-Output "installing: $install" 
        winget install -h --accept-package-agreements --accept-source-agreements $install
        Write-Output " " 
    }
}

#LINKS
Write-Output "Creating Symlinks" 
python .\createSymlinks.py

#LOCAL NVIM PLUGINS
$projectPath = "$HOME\Projects\nvim"
$repos = @(
    "git@github.com:Hippasusss/easypeasy.git"
    "git@github.com:Hippasusss/diyank.git"
)

if (-not (Test-Path $projectPath)) {
    New-Item -ItemType Directory -Path $projectPath -Force
}

$originalDir = Get-Location
Set-Location $projectPath
foreach ($repo in $repos) {
    git clone $repo
}
Set-Location $originalDir
