#!/bin/bash

if [ ! -d /program/.vscode-server ]; then
  mkdir -p /program/.vscode-server
fi
CONF_DIR="/program/dropbear"
SSH_KEY_DSS="${CONF_DIR}/dropbear_dss_host_key"
SSH_KEY_RSA="${CONF_DIR}/dropbear_rsa_host_key"

# Check if conf dir exists
if [ ! -d ${CONF_DIR} ]; then
    mkdir -p ${CONF_DIR}
fi
sudo chown root:root ${CONF_DIR}
sudo chmod 755 ${CONF_DIR}

# Check if keys exists
if [ ! -f ${SSH_KEY_DSS} ]; then
    sudo dropbearkey  -t dss -f ${SSH_KEY_DSS}
fi
sudo chown root:root ${SSH_KEY_DSS}
sudo chmod 600 ${SSH_KEY_DSS}

if [ ! -f ${SSH_KEY_RSA} ]; then
    sudo dropbearkey  -t rsa -f ${SSH_KEY_RSA} -s 2048
fi
sudo chown root:root ${SSH_KEY_RSA}
sudo chmod 600 ${SSH_KEY_RSA}



# Start the first process
cd /code
code-server --bind-addr 0.0.0.0:8080 --config /program/code-server.yml --user-data-dir /program &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start code-server: $status"
  exit $status
fi

# Start the second process
cd /lab
jupyter notebook --allow-root --no-browser --ip=* --port=8082 &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start jupyter: $status"
  exit $status
fi

# Start the third process
echo "starting dropbear"
#/usr/sbin/dropbear -j -k -E -F &
sudo /usr/sbin/dropbear &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start dropbear: $status"
  exit $status
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