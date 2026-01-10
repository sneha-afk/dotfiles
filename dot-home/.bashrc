# ~/.bashrc: executed by bash(1) for non-login shells.
# vim: set ft=sh ts=4 sts=4 sw=4 et:

# Only execute for interactive shells
case $- in
    *i*) ;;      # Interactive mode: continue
    *) return ;; # Non-interactive: exit immediately
esac

# History configuration
HISTCONTROL=ignoreboth # Ignore duplicate lines and lines starting with space
HISTSIZE=10000         # Increase number of commands to remember
HISTFILESIZE=20000     # Increase maximum size of history file

# Set shell options:
# histappend      - Append to history file instead of overwriting
# cmdhist         - Save multi-line commands as single history entry
# checkwinsize    - Update LINES/COLUMNS after each command
# autocd          - Type directory name to cd into it
# cdspell         - Auto-correct minor typos in cd commands
# globstar        - Enable ** for recursive globbing (e.g., **/*.txt)
# nocaseglob      - Case-insensitive glob matching
# dotglob         - Include dotfiles in pathname expansion (use carefully)
shopt -s histappend cmdhist checkwinsize autocd cdspell globstar nocaseglob

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Detect and set debian_chroot variable if applicable
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Detect color support
case "$TERM" in
    xterm-color | *-256color) color_prompt=yes ;;
esac

# Enable color for ls and grep utilities
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
# Default Aliases
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

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Enable programmable completion features
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# -----------------------------------------------------------------------------

# Fallback PATH if no .profile for extended setup
[[ -z "$PATH" ]] && export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Sets if not already
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
[ -f "$HOME/.shell_helpers" ] && source "$HOME/.shell_helpers"
[ -f "$HOME/.wsl_env" ] && source "$HOME/.wsl_env"

# pnpm
export PNPM_HOME="~/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# ========================================================
# Aliases
# ========================================================
# Confirm destructive actions
alias cp='cp -iv'
alias mv='mv -iv'

alias mkdir='mkdir -pv' # Create parent directories and verbose
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

alias home='cd ~'

# ========================================================
# Completions
# ========================================================

command -v uv >/dev/null 2>&1 && eval "$(uv generate-shell-completion bash)"

if [[ -n "${NVM_DIR:-}" ]]; then
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

# ========================================================
# Prompt Customization
# ========================================================
# Fallback to basic terminal if no color support
if [ "$color_prompt" != yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
    unset color_prompt force_color_prompt
    return
fi
unset color_prompt force_color_prompt

PS1_RESET=$'\001\033[0m\002'
PS1_GREEN=$'\001\033[32m\002'
PS1_BLUE=$'\001\033[34m\002'
PS1_YELLOW=$'\001\033[33m\002'
PS1_RED=$'\001\033[31m\002'
PS1_MAGENTA=$'\001\033[35m\002'
PS1_CYAN=$'\001\033[36m\002'

# Source git-prompt if available and not declared yet
if ! declare -F __git_ps1 &> /dev/null; then
    for path in /usr/share/git-core/contrib/completion/git-prompt.sh \
                /usr/lib/git-core/git-sh-prompt \
                /usr/local/etc/bash_completion.d/git-prompt.sh; do
        [[ -f "$path" ]] && . "$path" && break
    done
fi

# Configure git prompt features
export GIT_PS1_SHOWDIRTYSTATE=1     # * for unstaged, + for staged
export GIT_PS1_SHOWSTASHSTATE=1     # $ for stashed changes
export GIT_PS1_SHOWUNTRACKEDFILES=1 # % for untracked files
export GIT_PS1_SHOWUPSTREAM="auto"  # < > = for behind/ahead/diverged
export GIT_PS1_SHOWCONFLICTSTATE="yes" # |CONFLICT when in conflict state
export GIT_PS1_SHOWCOLORHINTS=1

# Fast path: use git-prompt if available, else use a minimal version
__git_info() {
    ! command -v git >/dev/null && return
    # Use git's built-in prompt function if available
    if type -t __git_ps1 > /dev/null; then
        printf " %s " "$(__git_ps1 "[%s]")"
    else
        local branch
        branch=$(git branch --show-current 2>/dev/null) || return

        # Add a "dirty symbol" if there are any changes to commit
        local status=""
        [[ -n $(git status --porcelain 2>/dev/null) ]] && status="*"

        printf " %s " "${PS1_MAGENTA}[$branch$status]"
    fi
}

# Construct prompt: username@hostname, CWD, virtualenv, Git, last status
PS1_BASE="\n${PS1_GREEN}\u@\h:${PS1_BLUE}\w${PS1_RESET}"
__set_prompt() {
    local last_status=$?

    PS1=$PS1_BASE
    [[ -n "$VIRTUAL_ENV" ]] && PS1+=" ${PS1_YELLOW}($(basename "$VIRTUAL_ENV"))${PS1_RESET}"
    PS1+="$(__git_info)"
    [[ -n "${SSH_CONNECTION:-}" ]] && PS1+="${PS1_CYAN}[SSH]${PS1_RESET} "
    PS1+="\n"$([[ $last_status -eq 0 ]] && echo "${PS1_GREEN}+" || echo "${PS1_RED}-")
    PS1+="${PS1_RESET} "
}

PROMPT_COMMAND=__set_prompt
