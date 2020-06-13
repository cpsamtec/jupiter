#/usr/bin/env bash

echo "getting credentials"
token=$(jupyter notebook list | grep token | sed -n '0,/http/s/.*token=\([a-zA-Z0-9]\+\).*/\1/p')

echo "jupyter lab token is ${token}"
echo "jupyter lab located locally at"
echo "http://${BALENA_DEVICE_UUID:0:7}.local/lab?token=${token}"
echo "jupyter lab located remotely at"
echo "https://${BALENA_DEVICE_UUID}.balena-devices.com/lab?token=${token}"
code_pass=$(cat /program/code-server.yml | sed -n 's/^password: \([a-zA-Z0-9]\+\)/\1/p')
echo "code server password is ${code_pass}"
echo "code located locally at"
echo "http://${BALENA_DEVICE_UUID:0:7}.local/code/login?password=${code_pass}"
echo "code server located remotely at"
echo "https://${BALENA_DEVICE_UUID}.balena-devices.com/code/login?password=${code_pass}"
echo "minio s3 client"
echo "mc config host add myminio http://minio:9000 ${MINIO_ACCESS_KEY} ${MINIO_SECRET_KEY}"
echo "then run commands like"
echo "mc ls myminio || mc mb myminio/my_bucket"