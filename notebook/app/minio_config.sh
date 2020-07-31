#!/usr/bin/env bash 
JUPI_MYMINIO_ACCESS_KEY=${JUPI_MYMINIO_ACCESS_KEY:=minioadmin}
JUPI_MYMINIO_SECRET_KEY=${JUPI_MYMINIO_SECRET_KEY:=minioadmin}
mc config host add myminio http://myminio:9000 ${JUPI_MYMINIO_ACCESS_KEY} ${JUPI_MYMINIO_SECRET_KEY}
#if fails wait 5 seconds and retry once allowing server chance to start
if [ $? -ne 0 ]; then 
  sleep 5
  mc config host add myminio http://myminio:9000 ${JUPI_MYMINIO_ACCESS_KEY} ${JUPI_MYMINIO_SECRET_KEY}
fi
if [ ! -z $JUPI_AWS_ACCESS_KEY_ID ] && [ ! -z $JUPI_AWS_SECRET_ACCESS_KEY ]; then
  mc config host add s3 https://s3.amazonaws.com ${JUPI_AWS_ACCESS_KEY_ID} ${JUPI_AWS_SECRET_ACCESS_KEY}
fi