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
alias l1="la -1"       # Show all in vertical form
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
    "$HOME/.local/share/nvim/mason/bin"     # LSPs installed through Mason
    /usr/local/go/bin
    "$HOME/gems/bin"
    /usr/share/texlive
    /opt/nvim-linux-x86_64/bin
)

# Join entries and remove any duplicate entries
export PATH=$(printf "%s:" "${path_entries[@]}" | awk -v RS=: '!a[$0]++ {printf "%s%s",!NR++?"":":",$0}')

# ========================================================
# Environment Variables
# ========================================================
export PYTHONPATH="$HOME/python_libs"
export GEM_HOME="$HOME/gems"

# Ordered editor preference (left-to-right)
for editor in nvim vim vi nano; do
    if command -v "$editor" &> /dev/null; then
        export EDITOR="$editor"
        break
    fi
done
export VISUAL="$EDITOR"
git config --global core.editor "$EDITOR"

export DISPLAY=:0
export WAYLAND_DISPLAY=wayland-0

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

# Git Aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

# ========================================================
# WSL-Specific Utilities
# ========================================================
if [[ -n "$WSL_DISTRO_NAME" || -n "$WSL_INTEROP" ]]; then
    export PATH="$PATH:/mnt/c/Program Files/Microsoft VS Code/bin"

    WINDOWS_DIR="/mnt/c"
    SYSTEM32_DIR="$WINDOWS_DIR/Windows/System32"
    CMD_EXE="$SYSTEM32_DIR/cmd.exe"
    ADOBE_ACROBAT_EXE="$WINDOWS_DIR/Program Files/Adobe/Acrobat DC/Acrobat/Acrobat.exe"
    SUBLIME_TEXT_EXE="$WINDOWS_DIR/Program Files/Sublime Text/sublime_text.exe"

    alias wincdrive="cd $WINDOWS_DIR"
    alias wincmd="cd $CMD_EXE"
    alias winhome="cd $WINDOWS_DIR/Users/"

    # Open Windows Explorer
    explorer() {
        local win_path="${1:-$PWD}"
        win_path=$(wslpath -w "$win_path" 2>/dev/null) || {
            echo "Invalid WSL path: $win_path" >&2
            return 1
        }
        ( "$CMD_EXE" /c "explorer.exe $win_path" &>/dev/null & ) &&
        echo "📂 Opening: ${win_path}"
    }

    # Open PDFs in Adobe Acrobat
    openpdf() {
        (( $# == 0 )) && { echo "Usage: openpdf <file.pdf>"; return 1; }
        local file_path
        file_path=$(wslpath -w "$1" 2>/dev/null) || {
            echo "Invalid WSL path: $1" >&2
            return 1
        }
        ( "$ADOBE_ACROBAT_EXE" "$file_path" &>/dev/null & ) &&
        echo "🔖 Opened PDF: ${1##*/}"
    }

    # Open files/directories in Sublime Text
    subl() {
        ( "$SUBLIME_TEXT_EXE" "$@" &>/dev/null & ) &&
        echo "✏️ Opened in Sublime: $@"
    }
fi

# ========================================================
# Utilities
# ========================================================

# Fast searching with ripgrep
alias search="rg --smart-case --hidden --follow"

mkcd() {
    mkdir -p "$1" && cd "$1" || return 1
}

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

# Extract multiple types of archive files
extract() {
    if [ -z "$1" ]; then
        echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
        return 1
    fi

    if [ ! -f "$1" ]; then
        echo "'$1' - file doesn't exist"
        return 1
    fi

    case "$1" in
        *.tar.bz2)   tar xjf "$1"     ;;
        *.tar.gz)    tar xzf "$1"     ;;
        *.tar.xz)    tar xJf "$1"     ;;
        *.bz2)       bunzip2 "$1"     ;;
        *.rar)       unrar x "$1"     ;;
        *.gz)        gunzip "$1"      ;;
        *.tar)       tar xf "$1"      ;;
        *.tbz2)      tar xjf "$1"     ;;
        *.tgz)       tar xzf "$1"     ;;
        *.zip)       unzip "$1"       ;;
        *.Z)         uncompress "$1"  ;;
        *.7z)        7z x "$1"        ;;
        *.xz)        unxz "$1"        ;;
        *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
}

