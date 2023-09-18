#!/bin/bash


_error() {
    echo -e "\e[31mError: $1\e[0m" >&2
    return 1
}

_gecho() {
    echo -e "\e[32m$1\e[0m"
}

_becho() {
    echo -e "\e[34m$1\e[0m"
}

_help() {
    echo "Usage: package-install.sh <command> [options] [<package-group> <package-group>]"
    echo "Install package groups defined within this script for ease of setup of new systems"
    echo ""
    echo "Options:"
    echo "  -h, --help,     Display this help message"
    echo ""
    echo "Commands:"
    echo "  install,        Install packages groups in args"
    echo "                    Usage: package-install.sh install [options] <package-group> <package-group> ..."
    echo "                    Options:"
    echo "                      -y,         Pass -y to apt"
    echo ""
    echo "  list,           List available package groups or the packages in a group"
    echo "                    Usage: package-install.sh list"
    echo "                    Usage: package-install.sh list <package-group>"
}

_process_install_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -y)
                _Y="-y"
                shift
            ;;
            -*)
                _error "Unknown option: $1"
                _help
                exit 1
            ;;
            --*)
                _error "Unknown option: $1"
                _help
                exit 1
            ;;
            *)
                _PACKAGE_GROUPS=$@
                break
            ;;
        esac
    done
}

_process_agrs() {
    
    COMMAND=$1
    shift
    case $COMMAND in
        -h|--help)
            _help
            exit 0
        ;;
        install)
            _process_install_args $@
            for PACKAGE_GROUP in $_PACKAGE_GROUPS; do
                # if package group not in available package groups then error
                if ! _get_available_package_groups | grep -q -w "$PACKAGE_GROUP"; then
                    _error "Unknown package group: $PACKAGE_GROUP"
                    exit 1
                fi

                _becho "Installing package group: $PACKAGE_GROUP..."
                if type "_this_install_group_$PACKAGE_GROUP" > /dev/null 2>&1; then
                    _this_install_group_${PACKAGE_GROUP} \
                        || _error "Failed to install package group: $PACKAGE_GROUP" || exit 1
                else
                    _install_apt_packages "$(_this_get_group_${PACKAGE_GROUP})" \
                        || _error "Failed to install package group: $PACKAGE_GROUP" || exit 1
                fi
            done
            _gecho "Done"
            exit 0
        ;;
        list)
            if [ -z "$1" ]; then
                _get_available_package_groups
            else
                if type "_this_get_group_$1" > /dev/null 2>&1; then
                    for PACKAGE in $(_this_get_group_$1); do
                        echo $PACKAGE
                    done
                else
                    _error "Unknown package group: $1"
                    exit 1
                fi
            fi
            exit 0
        ;;
        *)
            _error "Unknown command: $COMMAND"
            exit 1
        ;;
    esac
}




_get_available_package_groups() {
    # echo all packages which have a function defined _this_get_group_$PACKAGE_GROUP 
    # get all functions
    declare -F | awk '{print $3}' \
        | grep -E '_this_get_group_' \
        | sed -E 's/_this_get_group_//g' \
        | sort | uniq
}

_this_get_group_cli-basic() {
    echo "curl \
zsh \
git \
xclip \
nmap \
python3 \
python-is-python3 \
micro"
}

_this_get_group_decoding() {
    echo heif-gdk-pixbuf heif-thumbnailer
}

_this_get_group_cli-dev() {
    echo "noapm"
}


_this_install_group_cli-dev() {
    NOAPM_LOCATION=${NOAPM_LOCATION:="$HOME/.local/bin"}
    local NOAPM_PATH=$NOAPM_LOCATION/noapm
    if [ -f $NOAPM_PATH ]; then
        echo "All packages already installed"
        return 0
    fi
    mkdir -p $NOAPM_LOCATION > /dev/null 2>&1 && \
        curl -fsSL https://raw.githubusercontent.com/BaxHugh/noapm/main/noapm -o $NOAPM_PATH \
        && chmod +x $NOAPM_PATH
}

_install_apt_packages() {
    local PACKAGES=$1
    # using flag_package_for_install_if_command_not_found
    local TO_INSTALL=""
    for PACKAGE in $PACKAGES; do
        if ! dpkg -s $PACKAGE > /dev/null 2>&1; then
            TO_INSTALL="$TO_INSTALL $PACKAGE"
        fi
    done
    if [ -n "$TO_INSTALL" ]; then
        sudo apt update
        echo "sudo apt $_Y install $TO_INSTALL"
        sudo apt $_Y install $TO_INSTALL
    else
        echo "All packages already installed"
    fi

}

_main() {
    _process_agrs $@
}

_main $@