# BaxHughConfig
A place to keep my config files for my Linux / Shell environment for easy install.

# Shell Config Installation
```bash
curl -fsSL https://raw.githubusercontent.com/BaxHugh/BaxHughConfig/main/shell-config-install.sh | bash -s 
```
See `shell-config-install.sh --help` for more options.
```
Usage: shell-config-install.sh [options]
Configure the shell environment to the default for BaxHugh
Options:
-y	Install BaxHughBin to ~/.bin without asking
-n	Don't install BaxHughBin to ~/.bin
-h	Display this help message
```

# Package Installation
```bash
curl -fsSL https://raw.githubusercontent.com/BaxHugh/BaxHughConfig/main/package-group-install.sh | bash -s -- install -y cli-basic cli-dev decoding
```
See `package-group-install.sh --help` for more options.
```
Usage: package-install.sh <command> [options] [<package-group> <package-group>]
Install package groups defined within this script for ease of setup of new systems

Options:
  -h, --help,     Display this help message

Commands:
  install,        Install packages groups in args
                    Usage: package-install.sh install [options] <package-group> <package-group> ...
                    Options:
                      -y,         Pass -y to apt

  list,           List available package groups or the packages in a group
                    Usage: package-install.sh list
                    Usage: package-install.sh list <package-group>
```
