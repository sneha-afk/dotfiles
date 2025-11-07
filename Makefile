STOW = stow --verbose
TARGET_HOME = $(HOME)
TARGET_CONFIG = $(TARGET_HOME)/.config

HOME_PACKAGES := dot-home
ZSH_PACKAGE := dot-zsh
CONFIG_PACKAGES := dot-config

APT_PACKAGES := build-essential git make ripgrep vim

.PHONY: all boostrap install-home install-config zsh uninstall dry-run windows _check_stow

all: boostrap

# Defaults to a bash installation
boostrap: _check_stow install-home install-config apt

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

_check_stow:
	@command -v stow >/dev/null || { echo "'stow' not found. Please install it."; exit 1; }

apt:
	sudo apt-get update
	sudo apt-get install -y $(APT_PACKAGES)

windows:
	powershell -NoProfile -ExecutionPolicy Bypass -Command "& { \
		.\windows\bootstrap.ps1 \
	}"
