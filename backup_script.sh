#!/bin/bash

# Backup script for copying over configuration files into the current directory

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Determine the operating system
OS=$(uname -s)

# Assumes this script is where to copy all these files
BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to check if a directory exists
check_dir() {
    if [ ! -d "$1" ]; then
        echo -e "${YELLOW}Warning: Directory $1 does not exist.${NC}"
        return 1
    fi
    return 0
}

# Function to copy configuration files
copy_config() {
    local source="$1"
    local dest="$2"
    local name="$3"

    if [ -d "$source" ] || [ -f "$source" ]; then
        mkdir -p "$(dirname "$dest")"
        cp -r "$source" "$dest"
        echo -e "${GREEN}Copied $name configuration${NC}"
    else
        echo -e "${YELLOW}Skipping $name - source not found${NC}"
    fi
}

backup_configs() {
    echo -e "${GREEN}Starting configuration backup...${NC}"

    # Neovim Configurations
    if [[ "$OS" == "Darwin" || "$OS" == "Linux" ]]; then
        # Unix-like systems (macOS, Linux, WSL)
        copy_config "$HOME/.config/nvim" "$BACKUP_DIR/.config/nvim" "Neovim"
        copy_config "$HOME/.vimrc" "$BACKUP_DIR/.vimrc" "Vim"
        copy_config "$HOME/.tmux.conf" "$BACKUP_DIR/.tmux.conf" "Tmux"
        copy_config "$HOME/.zshrc" "$BACKUP_DIR/.zshrc" "Zsh"
        copy_config "$HOME/.bashrc" "$BACKUP_DIR/.bashrc" "Bash"
    fi

    # Windows-specific paths (for Git Bash or WSL)
    if [[ "$OS" == "MINGW64_NT"* || "$OS" == "MSYS_NT"* ]]; then
        # Windows Neovim location
        copy_config "$USERPROFILE/AppData/Local/nvim" "$BACKUP_DIR/.config/nvim" "Neovim (Windows)"
        copy_config "$USERPROFILE/_vimrc" "$BACKUP_DIR/.vimrc" "Vim (Windows)"
    fi

    echo -e "${GREEN}Staging changes...${NC}"
    git add .
}

# Run the backup
backup_configs

# Start prompting for git operations
read -p "Do you want to commit these changes? (y/n) " commit_choice
if [[ "$commit_choice" == [Yy] ]]; then
    # Get current timestamp
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

    # Commit with timestamp
    git commit -m "Backup configurations - $TIMESTAMP"

    echo -e "${GREEN}Backup complete! Ready to push.${NC}"

    # Prompt for push
    read -p "Do you want to push the changes to remote? (y/n) " push_choice
    if [[ "$push_choice" == [Yy] ]]; then
        git push
        echo -e "${GREEN}Changes pushed to remote repository.${NC}"
    fi
fi
