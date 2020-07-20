#!/usr/bin/env bash 

if [ "$(uname -m)" = 'x86_64' ]; then 
    export COMPOSE_PROJECT_NAME=jupyter-x86 
else
    export COMPOSE_PROJECT_NAME=jupyter
fi

