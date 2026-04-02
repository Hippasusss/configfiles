param(
    [switch]$SkipWinget
)

# --- CONFIGURATION DATA ---
$InstallArray = @(
    "Neovim.Neovim",
    "tree-sitter-cli",
    "GodotEngine.GodotEngine.Mono",
    "cmake",
    "nodejs",
    "python3",
    "Microsoft.WindowsTerminal",
    "Microsoft.PowerShell",
    "Microsoft.VisualStudio.Community",
    "LLVM.LLVM",
    "Cockos.REAPER",
    "Git.Git",
    "JanDeDobbeleer.OhMyPosh",
    "fzf",
    "BurntSushi.ripgrep.MSVC",
    "sharkdp.bat",
    "sharkdp.fd",
    "JesseDuffield.lazygit",
    "ajeetdsouza.zoxide",
    "sigoden.aichat"
)

$HardLinks = @(
    [PSCustomObject]@{ source = "_vsvimrc"; destination = "$HOME" }
    [PSCustomObject]@{ source = ".theme.omp.json"; destination = "$HOME" }
    [PSCustomObject]@{ source = "init.lua"; destination = "$HOME/AppData/Local/nvim" }
    [PSCustomObject]@{ source = "settings.json"; destination = "$HOME/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState" }
)

$NvimRepoList = @(
    "git@github.com:Hippasusss/easypeasy.git",
    "git@github.com:Hippasusss/diyank.git"
)

# --- FUNCTIONS ---

function Install-WingetPackages 
{
    param($Programs)
    
    Write-Host "Installing Programs" -ForegroundColor Magenta
    foreach($install in $Programs) 
    {
        Write-Host "installing: $install" 
        winget install -h --accept-package-agreements --accept-source-agreements $install
        Write-Host " " 
    }
    Install-Module -Name CompletionPredictor -Repository PSGallery -Force -AllowClobber
}

function Sync-HardLinks 
{
    param($Links)

    function Write-Status 
    { 
        param($Path)
        if (Test-Path $Path) { Write-Host "True " -ForegroundColor Green -NoNewline } 
        else { Write-Host "False " -ForegroundColor Red -NoNewline }
    }

    Write-Host "Creating Symlinks" -ForegroundColor Magenta

    foreach ($link in $Links) 
    {
        $source = $link.source
        $destination = Join-Path $link.destination $source

        Write-Host "`nsource $source found: " -NoNewline; Write-Status $source
        Write-Host "------> destination $destination found: " -NoNewline; Write-Status $destination
        Write-Host "" 

        if (-not (Test-Path $link.destination)) 
        {
            Write-Host "no valid destination path`ncreated at $($link.destination)" -ForegroundColor Magenta
            New-Item -ItemType Directory -Path $link.destination -Force | Out-Null
        }

        if (Test-Path $destination) 
        {
            Write-Host "$destination already exists and is " -NoNewline
            $destItem = Get-Item $destination
            if ($destItem.LinkType -eq "HardLink") 
            {
                Write-Host "already linked!" -ForegroundColor Green 
                continue
            } 
            else 
            {
                Write-Host "a different file" -ForegroundColor Red
                Write-Host "deleting $destination" -ForegroundColor Red
                Remove-Item $destination -Force
            }
        }

        New-Item -ItemType HardLink -Path $destination -Value $source | Out-Null
        Write-Host "$source linked to $destination" -ForegroundColor Green
    }
    Write-Host " " 
}

function Sync-NvimPlugins 
{
    param($Repos)
    
    $projectPath = "$HOME\Projects\nvim"

    if (-not (Test-Path $projectPath)) 
    {
        New-Item -ItemType Directory -Path $projectPath -Force | Out-Null
    }

    $originalDir = Get-Location
    Set-Location $projectPath
    foreach ($repo in $Repos) 
    {
        $repoName = ($repo -split '/')[-1] -replace '\.git$', ''
        $repoPath = Join-Path $projectPath $repoName
        if (-not (Test-Path $repoPath)) 
        {
            git clone $repo
        } 
        else 
        {
            Write-Host "Directory '$repoName' already exists, skipping clone." -ForegroundColor Magenta
        }
    }
    Set-Location $originalDir
}

# --- EXECUTION ---

if(-not $SkipWinget) { Install-WingetPackages -Programs $InstallArray }
Sync-HardLinks -Links $HardLinks
Sync-NvimPlugins -Repos $NvimRepoList
