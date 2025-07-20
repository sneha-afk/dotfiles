# .zprofile: only run on login shells
# vim: set ft=sh ts=4 sts=4 sw=4 et:

# ========================================================
# Load ~/.profile in POSIX mode
# ========================================================
if [ -f "$HOME/.profile" ]; then
    emulate -L sh
    . "$HOME/.profile"
    emulate -L zsh
fi

# ========================================================
# Fallback PATH if no .profile
if [ -z "$PATH" ]; then
    export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
fi

export HISTFILE=~/.zsh_history
export HISTORY_IGNORE="(ls|ll|la|cd|exit|history|pwd)"
