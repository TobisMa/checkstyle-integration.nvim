# Nvim checkstyle integration
Plugin with checkstyle integration for neovim

## Install
1. Download `checkstyle` from the AUR. For example by using `yay -S checkstyle`
2. Set options in your package manager.

For example in Lazy.nvim add following to your plugins and correct the path
```lua
{
    "TobisMa/checkstyle-integration.nvim",
    opts = {
        checkstyle_file = "<your path to the checkstyle file>",
        checkstyle_on_write = true
    },
},
```
NOTE: if `checkstyle_file` is not set, this plugin will not create user and auto commands.

## How to use
### User command
`Jcheck` is the given user command to trigger checkstyle. Make sure the file is saved before using it

### Auto commands
if `checkstyle_on_write` is set to true, then checkstyle diagnostics will appear on writes in the current buffer. Otherwise, the user command `Jcheck` has to be used to update the checkstyle analysis

