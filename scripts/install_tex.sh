#!/bin/bash
#
# TeX environment setup script for Linux
# --------------------------------------
# Default: Installs Tectonic (modern LaTeX engine)
# Options:
#   --texlive    Install TeX Live instead
#   --uninstall  Remove TeX Live, Tectonic, and related files
#   -h, --help   Show help
#

set -e  # Exit on any error

usage() {
    echo "Usage: $0 [--texlive | --uninstall]"
    echo
    echo "Options:"
    echo "  --texlive     Install full TeX Live distribution"
    echo "  --uninstall   Remove TeX Live, Tectonic, and residual files"
    echo "  -h, --help    Show this message"
    exit 0
}

uninstall_tex() {
    echo "> Uninstalling TeX..."
    sudo apt-get remove --purge -y texlive* tex-common || true
    sudo rm -f /usr/local/bin/tectonic /usr/bin/tectonic 2>/dev/null || true

    echo "> Removing related directories..."
    sudo rm -rf ~/.texlive* ~/.cache/Tectonic ~/.local/share/tectonic ~/.config/tectonic
    sudo rm -rf /usr/local/texlive /usr/share/texlive /opt/texlive

    echo "> Cleaning up residual packages..."
    sudo apt-get autoremove -y
    sudo apt-get clean

    echo "> Uninstallation complete."
    exit 0
}

INSTALL_TEXLIVE=false
UNINSTALL=false

for arg in "$@"; do
    case "$arg" in
        --help|-h)
            usage
            ;;
        --texlive)
            INSTALL_TEXLIVE=true
            ;;
        --uninstall)
            UNINSTALL=true
            ;;
        *)
            echo "Unknown option: $arg"
            usage
            ;;
    esac
done

# Handle uninstall first
if [ "$UNINSTALL" = true ]; then
    uninstall_tex
fi

if [ "$INSTALL_TEXLIVE" = true ]; then
    echo "> Installing TeX Live (manual option)..."

    echo "> Removing any existing TeX Live or Tectonic installation..."
    sudo apt-get remove --purge -y texlive* tex-common tectonic || true
    sudo rm -rf ~/.texlive* ~/.cache/Tectonic ~/.local/share/tectonic ~/.config/tectonic

    echo "> Updating package lists..."
    sudo apt-get update

    echo "> Installing TeX Live and related packages..."
    sudo apt-get install -y \
        texlive-base \
        texlive-latex-base \
        texlive-latex-extra \
        texlive-fonts-recommended \
        texlive-fonts-extra \
        texlive-pictures \
        latexmk \
        python3-pygments

    echo "> Verifying TeX Live installation..."
    tex --version || true
    pdflatex --version || true
    latexmk --version || true
    bibtex --version || true
    pygmentize -V || true

    echo "> TeX Live setup complete."
else
    echo "> Installing Tectonic (default option)..."

    echo "> Removing any existing TeX Live installation..."
    sudo apt-get remove --purge -y texlive* tex-common || true
    sudo rm -rf ~/.texlive*

    echo "> Updating package lists..."
    sudo apt-get update

    echo "> Installing dependencies..."
    sudo apt-get install -y curl python3-pygments latexmk

    echo "> Installing Tectonic via official script..."
    curl --proto '=https' --tlsv1.2 -sSf https://tectonic.dev/install.sh | sh

    echo "> Verifying Tectonic installation..."
    tectonic --version || true
    latexmk --version || true
    pygmentize -V || true

    echo "> Tectonic setup complete."
fi
