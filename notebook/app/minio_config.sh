#!/usr/bin/env bash 
JUPI_MYMINIO_ACCESS_KEY=${JUPI_MYMINIO_ACCESS_KEY:=minioadmin}
JUPI_MYMINIO_SECRET_KEY=${JUPI_MYMINIO_SECRET_KEY:=minioadmin}
mc config host rm myminio
mc config host add myminio http://myminio:9000 ${JUPI_MYMINIO_ACCESS_KEY} ${JUPI_MYMINIO_SECRET_KEY}
if [ ! -z $JUPI_AWS_ACCESS_KEY_ID ] && [ ! -z $JUPI_AWS_SECRET_ACCESS_KEY ]; then
  mc config host rm s3
  mc config host add s3 https://s3.amazonaws.com ${JUPI_AWS_ACCESS_KEY_ID} ${JUPI_AWS_SECRET_ACCESS_KEY}
fi