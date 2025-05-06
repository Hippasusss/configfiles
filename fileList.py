import os
from pathlib import Path

HOME = Path.home()
HardLinkFilesDestination = {
    "_vsvimrc":                         HOME,
    "Microsoft.PowerShell_profile.ps1": os.path.join(HOME, "Documents\\PowerShell"),
    ".theme.omp.json":                  HOME,
    "init.lua":                         os.path.join(HOME, 'AppData\\Local\\nvim'),
    "settings.json":                    os.path.join(HOME, "AppData\\Local\\Packages\\Microsoft.WindowsTerminal_8wekyb3d8bbwe\\LocalState")
}

SoftLinkFilesDestination = {
}
