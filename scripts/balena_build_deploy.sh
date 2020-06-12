#!/usr/bin/env bash 
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR/.. 

bash scripts/create-local-docker-compose.sh 

SERVICES="samtecdeviceshare nginx notebook minio"
DEPLOY_ARCH=${DEPLOY_ARCH:='aarch64'}
SYSTEM_ARCH=$(uname -m)
if [ "$DEPLOY_ARCH" = 'aarch64' ]; then 
    if [ "$SYSTEM_ARCH" = 'x86_64' ]; then 
        docker-compose -f docker-compose-local.yml build --build-arg NOTEBOOK_BASE_IMAGE=python:3.8-buster --build-arg 'SDS_BASE_IMAGE=balenalib/aarch64-alpine-python:3.7' ${SERVICES} 
    else
        balena build --deviceType raspberrypi4-64 --arch aarch64 -B 'NOTEBOOK_BASE_IMAGE=python:3.8-buster' -B 'SDS_BASE_IMAGE=balenalib/aarch64-alpine-python:3.7'
    fi
    balena deploy --deviceType raspberrypi4-64 --arch aarch64 -B 'NOTEBOOK_BASE_IMAGE=python:3.8-buster' -B 'SDS_BASE_IMAGE=balenalib/aarch64-alpine-python:3.7' jupyter
elif [ "$DEPLOY_ARCH" = 'amd64' ]; then 
    if [ "$SYSTEM_ARCH" = 'x86_64' ]; then 
        docker-compose --project-name jupyter-x86 build --build-arg NOTEBOOK_BASE_IMAGE=python:3.8-buster --build-arg 'SDS_BASE_IMAGE=python:3.8-alpine' ${SERVICES}
    else
        balena build --projectName jupyter-x86 --deviceType intel-nuc --arch amd64 -B 'NOTEBOOK_BASE_IMAGE=python:3.8-buster' -B 'SDS_BASE_IMAGE=python:3.8-alpine'
    fi
    balena deploy --deviceType raspberrypi4-64 --arch aarch64 -B 'NOTEBOOK_BASE_IMAGE=python:3.8-buster' -B 'SDS_BASE_IMAGE=python:3.8-alpine' jupyter-x86
else #arm7
    if [ "$SYSTEM_ARCH" = 'x86_64' ]; then 
        docker-compose -f docker-compose-local.yml build --build-arg 'NOTEBOOK_BASE_IMAGE=python:3.8-buster' --build-arg 'SDS_BASE_IMAGE=balenalib/armv7hf-alpine-python:3.7' samtecdeviceshare nginx notebook minio
    else 
        balena build --deviceType raspberrypi4-64 --arch armv7hf -B 'NOTEBOOK_BASE_IMAGE=python:3.8-buster' -B 'SDS_BASE_IMAGE=balenalib/armv7hf-alpine-python:3.7'
    fi
    balena deploy --deviceType raspberrypi4-64 --arch armv7hf -B 'NOTEBOOK_BASE_IMAGE=python:3.8-buster' -B 'SDS_BASE_IMAGE=balenalib/armv7hf-alpine-python:3.7' jupyter
fi


