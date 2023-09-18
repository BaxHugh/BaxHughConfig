#!/bin/bash

_help() {
    echo "Usage: $0 [options]"
    echo "Configure the shell environment to the default for BaxHugh"
    echo "Options:"
    echo "-y	Install BaxHughBin to ~/.bin without asking"
    echo "-n	Don't install BaxHughBin to ~/.bin"
    echo "-h	Display this help message"
}

while getopts "hyn" arg; do
    case $arg in
        h) # display Help
            _help
        	exit;;
      	y)
            _YES=1
            ;;
      	n)
            _NO=1
            ;;
      	\j?) # Invalid arg
         	echo "Error: Invalid arg"
         	exit;;
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
    if grep -q "$MARKER_COMMENT" $FILE; then
        echo "$SOURCE_TARGET is already sourced in $FILE"
    else
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
    curl -fsSL $URL > $HOME/$1 \
        || _warn "Failed to download $URL"
}

download_and_append_sourcing_to_file() {
    download_home_file_from_github $2
    append_sourcing_to_file $1 $2
}


# Set plugins externally to zshrc which is sourced before oh-my-zsh.sh
sed -i -E 's#plugins=\([A-Z,a-z,1-9,\ ]+\)#plugins=($ZSH_PLUGINS)#g' ~/.zshrc


# For custom bash commands
download_and_append_sourcing_to_file $HOME/.zshenv .shenv_custom
download_and_append_sourcing_to_file $HOME/.zshrc .zshrc_config
download_and_append_sourcing_to_file $HOME/.zshrc .shrc_custom

download_and_append_sourcing_to_file $HOME/.bashrc .bashrc_config
download_and_append_sourcing_to_file $HOME/.bashrc .shrc_custom

append_sourcing_to_file $HOME/.zshrc .shrc_custom_local
append_sourcing_to_file $HOME/.bashrc .shrc_custom_local

cp ~/.inputrc ~/.inputrc~
echo "Original ~/.inputrc backed up to ~/.inputrc~"
download_home_file_from_github .inputrc
download_home_file_from_github .nanorc
download_home_file_from_github .style.yapf

echo "Setting zsh theme"
ZSH_THEME_NAME="frobick"
curl -fsSL https://gist.githubusercontent.com/BaxHugh/ea7e016660a58eac4c349a9d8cdd711f/raw/$ZSH_THEME_NAME.zsh-theme > ${ZSH_CUSTOM:=$HOME/.oh-my-zsh/custom}/themes/$ZSH_THEME_NAME.zsh-theme \
    || _warn "Failed to download $ZSH_THEME_NAME.zsh-theme"
sed -i 's/'"ZSH_THEME=\".*\""'/ZSH_THEME="'$ZSH_THEME_NAME'"/g' $HOME/.zshrc

# Custom scripts on path

# if -y or -n in args, then don't ask
if [[ ! -z $_YES ]]; then
    echo "Cloning BaxHughBin to ~/.bin"
    git clone https://github.com/BaxHugh/BaxHughBin.git ~/.bin
if [[ ! -z $_NO ]]; then
    mkdir ~/.bin > /dev/null 2>&1
else
    echo "Do you want to install BaxHughBin.git to ~/.bin ? (y/n)"
    read -p "$1 (y/n): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes)
            echo "Cloning BaxHughBin to ~/.bin"
            git clone https://github.com/BaxHugh/BaxHughBin.git ~/.bin
        ;;
        * )
            mkdir ~/.bin > /dev/null 2>&1
        ;;
    esac
fi
