# Function to provide single command to enable/disable pipenv shell

PIPENV_INSTALLED=$(which pipenv)
if [ ! -z ${PIPENV_INSTALLED} ]; then
    function pshell {
        export PIPENV_VERBOSITY=-1
        pipenv --py >/dev/null
        EXITCODE=$?
        if [ ${EXITCODE} -eq 0 ]; then
            if [ -z ${PSHELL_ACTIVE} ]; then
                export PSHELL_PS1=${PS1}
                export PS1=${PS1:2}
                source $(pipenv --venv)/bin/activate
                export PS1="\n${PS1}"
                export PS1=$(echo "$PS1" | sed -e 's|(\S*)|(pipenv)|')
                export PSHELL_ACTIVE=1
            else
                deactivate
                export PS1=$PSHELL_PS1
                unset PSHELL_ACTIVE PSHELL_PS1
            fi
        fi
        unset PIPENV_VERBOSITY
    }
fi
unset PIPENV_INSTALLED
