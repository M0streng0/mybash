#!/bin/bash

# Script based on ChrisTitusTech mybash script.sh

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to print messages
print_message() {
    echo -e "${1}${2}${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

checkEnv() {
    # Check for requirements.
    REQUIREMENTS='curl groups sudo'
    for req in ${REQUIREMENTS}; do
        if ! command_exists "${req}"; then
            print_message "${RED}" "To run me, you need: ${req}"
            exit 1
        fi
    done

    # Check Package Handeler
    PACKAGEMANAGER='nala apt dnf yum pacman zypper emerge xbps-install nix-env'
    for pgm in ${PACKAGEMANAGER}; do
        if command_exists "${pgm}"; then
            PACKAGER=${pgm}
            print_message "${YELLOW}" "Using ${pgm}"
            break
        fi
    done

    if [ -z "${PACKAGER}" ]; then
        print_message "${RED}" "Can't find a supported package manager"
        exit 1
    fi

    if command_exists sudo; then
        SUDO_CMD="sudo"
    elif command_exists doas && [ -f "/etc/doas.conf" ]; then
        SUDO_CMD="doas"
    else
        SUDO_CMD="su -c"
    fi

    # Check if the current directory is writable.
    GITPATH="$(dirname "$(realpath "$0")")"
    if [[ ! -w ${GITPATH} ]]; then
        print_message "${RED}" "Can't write to ${GITPATH}"
        exit 1
    fi

    # Check SuperUser Group
    SUPERUSERGROUP='wheel sudo root'
    for sug in ${SUPERUSERGROUP}; do
        if groups | grep -q "${sug}"; then
            SUGROUP=${sug}
            print_message "${YELLOW}" "Super user group ${SUGROUP}"
            break
        fi
    done

    # Check if member of the sudo group.
    if ! groups | grep -q "${SUGROUP}"; then
        print_message "${RED}" "You need to be a member of the sudo group to run me!"
        exit 1
    fi

}

installDepend() {
    # Check for dependencies.
    DEPENDENCIES='bash bash-completion tar tree fastfetch tldr trash-cli fzf zoxide'

    # Check nvim existance
    if ! command_exists nvim; then
        DEPENDENCIES="${DEPENDENCIES} neovim"
    fi

    print_message "${YELLOW}" "Installing dependencies..."
    case "$PACKAGER" in
        "pacman")
            if ! command_exists yay && ! command_exists paru; then
                print_message "${YELLOW}" "Installing yay as AUR helper..."
                $SUDO_CMD "$PACKAGER" --noconfirm -S base-devel &> /dev/null
                $SUDO_CMD git clone https://aur.archlinux.org/yay-git.git /opt/yay-git &> /dev/null
                $SUDO_CMD chown -R "${USER}:${USER}" /opt/yay-git
                cd /opt/yay-git && makepkg --noconfirm -si &> /dev/null
            else
                print_message "${GREEN}" "AUR helper already installed"
            fi
            AUR_HELPER=$(command_exists yay && echo "yay" || echo "paru")
            "$AUR_HELPER" --noconfirm -S "$DEPENDENCIES" &> /dev/null
            ;;
        "nala"|"dnf"|"apt")
            "$SUDO_CMD" "$PACKAGER" install -y "$DEPENDENCIES" &> /dev/null
            ;;
        "emerge")
            "$SUDO_CMD" "$PACKAGER" -v app-shells/bash app-shells/bash-completion app-arch/tar app-text/tree app-misc/fastfetch app-text/tldr app-misc/trash-cli app-shells/fzf app-shells/zoxide app-editors/neovim &> /dev/null 
            ;;
        "xbps-install")
            "$SUDO_CMD" "$PACKAGER" -v "$DEPENDENCIES" &> /dev/null
            ;;
        "nix-env")
            "$SUDO_CMD" "$PACKAGER" -iA nixos.bash nixos.bash-completion nixos.tree nixos.fastfetch nixos.tldr nixos.trash-cli nixos.fzf nixos.zoxide nixos.neovim &> /dev/null
            ;;
        *)
            "$SUDO_CMD" "$PACKAGER" install -yq "$DEPENDENCIES" &> /dev/null
            ;;
    esac
}

config_link() {
    local source_file=$1
    local target_file=$2

    # Move existing config file if it exists.
    if [ -e "$target_file" ]; then
        print_message "${YELLOW}" "Moving old $(basename "$target_file") to ${target_file}.bak"
        mv "$target_file" "${target_file}.bak" || {
            print_message "${RED}" "Can't move the old config file!"
            exit 1
        }
    fi

    # Create target directory if it doesn't exist.
    mkdir -p "$(dirname "$target_file")"

    # Link the new config file.
    ln -svf "$source_file" "$target_file" || {
        print_message "${RED}" "Failed to create symbolic link for $(basename "$source_file")"
        exit 1
    }
}

linkConfig() {
    USER_HOME=$(getent passwd "${SUDO_USER:-$USER}" | cut -d: -f6)
    
    config_link "${GITPATH}/config.jsonc" "${USER_HOME}/.config/fastfetch/config.jsonc"   # Fastfetch
    config_link "${GITPATH}/.bashrc" "${USER_HOME}/.bashrc"                               # Bash
}

checkEnv
installDepend

if linkConfig; then
    print_message "${GREEN}" "Done!\nRestart your shell to see the changes."
else
    print_message "${RED}" "Something went wrong!"
fi
