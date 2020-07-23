#!/bin/bash
echo "running notebook"
set -x
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
VIM_USER=${VIM_USER:=0}
if [ -e "${JUPYTERLAB_DIR_VIM}" ] && [ ! -z "${VIM_USER}" ] && [ "${VIM_USER}" -ne 0 ]; then 
  JUPYTERLAB_DIR=${JUPYTERLAB_DIR_VIM}
fi

USER=$(stat -c '%U' /lab)
if [ $USER != "dev" ]; then 
  chown -R dev:dev /lab 
USER=$(stat -c '%U' /code)
if [ $USER != "dev" ]; then 
  chown -R dev:dev /code
USER=$(stat -c '%U' /home/dev)
if [ $USER != "dev" ]; then 
  chown -R dev:dev /home/dev 
fi

if [ ! -e /program/jupiter_config_version ] || [ $(cat /program/jupiter_config_version) -ne 1 ]; then
  su - dev -c 'git config --global credential.helper "cache --timeout=14400"'
  su - dev -c 'echo "
  if [ -e \"/var/run/balena.sock\" ]; then 
    export DOCKER_HOST=unix:///var/run/balena.sock
  fi
  " >> /home/dev/.bashrc'
  su -w "JUPI_MINIO_ACCESS_KEY,JUPI_MINIO_SECRET_KEY,JUPI_AWS_ACCESS_KEY_ID,JUPI_AWS_SECRET_ACCESS_KEY" - dev -c "bash ${DIR}/minio_config.sh"
  su -w "VIM_USER" - dev -c "bash /app/code-server-installs.sh"
  echo 1 > /program/jupiter_config_version
  sync
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

if [ ! -f "/home/dev/.jupyter/jupyter_notebook_config.py" ]; then 
  su -w "PATH" - dev -c "jupyter notebook --generate-config && 
    sed -i 's/#c.FileContentsManager.delete_to_trash.*/c.FileContentsManager.delete_to_trash = False/' '/home/dev/.jupyter/jupyter_notebook_config.py'"
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
  if [ -f "$f" ]; then 
    chown :i2c "$f"
    chmod g+rw "$f"
  fi
done
if [ -e /dev/gpiomem ]; then 
  chown :gpio "/dev/gpiomem"
  chmod g+rw "/dev/gpiomem"
fi


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