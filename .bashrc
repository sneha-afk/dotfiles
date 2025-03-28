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
    $HOME/go/bin
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
    # Open Windows Explorer
    explorer() {
        local win_path=$([ -z "$1" ] && wslpath -w "$PWD" || wslpath -w "$1")
        cmd.exe /c "explorer.exe $win_path" 2>/dev/null
        echo "Opening $win_path"
    }

    # Open PDFs in Adobe Acrobat
    openpdf() {
        (( $# == 0 )) && { echo "Usage: openpdf <file.pdf>"; return 1; }
        local file_path
        file_path=$(wslpath -w "$1" 2>/dev/null) || { echo "Invalid path: $1"; return 1; }
        "/mnt/c/Program Files/Adobe/Acrobat DC/Acrobat/Acrobat.exe" "$file_path" &>/dev/null &
    }

    # Open files/directories in Sublime Text
    subl() {
        ( "/mnt/c/Program Files/Sublime Text/sublime_text.exe" "$@" &>/dev/null & )
    }
fi

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
    echo
}

neovim_reset() {
    rm -rf ~/.local/share/nvim/lazy
    rm -rf ~/.cache/nvim
    echo "Neovim has been reset."
}

neovim_config_size() {
    # Define paths
    local config_dir=~/.config/nvim/
    local lazy_dir=~/.local/share/nvim/lazy/
    local mason_dir=~/.local/share/nvim/mason/
    local cache_dir=~/.cache/nvim/

    # Get human-readable sizes
    local config_size=$(du -sh "$config_dir" 2>/dev/null | cut -f1)
    local lazy_size=$(du -sh "$lazy_dir" 2>/dev/null | cut -f1)
    local mason_size=$(du -sh "$mason_dir" 2>/dev/null | cut -f1)
    local cache_size=$(du -sh "$cache_dir" 2>/dev/null | cut -f1)

    # Count plugins and LSPs
    local plugin_count=0
    local lsp_count=0
    [ -d "$lazy_dir" ] && plugin_count=$(ls -1 "$lazy_dir" | wc -l)
    [ -d "$mason_dir/packages/" ] && lsp_count=$(ls -1 "$mason_dir/packages/" | wc -l)

    # Calculate total size
    local total_size=$(($(du -sk "$config_dir" 2>/dev/null | cut -f1) + \
                        $(du -sk "$lazy_dir" 2>/dev/null | cut -f1) + \
                        $(du -sk "$mason_dir" 2>/dev/null | cut -f1) + \
                        $(du -sk "$cache_dir" 2>/dev/null | cut -f1)))
    local human_total=$(numfmt --to=iec-i --suffix=B --format="%.1f" $((total_size * 1024)))

    # Determine column widths
    local left_width=$(( $(printf "LSP Servers" | wc -c) + 2 ))
    local right_width=$(( $(printf "%s (%d)" "$mason_size" "$lsp_count" | wc -c) + 2 ))

    # Print header
    echo "NEOVIM CONFIGURATION SIZE"
    printf "%-${left_width}s %${right_width}s\n" "ITEM" "USAGE"
    printf "%-${left_width}s %${right_width}s\n" "──────────────" "──────────"

    # Print items
    printf "%-${left_width}s %${right_width}s\n" "Configuration:" "$config_size"
    printf "%-${left_width}s %${right_width}s\n" "Plugins:" "$lazy_size ($plugin_count)"
    printf "%-${left_width}s %${right_width}s\n" "LSP Servers:" "$mason_size ($lsp_count)"
    printf "%-${left_width}s %${right_width}s\n" "Cache:" "$cache_size"

    # Print total
    printf "\n%-${left_width}s %${right_width}s\n" "Total:" "$human_total"
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
    [[ -n $status_flags ]] && status="*"  # Dirty if any output

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
