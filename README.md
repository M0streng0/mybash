# `.bashrc` Configuration - based on ChrisTitusTech mybash
The `.bashrc` file is a script executed whenever a new terminal session is initiated in Unix-like operating systems. This file is used to configure the shell environment, set up aliases, define functions, and more, to enhance terminal usability and functionality. Below is an overview of the key sections and features defined in the provided `.bashrc` file.

## Initial Setup and System Checks
- **Environment Checks:** The script ensures it runs in an interactive mode and sets up the environment accordingly.
- **System Utilities:** Global definitions are sourced, and the script checks for the availability of utilities like `bash-completion`.

## Aliases and Functions
- **Aliases:** Shortcuts for common commands to boost productivity. For example:
```bash
alias cp='cp -i'
alias mv='mv -i'
alias rm='trash -v'
alias mkdir='mkdir -p'
alias ps='ps auxf'
alias ping='ping -c 10'
alias less='less -R'
alias vi='nvim'

alias la='ls -Alh' # show hidden files
alias ls='ls -aFh --color=always' # add colors and file type extensions
alias ll='ls -Fls' # long listing format
```
- **Functions:**
	- _extract:_ Extract various types of archives.

## Prompt Customization and History Management
- **Prompt Command:** Automatically saves the command history after each command.
- **History Control** Settings to manage the size of the history file and prevent duplicates.

## System-Specific Aliases and Settings
- **Editor Settings:** Sets `nvim` (NeoVim) as the default editor.
- **Conditional Aliases:** Aliases to simplify directory navigation and enhance command functionalities.

## Enhancements and Utilities
- **Color and Formatting:** Enhancements for better readability of command outputs using colors and formatting.

## Installation and Configuration Helpers
- **Zoxide:** Enables Zoxide if available.

## Conclusion
This `.bashrc` file offers a robust setup that enhances the shell experience with useful aliases and functions. It also includes system-specific configurations and safety features to cater to various user needs and system environments, making the terminal more user-friendly, efficient, and powerful for everyday use.