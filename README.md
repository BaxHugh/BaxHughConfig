# BaxHughConfig
A place to keep my config files for my Linux / Shell environment for easy install.
And package installation script to quickly install the packages I need (using apt).

# Shell Configuration
There are custom shell agnostic `rc` and `env` files in the user's home directory which are sourced by the shell's config file.
Currently zsh and bash are supported.
Having separate custom `rc` and `env` files allows a user to more easily manage their shell environment separate from any defaults or third party tools.
I.e. adding specific directories to their path.

# Shell Config Installation

```bash
curl -fsSL https://raw.githubusercontent.com/BaxHugh/BaxHughConfig/main/shell-config-install.sh | bash -s --install-zsh
```
See `shell-config-install.sh --help` for more options.
```
Usage: shell-config-install.sh [options]
Configure the shell environment to the default used by BaxHugh
This includes shell config + env files, custom tool config files, and setting the oh-my-zsh theme
Options:
  --no-backup,              Don't backup existing files
  --install-zsh             Install zsh (and oh-my-zsh) if not already installed
  --install-baxhugh-bin,    Install BaxHughBin to ~/.bin
  --unattended,             Answer no to any prompts
  -h, --help,               Display this help message
```

<!-- This is copies from the help output -->

**What this script does**
This command will install the below to the user's home directory.
If a file already exists, it will be backed up to <filename>~ unless --no-backup is passed.

**Custom shell config + env files**
These will be installed in the user's home directory, and sourced in their appropriate shell config files.
| File             | Description                                     | Sourced in               |
| ---------------- | ----------------------------------------------- | ------------------------ |
| `.zshrc_config`  | Custom zsh config                               | `.zshrc`                 |
| `.bashrc_config` | Custom bash config                              | `.bashrc`                |
| `.shenv_custom`  | Custom shell environment setup (shell agnostic) | `.zshenv` and `.profile` |
| `.shrc_custom`   | Custom shell config (shell agnostic)            | `.zshrc` and `.bashrc`   |

**Custom shell config files (machine specific)**
These files will be sourced if the user creates them
| File                  | Description                                     | Sourced in                          |
| --------------------- | ----------------------------------------------- | ----------------------------------- |
| `.shrc_custom_local`  | Custom shell config (shell agnostic)            | sourced in `.zshrc` and `.bashrc`   |
| `.shenv_custom_local` | Custom shell environment setup (shell agnostic) | sourced in `.zshenv` and `.profile` |

**Custom tool config files**
These will be installed in the user's home directory.
| File          | Description            |
| ------------- | ---------------------- |
| `.inputrc`    | Custom readline config |
| `.nanorc`     | Custom nano config     |
| `.style.yapf` | Custom yapf config     |

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
