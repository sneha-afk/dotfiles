STOW = stow --verbose
TARGET_HOME = $(HOME)
TARGET_CONFIG = $(TARGET_HOME)/.config

HOME_PACKAGES = dot-home
ZSH_PACKAGE = dot-zsh
CONFIG_PACKAGES = dot-config

all: stowall

stowall:
	$(STOW) --restow --target $(TARGET_HOME) $(HOME_PACKAGES)
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
