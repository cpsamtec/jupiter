#!/bin/bash
echo "running notebook"
set -x
printenv 
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
JUPI_VIM_USER=${JUPI_VIM_USER:=0}

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

CONFIG_VERSION=3
if [ ! -e /program/.jupiter/jupiter_config_version ] || [ "$(cat /program/.jupiter/jupiter_config_version)" != $CONFIG_VERSION ]; then
  mkdir -p /program/.jupiter
  su - dev -c 'git config --global credential.helper "cache --timeout=14400"'
  su - dev -c '
  sed -i "/####BEGIN JUPITER SETTINGS/,/####END JUPITER SETTINGS/d" /home/dev/.bashrc && \
  cat << EOF >> /home/dev/.bashrc
####BEGIN JUPITER SETTINGS
if [ -e "/var/run/balena.sock" ]; then 
  export DOCKER_HOST=unix:///var/run/balena.sock
  export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket
fi
####END JUPITER SETTINGS
EOF
'
 
  su -w "JUPI_VIM_USER" - dev -c "bash ${DIR}/code-server-installs.sh"
  echo $CONFIG_VERSION > /program/.jupiter/jupiter_config_version
  sync
fi

SYSTEM_CREDENTIAL_VERSION=1
USER_CREDENTIAL_VERSION=${JUPI_CREDENTIAL_VERSION:=0}
SYSTEM_CREDENTIAL_VERSION="${SYSTEM_CREDENTIAL_VERSION}-${USER_CREDENTIAL_VERSION}"

if [ -f /program/.jupiter/jupiter_credential_version ]; then
  CURR_CREDENTIAL_VERSION=$(cat /program/.jupiter/jupiter_credential_version)
fi
CURR_CREDENTIAL_VERSION=${CURR_CREDENTIAL_VERSION:="x-x"}
if [ "$CURR_CREDENTIAL_VERSION" != "$SYSTEM_CREDENTIAL_VERSION" ]; then
  mkdir -p /program/.jupiter
  su -w "JUPI_AWS_ACCESS_KEY_ID,JUPI_AWS_SECRET_ACCESS_KEY" - dev -c "bash ${DIR}/s3_config.sh"
  echo "${SYSTEM_CREDENTIAL_VERSION}" > /program/.jupiter/jupiter_credential_version
  sync
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
    sed -i -e 's/#c.FileContentsManager.delete_to_trash.*/c.FileContentsManager.delete_to_trash = False/' -e 's/#c.NotebookApp.allow_password_change = True*/c.NotebookApp.allow_password_change = True/' '/home/dev/.jupyter/jupyter_notebook_config.py'"
fi

# Make sure dev user can run docker commands
if [ -e /var/run/docker.sock ]; then 
  chgrp docker /var/run/docker.sock
fi

su -w "JUPI_AIRFLOW_SECRET_KEY,JUPI_AIRFLOW_WEB_BASE_URL,PATH,CARGO_HOME,BALENA_DEVICE_UUID" - dev -c "/app/airflow.sh &"

# Start the first process
cd /code
JUPI_CODESERVER_TOKEN=${JUPI_CODESERVER_TOKEN:-${BALENA_DEVICE_UUID:-jupiter}}
su -w "JUPI_CODESERVER_TOKEN,JUPI_AWS_ACCESS_KEY_ID,JUPI_AWS_SECRET_ACCESS_KEY,PATH,CARGO_HOME,RUSTUP_HOME,BALENA_DEVICE_UUID" - dev -c "PASSWORD=${JUPI_CODESERVER_TOKEN} code-server --bind-addr 0.0.0.0:8080 /code &"
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start code-server: $status"
  exit $status
fi


# Start the second process
cd /lab
JUPI_NOTEBOOK_TOKEN=${JUPI_NOTEBOOK_TOKEN:-${BALENA_DEVICE_UUID:-jupiter}}
JUPI_CODESERVER_TOKEN=${JUPI_CODESERVER_TOKEN:-${BALENA_DEVICE_UUID:-jupiter}}
su -w "JUPI_NOTEBOOK_TOKEN,JUPI_AWS_ACCESS_KEY_ID,JUPI_AWS_SECRET_ACCESS_KEY,PATH,JUPYTERLAB_DIR,BALENA_DEVICE_UUID" - dev  -c "cd /lab; jupyter notebook --NotebookApp.token=${JUPI_NOTEBOOK_TOKEN} --no-browser --ip=* --port=8082 &"
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

sleep 5
su -w "JUPI_NOTEBOOK_TOKEN,BALENA_DEVICE_UUID" - dev -c "bash ${DIR}/credentials.sh > /tmp/credentials.txt"
service grafana-server start

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