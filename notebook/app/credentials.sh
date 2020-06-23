#/usr/bin/env bash

echo "getting credentials"
token=$(su - dev -c "jupyter notebook list" | grep token | sed -n '0,/http/s/.*token=\([a-zA-Z0-9]\+\).*/\1/p')

echo "jupyter lab token is ${token}"
if [ ! -z ${BALENA_DEVICE_UUID} ]; then
    echo "jupyter lab located locally at"
    echo "http://${BALENA_DEVICE_UUID:0:7}.local/lab?token=${token}"
    echo "jupyter lab located remotely at"
    echo "https://${BALENA_DEVICE_UUID}.balena-devices.com/lab?token=${token}"
fi
code_pass=$(cat /home/dev/.config/code-server/config.yaml | sed -n 's/^password: \([a-zA-Z0-9]\+\)/\1/p')
echo "code server password is ${code_pass}"
if [ ! -z ${BALENA_DEVICE_UUID} ]; then
    echo "code located locally at"
    echo "http://${BALENA_DEVICE_UUID:0:7}.local/code/login?password=${code_pass}"
    echo "code server located remotely at"
    echo "https://${BALENA_DEVICE_UUID}.balena-devices.com/code/login?password=${code_pass}"
fi
echo "minio s3 client"
echo "mc config host add myminio http://minio:9000 ${MINIO_ACCESS_KEY} ${MINIO_SECRET_KEY}"
echo "then run commands like"
echo "mc ls myminio || mc mb myminio/my_bucket"