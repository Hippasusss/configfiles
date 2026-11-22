# configfiles shell setup for macOS.
# Sourced from ~/.zshrc through the "configfiles" marker block added by install.sh.
# Ported from Microsoft.PowerShell_profile.ps1.

# Prompt theme
if command -v oh-my-posh >/dev/null 2>&1; then
    export POSH_THEME="$HOME/.theme.omp.json"
    eval "$(oh-my-posh init zsh --config "$POSH_THEME")"
fi

# Smarter cd
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# Aliases, guarded so a missing tool never breaks the shell
command -v aichat >/dev/null 2>&1 && alias ai='aichat'
command -v lazygit >/dev/null 2>&1 && alias lz='lazygit'

# ff [path]: pick a directory with fd + fzf and cd into it
ff() {
    local base selection
    base=$(cd "${1:-.}" && pwd) || return 1
    selection=$(fd -t d -H --base-directory "$base" | fzf) || return 0
    [[ -n "$selection" ]] && cd "$base/$selection"
}

# fff [-s] [path]: pick a file with fd + fzf and open it in nvim
#   -s  cd to the file's directory before opening
fff() {
    local sl=0
    if [[ "${1:-}" == "-s" ]]; then
        sl=1
        shift
    fi

    local base selection full
    base=$(cd "${1:-.}" && pwd) || return 1
    selection=$(fd -t f -H --base-directory "$base" | fzf) || return 0
    [[ -z "$selection" ]] && return 0

    full="$base/$selection"
    if (( sl )); then
        cd "${full:h}" || return 1
        nvim "${full:t}"
    else
        nvim "$full"
    fi
}

# Tab completion: complete on Tab, cycle matches on repeated Tab
autoload -Uz compinit && compinit
setopt menu_complete

# Vi mode, matching PSReadLine's EditMode Vi
bindkey -v
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# Fish-style autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Tab accepts the inline suggestion when one is showing, otherwise completes.
# Name starts with "_" so zsh-autosuggestions does not wrap the widget and
# clear POSTDISPLAY before it runs.
_tab-complete() { if [[ -n "$POSTDISPLAY" && "$CURSOR" -eq "$#BUFFER" ]]; then zle autosuggest-accept; else zle expand-or-complete; fi }
zle -N _tab-complete && bindkey -M viins '^I' _tab-complete

# Shift+Tab cycles the completion menu backwards
bindkey -M viins '^[[Z' reverse-menu-complete
