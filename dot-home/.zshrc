# ~/.zshrc: executed by zsh for all shells

autoload -Uz promptinit
promptinit
prompt adam1

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
# autoload -Uz compinit
# compinit
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path ~/.zsh/cache

# Avoid slow `compinit` on each shell
if [[ ! -d ~/.zsh/cache ]]; then mkdir -p ~/.zsh/cache; fi
autoload -Uz compinit
compinit -C

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# -----------------------------------------------------------------------------
# ========================================================
# PATH configuration
# ========================================================
# Fallback PATH if no .profile
if [[ -z "$PATH" ]]; then
    export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
fi

# Load shell-helper utility functions
if [ -f ~/.shell_helpers ]; then
    . ~/.shell_helpers
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
alias cp='cp -iv'
alias mv='mv -iv'

alias mkdir='mkdir -pv' # Create parent directories and verbose
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

# ========================================================
# Prompt Customization
# ========================================================
autoload -U colors && colors

# Git integration with vcs_info
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' [%b%u%c]%f'
zstyle ':vcs_info:git:*' actionformats ' [%b|%a]%f'
zstyle ':vcs_info:*' unstagedstr '*'
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:*' check-for-changes true

# Enable prompt substitution
setopt prompt_subst

# Construct prompt
__set_prompt() {
    vcs_info
    local last_status=$?

    PS1=$'\n'"%F{green}%n@%m:%F{blue}%~"
    [[ -n "$VIRTUAL_ENV" ]] && PS1+=" %F{yellow}($(basename "$VIRTUAL_ENV"))%f"
    [[ -n "$vcs_info_msg_0_" ]] && PS1+="${vcs_info_msg_0_}"
    PS1+="%F{cyan} %*"
    PS1+=$'\n'"$([[ $last_status -eq 0 ]] && echo -n "%F{green}+" || echo -n "%F{red}-")%f%b"
    PS1+="${PS1_RESET} "
}

precmd_functions+=(__set_prompt)
