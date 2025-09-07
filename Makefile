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

install-home:
	$(STOW) --restow --target $(TARGET_HOME) $(HOME_PACKAGES)

install-config:
	mkdir -p $(TARGET_CONFIG)
	$(STOW) --restow --target $(TARGET_CONFIG) $(CONFIG_PACKAGES)

zsh:
	$(STOW) --restow --target $(TARGET_HOME) $(ZSH_PACKAGE)

delete:
	$(STOW) --delete --target $(TARGET_HOME) $(HOME_PACKAGES) $(ZSH_PACKAGE)
	$(STOW) --delete --target $(TARGET_CONFIG) $(CONFIG_PACKAGES)

dry-run:
	$(STOW) --simulate --restow --target $(TARGET_HOME) $(HOME_PACKAGES)
	$(STOW) --simulate --restow --target $(TARGET_CONFIG) $(CONFIG_PACKAGES)

_check_stow:
	@command -v stow >/dev/null || { echo "'stow' not found. Please install it."; exit 1; }

apt:
	sudo apt-get update
	sudo apt-get install -y $(APT_PACKAGES)

# Chicken-and-egg problem: this can't be run until running the bootstrap script at least once.
windows:
	powershell -NoProfile -ExecutionPolicy Bypass -Command "& { \
		.\windows\bootstrap.ps1 \
	}"
