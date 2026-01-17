#!/bin/bash
#
# The `apt` package for Neovim is often outdated. This script installs the
# latest release from GitHub into `/opt/nvim`.
#
# Don't use this on Windows, use winget install Neovim.Neovim from which is bleeding-edge.
#
# Extras:
#   - Installs `ripgrep` (recommended for plugins like Telescope).
#   - Installs `xclip` only in WSL for clipboard support.

set -euo pipefail

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Installs latest Neovim from GitHub to /opt/nvim"
    echo
    echo "Options:"
    echo "  --skip-checksum   Skip SHA256 verification"
    echo "  --skip-symlinks   Don't create global nvim symlink"
    echo "  --uninstall       Remove Neovim, symlinks, and tree-sitter"
    echo "  -h, --help        Show this message"
    exit 0
}

SKIP_CHECKSUM=false
SKIP_SYMLINKS=false
UNINSTALL=false

for arg in "$@"; do
    case "$arg" in
        --help|-h) usage ;;
        --skip-checksum) SKIP_CHECKSUM=true ;;
        --skip-symlinks) SKIP_SYMLINKS=true ;;
        --uninstall) UNINSTALL=true ;;
        *) echo "Unknown option: $arg"; usage ;;
    esac
done

INSTALL_DIR="/opt"
LOCAL_BIN="$HOME/.local/bin"

cleanup() {
    echo "> Cleaning up temporary files..."
    rm -f nvim-linux-*.tar.gz tree-sitter-linux-*.gz
}
trap cleanup EXIT

if $UNINSTALL; then
    echo "> Uninstalling Neovim and tree-sitter..."
    sudo rm -rf "$INSTALL_DIR"/nvim*
    sudo rm -f /usr/bin/nvim /usr/local/bin/nvim
    rm -f "$LOCAL_BIN/tree-sitter"
    echo "> Uninstalled."
    exit 0
fi

for cmd in curl sha256sum tar awk gunzip; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: missing required command '$cmd'."
        exit 1
    fi
done

ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
        TS_URL="https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz"
        ;;
    aarch64)
        NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz"
        TS_URL="https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-arm64.gz"
        ;;
    *) echo "Unsupported arch: $ARCH"; exit 1 ;;
esac

mkdir -p "$LOCAL_BIN"
if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
    echo "> Adding $LOCAL_BIN to PATH for this session..."
    export PATH="$LOCAL_BIN:$PATH"
    echo ">> REMINDER: Add 'export PATH=\"\$HOME/.local/bin:\$PATH\"' to your .bashrc"
fi

if ! command -v tree-sitter >/dev/null 2>&1; then
    echo "> Installing tree-sitter to $LOCAL_BIN..."
    TS_ARCHIVE=$(basename "$TS_URL")
    curl -LO "$TS_URL"
    gunzip -c "$TS_ARCHIVE" > "$LOCAL_BIN/tree-sitter"
    chmod +x "$LOCAL_BIN/tree-sitter"
    rm "$TS_ARCHIVE"
    echo "> tree-sitter installed."
else
    echo "> tree-sitter already exists at $(which tree-sitter). Skipping."
fi

NVIM_ARCHIVE=$(basename "$NVIM_URL")
echo "> Downloading Neovim..."
curl -LO "$NVIM_URL"

if ! $SKIP_CHECKSUM; then
    echo "> Paste SHA256 checksum from release page (or press Enter to skip):"
    read -rp "> " EXPECTED_SHA
    if [[ -n "$EXPECTED_SHA" ]]; then
        EXPECTED_SHA=${EXPECTED_SHA#sha256:}
        ACTUAL_SHA=$(sha256sum "$NVIM_ARCHIVE" | awk '{print $1}')
        if [[ "$EXPECTED_SHA" != "$ACTUAL_SHA" ]]; then
            echo "Checksum mismatch!"
            exit 1
        fi
    fi
fi

echo "> Extracting Neovim to $INSTALL_DIR..."
sudo rm -rf "$INSTALL_DIR"/nvim*
sudo tar -C "$INSTALL_DIR" -xzf "$NVIM_ARCHIVE"

if ! $SKIP_SYMLINKS; then
    echo "> Creating Neovim symlink..."
    sudo rm -f /usr/bin/nvim /usr/local/bin/nvim
    sudo ln -s "$INSTALL_DIR"/nvim-linux-*/bin/nvim /usr/bin/nvim
fi

echo "> Installing utilities..."
sudo apt-get update -y
command -v rg >/dev/null 2>&1 || sudo apt-get install -y ripgrep
command -v fd >/dev/null 2>&1 || command -v fdfind >/dev/null 2>&1 || command -v fd-find >/dev/null 2>&1 || sudo apt-get install -y fd-find

if grep -qi microsoft /proc/version 2>/dev/null; then
    echo "> WSL detected. Installing xclip..."
    sudo apt-get install -y xclip
fi

echo -e "-----------------------------------\n"
printf "%-15s %-15s %s\n" "COMMAND" "VERSION" "PATH"
printf "%-15s %-15s %s\n" "-------" "-------" "----"

NV_PATH=$(command -v nvim || echo "NOT FOUND")
NV_VER=$($NV_PATH --version | head -n 1 | awk '{print $2}' || echo "N/A")
printf "%-15s %-15s %s\n" "neovim" "$NV_VER" "$NV_PATH"

TS_PATH=$(command -v tree-sitter || echo "NOT FOUND")
TS_VER=$($TS_PATH --version | awk '{print $2}' || echo "N/A")
printf "%-15s %-15s %s\n" "tree-sitter" "$TS_VER" "$TS_PATH"

RG_PATH=$(command -v rg || echo "NOT FOUND")
RG_VER=$($RG_PATH --version | head -n 1 | awk '{print $2}' || echo "N/A")
printf "%-15s %-15s %s\n" "ripgrep" "$RG_VER" "$RG_PATH"

FD_PATH=$(command -v fd || command -v fdfind || command -v fd-find || echo "NOT FOUND")
FD_VER=$($FD_PATH --version | head -n 1 | awk '{print $2}' || echo "N/A")
printf "%-15s %-15s %s\n" "fd" "$FD_VER" "$FD_PATH"

echo -e "-----------------------------------\n"
echo "> Done! Restart your shell or run: source ~/.bashrc"
