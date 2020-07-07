#!/bin/bash
echo "running notebook"
set -x
VIM_USER=${VIM_USER:=0}
MINIO_ACCESS_KEY=${MINIO_ACCESS_KEY:=minioadmin}
MINIO_SECRET_KEY=${MINIO_SECRET_KEY:=minioadmin}
#JUPYTERLAB_DIR=${JUPYTERLAB_DIR:=/home/dev/.local/share/jupyter/lab}
if [ -e "${JUPYTERLAB_DIR_VIM}" ] && [ ! -z "${VIM_USER}" ] && [ "${VIM_USER}" -ne 0 ]; then 
  JUPYTERLAB_DIR=${JUPYTERLAB_DIR_VIM}
fi

USER=$(stat -c '%U' /lab)
if [ $USER != "dev" ]; then 
  chown -R dev:dev /lab 
  chown -R dev:dev /code 
  chown -R dev:dev /home/dev 
fi

if [ ! -d /home/dev/.vscode-server ]; then 
  echo "add default extensions in future"
fi

#if [ ! -e /home/dev/.jupyter-ext-installed ]; then
  #su -w "JUPYTERLAB_DIR,VIM_USER" - dev -c "bash /app/jupyter-installs.sh"
#fi

if [ ! -e /home/dev/.code-server-ext-installed ]; then
  su -w "VIM_USER" - dev -c "bash /app/code-server-installs.sh"
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

mc config host ls | grep -q myminio
if [ $? -ne 0 ] && [ ! -z $MINIO_ACCESS_KEY ] && [ ! -z $MINIO_SECRET_KEY ]; then
  su -w "MINIO_ACCESS_KEY,MINIO_SECRET_KEY" - dev -c "mc config host add myminio http://minio:9000 ${MINIO_ACCESS_KEY} ${MINIO_SECRET_KEY}"
fi

# Start the first process
cd /code
su -w "CARGO_HOME,RUSTUP_HOME,BALENA_DEVICE_UUID" - dev -c "code-server --bind-addr 0.0.0.0:8080 /code &"
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start code-server: $status"
  exit $status
fi

# Start the second process
cd /lab
su -w "JUPYTERLAB_DIR,BALENA_DEVICE_UUID" - dev  -c "cd /lab; jupyter notebook --no-browser --ip=* --port=8082 &"
#jupyter notebook --allow-root --no-browser --ip=* --port=8082 &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start jupyter: $status"
  exit $status
fi

# Start the third process
echo "starting dropbear"
/usr/sbin/dropbear &
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