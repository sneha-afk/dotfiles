STOW = stow --verbose
TARGET_HOME = $(HOME)
TARGET_CONFIG = $(TARGET_HOME)/.config

HOME_PACKAGES = dot-vim dot-bash

# Work around in case other folders exist in a .config/ already
CONFIG_PACKAGES = dot-config

all: stowall

stowall:
	$(STOW) --restow --target $(TARGET_HOME) $(HOME_PACKAGES)
	mkdir -p $(TARGET_CONFIG)
	$(STOW) --restow --target $(TARGET_CONFIG) $(CONFIG_PACKAGES)

delete:
	$(STOW) --delete --target $(TARGET_HOME) $(HOME_PACKAGES)
	$(STOW) --delete --target $(TARGET_CONFIG) $(CONFIG_PACKAGES)

dry-run:
	$(STOW) --simulate --restow --target $(TARGET_HOME) $(HOME_PACKAGES)
	$(STOW) --simulate --restow --target $(TARGET_CONFIG) $(CONFIG_PACKAGES)
