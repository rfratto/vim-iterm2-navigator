install:
	mkdir -p "${HOME}/Library/Application Support/iTerm2/Scripts/AutoLaunch"
	ln -sfv $(shell pwd)/iterm2_nvim_integration.py \
		"${HOME}/Library/Application Support/iTerm2/Scripts/AutoLaunch/iterm2_nvim_integration.py"
	ln -sfv $(shell pwd)/iterm2_nvim_switch_pane.py \
		"${HOME}/Library/Application Support/iTerm2/Scripts/AutoLaunch/iterm2_nvim_switch_pane.py"
