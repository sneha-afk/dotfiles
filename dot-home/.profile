# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# ========================================================
# Environment Variables
# ========================================================

# ---- XDG Base Directory Specification ----
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# Create directories if they don't exist
for dir in "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"; do
    [ ! -d "$dir" ] && mkdir -p "$dir"
done

# ---- History Files ----
export HISTFILE="$XDG_STATE_HOME/bash/history"
export LESSHISTFILE="$XDG_CACHE_HOME/less/history"
export SQLITE_HISTORY="$XDG_DATA_HOME/sqlite_history"

# ---- Language Configurations ----
export PYTHONPATH="$HOME/python_libs:${PYTHONPATH:-}"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export PIP_CONFIG_FILE="$XDG_CONFIG_HOME/pip/pip.conf"
export PIP_LOG_FILE="$XDG_CACHE_HOME/pip/log"
export PYLINTHOME="$XDG_CACHE_HOME/pylint"

export GEM_HOME="$HOME/gems"
export GEM_SPEC_CACHE="$XDG_CACHE_HOME/gem"
export BUNDLE_USER_CONFIG="$XDG_CONFIG_HOME/bundle"
export BUNDLE_USER_CACHE="$XDG_CACHE_HOME/bundle"
export BUNDLE_USER_PLUGIN="$XDG_DATA_HOME/bundle"

export GOPATH="$HOME/go"
export GOMODCACHE="$XDG_CACHE_HOME/go/mod"

export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"

# ========================================================
# PATH Configuration
# ========================================================
# Start with system defaults
if [ -z "$PATH" ]; then
    export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
fi

path_prepend() {
    [ -d "$1" ] || return 1 # Only proceed if directory exists
    case ":${PATH}:" in
        *:"$1":*) ;; # Already in PATH - do nothing
        *) PATH="$1:${PATH}" ;;
    esac
}

path_append() {
    [ -d "$1" ] || return 1 # Only proceed if directory exists
    case ":${PATH}:" in
        *:"$1":*) ;; # Already in PATH - do nothing
        *) PATH="${PATH:+$PATH:}$1" ;;
    esac
}

path_prepend "$HOME/scripts"
path_prepend "$HOME/bin"
path_prepend "$HOME/.local/bin"

path_append "/opt/nvim-linux-x86_64/bin"

path_append "$HOME/.local/share/nvim/mason/bin"
path_append "$HOME/.cargo/bin"
path_append "$HOME/.dotnet/tools"
path_append "/usr/share/texlive/bin"

path_append "/usr/local/go/bin"
path_append "$GOPATH/bin"
path_append "$GEM_HOME/bin"

if [ -n "$WSL_DISTRO_NAME" ]; then
    path_append "/mnt/c/Windows/System32"
fi

export PATH

unset -f path_prepend path_append

# ========================================================
# Editor Configuration
# ========================================================
if [ -z "$EDITOR" ]; then
    for editor in nvim vim vi nano; do
        if command -v "$editor" > /dev/null 2>&1; then
            export EDITOR="$editor" VISUAL="$editor"

            case "$editor" in
                nvim) export MANPAGER="nvim -c 'Man!' -o -" ;;
                vim) export MANPAGER='vim -R +"set ft=man"' ;;
            esac

            break
        fi
    done
fi

# ========================================================
# WSL-Specific Configuration
# ========================================================
if [ -n "$WSL_DISTRO_NAME" ] || [ -n "$WSL_INTEROP" ]; then
    WINDOWS_DIR="/mnt/c"
    WINDOWS_PROG_FILES="$WINDOWS_DIR/Program Files"
    WINDOWS_LOCALAPPDATA=$(wslpath -u "$(cmd.exe /c "echo %LOCALAPPDATA%" 2> /dev/null | tr -d '\r')")
    SYSTEM32_DIR="$WINDOWS_DIR/Windows/System32"
    CMD_EXE="$SYSTEM32_DIR/cmd.exe"

    VSCODE_EXE="$WINDOWS_PROG_FILES/Microsoft VS Code/bin/code"
    PDF_READER="$WINDOWS_LOCALAPPDATA/SumatraPDF/SumatraPDF.exe"
    SUBLIME_TEXT_EXE="$WINDOWS_PROG_FILES/Sublime Text/sublime_text.exe"

    if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
        export DISPLAY=:0 WAYLAND_DISPLAY=wayland-0
    fi
fi

# ---------------------------------------------------------------

# If running bash, source .bashrc
[ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
