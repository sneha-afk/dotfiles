# ~/.zshrc file for zsh interactive shells.
# see /usr/share/doc/zsh/examples/zshrc for examples

# vim: set ft=sh ts=4 sts=4 sw=4 et:

# ========================
# Options
# ========================
# autolist: show completion options when ambiguous matches
# correct: try to correct spelling; correctall: correct arguments
setopt autolist correct

autoload -U colors && colors

# ========================
# Completions
# ========================
autoload -Uz compinit

# Only rebuild if cache is older than 24 hours
if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)" ]; then
    compinit
else
    compinit -C
fi

zstyle ':completion:*' completer _expand _complete
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors '=(#b) #([a-z]*|[0-9]*)=36'
zstyle ':completion:*' rehash true
zstyle ':completion:*' verbose false

# =====================
# History
# =====================
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt hist_ignore_dups  # No duplicates
setopt share_history     # Share history across sessions
setopt hist_ignore_space  # Ignore commands starting with space

# =====================
# Key Bindings (Emacs mode)
# =====================
bindkey -e  # Emacs-style shortcuts (Ctrl+A, Ctrl+E, etc.)
bindkey '^[[3~' delete-char  # Fix Delete key

# =====================
# Color support
# =====================
if [ -x /usr/bin/dircolors ]; then
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# ========================================================
# Aliases and Helpers
# ========================================================
[ -f ~/.shell_helpers ] && source ~/.shell_helpers
[ -f ~/.bash_aliases ] && source ~/.bash_aliases

if command -v uv > /dev/null 2>&1; then
    eval "$(uv generate-shell-completion zsh)"
fi

# Listing aliases
alias ll='ls -alF' # Long format, show all except .
alias la='ls -A'   # Show all except . and ..
alias l1="la -1"   # Show all in vertical form
alias l='ls -CF'   # Column format, classify files

# Navigation alias
alias ..='cd ..'

# Add an "alert" alias for long running commands. Example: sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Confirm destructive actions
alias cp='nocorrect cp -iv'
alias mv='nocorrect mv -iv'

alias mkdir='nocorrect mkdir -pv' # Create parent directories and verbose
alias ...='cd ../..'
alias df='df -h' # Human-readable sizes
alias du='du -h' # Human-readable sizes

# Git Aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias glg='git log --graph --oneline --decorate --all'

# =====================
# Prompt
# =====================

__git_info() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return 1
    
    local status=""
    git diff-index --quiet HEAD -- 2>/dev/null || status="*"
    
    printf " [%s%s]" "$branch" "$status"
}

# Enable prompt substitution
setopt prompt_subst

__set_prompt() {
    local last_status=$?

    # user@host:path
    PROMPT=$'\n'"%F{green}%n@%m%f:%F{blue}%~%f"

    [[ -n $VIRTUAL_ENV ]] && PROMPT+=" %F{yellow}($(basename $VIRTUAL_ENV))%f"
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        PROMPT+="%F{magenta}$(__git_info)%f"
    fi

    # Green plus (last command succeeded), else red minus on a new line
    PROMPT+=$'\n'"$([[ $last_status -eq 0 ]] && echo "%F{green}+" || echo "%F{red}-")%f "
}

precmd_functions+=(__set_prompt)
