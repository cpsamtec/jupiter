#!/bin/bash
echo "running notebook"
set -x
printenv 
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
JUPI_VIM_USER=${JUPI_VIM_USER:=0}
if [ -e "${JUPYTERLAB_DIR_VIM}" ] && [ ! -z "${JUPI_VIM_USER}" ] && [ "${JUPI_VIM_USER}" -ne 0 ]; then 
  JUPYTERLAB_DIR=${JUPYTERLAB_DIR_VIM}
fi

USER=$(stat -c '%U' /lab)
if [ $USER != "dev" ]; then 
  chown -R dev:dev /lab 
fi
USER=$(stat -c '%U' /code)
if [ $USER != "dev" ]; then 
  chown -R dev:dev /code
fi
USER=$(stat -c '%U' /home/dev)
if [ $USER != "dev" ]; then 
  chown -R dev:dev /home/dev 
fi

CONFIG_VERSION=2
if [ ! -e /program/.jupiter/jupiter_config_version ] || [ $(cat /program/.jupiter/jupiter_config_version) != $CONFIG_VERSION ]; then
  mkdir -p /program/.jupiter
  su - dev -c 'git config --global credential.helper "cache --timeout=14400"'
  su - dev -c '
  sed -i "/####BEGIN JUPITER SETTINGS/,/####END JUPITER SETTINGS/d" /home/dev/.bashrc && \
  echo "
####BEGIN JUPITER SETTINGS
if [ -e \"/var/run/balena.sock\" ]; then 
  export DOCKER_HOST=unix:///var/run/balena.sock
  export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket
fi
####END JUPITER SETTINGS
  " >> /home/dev/.bashrc'
  su -w "JUPI_VIM_USER" - dev -c "bash ${DIR}/code-server-installs.sh"
  echo $CONFIG_VERSION > /program/.jupiter/jupiter_config_version
  sync
fi

SYSTEM_CREDENTIAL_VERION=1
USER_CREDENTIAL_VERSION=${JUPI_CREDENTIAL_VERSION:-1}
SYSTEM_CREDENTIAL_VERION="${SYSTEM_CREDENTIAL_VERION}-${USER_CREDENTIAL_VERSION}"

if [ ! -e /program/.jupiter/jupiter_credential_version ] || [ $(cat /program/.jupiter/jupiter_credential_version) != $SYSTEM_CREDENTIAL_VERION ]; then
  mkdir -p /program/.jupiter
  su -w "JUPI_MYMINIO_ACCESS_KEY,JUPI_MYMINIO_SECRET_KEY,JUPI_AWS_ACCESS_KEY_ID,JUPI_AWS_SECRET_ACCESS_KEY" - dev -c "bash ${DIR}/minio_config.sh"
  su - dev -c "mc mb -p myminio/jupiter" 
  echo "${SYSTEM_CREDENTIAL_VERION}" > /program/.jupiter/jupiter_credential_version
fi

if [ ! -z ${JUPI_OVERRIDE_USER_PASSWORD} ] && [ ${JUPI_OVERRIDE_USER_PASSWORD} != ${JUPI_DEFAULT_USER_PASSWORD} ]; then 
  echo "dev:${JUPI_OVERRIDE_USER_PASSWORD}" | chpasswd
fi

CONF_DIR="/program/dropbear"
SSH_KEY_DSS="${CONF_DIR}/dropbear_dss_host_key"
SSH_KEY_RSA="${CONF_DIR}/dropbear_rsa_host_key"

# Check if conf dir exists
if [ ! -d ${CONF_DIR} ]; then
  mkdir -p ${CONF_DIR}
  chown root:root ${CONF_DIR}
  chmod 755 ${CONF_DIR}
fi

if [ ! -d /home/dev/.ssh ]; then 
  mkdir -p /home/dev/.ssh 
  chmod 700 /home/dev/.ssh
  touch /home/dev/.ssh/authorized_keys
  chmod 600 /home/dev/.ssh/authorized_keys
  touch /home/dev/.ssh/config
  chmod 600 /home/dev/.ssh/config
  chown -R dev:dev /home/dev/.ssh
fi

# Check if keys exists
if [ ! -f ${SSH_KEY_DSS} ]; then
  dropbearkey  -t dss -f ${SSH_KEY_DSS}
  chown root:root ${SSH_KEY_DSS}
  chmod 600 ${SSH_KEY_DSS}
fi

if [ ! -f ${SSH_KEY_RSA} ]; then
  dropbearkey  -t rsa -f ${SSH_KEY_RSA} -s 2048
  chown root:root ${SSH_KEY_RSA}
  chmod 600 ${SSH_KEY_RSA}
fi

# Check if jupyter notebook config exists. If not create it with delete to trash false
if [ ! -f "/home/dev/.jupyter/jupyter_notebook_config.py" ]; then 
  su -w "PATH" - dev -c "jupyter notebook --generate-config && 
    sed -i 's/#c.FileContentsManager.delete_to_trash.*/c.FileContentsManager.delete_to_trash = False/' '/home/dev/.jupyter/jupyter_notebook_config.py'"
fi

# Make sure dev user can run docker commands
if [ -e /var/run/docker.sock ]; then 
  chgrp docker /var/run/docker.sock
fi

# Start the first process
cd /code
su -w "JUPI_AWS_ACCESS_KEY_ID,JUPI_AWS_SECRET_ACCESS_KEY,PATH,CARGO_HOME,RUSTUP_HOME,BALENA_DEVICE_UUID" - dev -c "code-server --bind-addr 0.0.0.0:8080 /code &"
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start code-server: $status"
  exit $status
fi


# Start the second process
cd /lab
su -w "JUPI_AWS_ACCESS_KEY_ID,JUPI_AWS_SECRET_ACCESS_KEY,PATH,JUPYTERLAB_DIR,BALENA_DEVICE_UUID" - dev  -c "cd /lab; jupyter notebook --no-browser --ip=* --port=8082 &"
#jupyter notebook --allow-root --no-browser --ip=* --port=8082 &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start jupyter: $status"
  exit $status
fi

# Start the third process
echo "starting dropbear"
/usr/sbin/dropbear -g -r ${SSH_KEY_DSS} -r ${SSH_KEY_RSA} &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start dropbear: $status"
  exit $status
fi

for f in /dev/i2c-*; do 
  if [ -e "$f" ]; then 
    chown :i2c "$f"
    chmod g+rw "$f"
  fi
done

for f in /dev/spidev*; do 
  if [ -e "$f" ]; then 
    chown :spi "$f"
    chmod g+rw "$f"
  fi
done

for f in dev/ttyUSB* /dev/ttyACM* /dev/ttyAMA*; do 
  if [ -e "$f" ]; then 
    chown :dialout "$f"
    chmod g+rw "$f"
  fi
done

if [ -e /dev/gpiomem ]; then 
  chown :gpio "/dev/gpiomem"
  chmod g+rw "/dev/gpiomem"
fi

sleep 20
su - dev -c "bash ${DIR}/credentials.sh > /tmp/credentials.txt"
su - dev -c "mc cp /tmp/credentials.txt myminio/jupiter" 

while sleep 60; do
  ps aux |grep code-server | grep -q -v grep
  PROCESS_1_STATUS=$?
  ps aux |grep jupyter | grep -q -v grep
  PROCESS_2_STATUS=$?
  ps aux |grep dropbear | grep -q -v grep
  PROCESS_3_STATUS=$?
  if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 -o $PROCESS_3_STATUS -ne 0 ]; then
    echo "One of the processes has already exited."
    exit 1
  fi
done