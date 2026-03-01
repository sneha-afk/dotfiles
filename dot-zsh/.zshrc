# ~/.zshrc file for zsh interactive shells.
# see /usr/share/doc/zsh/examples/zshrc for examples

# vim: set ft=sh ts=4 sts=4 sw=4 et:

# Early exit for non-interactive shells
[[ -o interactive ]] || return

# Set if not already
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

[[ -d "$XDG_CACHE_HOME/zsh" ]] || mkdir -p "$XDG_CACHE_HOME/zsh"

# Fallback PATH
[[ -z $PATH ]] && export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

setopt autolist
setopt hist_ignore_dups hist_ignore_space

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

autoload -U colors && colors
if [ -x /usr/bin/dircolors ]; then
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

autoload -Uz compinit
ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump"

# Rebuild completion dump if zshrc changes
if [[ -f "$ZSH_COMPDUMP" && "$ZSH_COMPDUMP" -nt "$HOME/.zshrc" ]]; then
    compinit -C -d "$ZSH_COMPDUMP"
else
    compinit -d "$ZSH_COMPDUMP"
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-z}'
zstyle ':completion:*' rehash true
zstyle ':completion:*' verbose false
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"

export NVM_DIR="${NVM_DIR:-$HOME/.config/nvm}"
[ -f "$HOME/.ripgreprc" ] && export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

[[ -f $HOME/.shell_helpers ]] && source $HOME/.shell_helpers
[[ -f $HOME/.bash_aliases ]] && source $HOME/.bash_aliases
[[ -f $HOME/.wsl_env ]] && source $HOME/.wsl_env

[[ -f $HOME/.cargo/env ]] && source $HOME/.cargo/env

# pnpm
export PNPM_HOME="~/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

(( $+commands[uv] )) && eval "$(uv generate-shell-completion zsh)"
(( $+commands[fzf] )) && source <(fzf --zsh)

if [[ -n "${NVM_DIR:-}" && -d "$NVM_DIR" ]]; then
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

# Listing
alias ll='ls -alF'
alias la='ls -A'
alias l1='la -1'
alias l='ls -CF'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias home='cd ~'

# Add an "alert" alias for long running commands. Example: sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Safety
alias cp='nocorrect cp -iv'
alias mv='nocorrect mv -iv'
alias mkdir='nocorrect mkdir -pv'

# Disk
alias df='df -h' # Human-readable sizes
alias du='du -h' # Human-readable sizes

bindkey -e  # Emacs-style shortcuts (Ctrl+A, Ctrl+E, etc.)
bindkey '^[[3~' delete-char  # Fix Delete key

# ========================================================
# PROMPT
# ========================================================
# Configuration variables (set before sourcing to customize):
#   _PROMPT_USE_CUSTOM=true              - Enable/disable custom prompt entirely
#   _PROMPT_SHOW_GIT_STATUS=true         - Show git dirty state (* indicator)
#   _PROMPT_PREPEND=""                   - Text to prepend to prompt
# ========================================================

# Control prompt behavior (defaults)
_PROMPT_USE_CUSTOM=${_PROMPT_USE_CUSTOM:-true}
_PROMPT_SHOW_GIT_STATUS=${_PROMPT_SHOW_GIT_STATUS:-true}

# Exit early if custom prompt is disabled
[[ "$_PROMPT_USE_CUSTOM" != "true" ]] && return

setopt PROMPT_SUBST

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes "$_PROMPT_SHOW_GIT_STATUS"
zstyle ':vcs_info:git:*' stagedstr '+'
zstyle ':vcs_info:git:*' unstagedstr '*'
zstyle ':vcs_info:git:*' formats ' [%b%u%c]'
zstyle ':vcs_info:git:*' actionformats ' [%b|%a%u%c]'

__set_prompt() {
    local last_status=$? indicators=""

    [[ -n "${VIRTUAL_ENV:-}" ]] && indicators+=" %F{yellow}(${VIRTUAL_ENV:t})%f"
    [[ -n "$vcs_info_msg_0_" ]] && indicators+="%F{magenta}${vcs_info_msg_0_}%f"
    [[ -n "${SSH_CONNECTION:-}" ]] && indicators+=" %F{cyan}[SSH]%f"

    local status_line="%F{green}+%f"
    (( last_status != 0 )) && {
        indicators+=" %F{red}[exited: $last_status]%f"
        status_line="%F{red}-%f"
    }

    PROMPT="${_PROMPT_PREPEND:-}%F{green}%n@%m%f:%F{blue}%~%f${indicators}"$'\n'"${status_line} "
}
typeset -gU precmd_functions
precmd_functions+=(vcs_info __set_prompt)
