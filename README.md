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
        checkstyle_on_write = false,  -- or true, but it may lag
        alwaysUseDefaultSeverity = false,  -- will always use the default severity or its default. if false, severity will be infered
        defaultSeverity = "ERROR"  -- possibly "ERROR", "WARN", "INFO"

    },
},
```
NOTE: if `checkstyle_file` is not set, this plugin will not create user and auto commands.

## How to use
### User command
`Jcheck` is the given user command to trigger checkstyle.

### Auto commands
if `checkstyle_on_write` is set to true, then checkstyle diagnostics will appear on writes in the current buffer additionally to the user command

