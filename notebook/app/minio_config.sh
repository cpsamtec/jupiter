#!/usr/bin/env bash 
JUPI_MINIO_ACCESS_KEY=${JUPI_MINIO_ACCESS_KEY:=minioadmin}
JUPI_MINIO_SECRET_KEY=${JUPI_MINIO_SECRET_KEY:=minioadmin}
mc config host add myminio http://minio:9000 ${JUPI_MINIO_ACCESS_KEY} ${JUPI_MINIO_SECRET_KEY}
if [ ! -z $JUPI_AWS_ACCESS_KEY_ID ] && [ ! -z $JUPI_AWS_SECRET_ACCESS_KEY ]; then
  mc config host add jupiter https://s3.amazonaws.com ${AWS_ACCESS_KEY_ID} ${AWS_SECRET_ACCESS_KEY}
fi