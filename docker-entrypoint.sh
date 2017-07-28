#!/bin/bash
set -e

# Always run GoTTY
if [ "$1" != 'gotty' ]; then
    set -- gotty "$@"
fi

if [ "$(id -u)" = '0' ]; then
    # Get uid from bind mounted volume
    USER_MOUNT_UID="$(stat -c '%u' /userdata)"

    if [ -z "${LOGIN_UID}" ] && [ "${USER_MOUNT_UID}" = '0' ] || [ "${LOGIN_UID}" = '0' ]; then
        # Run as root
        echo "No users created, login as $(tput bold)root$(tput sgr0) (set -e LOGIN_UID or mount a directory to /userdata to create a user)"
        LOGIN_NAME='root'
        LOGIN_UID='0'
        HOME='/root'
    else
        # Run as user
        if [ -z "${LOGIN_NAME}" ]; then
            LOGIN_NAME="dev"
            echo "Using default login name of $(tput bold)dev$(tput sgr0) (set -e LOGIN_NAME to override)"
        fi

        if [ -z "${LOGIN_UID}" ]; then
            if [ -z "${USER_MOUNT_UID}" ]; then
                LOGIN_UID="1000"
                echo "Using default login uid of $(tput bold)1000$(tput sgr0) (set -e LOGIN_UID or mount a directory to /userdata to override)"
            else
                LOGIN_UID="${USER_MOUNT_UID}"
                echo "Using uid of mounted volume at /userdata of $(tput bold)${USER_MOUNT_UID}$(tput sgr0) (set -e LOGIN_UID to override)"
            fi
        fi

        if [ -z "${LOGIN_PASSWORD}" ]; then
            LOGIN_PASSWORD="$(pwgen -1nc 8)"
            echo "Generated login password for ${LOGIN_NAME}: $(tput bold)${LOGIN_PASSWORD}$(tput sgr0) (set -e LOGIN_PASSWORD to override)"
        fi

        if [ -z "$(getent passwd ${LOGIN_NAME})" ]; then
            groupadd -g "${LOGIN_UID}" "${LOGIN_NAME}"
            useradd -u "${LOGIN_UID}" -g "${LOGIN_UID}" -G sudo -m -s /bin/bash "${LOGIN_NAME}"
            echo "${LOGIN_NAME}:${LOGIN_PASSWORD}" | chpasswd
            HOME="/home/${LOGIN_NAME}"
        fi
    fi

    # link userdata to home and copy default GoTTY config
    if [ -n "$(ls -A /userdata)" ]; then rm -rf "${HOME}" && ln -s /userdata "${HOME}"; fi
    if [ ! -f '/userdata/.gotty' ]; then
        cp '/tmp/.gotty.default' "${HOME}/.gotty"
        chown "${LOGIN_NAME}:${LOGIN_UID}" "${HOME}/.gotty"
    fi
    cd $HOME

    # set root password
    if [ -z "${ROOT_PASSWORD}" ]; then
        ROOT_PASSWORD="$(pwgen -1nc 8)"
        echo "Generated root password: $(tput bold)${ROOT_PASSWORD}$(tput sgr0) (set -e ROOT_PASSWORD to override)"
    fi
    echo "root:${ROOT_PASSWORD}" | chpasswd

    apt-get update

    # install packages
    if [ "${INSTALL_PACKAGES}" ] && [ -z '/.packages-installed' ]; then
        apt-get install -y "${INSTALL_PACKAGES}"
        touch '/.packages-installed'
    fi

    echo
    echo "remotedev init process done. Ready for start up."
    echo
else
    echo
    echo "User setup not supported with docker \"--user -u\""
    echo "Set -e LOGIN_UID or mount a directory to /userdata to set uid instead"
    echo
fi

exec "$@"
