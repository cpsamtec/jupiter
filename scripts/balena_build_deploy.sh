#!/usr/bin/env bash 
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR/.. 

AARCH=${BUILD_ARCH,:-'armv7hf'}
if [ "$AARCH" = 'aarch64' ]; then 
    balena build --deviceType raspberrypi4-64 --arch aarch64 -B 'SWITCHER_BASE_IMAGE=balenalib/aarch64-alpine-python:3.7' -B 'SDS_BASE_IMAGE=balenalib/aarch64-alpine-python:3.7'
    balena deploy --deviceType raspberrypi4-64 --arch aarch64 -B 'SWITCHER_BASE_IMAGE=balenalib/aarch64-alpine-python:3.7' -B 'SDS_BASE_IMAGE=balenalib/aarch64-alpine-python:3.7' hdr-switcher
else
    balena build --deviceType raspberrypi4-64 --arch armv7hf -B 'SWITCHER_BASE_IMAGE=balenalib/armv7hf-alpine-python:3.7' -B 'SDS_BASE_IMAGE=balenalib/armv7hf-alpine-python:3.7'
    balena deploy --deviceType raspberrypi4-64 --arch armv7hf -B 'SWITCHER_BASE_IMAGE=balenalib/armv7hf-alpine-python:3.7' -B 'SDS_BASE_IMAGE=balenalib/armv7hf-alpine-python:3.7' hdr-switcher
fi


