import os
from pathlib import Path
from win32file import *

HOME = Path.home()

FilesDestination = {
    "_vimrc"                           : HOME,
    "_vsvimrc"                         : HOME,
    ".bashrc"                          : HOME,
    "Tomorrow-Night.vim"               : os.path.join(HOME, "vimfiles\\colors"),
    "coc-settings.json "               : os.path.join(HOME, "vimfiles"),
    "Microsoft.PowerShell_profile.ps1" : os.path.join(HOME, "Documents\\WindowsPowerShell"),
}

for key, value in FilesDestination.items():
    source = key
    destination = os.path.join(value,key)
    print("")
    print("========================================================")
    print (f"source file {source} found: {os.path.isfile(source)}")
    print (f"desitnation file {destination} found: {os.path.isfile(destination)}")

    #check for destination path and create if not
    if not os.path.exists(value):
        print("no valid destination path")
        print(f"created at {value}")
        os.makedirs(value)
    # check for preexisting file and delete it if there to be replaced with link
    if os.path.isfile(destination):
        print(f"file {destination} already exits")
        print(f"deleting {destination}")
        if os.path.islink(destination):
            os.unlink(destination)
        else:
            os.remove(destination)

    #create links
    try:
        os.link(source, destination)
        print (f"{source} linked to {destination}")
    except FileExistsError:
        print("no file")
    except FileNotFoundError:
        print(f"file can't be found")
    print("========================================================")
