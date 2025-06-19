# ~/.bashrc: executed by bash(1) for non-login shells.

# Only execute for interactive shells
case $- in
    *i*) ;;      # Interactive mode: continue
    *) return ;; # Non-interactive: exit immediately
esac

# History configuration
HISTCONTROL=ignoreboth # Ignore duplicate lines and lines starting with space
HISTSIZE=10000         # Increase number of commands to remember
HISTFILESIZE=20000     # Increase maximum size of history file

# histappend     - Append to history file instead of overwriting
# cmdhist        - Save multi-line commands as single history entry
shopt -s histappend cmdhist

# Set shell options:
#   checkwinsize - Update LINES/COLUMNS after each command to maintain correct window size
#   dirspell     - Auto-correct minor spelling errors in directory names during completion
shopt -s checkwinsize dirspell

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

# # Set prompt based on color support
# if [ "$color_prompt" = yes ]; then
#     PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
# else
#     PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
# fi
# unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
    xterm* | rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
    *) ;;
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
if [[ -z "$PATH" ]]; then
    export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
fi

# Source Rust/Cargo env
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Load shell-helper utility functions
if [ -f ~/.shell_helpers ]; then
    . ~/.shell_helpers
fi

# ========================================================
# Aliases
# ========================================================
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
# Fallback to basic terminal if no color support
if [ "$color_prompt" != yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
    unset color_prompt force_color_prompt
    return
fi
unset color_prompt force_color_prompt

PS1_RESET='\[\033[0m\]'
PS1_GREEN='\[\033[32m\]'
PS1_BLUE='\[\033[34m\]'
PS1_YELLOW='\[\033[33m\]'
PS1_CYAN='\[\033[36m\]'
PS1_RED='\[\033[31m\]'
PS1_MAGENTA='\[\033[35m\]'

# Source git-prompt if available and not declared yet
if ! declare -F __git_ps1 &> /dev/null; then
    for path in \
        /usr/share/git-core/contrib/completion/git-prompt.sh \
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
export GIT_PS1_SHOWCOLORHINTS=1

__git_info() {
    # Use git's built-in prompt function if available
    if type -t __git_ps1 > /dev/null; then
        printf " %s " "$(__git_ps1 "[%s]")"
    else
        # Fast path: return empty string if not in a git repo
        git rev-parse --is-inside-work-tree &> /dev/null || return

        local branch
        branch=$(git symbolic-ref --short HEAD 2> /dev/null) || return

        # Add a "dirty symbol" if there are any changes to commit
        local status=""
        if ! git diff --quiet --ignore-submodules HEAD 2> /dev/null; then
            status=" *"
        fi

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
    PS1+="${PS1_CYAN}\T"
    PS1+="\n"$([[ $last_status -eq 0 ]] && echo "${PS1_GREEN}+" || echo "${PS1_RED}-")
    PS1+="${PS1_RESET} "
}

PROMPT_COMMAND=__set_prompt
