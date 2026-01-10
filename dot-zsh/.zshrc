# ~/.zshrc file for zsh interactive shells.
# see /usr/share/doc/zsh/examples/zshrc for examples

# vim: set ft=sh ts=4 sts=4 sw=4 et:

# Early exit for non-interactive shells
[[ -o interactive ]] || return

# ========================================================
# Options
# ========================================================
setopt autolist
setopt auto_cd
setopt hist_ignore_dups hist_ignore_space share_history
setopt prompt_subst

# ========================================================
# History
# ========================================================
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# ========================================================
# Colors
# ========================================================
autoload -U colors && colors

if [ -x /usr/bin/dircolors ]; then
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# ========================================================
# Completion system
# ========================================================
autoload -Uz compinit
ZSH_COMPDUMP=$HOME/.zcompdump

# Rebuild completion dump if zshrc changes
if [[ ! -f $ZSH_COMPDUMP || $ZSH_COMPDUMP -ot ~/.zshrc ]]; then
    compinit
else
    compinit -C
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' rehash true
zstyle ':completion:*' verbose false
zstyle ':completion:*' list-colors '=(#b) #([a-z]*|[0-9]*)=36'

# ========================================================
# PATH safety fallback
# ========================================================

[[ -z $PATH ]] && export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Set if not already
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

export NVM_DIR="${NVM_DIR:-$HOME/.config/nvm}"

# ========================================================
# Environment loaders
# ========================================================

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

if command -v uv >/dev/null 2>&1; then
    eval "$(uv generate-shell-completion zsh)"
fi

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# ========================================================
# Aliases
# ========================================================

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

# Git Aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias glg='git log --graph --oneline --decorate --all'

# ========================================================
# Prompt
# ========================================================

autoload -Uz vcs_info
zstyle ':vcs_info:git:*' stagedstr='+'
zstyle ':vcs_info:git:*' unstagedstr '*'
zstyle ':vcs_info:git:*' check-for-changes true

zstyle ':vcs_info:git:*' formats ' [%b%u%c]'
zstyle ':vcs_info:git:*' actionformats ' [%b|%a%u%c]'

precmd_vcs() { vcs_info }
precmd_functions+=(precmd_vcs)

__set_prompt() {
    local last_status=$?

    PROMPT=$'\n'
    PROMPT+="%F{green}%n@%m%f:%F{blue}%~%f"

    [[ -n ${VIRTUAL_ENV:-} ]] && PROMPT+=" %F{yellow}($(basename $VIRTUAL_ENV))%f"
    [[ -n $vcs_info_msg_0_ ]] && PROMPT+="%F{magenta}$vcs_info_msg_0_%f"

    # Green plus (last command succeeded), else red minus on a new line
    PROMPT+=$'\n'
    PROMPT+=$([[ $last_status -eq 0 ]] && echo "%F{green}+" || echo "%F{red}-")
    PROMPT+="%f "
}

precmd_functions+=(__set_prompt)

# ========================================================
# Key Bindings (Emacs mode)
# ========================================================
bindkey -e  # Emacs-style shortcuts (Ctrl+A, Ctrl+E, etc.)
bindkey '^[[3~' delete-char  # Fix Delete key
