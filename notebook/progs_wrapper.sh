#!/bin/bash

# Start the first process
code-server --bind-addr 0.0.0.0:8080 --config /program/code-server.yml --user-data-dir /code &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start code-server: $status"
  exit $status
fi

# Start the second process
jupyter notebook --allow-root --no-browser --ip=* --port=8082 &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start jupyter: $status"
  exit $status
fi

while sleep 60; do
  ps aux |grep code-server |grep -q -v grep
  PROCESS_1_STATUS=$?
  ps aux |grep jupyter  |grep -q -v grep
  PROCESS_2_STATUS=$?
  if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 ]; then
    echo "One of the processes has already exited."
    exit 1
  fi
done