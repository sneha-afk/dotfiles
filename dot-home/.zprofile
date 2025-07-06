# Run ~/.profile in bash mode

emulate sh
. ~/.profile
emulate zsh

if command -v uv > /dev/null 2>&1; then
    eval "$(uv generate-shell-completion zsh)"
fi
