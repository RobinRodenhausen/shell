# Shell

Repository to easily setup a bash environment. This repository plans to deliver the following files:

* `.bash_profile`
* `.bashrc`
* `.inputrc`

In case you want to customize the setup further you can put additional settings into the `~/.shell/bash_profile.d/`, `~/.shell/bashrc.d/` or `~/.shell/bash-completion.d/` folders and name them with the suffix `.sh` or `.bash`.

## Setup

The script will download the files into the `~/.shell/` folder and link to them from the home directory. In case the files already exist in the home directory they will be renamed with the current timestamp. Existing symlinks in the home directory will be removed. Existing files in the `~/.shell/` directory will be overwritten.
The script can also be used to update the 3 files and won't touch any files in the `.d` folders.
This one liner will download the setup script and execute it:

```sh
curl --silent https://raw.githubusercontent.com/RobinRodenhausen/shell/main/setup.sh | bash
```
