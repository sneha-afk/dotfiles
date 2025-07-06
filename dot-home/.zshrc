# ~/.zshrc file for zsh interactive shells.
# see /usr/share/doc/zsh/examples/zshrc for examples

# vim: set ft=sh ts=4 sts=4 sw=4 et:

# ========================
# Options
# ========================
# autolist: show completion options when ambiguous matches
# correct: try to correct spelling; correctall: correct arguments
setopt autolist correct

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

zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' rehash true
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# =====================
# History
# =====================
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt hist_ignore_dups  # No duplicates
setopt share_history     # Share history across sessions
setopt hist_ignore_space  # Ignore commands starting with space
export HISTORY_IGNORE="(ls|ll|la|cd|exit|history|pwd)"

# =====================
# Key Bindings (Emacs mode)
# =====================
bindkey -e  # Emacs-style shortcuts (Ctrl+A, Ctrl+E, etc.)
bindkey '^[[3~' delete-char  # Fix Delete key

# =====================
# Color support
# =====================
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# ========================================================
# PATH configuration
# ========================================================
# Fallback PATH if no .profile
if [[ -z "$PATH" ]]; then
    export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
fi

# Load shell-helper utility functions
[ -f ~/.shell_helpers ] && . ~/.shell_helpers

[ -f ~/.bash_aliases ] && . ~/.bash_aliases

if command -v uv > /dev/null 2>&1; then
    eval "$(uv generate-shell-completion zsh)"
fi

# ========================================================
# Aliases
# ========================================================
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
alias ..='cd ..'
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
autoload -U colors && colors

# Git integration with vcs_info
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' [%b%u%c%m]%f'
zstyle ':vcs_info:git:*' actionformats ' [%b|%a]%f'
zstyle ':vcs_info:*' unstagedstr '*'
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:*' check-for-changes true

# Enable prompt substitution
setopt prompt_subst

__set_prompt() {
    local last_status=$?
    vcs_info

    # user@host:path
    PROMPT=$'\n'"%F{green}%n@%m%f:%F{blue}%~%f"

    [[ -n $VIRTUAL_ENV ]] && PROMPT+=" %F{yellow}($(basename $VIRTUAL_ENV))%f"
    [[ -n "$vcs_info_msg_0_" ]] && PROMPT+="%F{magenta}${vcs_info_msg_0_}%f"

    # Green plus (last command succeeded), else red minus on a new line
    PROMPT+=$'\n'"$([[ $last_status -eq 0 ]] && echo "%F{green}+" || echo "%F{red}-")%f "
}

precmd_functions+=(__set_prompt)
