#!/bin/bash

echo -e "
\033[31m█▀▄▀█ █▀█ █▀ ▀█▀ █▀█ █▀▀ █▄░█ █▀▀ █▀█
\033[31m█░▀░█ █▄█ ▄█ ░█░ █▀▄ ██▄ █░▀█ █▄█ █▄█"

PROMPT_DIRTRIM=3
VIRTUAL_ENV_DISABLE_PROMPT=1

PS1='\n\[\e[96m\]┌──\[\e[96m\]${VIRTUAL_ENV:+(\[\e[0m\]${VIRTUAL_ENV##*/}\[\e[96m\])}\[\e[96m\](\[\e[93;1m\]\u\[\e[96m\]@\[\e[32m\]\H\[\e[0;96m\])-[\[\e[0m\]\w\[\e[96m\]]\n└─\[\e[94;1m\]\$\[\e[0m\] '

x=${-%%i*}
iatest=$((${#x} + 1))

#######################################################
# SOURCED ALIAS'S AND SCRIPTS BY zachbrowne.me
#######################################################

# Source global definitions
if [ -f /etc/bashrc ]; then
	 . /etc/bashrc
fi

# Enable bash programmable completion features in interactive shells
if [ -f /usr/share/bash-completion/bash_completion ]; then
	. /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
fi

#######################################################
# EXPORTS
#######################################################

# Disable the bell
if [[ $iatest -gt 0 ]]; then bind "set bell-style visible"; fi

# Expand the history size
export HISTFILESIZE=10000
export HISTSIZE=500
export HISTTIMEFORMAT="%F %T: " # add timestamp to history

# Don't put duplicate lines in the history and do not add lines that start with a space
export HISTCONTROL=erasedups:ignoredups:ignorespace

# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS
shopt -s checkwinsize

# Causes bash to append to history instead of overwriting it so if you start a new terminal, you have old session history
shopt -s histappend
PROMPT_COMMAND='history -a'

# Allow ctrl-S for history navigation (with ctrl-R)
[[ $- == *i* ]] && stty -ixon

# Ignore case on auto-completion
# Note: bind used instead of sticking these in .inputrc
if [[ $iatest -gt 0 ]]; then bind "set completion-ignore-case on"; fi

# Show auto-completion list automatically, without double tab
if [[ $iatest -gt 0 ]]; then bind "set show-all-if-ambiguous On"; fi

# Set the default editor
export EDITOR=nvim
export VISUAL=nvim
alias nano='nvim'
alias vim='nvim'

# To have colors for ls and all grep commands such as grep, egrep and zgrep
export CLICOLOR=1
export LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:'

# Check if ripgrep is installed
if command -v rg &> /dev/null; then
    # Alias grep to rg if ripgrep is installed
    alias grep='rg'
fi

# Color for manpages in less makes manpages a little easier to read
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

#######################################################
# MACHINE SPECIFIC ALIAS'S
#######################################################

# Alias's for SSH (Example)
# alias remote='ssh -i ~/.ssh/key.pem user@IP'

#######################################################
# GENERAL ALIAS'S
#######################################################

# Alias's to modified commands
alias cp='cp -i'
alias mv='mv -i'
alias rm='trash -v'
alias mkdir='mkdir -p'
alias ps='ps auxf'
alias ping='ping -c 10'
alias less='less -R'
alias vi='nvim'

# Alias's for multiple directory listing commands
alias la='ls -Alh' # show hidden files
alias ls='ls -aFh --color=always' # add colors and file type extensions
alias ll='ls -Fls' # long listing format

# Search command line history
alias h="history | grep "

# Search files in the current folder
alias f="find . | grep "

# Alias's to show disk space and space used in a folder
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'

# Show all logs in /var/log
alias logs="sudo find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"

# Extracts any archive(s) (if unp isn't installed)
extract () {
	for archive in "$@"; do
		if [ -f "$archive" ] ; then
			case $archive in
				*.tar.bz2)   tar xvjf "$archive"    ;;
				*.tar.gz)    tar xvzf "$archive"    ;;
				*.tar.xz)	   tar xvJf "$archive"	  ;;
				*.bz2)       bunzip2 "$archive"     ;;
				*.rar)       rar x "$archive"       ;;
				*.gz)        gunzip "$archive"      ;;
				*.tar)       tar xvf "$archive"     ;;
				*.tbz2)      tar xvjf "$archive"    ;;
				*.tgz)       tar xvzf "$archive"    ;;
				*.zip)       unzip "$archive"       ;;
				*.Z)         uncompress "$archive"  ;;
				*.7z)        7z x "$archive"        ;;
				*)           echo "don't know how to extract '$archive'..." ;;
			esac
		else
			echo "'$archive' is not a valid file!"
		fi
	done
}

# IP address lookup
whatsmyip () {
    # Detect the active network interface
    active_interface=$(ip route | grep '^default' | awk '{print $5}')
    
    # Internal IP Lookup
    if command -v ip &> /dev/null; then
        echo -n "Internal IP: "
        ip addr show "$active_interface" | grep "inet " | awk '{print $2}' | cut -d/ -f1
    else
        echo -n "Internal IP: "
        ifconfig "$active_interface" | grep "inet " | awk '{print $2}'
    fi

    # External IP Lookup
    echo -n "External IP: "
    curl -s ifconfig.me
}

# Zoxide
eval "$(zoxide init bash)"

# Dynamic window title
set-window-title() {
  echo -en "\033]0;$(pwd | sed -e "s;^$HOME;~;")\a"
}

if [[ "$PROMPT_COMMAND" ]]; then
  export PROMPT_COMMAND="$PROMPT_COMMAND;set-window-title"
else
  export PROMPT_COMMAND=set-window-title
fi
