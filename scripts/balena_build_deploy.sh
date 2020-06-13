#!/usr/bin/env bash 
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR/.. 

bash scripts/create-local-docker-compose.sh 

SERVICES="samtecdeviceshare nginx notebook minio"
DEPLOY_ARCH=${DEPLOY_ARCH:='aarch64'}
SYSTEM_ARCH=$(uname -m)
BUILD_ARGS="BUILD_ARG BASE_IMAGE_ARCH=DOCKER_ARCH BUILD_ARG NOTEBOOK_BASE_IMAGE=DOCKER_ARCH/python:3.8-buster BUILD_ARG SDS_BASE_IMAGE=DOCKER_ARCH/python:3.8-alpine"
COMPOSE_BUILD_ARGS=${BUILD_ARGS//BUILD_ARG/--build-arg}
BALENA_BUILD_ARGS=${BUILD_ARGS//BUILD_ARG/-B}
if [ "$DEPLOY_ARCH" = 'aarch64' ]; then 
    COMPOSE_BUILD_ARGS=${COMPOSE_BUILD_ARGS//DOCKER_ARCH/arm64v8}
    BALENA_BUILD_ARGS=${BALENA_BUILD_ARGS//DOCKER_ARCH/arm64v8}
    if [ "$SYSTEM_ARCH" = 'x86_64' ]; then 
        docker-compose -f docker-compose-aarch64.yml build ${COMPOSE_BUILD_ARGS} ${SERVICES} 
    else
        balena build --arch aarch64 ${BALENA_BUILD_ARGS} 
    fi
    balena deploy --arch aarch64 ${BALENA_BUILD_ARGS} jupyter
elif [ "$DEPLOY_ARCH" = 'amd64' ]; then 
    COMPOSE_BUILD_ARGS=${COMPOSE_BUILD_ARGS//DOCKER_ARCH/amd64}
    BALENA_BUILD_ARGS=${BALENA_BUILD_ARGS//DOCKER_ARCH/amd64}
    if [ "$SYSTEM_ARCH" = 'x86_64' ]; then 
        docker-compose --project-name jupyter-x86 build ${COMPOSE_BUILD_ARGS} ${SERVICES}
    else
        balena build --projectName jupyter-x86 --arch amd64 ${BALENA_BUILD_ARGS} 
    fi
    balena deploy --project-name jupyter-x86 --arch amd64 ${BALENA_BUILD_ARGS} jupyter-x86
else #arm7
    COMPOSE_BUILD_ARGS=${COMPOSE_BUILD_ARGS//DOCKER_ARCH/arm32v7}
    BALENA_BUILD_ARGS=${BALENA_BUILD_ARGS//DOCKER_ARCH/arm32v7}
    if [ "$SYSTEM_ARCH" = 'x86_64' ]; then 
        docker-compose -f docker-compose-armv7hf.yml build ${BALENA_BUILD_ARGS} ${SERVICES}
    else 
        balena build --arch armv7hf ${BALENA_BUILD_ARGS} 
    fi
    balena deploy --arch armv7hf ${BALENA_BUILD_ARGS} jupyter
fi


