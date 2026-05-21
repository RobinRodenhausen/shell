#!/bin/bash

function clean_up {
    if [[ -L  "$1" ]]; then
        echo "Removing already existing symlink at $1"
        rm $1
    fi

    if [[ -f "$1" ]]; then
        TIMESTAMP=$(date +%s)
        echo "Moving already existing file at $1 to $1.${TIMESTAMP}"
        mv $1 $1.${TIMESTAMP}
    fi
}

function check_url {
    curl -skI "$1" > /dev/null 2>&1
    echo $?
}

if [ $(check_url https://raw.githubusercontent.com/) -ne 0 ]; then
    echo Unable to access Github. Exiting...
    exit 1
fi

mkdir -p ${HOME}/.shell/

curl -so ${HOME}/.shell/bash_profile https://raw.githubusercontent.com/RobinRodenhausen/shell/main/bash_profile
curl -so ${HOME}/.shell/bashrc https://raw.githubusercontent.com/RobinRodenhausen/shell/main/bashrc
curl -so ${HOME}/.shell/inputrc https://raw.githubusercontent.com/RobinRodenhausen/shell/main/inputrc

mkdir -p ${HOME}/.shell/bash_profile.d/ ${HOME}/.shell/bashrc.d/ ${HOME}/.shell/bash-completion.d/

curl -so ${HOME}/.shell/bashrc.d/00_gpg_ssh_agent.sh https://raw.githubusercontent.com/RobinRodenhausen/shell/main/bashrc.d/00_gpg_ssh_agent.sh
curl -so ${HOME}/.shell/bashrc.d/00_log.sh https://raw.githubusercontent.com/RobinRodenhausen/shell/main/bashrc.d/00_log.sh
curl -so ${HOME}/.shell/bashrc.d/00_unset_aws_variables.sh https://raw.githubusercontent.com/RobinRodenhausen/shell/refs/heads/main/bashrc.d/00_unset_aws_variables.sh
curl -so ${HOME}/.shell/bashrc.d/01_assume_aws_role.sh https://raw.githubusercontent.com/RobinRodenhausen/shell/refs/heads/main/bashrc.d/01_assume_aws_role.sh
curl -so ${HOME}/.shell/bashrc.d/01_pshell.sh https://raw.githubusercontent.com/RobinRodenhausen/shell/main/bashrc.d/01_pshell.sh
curl -so ${HOME}/.shell/bashrc.d/01_vscode.sh https://raw.githubusercontent.com/RobinRodenhausen/shell/main/bashrc.d/01_vscode.sh
curl -so ${HOME}/.shell/bashrc.d/01_yubikey_reminder.sh https://raw.githubusercontent.com/RobinRodenhausen/shell/main/bashrc.d/01_yubikey_reminder.sh

curl -so ${HOME}/.shell/bash-completion.d/git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
curl -so ${HOME}/.shell/bash-completion.d/git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh

clean_up "${HOME}/.bash_profile"
clean_up "${HOME}/.bashrc"
clean_up "${HOME}/.inputrc"

ln -s ${HOME}/.shell/bash_profile ${HOME}/.bash_profile
ln -s ${HOME}/.shell/bashrc ${HOME}/.bashrc
ln -s ${HOME}/.shell/inputrc ${HOME}/.inputrc
