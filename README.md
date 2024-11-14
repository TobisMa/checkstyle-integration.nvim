# Nvim checkstyle integration
Plugin with checkstyle integration for neovim

## Install
1. Download `checkstyle` from the AUR. For example by using `yay -S checkstyle`
2. Set `vim.g.checkstyle_file` in your neovim config to an checkstyle.xml file

NOTE: if `vim.g.checkstyle_file` is not set, this plugin will not create user and auto commands.

## How to use
### User command
`Jcheck` is the given user command to trigger checkstyle.

### Auto commands
if `vim.g.checkstyle_on_write` is set to true, then checkstyle diagnostics will appear on writes in the current buffer

