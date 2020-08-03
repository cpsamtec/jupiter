#!/usr/bin/env bash 
mkdir -p /home/dev/.aws
CREDENTIALS_FILE=/home/dev/.aws/credentials
touch $CREDENTIALS_FILE
if [ -z $JUPI_AWS_ACCESS_KEY_ID ] || [ -z $JUPI_AWS_SECRET_ACCESS_KEY ]; then
  exit 0 
fi 
if ! grep -q "[default]" $CREDENTIALS_FILE; then
  cat << EOF >> $CREDENTIALS_FILE
[default]
aws_access_key_id=${JUPI_AWS_ACCESS_KEY_ID}
aws_secret_access_key=${JUPI_AWS_SECRET_ACCESS_KEY}
EOF
fi

sed -i "/####BEGIN JUPITER SETTINGS/,/####END JUPITER SETTINGS/d" $CREDENTIALS_FILE
cat << EOF >> $CREDENTIALS_FILE
####BEGIN JUPITER SETTINGS
[jupiter]
aws_access_key_id=${JUPI_AWS_ACCESS_KEY_ID}
aws_secret_access_key=${JUPI_AWS_SECRET_ACCESS_KEY}
####END JUPITER SETTINGS
EOF

mc config host add s3 https://s3.amazonaws.com ${JUPI_AWS_ACCESS_KEY_ID} ${JUPI_AWS_SECRET_ACCESS_KEY}