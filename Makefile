STOW = stow --verbose
TARGET_HOME = $(HOME)
TARGET_CONFIG = $(TARGET_HOME)/.config

HOME_PACKAGES := dot-home
ZSH_PACKAGE := dot-zsh
CONFIG_PACKAGES := dot-config

.PHONY: all install install-home install-config zsh uninstall dry-run windows _check_stow

all: install

# Defaults to a bash installation
install: _check_stow install-home install-config

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

#region Windows
windows:
	powershell -NoProfile -ExecutionPolicy Bypass -Command "& { \
		try { \
			Unblock-File -Path '.\\windows\\install_windows.ps1'; \
			.\windows\install_windows.ps1 \
			Write-Host 'install_windows.ps1 executed successfully' -ForegroundColor Green \
		} catch { \
			Write-Warning 'Failed to execute install_windows.ps1'; \
			Write-Warning $_.Exception.Message \
		} \
	}"
#endregion
