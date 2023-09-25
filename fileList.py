import os
from pathlib import Path

HOME = Path.home()
FilesDestination = {
    "_vimrc"                           : HOME,
    "_vsvimrc"                         : HOME,
    ".bashrc"                          : HOME,
    "Tomorrow-Night.vim"               : os.path.join(HOME, "vimfiles\\colors"),
    "coc-settings.json "               : os.path.join(HOME, "vimfiles"),
    "Microsoft.PowerShell_profile.ps1" : os.path.join(HOME, "Documents\\WindowsPowerShell"),
}
