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

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

checkEnv() {
    ## Check for requirements.
    REQUIREMENTS='curl groups sudo'
    if ! command_exists "${REQUIREMENTS}"; then
        print_message "${RED}" "To run me, you need: ${REQUIREMENTS}"
        exit 1
    fi

    ## Check Package Handeler
    PACKAGEMANAGER='apt yum dnf pacman zypper'
    for pgm in ${PACKAGEMANAGER}; do
        if command_exists "${pgm}"; then
            PACKAGER=${pgm}
            print_message "${YELLOW}" "Using ${pgm}"
        fi
    done

    if [ -z "${PACKAGER}" ]; then
        print_message "${RED}" "Can't find a supported package manager"
        exit 1
    fi

    ## Check if the current directory is writable.
    GITPATH="$(dirname "$(realpath "$0")")"
    if [[ ! -w ${GITPATH} ]]; then
        print_message "${RED}" "Can't write to ${GITPATH}"
        exit 1
    fi

    ## Check SuperUser Group
    SUPERUSERGROUP='wheel sudo root'
    for sug in ${SUPERUSERGROUP}; do
        if groups | grep "${sug}"; then
            SUGROUP=${sug}
            print_message "${YELLOW}" "Super user group ${SUGROUP}"
        fi
    done

    ## Check if member of the sudo group.
    if ! groups | grep "${SUGROUP}" >/dev/null; then
        print_message "${RED}" "You need to be a member of the sudo group to run me!"
        exit 1
    fi

}

installDepend() {
    ## Check for dependencies.
    DEPENDENCIES='bash bash-completion tar tree fastfetch tldr trash-cli'
    print_message "${YELLOW}" "Installing dependencies..."
    if [[ $PACKAGER == "pacman" ]]; then
        if ! command_exists yay && ! command_exists paru; then
            print_message "${YELLOW}" "Installing yay as AUR helper..."
            sudo "${PACKAGER}" --noconfirm -S base-devel
            cd /opt && sudo git clone https://aur.archlinux.org/yay-git.git && sudo chown -R "${USER}:${USER}" ./yay-git
            cd yay-git && makepkg --noconfirm -si
        else
            print_message "${GREEN}" "Aur helper already installed"
        fi
        if command_exists yay; then
            AUR_HELPER="yay"
        elif command_exists paru; then
            AUR_HELPER="paru"
        else
            print_message "${RED}" "No AUR helper found. Please install yay or paru."
            exit 1
        fi
        "${AUR_HELPER}" --noconfirm -S "${DEPENDENCIES}"
    else
        sudo "${PACKAGER}" install -yq "${DEPENDENCIES}"
    fi
}

installStarship() {
    if command_exists starship; then
        print_message "${GREEN}" "Starship already installed"
        return
    fi
    if ! curl -sS https://starship.rs/install.sh | sh; then
        print_message "${RED}" "Something went wrong during starship install!"
        exit 1
    fi
}

install_additional_dependencies() {
    case $(command -v apt || command -v zypper || command -v dnf || command -v pacman) in
        *apt)
            curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
            chmod u+x nvim.appimage
            ./nvim.appimage --appimage-extract
            sudo mv squashfs-root /opt/neovim
            sudo ln -s /opt/neovim/AppRun /usr/bin/nvim
            ;;
        *zypper)
            sudo zypper refresh
            sudo zypper install -y neovim 
            ;;
        *dnf)
            sudo dnf check-update
            sudo dnf install -y neovim 
            ;;
        *pacman)
            sudo pacman -Syu
            sudo pacman -S --noconfirm neovim 
            ;;
        *)
            print_message "${RED}" "No supported package manager found. Please install neovim manually."
            exit 1
            ;;
    esac
}

linkConfig() {
    ## Get the correct user home directory.
    USER_HOME=$(getent passwd "${SUDO_USER:-$USER}" | cut -d: -f6)
    ## Check if a bashrc file is already there.
    OLD_BASHRC="${USER_HOME}/.bashrc"
    if [[ -e ${OLD_BASHRC} ]]; then
        print_message "${YELLOW}" "Moving old bash config file to ${USER_HOME}/.bashrc.bak"
        if ! mv "${OLD_BASHRC}" "${USER_HOME}/.bashrc.bak"; then
            print_message "${RED}" "Can't move the old bash config file!"
            exit 1
        fi
    fi

    print_message "${YELLOW}" "Linking new bash config file..."
    ## Make symbolic link.
    ln -svf "${GITPATH}/.bashrc" "${USER_HOME}/.bashrc"
    ln -svf "${GITPATH}/starship.toml" "${USER_HOME}/.config/starship.toml"
}

checkEnv
installDepend
installStarship
install_additional_dependencies

if linkConfig; then
    print_message "${GREEN}" "Done!\nrestart your shell to see the changes."
else
    print_message "${RED}" "Something went wrong!"
fi