# dotfiles/Makefile

STOW          := stow --verbose
TARGET_HOME   := $(HOME)
TARGET_CONFIG := $(TARGET_HOME)/.config

ARCH          := $(shell uname -m)
EGET_ARCH     := $(ARCH)
ifeq ($(ARCH),x86_64)
    EGET_ARCH := amd64
endif
ifeq ($(ARCH),aarch64)
    EGET_ARCH := arm64
endif

LOCAL_BIN      := $(HOME)/.local/bin
EGET_BIN       := /usr/local/bin
SHELL_RC_FILES := $(HOME)/.bashrc $(HOME)/.zshrc

TROVL_BIN      := $(LOCAL_BIN)/trovl
TROVL_MANIFEST := trovl-manifest.json

# For stow
HOME_PACKAGES   := dot-home
ZSH_PACKAGE     := dot-zsh
CONFIG_PACKAGES := dot-config

APT_PACKAGES := build-essential make git curl tar stow

.PHONY: all bootstrap install-home install-config zsh delete dry-run apt upgrade trovl \
        _check_stow _check_eget _check_local_bin _check_trovl

all: bootstrap

bootstrap: apt _check_local_bin trovl upgrade

upgrade: _check_eget
	@./scripts/upgrade_tools.sh

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
	@echo "applying trovl manifest..."
	@$(TROVL_BIN) apply $(TROVL_MANIFEST)

_check_local_bin:
	@mkdir -p $(LOCAL_BIN)

_check_stow:
	@command -v stow >/dev/null || { \
		echo "stow not found. installing..."; \
		sudo apt-get install -y stow; \
	}

_check_eget:
	@command -v eget >/dev/null || { \
		echo "eget not found. installing..."; \
		curl -fsSL https://zyedidia.github.io/eget.sh | sh; \
		sudo mv eget $(EGET_BIN)/; \
	}

_check_trovl:
	@command -v $(TROVL_BIN) >/dev/null 2>&1 || { \
		echo "trovl not found. installing ($(ARCH))..."; \
		tmp=$$(mktemp -d); \
		cd $$tmp && \
		curl -LO https://github.com/sneha-afk/trovl/releases/latest/download/trovl_linux_$(EGET_ARCH).tar.gz && \
		tar -xzf trovl_linux_$(EGET_ARCH).tar.gz && \
		mv * $(LOCAL_BIN)/ && \
		chmod +x $(TROVL_BIN) && \
		rm -rf $$tmp; \
	}
