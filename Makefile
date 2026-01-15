# dotfiles/Makefile

STOW          := stow --verbose
TARGET_HOME   := $(HOME)
TARGET_CONFIG := $(TARGET_HOME)/.config

ARCH          := $(shell uname -m)

LOCAL_BIN     := $(HOME)/.local/bin
EGET_BIN      := /usr/local/bin/
EGET_ARCH := $(ARCH)
ifeq ($(ARCH),x86_64)
    EGET_ARCH := amd64
endif
ifeq ($(ARCH),aarch64)
    EGET_ARCH := arm64
endif

EGET_ARCH_LINUX := linux/$(EGET_ARCH)

SHELL_RC_FILES := $(HOME)/.bashrc $(HOME)/.zshrc

NVIM_DIR      := /opt/nvim-linux-$(ARCH)
NVIM_BIN      := $(NVIM_DIR)/bin

TROVL_BIN      := $(LOCAL_BIN)/trovl
TROVL_MANIFEST := trovl-manifest.json

# For stow
HOME_PACKAGES   := dot-home
ZSH_PACKAGE     := dot-zsh
CONFIG_PACKAGES := dot-config

APT_PACKAGES := build-essential make git curl tar

.PHONY: all bootstrap install-home install-config zsh delete dry-run apt eget nvim trovl \
        _check_stow _check_eget _check_local_bin

all: bootstrap

bootstrap: apt _check_local_bin trovl eget nvim

eget: _check_eget
	@eget jesseduffield/lazygit --to $(LOCAL_BIN)
	@eget tree-sitter/tree-sitter --to $(LOCAL_BIN)
	@eget BurntSushi/ripgrep --to $(LOCAL_BIN)
	@eget sharkdp/fd --system=$(EGET_ARCH_LINUX) --to $(LOCAL_BIN)

	@sudo mkdir -p $(NVIM_BIN)
	@sudo eget neovim/neovim --system=$(EGET_ARCH_LINUX) --to $(NVIM_BIN)/nvim
	@echo "Neovim installed to $(NVIM_BIN)/nvim (make sure to add to PATH)"

# These targets use GNU stow
install-home: _check_stow
	$(STOW) --restow --target $(TARGET_HOME) $(HOME_PACKAGES)

install-config: _check_stow
	mkdir -p $(TARGET_CONFIG)
	$(STOW) --restow --target $(TARGET_CONFIG) $(CONFIG_PACKAGES)

zsh: _check_stow
	$(STOW) --restow --target $(TARGET_HOME) $(ZSH_PACKAGE)

delete: _check_stow
	$(STOW) --delete --target $(TARGET_HOME) $(HOME_PACKAGES) $(ZSH_PACKAGE)
	$(STOW) --delete --target $(TARGET_CONFIG) $(CONFIG_PACKAGES)

dry-run: _check_stow
	$(STOW) --simulate --restow --target $(TARGET_HOME) $(HOME_PACKAGES)
	$(STOW) --simulate --restow --target $(TARGET_CONFIG) $(CONFIG_PACKAGES)

apt:
	sudo apt-get update
	sudo apt-get install -y $(APT_PACKAGES)

trovl: _check_local_bin _check_trovl
	@echo "Applying trovl manifest..."
	@$(TROVL_BIN) apply $(TROVL_MANIFEST)

_check_local_bin:
	@mkdir -p $(LOCAL_BIN)

_check_stow:
	@command -v stow >/dev/null || { \
		echo "stow not found. Installing..."; \
		sudo apt-get install -y stow; \
	}

_check_eget:
	@command -v eget >/dev/null || { \
		echo "eget not found. Installing..."; \
		curl -fsSL https://zyedidia.github.io/eget.sh | sh; \
		mkdir -p $(EGET_BIN); \
		sudo mv eget $(EGET_BIN); \
	}

_check_trovl:
	@command -v $(TROVL_BIN) >/dev/null 2>&1 || { \
		echo "trovl not found. Installing ($(ARCH))..."; \
		tmp=$$(mktemp -d); \
		cd $$tmp && \
		curl -LO https://github.com/sneha-afk/trovl/releases/latest/download/trovl_linux_$(EGET_ARCH).tar.gz && \
		tar -xzf trovl_linux_$(EGET_ARCH).tar.gz && \
		mv * $(LOCAL_BIN)/ && \
		chmod +x $(TROVL_BIN) && \
		rm -rf $$tmp; \
	}
