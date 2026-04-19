#!/usr/bin/env bash

# apt is known for not being bleeding edge, this script simulates a bleeding
# edge package manager by upgrading tools installed via eget.

set -e

ARCH=$(uname -m)
EGET_ARCH="$ARCH"
case "$ARCH" in
    x86_64)  EGET_ARCH="amd64" ;;
    aarch64) EGET_ARCH="arm64" ;;
esac

EGET_ARCH_LINUX="linux/$EGET_ARCH"
LOCAL_BIN="${HOME}/.local/bin"
NVIM_DIR="/opt/nvim-linux-${ARCH}"
NVIM_BIN="${NVIM_DIR}/bin"

check_eget() {
    command -v eget >/dev/null || {
        echo "error: eget not found. install it first." >&2
        exit 1
    }
}

upgrade_tools() {
    mkdir -p "$LOCAL_BIN"

    cat <<EOF
upgrading tools via eget...
note: downloads may hang due to github rate-limiting. wait or ctrl+c and retry later.

EOF

    echo "  lazygit..."
    eget jesseduffield/lazygit --to "$LOCAL_BIN" --upgrade-only || echo "    failed"

    echo "  tree-sitter..."
    eget tree-sitter/tree-sitter --asset '.gz' --to "$LOCAL_BIN" --upgrade-only || echo "    failed"

    echo "  ripgrep..."
    eget BurntSushi/ripgrep --to "$LOCAL_BIN" --upgrade-only || echo "    failed"

    echo "  fd..."
    eget sharkdp/fd --system="$EGET_ARCH_LINUX" --asset 'gnu' --to "$LOCAL_BIN" --upgrade-only || echo "    failed"

    sudo mkdir -p "$NVIM_BIN"
    echo "  neovim..."
    sudo eget neovim/neovim --asset "nvim-linux-${ARCH}.tar.gz" --file '*/bin/nvim' --to "$NVIM_BIN/nvim" --upgrade-only || echo "    failed"

    echo -e "\ndone."
}

show_usage() {
    cat <<EOF
usage: ${0##*/} [options]

upgrade installed tools via eget.

options:
    -h, --help      show this help

tools:
    lazygit, tree-sitter, ripgrep, fd, neovim
EOF
}

main() {
    check_eget

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) show_usage; exit 0 ;;
            *) echo "unknown option: $1" >&2; show_usage; exit 1 ;;
        esac
        shift
    done

    upgrade_tools
}

main "$@"
