#!/usr/bin/env bash 
set -e
cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/.."

if [ "$(uname -m)" = 'x86_64' ]; then 
    export COMPOSE_PROJECT_NAME=jupyter-x86 
else
    export COMPOSE_PROJECT_NAME=jupyter
fi

