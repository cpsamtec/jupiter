#/usr/bin/env bash

echo "/lab token is"
token=$(jupyter notebook list | grep token | sed -n '0,/http/s/.*token=\([a-zA-Z0-9]\+\).*/\1/p')

echo "jupyter lab token is ${token}"
echo "jupyter lab located locally at"
echo "http://${BALENA_DEVICE_UUID:0:7}.local/lab"
echo "jupyter lab located remotely at"
echo "https://${BALENA_DEVICE_UUID}.balena-devices.com/lab"
code_pass=$(cat /program/code-server.yml | sed -n 's/^password: \([a-zA-Z0-9]\+\)/\1/p')
echo "code server password is ${code_pass}"
echo "code located locally at"
echo "http://${BALENA_DEVICE_UUID:0:7}.local/code"
echo "code server located remotely at"
echo "https://${BALENA_DEVICE_UUID}.balena-devices.com/code"