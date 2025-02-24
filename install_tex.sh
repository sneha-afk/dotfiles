#!/bin/bash

set -e  # Exit on error

echo "> Removing any existing TeX Live installation..."
sudo apt-get remove --purge -y texlive* tex-common
sudo rm -rf ~/.texlive*

echo "> Updating package lists..."
sudo apt-get update

echo "> Installing TeX Live (base) and required packages..."
sudo apt-get install -y \
    texlive-base \
    texlive-latex-base \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-bibtex-extra \
    texlive-pictures \
    texlive-science \
    latexmk \
    python3-pygments

echo "> Installation complete! Verifying installation..."
tex --version
latexmk --version
pdflatex --version
bibtex --version
pygmentize -V

echo "> TeX Live setup complete"
