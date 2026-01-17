#!/bin/bash
#
# Installs the latest tree-sitter CLI binary to ~/.local/bin.
# Ensures the directory exists and is added to the PATH.
#
# Don't use this on Windows, use scoop install tree-sitter

set -euo pipefail

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Installs latest tree-sitter CLI to ~/.local/bin"
    echo
    echo "Options:"
    echo "  --skip-checksum   Skip SHA256 verification"
    echo "  --uninstall       Remove tree-sitter binary"
    echo "  -h, --help        Show this message"
    exit 0
}

SKIP_CHECKSUM=false
UNINSTALL=false

for arg in "$@"; do
    case "$arg" in
        --help|-h) usage ;;
        --skip-checksum) SKIP_CHECKSUM=true ;;
        --uninstall) UNINSTALL=true ;;
        *) echo "Unknown option: $arg"; usage ;;
    esac
done

BINARY_NAME="tree-sitter"
LOCAL_BIN="$HOME/.local/bin"
INSTALL_PATH="$LOCAL_BIN/$BINARY_NAME"

cleanup() {
    echo "> Cleaning up temporary files..."
    rm -f tree-sitter-linux-*.gz
}
trap cleanup EXIT

if $UNINSTALL; then
    echo "> Removing tree-sitter from $LOCAL_BIN..."
    rm -f "$INSTALL_PATH"
    echo "> Uninstalled."
    exit 0
fi

for cmd in curl gunzip awk sha256sum; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: missing required command '$cmd'."
        exit 1
    fi
done

mkdir -p "$LOCAL_BIN"
if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
    echo "> Adding $LOCAL_BIN to PATH for this session..."
    export PATH="$LOCAL_BIN:$PATH"
    echo ">> REMINDER: Add 'export PATH=\"\$HOME/.local/bin:\$PATH\"' to your .bashrc"
fi

ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  TS_URL="https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz" ;;
    aarch64) TS_URL="https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-arm64.gz" ;;
    *) echo "Unsupported arch: $ARCH"; exit 1 ;;
esac

ARCHIVE=$(basename "$TS_URL")

echo "> Downloading tree-sitter ($ARCH)..."
curl -LO "$TS_URL"

if ! $SKIP_CHECKSUM; then
    echo "> Paste SHA256 checksum from release page (or press Enter to skip):"
    read -rp "> " EXPECTED_SHA
    if [[ -n "$EXPECTED_SHA" ]]; then
        EXPECTED_SHA=${EXPECTED_SHA#sha256:}
        ACTUAL_SHA=$(sha256sum "$ARCHIVE" | awk '{print $1}')
        if [[ "$EXPECTED_SHA" != "$ACTUAL_SHA" ]]; then
            echo "Checksum mismatch!"
            exit 1
        fi
    fi
fi

echo "> Unpacking and installing to $INSTALL_PATH..."
gunzip -c "$ARCHIVE" > "$INSTALL_PATH"
chmod +x "$INSTALL_PATH"

rm -f "$ARCHIVE"
trap - EXIT

printf "%-15s %-15s %s\n" "COMMAND" "VERSION" "PATH"
printf "%-15s %-15s %s\n" "-------" "-------" "----"
TS_PATH=$(command -v tree-sitter || echo "NOT FOUND")
TS_VER=$($TS_PATH --version | awk '{print $2}' || echo "N/A")
printf "%-15s %-15s %s\n" "tree-sitter" "$TS_VER" "$TS_PATH"
echo "> Done!"