# Generate a random password
genpass() {
    local length=${1:-16}
    < /dev/urandom tr -dc 'A-Za-z0-9!@#$%^&*()_+' | head -c "$length"
    echo
}

# Verify SHA-256 checksum of a file
# Usage: verify_sha256 <file> <expected_checksum>
verify_checksum() {
    if [[ $# -ne 2 ]]; then
        echo "Usage: verify_sha256 <file> <expected_checksum>"
        return 1
    fi

    local file="$1"
    if [[ ! -f "$file" ]]; then
        echo "Error: File '$file' does not exist"
        return 1
    fi

    local expected_checksum="$2"
    actual_checksum=$(sha256sum "$file" | awk '{print $1}')

    if [[ "$actual_checksum" = "$expected_checksum" ]]; then
        echo "✅ Checksum verified: $file"
        return 0
    else
        echo "❌ Checksum mismatch for: $file"
        echo "   Expected: $expected_checksum"
        echo "   Actual:   $actual_checksum"
        return 1
    fi
}

alias nvim_goto_config="cd ~/.config/nvim/"

nvim_reset() {
    rm -rf ~/.local/share/nvim/
    rm -rf ~/.local/state/nvim/
    rm -rf ~/.cache/nvim
    [ -f ~/.config/nvim/lazy-lock.json ] && rm -f ~/.config/nvim/lazy-lock.json
    echo "Neovim has been reset."
}

nvim_size() {
  local config=~/.config/nvim/
  local lazy=~/.local/share/nvim/lazy/
  local mason=~/.local/share/nvim/mason/
  local cache=~/.cache/nvim/

  local config_kb=$(du -sk "$config" 2>/dev/null | awk '{print $1}')
  local lazy_kb=$(du -sk "$lazy" 2>/dev/null | awk '{print $1}')
  local mason_kb=$(du -sk "$mason" 2>/dev/null | awk '{print $1}')
  local cache_kb=$(du -sk "$cache" 2>/dev/null | awk '{print $1}')
  local total_kb=$(( config_kb + lazy_kb + mason_kb + cache_kb ))

  local plugins=$([ -d "$lazy" ] && ls -1 "$lazy" | wc -l || echo 0)
  local lsps=$([ -d "$mason/packages" ] && ls -1 "$mason/packages" | wc -l || echo 0)

  fmt_size() {
    numfmt --to=iec --suffix=B --format="%.1f" $(($1 * 1024))
  }

  echo "╭───────────────────────────────╮"
  echo "│     🚀 NEOVIM CONFIG SIZE     │"
  echo "├───────────────┬───────────────┤"
  printf "│ %-13s │ %13s │\n" "Config Files" "$(fmt_size "$config_kb")"
  printf "│ %-13s │ %13s │\n" "Plugins ($plugins)" "$(fmt_size "$lazy_kb")"
  printf "│ %-13s │ %13s │\n" "LSPs ($lsps)" "$(fmt_size "$mason_kb")"
  printf "│ %-13s │ %13s │\n" "Cache" "$(fmt_size "$cache_kb")"
  echo "├───────────────┼───────────────┤"
  printf "│ %-13s │ \033[1m%13s\033[0m │\n" "Total" "$(fmt_size "$total_kb")"
  echo "╰───────────────┴───────────────╯"
}

nvim_dump_swap() {
    rm -rf ~/.local/state/nvim/swap/
}

# ========================================================
# Prompt Customization
# ========================================================
__git_status_for_prompt() {
    # Fast path: return immediately if not in a git repo
    git rev-parse --is-inside-work-tree &>/dev/null || return

    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return

    # Check repo status in a single git command
    local status_flags
    status_flags=$(git status --porcelain 2>/dev/null | head -n1)

    local status=""
    [[ -n $status_flags ]] && status=" *"  # Dirty if any output

    printf " [%s%s]" "$branch" "$status"
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
    PS1+=" ${cyan}$(date +"%I:%M:%S %p")"       # Timestamp
    PS1+="\n"
    PS1+="${status_indicator}${reset} "         # Status and reset color
}

PROMPT_COMMAND=__set_prompt
