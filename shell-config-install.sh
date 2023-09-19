#!/bin/bash

_zsh_is_installed() {
    which zsh > /dev/null 2>&1
}

_omzsh_is_installed() {
    [[ -d ${ZSH:=$HOME/.oh-my-zsh} ]]
}

_help() {
    echo "Usage: shell-config-install.sh [options]"
    echo "Configure the shell environment to the default for BaxHugh"
    echo "Options:"
    echo "  --no-backup,              Don't backup existing files"
    echo "  --install-zsh             Install zsh (and oh-my-zsh) if not already installed"
    echo "  --install-baxhugh-bin,    Install BaxHughBin to ~/.bin"
    echo "  --unattended,             Answer no to any prompts"
    echo "  -h, --help,               Display this help message"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-backup)
            _NO_BACKUP=1
            shift
        ;;
        --install-zsh)
            _INSTALL_ZSH=1
            shift
        ;;
        --install-baxhugh-bin)
            _INSTALL_BAXHUGH_BIN=1
            shift
        ;;
        --unattended)
            _UNATTENDED=--unattended
            shift
        ;;
        -h|--help)
            _help
            exit 0
        ;;
        *)
            echo "Unknown option: $1"
            _help
            exit 1
        ;;
    esac
done

FILES_DIR=$(dirname $0)/../files

_warn() {
    echo -e "\e[33mWarning: $1\e[0m"
}

append_sourcing_to_file() {
    local FILE=$1
    local SOURCE_TARGET=$2
    local MARKER_COMMENT=">>> shell config script $SOURCE_TARGET >>>"
    if ! grep -q "$MARKER_COMMENT" $FILE; then
        echo "Appending sourcing of ~/$SOURCE_TARGET to $FILE"
        echo "
# $MARKER_COMMENT
if [ -f ~/$SOURCE_TARGET ]; then
    source ~/$SOURCE_TARGET
fi
# <<< shell config script <<<
" >> $FILE
    fi
}

download_home_file_from_github() {
    local URL=https://raw.githubusercontent.com/BaxHugh/BaxHughConfig/main/home/$(basename $1)
    if [[ -z $_NO_BACKUP ]]; then
        echo "Writing $HOME/$1 - original backed up to $HOME/$1~"
        cp $HOME/$1 $HOME/$1~ > /dev/null 2>&1
    else
        echo "Writing $HOME/$1"
    fi
    curl -fsSL $URL > $HOME/$1 \
        || _warn "Failed to download $URL"
}

download_and_append_sourcing_to_file() {
    download_home_file_from_github $2
    append_sourcing_to_file $1 $2
}

if ! _zsh_is_installed || ! _omzsh_is_installed; then
    if [ -z $_INSTALL_ZSH ] && [ -z $_UNATTENDED ]; then
        echo "Do you want to install zsh and oh-my-zsh? (y/n)"
        read -p "$1 (y/n): "
        case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
            y|yes)
                _INSTALL_ZSH=1
            ;;
            * )
                echo "n"
            ;;
        esac
    fi
fi

if ! _zsh_is_installed; then
    if [[ ! -z $_INSTALL_ZSH ]]; then
        echo "Installing zsh..."
        sudo apt install -y zsh || _warn "Failed to install zsh"
    else
        _warn "zsh is not installed. Run this script with --install-zsh to install zsh or install it manually and run this script again."
    fi
fi

if ! _omzsh_is_installed; then
    if [[ ! -z $_INSTALL_ZSH ]]; then
        echo "Installing oh-my-zsh..."
        curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh -s -- $_UNATTENDED \
            || _warn "Failed to install oh-my-zsh"
    else
        _warn "oh-my-zsh is not installed. Run this script with --install-zsh to install oh-my-zsh or install it manually and run this script again."
    fi
fi


# Set plugins externally to zshrc which is sourced before oh-my-zsh.sh
if grep -q 'plugins=(' $HOME/.zshrc; then    
    echo "Setting zsh plugins to the \$ZSH_PLUGINS environment variable defined in ~/.shenv_custom"
    sed -i -E 's#plugins=\([A-Z,a-z,1-9,\ ]+\)#plugins=($ZSH_PLUGINS)#g' ~/.zshrc
fi

# For custom bash commands
download_and_append_sourcing_to_file $HOME/.zshenv .shenv_custom
download_and_append_sourcing_to_file $HOME/.zshrc .zshrc_config
download_and_append_sourcing_to_file $HOME/.zshrc .shrc_custom

download_and_append_sourcing_to_file $HOME/.profile .shenv_custom
download_and_append_sourcing_to_file $HOME/.bashrc .bashrc_config
download_and_append_sourcing_to_file $HOME/.bashrc .shrc_custom

append_sourcing_to_file $HOME/.zshrc .shrc_custom_local
append_sourcing_to_file $HOME/.bashrc .shrc_custom_local

cp ~/.inputrc ~/.inputrc~
echo "Original ~/.inputrc backed up to ~/.inputrc~"
download_home_file_from_github .inputrc
download_home_file_from_github .nanorc
download_home_file_from_github .style.yapf

if _omzsh_is_installed; then
    ZSH_THEME_NAME="frobick"
    curl -fsSL https://gist.githubusercontent.com/BaxHugh/ea7e016660a58eac4c349a9d8cdd711f/raw/$ZSH_THEME_NAME.zsh-theme > ${ZSH_CUSTOM:=$HOME/.oh-my-zsh/custom}/themes/$ZSH_THEME_NAME.zsh-theme \
        && (
            echo "Setting oh-my-zsh theme"
            sed -i 's/'"ZSH_THEME=\".*\""'/ZSH_THEME="frobick"/g' $HOME/.zshrc
        ) \
        || _warn "Failed to download $ZSH_THEME_NAME.zsh-theme"
fi

# Custom scripts on path

# if -y or -n in args, then don't ask
if [[ ! -z $_INSTALL_BAXHUGH_BIN ]]; then
    echo "Cloning BaxHughBin to ~/.bin"
    git clone https://github.com/BaxHugh/BaxHughBin.git ~/.bin || _warn "Failed to clone BaxHughBin.git"
else
    mkdir ~/.bin > /dev/null 2>&1
    echo "If you want to install BaxHughBin.git to ~/.bin, run this script with --install-baxhugh-bin"
fi

echo -e "\e[32mDone\e[0m"
