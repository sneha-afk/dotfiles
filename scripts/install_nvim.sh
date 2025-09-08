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
#
# Options:
#   --skip-checksum   Skip SHA256 verification
#   --skip-symlinks   Don’t create global `nvim` symlink
#   --uninstall       Remove Neovim and symlinks
#

set -euo pipefail

# =========[ Flags ]=========
SKIP_CHECKSUM=false
SKIP_SYMLINKS=false
UNINSTALL=false

for arg in "$@"; do
    case "$arg" in
        --skip-checksum) SKIP_CHECKSUM=true ;;
        --skip-symlinks) SKIP_SYMLINKS=true ;;
        --uninstall) UNINSTALL=true ;;
        *) echo "Unknown option: $arg"; exit 1 ;;
    esac
done

ARCHIVE=""
INSTALL_DIR="/opt"

# =========[ Uninstall ]=========
if $UNINSTALL; then
    echo "> Uninstalling Neovim..."
    sudo rm -rf "$INSTALL_DIR"/nvim*
    sudo rm -f /usr/bin/nvim /usr/local/bin/nvim
    echo "> Neovim uninstalled."
    exit 0
fi

# =========[ Prereqs ]=========
for cmd in curl sha256sum tar awk; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: missing required command '$cmd'."
        exit 1
    fi
done

# =========[ Arch detection ]=========
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz" ;;
    aarch64) NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz" ;;
    *) echo "Unsupported arch: $ARCH"; exit 1 ;;
esac

ARCHIVE=$(basename "$NVIM_URL")

# =========[ Download ]=========
echo "> Downloading Neovim ($ARCH)..."
curl -LO "$NVIM_URL"
trap 'rm -f "$ARCHIVE"' EXIT

# =========[ Checksum ]=========
if $SKIP_CHECKSUM; then
    echo "> Skipping checksum verification."
else
    echo "> Paste SHA256 checksum (from release page):"
    read -rp "> " EXPECTED_SHA
    EXPECTED_SHA=${EXPECTED_SHA#sha256:}
    ACTUAL_SHA=$(sha256sum "$ARCHIVE" | awk '{print $1}')
    if [[ "$EXPECTED_SHA" != "$ACTUAL_SHA" ]]; then
        echo "Checksum mismatch!"
        echo "Expected: $EXPECTED_SHA"
        echo "Got:      $ACTUAL_SHA"
        exit 1
    fi
fi

# =========[ Install ]=========
echo "> Installing Neovim to $INSTALL_DIR..."
sudo rm -rf "$INSTALL_DIR"/nvim*
sudo tar -C "$INSTALL_DIR" -xzf "$ARCHIVE"

if $SKIP_SYMLINKS; then
    echo "> Skipping symlink creation."
else
    echo "> Creating symlink..."
    sudo rm -f /usr/bin/nvim /usr/local/bin/nvim
    sudo ln -s "$INSTALL_DIR"/nvim-linux-*/bin/nvim /usr/bin/nvim
fi

rm -f "$ARCHIVE"
trap - EXIT

# =========[ Extras ]=========
echo "> Installing utilities..."
sudo apt-get update -y
sudo apt-get install -y ripgrep

if grep -qi microsoft /proc/version 2>/dev/null; then
    echo "> WSL detected. Installing xclip..."
    sudo apt-get install -y xclip
fi

# =========[ Done ]=========
echo "> Installed Neovim version:"
if $SKIP_SYMLINKS; then
    "$INSTALL_DIR"/nvim-linux-*/bin/nvim --version | head -n 1
else
    nvim --version | head -n 1
fi

echo "> Done!"
