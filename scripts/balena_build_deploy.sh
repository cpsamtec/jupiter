#!/usr/bin/env bash 
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR/.. 

AARCH=${BUILD_ARCH:='aarch64'}
SYSTEM_ARCH=$(uname -m)
if [ "$AARCH" = 'aarch64' ]; then 
    if [ "$SYSTEM_ARCH" = 'x86_64' ]; then 
        #docker-compose build --build-arg 'NOTEBOOK_BASE_IMAGE=balenalib/aarch64-debian-python:3.7' --build-arg 'SDS_BASE_IMAGE=balenalib/aarch64-alpine-python:3.7' notebook samtecdeviceshare
        docker-compose build --build-arg NOTEBOOK_BASE_IMAGE=python:3.8-buster --build-arg 'SDS_BASE_IMAGE=balenalib/aarch64-alpine-python:3.7' notebook samtecdeviceshare
    else
        balena build --deviceType raspberrypi4-64 --arch aarch64 -B 'NOTEBOOK_BASE_IMAGE=python:3.8-buster' -B 'SDS_BASE_IMAGE=balenalib/aarch64-alpine-python:3.7'
    fi
    balena deploy --deviceType raspberrypi4-64 --arch aarch64 -B 'NOTEBOOK_BASE_IMAGE=python:3.8-buster' -B 'SDS_BASE_IMAGE=balenalib/aarch64-alpine-python:3.7' jupyter
else
    if [ "$SYSTEM_ARCH" = 'x86_64' ]; then 
        docker-compose build --build-arg 'NOTEBOOK_BASE_IMAGE=python:3.8-buster' --build-arg 'SDS_BASE_IMAGE=balenalib/armv7hf-alpine-python:3.7' notebook samtecdeviceshare
    else 
        balena build --deviceType raspberrypi4-64 --arch armv7hf -B 'NOTEBOOK_BASE_IMAGE=python:3.8-buster' -B 'SDS_BASE_IMAGE=balenalib/armv7hf-alpine-python:3.7'
    fi
    balena deploy --deviceType raspberrypi4-64 --arch armv7hf -B 'NOTEBOOK_BASE_IMAGE=python:3.8-buster' -B 'SDS_BASE_IMAGE=balenalib/armv7hf-alpine-python:3.7' jupyter
fi


