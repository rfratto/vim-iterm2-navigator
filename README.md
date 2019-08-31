# (Neo)vim iTerm2 Navigator

This is a vim/neovim plugin inspired by [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)
to seamlessly navigate between your split Vim, Neovim, and iTerm2 panes while
editing.

## Requirements

1. iTerm2.app
2. Python API support enabled in iTerm2.app

## Installation

If you don't have a preferred installation method, I recommend using [Dein](https://github.com/Shougo/dein.vim).
Assuming you have Dein installed and configured, add the following into your
Dein configuration section:

```vim
if !empty($ITERM_SESSION_ID)
  call dein#add('rfratto/vim-iterm2-navigator', {'build': 'make install'})
endif
```

Open Vim and run `:call dein#install()` to install the plugin.

Then, in iTerm2, open Preferences and go to the Keys section. Add Key
Bindings for `<ctrl>-direction`. Each key binding should have an
action of `Invoke Script Function...` and be set to the following:

- `Ctrl-h`: `vim_aware_select_pane(direction: "h")`
- `Ctrl-j`: `vim_aware_select_pane(direction: "j")`
- `Ctrl-k`: `vim_aware_select_pane(direction: "k")`
- `Ctrl-l`: `vim_aware_select_pane(direction: "l")`

Restart iTerm2 and enjoy!

## Details

`make install` installs two scripts into iTerm2's `Scripts/AutoLaunch` folder,
which enables those scripts to run as soon as iTerm2 is launched.

`iterm2_nvim_integration.py` opens a Unix socket at `/tmp/iterm2.sock` and will
listen for connections and read a single string from them. The string sent to
the socket corresponds to the direction (`h`, `l`, `j`, or `k`) to move the
pane in iTerm2.

`iterm2_nvim_switch_pane.py` defines the `vim_aware_select_pane` function to
be exposed to the key bindings. When invoked, if the current iTerm2 pane
is vim/neovim, a vim function will be invoked to move to a new vim pane. If
there is no pane to move to, an iTerm pane will be moved to instead. If the
current iTerm2 pane isn't vim/neovim, a new iTerm pane will be moved to.
