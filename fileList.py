import os
from pathlib import Path

HOME = Path.home()
HardLinkFilesDestination = {
    "_vimrc"                           : HOME,
    "_vsvimrc"                         : HOME,
    ".bashrc"                          : HOME,
    "Tomorrow-Night.vim"               : os.path.join(HOME, "vimfiles\\colors"),
    "coc-settings.json "               : os.path.join(HOME, "vimfiles"),
    "coc-settings.json "               : os.path.join(HOME, "AppData\\Local\\nvim"),
    "Microsoft.PowerShell_profile.ps1" : os.path.join(HOME, "Documents\\PowerShell"),
    ".theme.omp.json"                  : HOME,
    ".themeBash.omp.json"              : HOME
    ,"settings.json"                    : os.path.join(HOME, "AppData\\Local\\Packages\\Microsoft.WindowsTerminal_8wekyb3d8bbwe\\LocalState")
}

SoftLinkFilesDestination = {
}
