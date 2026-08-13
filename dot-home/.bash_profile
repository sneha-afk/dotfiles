# ~/.bash_profile: executed by bash(1) for login shells.
# bash does not read ~/.profile when this file exists, so source it explicitly.
# vim: set ft=sh ts=4 sts=4 sw=4 et:

if [ -f "$HOME/.profile" ]; then
    . "$HOME/.profile"
fi

[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
