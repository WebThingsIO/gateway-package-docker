#!/bin/bash

#set -x

# This file originally came from https://github.com/sdt/docker-raspberry-pi-cross-compiler

# This is the entrypoint script for the dockerfile. Executed in the
# container at runtime.

if [[ $# == 0 ]]; then
    # Presumably the image has been run directly, so help the user get started.
    cat /owrt/owrt
    exit 0
fi

echo "============================================================="
echo "CROSS_COMPILE = ${CROSS_COMPILE}"
echo "CC = ${CC}"
echo "CXX = ${CXX}"
echo "SYSROOT = ${SYSROOT}"
echo "HOME = ${HOME}"
echo "PWD = $(pwd)"
echo "============================================================="

# If we are running docker natively, we want to create a user in the container
# with the same UID and GID as the user on the host machine, so that any files
# created are owned by that user. Without this they are all owned by root.
# If we are running from boot2docker, this is not necessary, and you end up not
# being able to write to the volume.
# The owrt script sets the OWRT_UID and OWRT_GID vars.
if [[ -n ${OWRT_UID} ]] && [[ -n ${OWRT_GID} ]]; then
    OWRT_USER=owrt-user
    OWRT_GROUP=owrt-group
    OWRT_HOME=/home/${OWRT_USER}

    sudo groupadd -o -g ${OWRT_GID} ${OWRT_GROUP} 2> /dev/null
    sudo useradd -o -m -d ${OWRT_HOME} -g ${OWRT_GID} -u ${OWRT_UID} ${OWRT_USER} 2> /dev/null

    # Run the command as the specified user/group.
    HOME=${OWRT_HOME} exec sudo chpst -u :${OWRT_UID}:${OWRT_GID} "$@"
else
    # Just run the command as root.
    exec "$@"
fi
