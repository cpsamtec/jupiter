#!/bin/bash
echo "running airflow"
if [ ! -z ${JUPI_DEBUG} ]; then 
  set -x
  printenv 
fi
if [ ! -e ~/airflow/airflow.db ]; then 
  airflow db init
else 
  airflow db upgrade
fi

export AIRFLOW__WEBSERVER__SECRET_KEY=${JUPI_AIRFLOW_SECRET_KEY:-jupiter}
export AIRFLOW__WEBSERVER__BASE_URL=${JUPI_AIRFLOW_WEB_BASE_URL:-/airflow}
airflow webserver -p 64000 &
airflow scheduler &
wait