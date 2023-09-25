
$installArray = @("vim.vim", "cmake", "nodejs", "python3", "Microsoft.WindowsTerminal", "Microsoft.PowerShell", "Microsoft.VisualStudio.2022.Community", "Cockos.REAPER" )

foreach($install in $installArray)
{
    winget install -h --accept-package-agreements	--accept-source-agreements $install
    [console]::beep(100,100)
}

python3 .\createSymlinks.py
