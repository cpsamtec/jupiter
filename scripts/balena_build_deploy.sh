#!/usr/bin/env bash 
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR/.. 

AARCH=${BUILD_ARCH,:-'aarch64'}
if [ "$AARCH" = 'aarch64' ]; then 
    #balena build --deviceType raspberrypi4-64 --arch aarch64 -B 'NOTEBOOK_BASE_IMAGE=balenalib/aarch64-debian-python:3.7' -B 'SDS_BASE_IMAGE=balenalib/aarch64-alpine-python:3.7'
    balena deploy --deviceType raspberrypi4-64 --arch aarch64 -B 'NOTEBOOK_BASE_IMAGE=balenalib/aarch64-debian-python:3.7' -B 'SDS_BASE_IMAGE=balenalib/aarch64-alpine-python:3.7' jupyter
else
    #balena build --deviceType raspberrypi4-64 --arch armv7hf -B 'NOTEBOOK_BASE_IMAGE=balenalib/armv7hf-debian-python:3.7' -B 'SDS_BASE_IMAGE=balenalib/armv7hf-alpine-python:3.7'
    balena deploy --deviceType raspberrypi4-64 --arch armv7hf -B 'NOTEBOOK_BASE_IMAGE=balenalib/armv7hf-debian-python:3.7' -B 'SDS_BASE_IMAGE=balenalib/armv7hf-alpine-python:3.7' jupyter
fi


