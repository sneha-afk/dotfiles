# .zprofile: only run on login shells
# vim: set ft=sh ts=4 sts=4 sw=4 et:

if [ -f "$HOME/.profile" ]; then
    . "$HOME/.profile"
fi

[ -f "$HOME/.zshrc" ] && . "$HOME/.zshrc"
