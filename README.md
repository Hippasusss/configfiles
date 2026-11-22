# configfiles

Dotfiles for Neovim, Windows Terminal, VS Code Vim, PowerShell, Oh My Posh and zsh.

## Layout

| Path | Platform | Contents |
| --- | --- | --- |
| `common/` | both | `init.lua` (Neovim config), `.theme.omp.json` (Oh My Posh theme) |
| `mac/` | macOS | `install.sh`, `.zshrc`, `configfiles.zsh` |
| `windows/` | Windows | `install.ps1`, `_vsvimrc`, `Microsoft.PowerShell_profile.ps1`, `settings.json` |

## macOS

```sh
./mac/install.sh              # link Neovim config, theme, zshrc and shell file (default)
./mac/install.sh --all        # everything: links, brew packages, nvim repos, plugins
./mac/install.sh --dry-run    # print what would happen without changing anything
```

| Flag | What it does |
| --- | --- |
| `--links` | Creates `~/vimfiles/{session,after,back}` and symlinks `common/init.lua`, `common/.theme.omp.json`, `mac/.zshrc`, `mac/configfiles.zsh`. Default when no flag is given. |
| `--brew` | Installs everything from `install.ps1`'s `$InstallArray` that isn't already present. Formulas: `neovim`, `tree-sitter-cli`, `cmake`, `node`, `python`, `llvm`, `curl`, `git`, `oh-my-posh`, `fzf`, `ripgrep`, `bat`, `opencode`, `fd`, `lazygit`, `zoxide`, `aichat`, `zsh-autosuggestions`. Casks: `godot-mono`, `blender`, `iterm2`, `reaper`. |
| `--plugins` | Clones or fast-forwards `easypeasy` and `diyank` in `~/Projects/nvim` (required by `init.lua`). |
| `--nvim` | Runs `vim.pack.update()` and installs the Treesitter parsers. |
| `--all` | All of the above, in that order. |

`.zshrc` is symlinked too, so shell startup is versioned: it sets `PATH` and sources `~/.config/configfiles.zsh` (oh-my-posh, zoxide, aliases, `ff`/`fff`, tab completion, autosuggestions).

`windows/settings.json` is Windows Terminal configuration and is not used on macOS. `windows/_vsvimrc` and `windows/Microsoft.PowerShell_profile.ps1` are only linked on machines running VS Code Vim or `pwsh`.

### Windows-to-macOS package mapping

| `install.ps1` package | macOS |
| --- | --- |
| `Microsoft.WindowsTerminal` | `iterm2` cask |
| `cURL.cURL` | `curl` formula |
| `GnuWin32.Tar` | skipped — macOS ships `tar` |
| `Microsoft.PowerShell` | skipped — not used on this machine |
| `Microsoft.VisualStudio.Community` | skipped — no Homebrew equivalent |

Everything else keeps its name (`Neovim.Neovim` → `neovim`, `nodejs` → `node`, `python3` → `python`, etc.).

## Secrets

`init.lua` reads the CodeCompanion API key from `~/.secret/keys.json`:

```json
{ "deepseek_api_key": "..." }
```

That file is intentionally not managed by this repo.

## Windows

```powershell
.\windows\install.ps1 -All
```

Or run individual switches: `-Winget`, `-Links`, `-Plugins`, `-Nvim`. The script resolves its sources relative to the repo root, so it can be launched from anywhere.
