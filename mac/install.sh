#!/usr/bin/env bash
# macOS counterpart to install.ps1.
#
#   ./mac/install.sh             same as --links
#   ./mac/install.sh --all       links, brew packages, plugin repos, nvim updates
#   ./mac/install.sh --dry-run   show what would happen without changing anything
#
# macOS destinations:
#   common/init.lua        -> ~/.config/nvim/init.lua
#   common/.theme.omp.json -> ~/.theme.omp.json
#   mac/.zshrc             -> ~/.zshrc
#   mac/configfiles.zsh    -> ~/.config/configfiles.zsh
#   ~/vimfiles/{session,after,back} are created so init.lua's Windows layout works here
#
# settings.json is skipped: it is Windows Terminal configuration and has no
# macOS equivalent. _vsvimrc and Microsoft.PowerShell_profile.ps1 are not
# linked because VS Code and pwsh are not installed on this machine.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
VIMFILES="$HOME/vimfiles"
PROJECTS="$HOME/Projects/nvim"
ZSH_SOURCE="$CONFIG_HOME/configfiles.zsh"

# Everything install.ps1's $InstallArray installs, mapped to macOS equivalents:
#   Microsoft.WindowsTerminal -> iterm2
#   cURL.cURL                 -> curl
# Skipped because there is no macOS Homebrew equivalent: GnuWin32.Tar (built-in tar),
# Microsoft.PowerShell (unused on this machine) and Microsoft.VisualStudio.Community.
BREW_FORMULAS=(
    neovim tree-sitter-cli cmake node python llvm curl git
    oh-my-posh fzf ripgrep bat opencode fd lazygit zoxide aichat zsh-autosuggestions
)
BREW_CASKS=( godot-mono blender iterm2 reaper )

DRY_RUN=0
DO_LINKS=0
DO_BREW=0
DO_PLUGINS=0
DO_NVIM=0

if [[ -t 1 ]] && command -v tput >/dev/null 2>&1 && [[ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]]; then
    C_MAGENTA="$(tput setaf 5)"
    C_GREEN="$(tput setaf 2)"
    C_RED="$(tput setaf 1)"
    C_DIM="$(tput dim)"
    C_RESET="$(tput sgr0)"
else
    C_MAGENTA=""
    C_GREEN=""
    C_RED=""
    C_DIM=""
    C_RESET=""
fi

