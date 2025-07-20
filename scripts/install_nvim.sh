#!/bin/bash

# Exit on error
set -e

WHICH_TO_DOWNLOAD="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"

echo "> Downloading Neovim..."
curl -LO $WHICH_TO_DOWNLOAD

echo "----------------------------------------"
echo " Get the official SHA256 checksum from:"
echo "   https://github.com/neovim/neovim/releases/latest"
echo "----------------------------------------"
read -p "> Paste SHA256 checksum: " EXPECTED_SHA

# Remove "sha256:" prefix if present
EXPECTED_SHA=${EXPECTED_SHA#sha256:}

ACTUAL_SHA=$(sha256sum nvim-linux-x86_64.tar.gz | awk '{print $1}')

if [[ "$EXPECTED_SHA" != "$ACTUAL_SHA" ]]; then
    echo "> Expected: $EXPECTED_SHA"
    echo "       Got: $ACTUAL_SHA"
    rm -f nvim-linux-x86_64.tar.gz
    exit 1
fi

echo "> Installing Neovim to /opt/nvim..."
sudo rm -rf /opt/nvim*
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
rm -f nvim-linux-x86_64.tar.gz

# Symlinks
sudo rm -f /usr/bin/nvim /usr/local/bin/nvim
sudo ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/bin/nvim

echo "> Neovim installed successfully!"

echo "> Optional helpful utilities: xclip and ripgrep"

sudo apt-get install xclip ripgrep
