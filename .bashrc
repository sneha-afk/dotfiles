# ~/.bashrc: executed by bash(1) for non-login shells.

# Only execute for interactive shells
case $- in
    *i*) ;;      # Interactive mode: continue
    *) return;;  # Non-interactive: exit immediately
esac


# ========================================================
# History Configuration
# ========================================================
HISTCONTROL=ignoreboth         # Ignore duplicate lines and lines starting with space
HISTSIZE=10000                 # Increase number of commands to remember
HISTFILESIZE=20000             # Increase maximum size of history file
shopt -s histappend            # Append to history file instead of overwriting
shopt -s cmdhist               # Save multi-line commands as single history entry

# ========================================================
# Shell Options
# ========================================================
shopt -s checkwinsize          # Update LINES and COLUMNS after each command
shopt -s autocd                # Automatically cd into directory typed without cd
shopt -s dirspell              # Attempt spell correction on directory names
shopt -s globstar              # Enable ** for recursive globbing

# Recursive globbing (uncomment if needed)
# shopt -s globstar

# ========================================================
# External Utilities
# ========================================================
# Enhance less for better non-text file handling
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# ========================================================
# Debian Chroot Support
# ========================================================
# Detect and set debian_chroot variable if applicable
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# ========================================================
# Terminal and Prompt Configuration
# ========================================================
# Detect color support
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# Set prompt based on color support
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt

# ========================================================
# Terminal Title Configuration
# ========================================================
# Set terminal title for xterm and rxvt
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# ========================================================
# Color Support
# ========================================================
# Enable color for ls and grep utilities
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"

    # Color aliases for various grep variants
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# ========================================================
# Default Aliases
# ========================================================
# Listing aliases
alias ll='ls -alF'     # Long format, show all except .
alias la='ls -A'       # Show all except . and ..
alias l='ls -CF'       # Column format, classify files

# Navigation alias
alias ..='cd ..'

# Alert alias for command line notifications
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Source user-specific aliases if they exist
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# ========================================================
# Bash Completion
# ========================================================
# Enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# -----------------------------------------------------------------------------

# ========================================================
# PATH configuration
# ========================================================
path_entries=(
  /usr/local/sbin
  /usr/local/bin
  /usr/sbin
  /usr/bin
  /sbin
  /bin

  # User binaries
  "$HOME/.local/bin"
  "$HOME/scripts"

  # Language/runtime paths
  /usr/local/go/bin
  "$HOME/gems/bin"
  /usr/share/texlive
  /opt/nvim-linux-x86_64/bin

  # WSL Windows paths (last to avoid conflicts + performance)
  /mnt/c/Windows/System32
)

# Join entries and remove any duplicate entries
IFS=: read -r -a unique_paths <<< "$(printf "%s:" "${path_entries[@]}")"
export PATH=$(IFS=:; echo "${unique_paths[*]}")

# ========================================================
# Environment Variables
# ========================================================
export PYTHONPATH="$HOME/python_libs"
export GEM_HOME="$HOME/gems"

# Ordered editor preference (left-to-right)
for editor in nvim vim vi nano; do
    if command -v "$editor" &> /dev/null; then
        export EDITOR="$editor"
        alias vim="$editor" 2> /dev/null
        break
    fi
done
export VISUAL="$EDITOR"
git config --global core.editor "$EDITOR"

# ========================================================
# Aliases
# ========================================================
alias cp='cp -iv'               # Confirm before overwriting
alias mv='mv -iv'               # Confirm before overwriting
alias mkdir='mkdir -pv'         # Create parent directories and verbose
alias ..='cd ..'
alias ...='cd ../..'
alias df='df -h'                # Human-readable sizes
alias du='du -h'                # Human-readable sizes

# alias vim=nvim                  # Make vim -> neovim?

# Git Aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

# ========================================================
# WSL-Specific Utilities
# ========================================================
if [[ $(uname -r) == *microsoft* ]]; then
    # Open PDFs in Windows
    openpdf() {
        local file_path=$(wslpath -w "$1")
        "/mnt/c/Program Files/Adobe/Acrobat DC/Acrobat/Acrobat.exe" "$file_path"
    }

    # Open Explorer in Windows
    explorer() {
        local win_path=$([ -z "$1" ] && wslpath -w "$PWD" || wslpath -w "$1")
        cmd.exe /c "explorer.exe $win_path" 2>/dev/null
        echo "Opening $win_path"
    }
fi

# ========================================================
# Prompt Customization
# ========================================================
__git_status_for_prompt() {
    local status=$(git status -s 2>/dev/null)
    local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

    if [[ -n "$branch" ]]; then
        if [[ -z "$status" ]]; then
            echo " [${branch}]"   # Clean branch
        else
            echo " [${branch}*]"  # Dirty branch with changes
        fi
    fi
}

__set_prompt() {
    local last_exit=$?
    local reset='\[\033[0m\]'
    local red='\[\033[31m\]'
    local green='\[\033[32m\]'
    local blue='\[\033[34m\]'
    local yellow='\[\033[33m\]'
    local cyan='\[\033[36m\]'

    # Status indicator (green + for success, red - for failure)
    local status_indicator=$([[ $last_exit -eq 0 ]] && echo "${green}+" || echo "${red}-")

    # Construct prompt
    PS1="\n"
    PS1+="${green}\u@\h:"                       # Username and hostname
    PS1+="${blue}\w"                            # Current working directory
    PS1+="${yellow}$(__git_status_for_prompt)"  # Git branch and status
    PS1+=" ${cyan}$(date +"%I:%M:%S %p")"     # Timestamp
    PS1+="\n"
    PS1+="${status_indicator}${reset} "         # Status and reset color
}
PROMPT_COMMAND=__set_prompt

# ========================================================
# Utilities
# ========================================================

# Find files quickly
ff() {
    find . -type f -name "*$1*"
}

# Find directories quickly
fd() {
    find . -type d -name "*$1*"
}

# Display a quick system info summary
sysinfo() {
    echo "Hostname: $(hostname)"
    echo "Kernel: $(uname -r)"
    echo "Uptime: $(uptime -p)"
    echo "CPU: $(cat /proc/cpuinfo | grep 'model name' | uniq | cut -d ':' -f2 | xargs)"
    echo "Memory:"
    free -h
}

# Generate a random password
genpass() {
    local length=${1:-16}
    < /dev/urandom tr -dc 'A-Za-z0-9!@#$%^&*()_+' | head -c "$length"
    echo  # add a newline
}