info() { printf '%s==>%s %s\n' "$C_MAGENTA" "$C_RESET" "$*"; }
ok()   { printf '%s  ok%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
note() { printf '%s  --%s %s\n' "$C_DIM" "$C_RESET" "$*"; }
die()  { printf '%serror:%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; exit 1; }

run() {
    if (( DRY_RUN )); then
        printf '%s  [dry-run]%s %s\n' "$C_DIM" "$C_RESET" "$*"
    else
        "$@"
    fi
}

usage() {
    cat <<'EOF'
Usage: ./mac/install.sh [options]

Options:
  --links        Create ~/vimfiles and symlink the dotfiles (default)
  --brew         Install missing Homebrew packages
  --plugins      Clone/update easypeasy and diyank in ~/Projects/nvim
  --nvim         Update Neovim packages and Treesitter parsers
  --all          Run every step above
  -n, --dry-run  Print actions without changing anything
  -h, --help     Show this help

With no options, only --links runs.
EOF
}

link_file() {
    local source="$1" dest="$2"

    [[ -e "$source" ]] || die "missing source file: $source"

    run mkdir -p "$(dirname "$dest")"

    if [[ -L "$dest" ]]; then
        if [[ "$(readlink "$dest")" == "$source" ]]; then
            ok "already linked: $dest"
            return 0
        fi
        note "replacing existing link: $dest"
        run rm -f "$dest"
    elif [[ -e "$dest" ]]; then
        note "replacing existing file: $dest"
        run rm -f "$dest"
    fi

    run ln -s "$source" "$dest"
    if (( DRY_RUN )); then
        note "would link $dest -> $source"
    else
        ok "$dest -> $source"
    fi
}

do_links() {
    info "Linking dotfiles"

    local dir
    for dir in "$VIMFILES" "$VIMFILES/session" "$VIMFILES/after" "$VIMFILES/back"; do
        run mkdir -p "$dir"
    done
    if (( DRY_RUN )); then
        note "would create vimfiles layout: $VIMFILES"
    else
        ok "vimfiles layout ready: $VIMFILES"
    fi

    link_file "$REPO_ROOT/common/init.lua"        "$CONFIG_HOME/nvim/init.lua"
    link_file "$REPO_ROOT/common/.theme.omp.json" "$HOME/.theme.omp.json"
    link_file "$SCRIPT_DIR/.zshrc"                "$HOME/.zshrc"
    link_file "$SCRIPT_DIR/configfiles.zsh"       "$ZSH_SOURCE"
}

do_brew() {
    info "Checking Homebrew packages"
    command -v brew >/dev/null 2>&1 || die "brew not found"

    local formula cask
    local missing_formulas=()
    for formula in "${BREW_FORMULAS[@]}"; do
        if brew list --formula "$formula" >/dev/null 2>&1; then
            ok "$formula"
        else
            note "missing formula: $formula"
            missing_formulas+=("$formula")
        fi
    done

    local missing_casks=()
    for cask in "${BREW_CASKS[@]}"; do
        if brew list --cask "$cask" >/dev/null 2>&1; then
            ok "$cask (cask)"
        else
            note "missing cask: $cask"
            missing_casks+=("$cask")
        fi
    done

    if (( ${#missing_formulas[@]} > 0 )); then
        run brew install "${missing_formulas[@]}"
    fi
    if (( ${#missing_casks[@]} > 0 )); then
        run brew install --cask "${missing_casks[@]}"
    fi
    if (( ${#missing_formulas[@]} == 0 && ${#missing_casks[@]} == 0 )); then
        ok "nothing to install"
    fi
}

do_plugins() {
    info "Syncing Neovim plugin repos in $PROJECTS"
    run mkdir -p "$PROJECTS"

    local repo name path
    for repo in "git@github.com:Hippasusss/easypeasy.git" "git@github.com:Hippasusss/diyank.git"; do
        name="${repo##*/}"
        name="${name%.git}"
        path="$PROJECTS/$name"

        if [[ -d "$path/.git" ]]; then
            note "updating $name"
            run git -C "$path" pull --ff-only
        else
            note "cloning $name"
            run git clone "$repo" "$path"
        fi
    done
}

do_nvim() {
    command -v nvim >/dev/null 2>&1 || die "nvim not found"

    info "Updating Neovim packages"
    run nvim --headless -c "lua vim.pack.update()" -c "qa"

    info "Installing Treesitter parsers"
    run nvim --headless -c "lua require('nvim-treesitter').install { 'c', 'c_sharp', 'css', 'lua', 'vim', 'vimdoc', 'cpp', 'python', 'html' }" -c "qa"
}

while (( $# > 0 )); do
    case "$1" in
        --links)      DO_LINKS=1 ;;
        --brew)       DO_BREW=1 ;;
        --plugins)    DO_PLUGINS=1 ;;
        --nvim)       DO_NVIM=1 ;;
        --all)        DO_LINKS=1; DO_BREW=1; DO_PLUGINS=1; DO_NVIM=1 ;;
        -n|--dry-run) DRY_RUN=1 ;;
        -h|--help)    usage; exit 0 ;;
        *)            usage >&2; die "unknown option: $1" ;;
    esac
    shift
done

if (( ! DO_LINKS && ! DO_BREW && ! DO_PLUGINS && ! DO_NVIM )); then
    DO_LINKS=1
fi

if (( DO_LINKS )); then do_links; fi
if (( DO_BREW )); then do_brew; fi
if (( DO_PLUGINS )); then do_plugins; fi
if (( DO_NVIM )); then do_nvim; fi

info "Done"
