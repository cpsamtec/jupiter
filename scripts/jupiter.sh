#!/usr/bin/env bash 
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR/.. 

#Initialize globals
SERVICES="sds nginx notebook minio"
SYSTEM_ARCH=$(uname -m)
BUILD_ARGS="BUILD_ARG BASE_IMAGE_ARCH=DOCKER_ARCH BUILD_ARG NOTEBOOK_BASE_IMAGE=DOCKER_ARCH/ubuntu:groovy BUILD_ARG SDS_BASE_IMAGE=DOCKER_ARCH/python:3.8-alpine"
COMPOSE_BUILD_ARGS=${BUILD_ARGS//BUILD_ARG/--build-arg}
BALENA_BUILD_ARGS=${BUILD_ARGS//BUILD_ARG/-B}

# if DEPLOY_ARCH not specified default to system. can be overriden with parameter
if [ -z $DEPLOY_ARCH ]; then 
    case $SYSTEM_ARCH in
        "aarch64")
            DEPLOY_ARCH="aarch64"
            ;;
        "aarch32")
            DEPLOY_ARCH="aarch32"
            ;;
        "x86_64")
            DEPLOY_ARCH=amd64
            ;;
        *)
            DEPLOY_ARCH=amd64
            ;;
    esac
fi

create_local_docker_aarch64() {
    cat docker-compose.yml | sed 's/#dockerfile/dockerfile/' > docker-compose-aarch64.yml
}
create_local_docker_aarch32() {
    cat docker-compose.yml | sed 's/#dockerfile.*/dockerfile: Dockerfile.arm.release/' > docker-compose-aarch32.yml
}

configure_arch() {
    if [ "$DEPLOY_ARCH" = 'aarch64' ]; then 
        COMPOSE_BUILD_ARGS=${COMPOSE_BUILD_ARGS//DOCKER_ARCH/arm64v8}
        BALENA_BUILD_ARGS=${BALENA_BUILD_ARGS//DOCKER_ARCH/arm64v8}
    elif [ "$DEPLOY_ARCH" = 'amd64' ]; then 
        COMPOSE_BUILD_ARGS=${COMPOSE_BUILD_ARGS//DOCKER_ARCH/amd64}
        BALENA_BUILD_ARGS=${BALENA_BUILD_ARGS//DOCKER_ARCH/amd64}
    else #aarch32
        COMPOSE_BUILD_ARGS=${COMPOSE_BUILD_ARGS//DOCKER_ARCH/arm32v7}
        BALENA_BUILD_ARGS=${BALENA_BUILD_ARGS//DOCKER_ARCH/arm32v7}
    fi
}


ProgName=$(basename $0)
  
sub_help(){
    echo "Usage: $ProgName <subcommand> [options]\n"
    echo "Subcommands:"
    echo "    build  - build the images"
    echo "    deploy - deploy images as application to balena"
    echo ""
    echo 'env DEPLOY_ARCH be "amd64" | "aarch64" | "aarch32"'
    echo ""
    echo "For help with each subcommand run:"
    echo "$ProgName <subcommand> -h|--help"
    echo ""
}
  
sub_build_help(){
    echo '
    build can pass "amd64" | "aarch64" | "aarch32"
        default: aarch64
        alternativly can be set in env DEPLOY_ARCH
    '
}
sub_build(){
    sub_option=$1
    case $sub_option in
        "-h" | "--help")
            sub_build_help
            exit 0
            ;;
        "amd64" | "aarch64" | "aarch32")
            DEPLOY_ARCH="${sub_option}"
            echo "building ${DEPLOY_ARCH}"
            ;;
        "")
            echo "building ${DEPLOY_ARCH}"
            ;;
        *)
            echo "invalid build architecture ${DEPLOY_ARCH}"
            echo "valid include - amd64 | aarch64 | aarch32" 
            exit 1
            ;;
    esac
    configure_arch
    if [ "$DEPLOY_ARCH" = 'aarch64' ]; then 
        if command -v docker-compose &> /dev/null; then
        #if [ "$SYSTEM_ARCH" = 'x86_64' ]; then 
            JUPI_MINIO_DOCKERFILE=Dockerfile.arm64.release docker-compose build ${COMPOSE_BUILD_ARGS} ${SERVICES} 
        else
            JUPI_MINIO_DOCKERFILE=Dockerfile.arm64.release balena build --arch aarch64 ${BALENA_BUILD_ARGS} 
        fi
    elif [ "$DEPLOY_ARCH" = 'amd64' ]; then 
        if command -v docker-compose &> /dev/null; then
        #if [ "$SYSTEM_ARCH" = 'x86_64' ]; then 
            JUPI_MINIO_DOCKERFILE=Dockerfile docker-compose --project-name jupyter-x86 build ${COMPOSE_BUILD_ARGS} ${SERVICES}
        else
            JUPI_MINIO_DOCKERFILE=Dockerfile balena build --projectName jupyter-x86 --arch amd64 ${BALENA_BUILD_ARGS} 
        fi
    else #aarch32
        if command -v docker-compose &> /dev/null; then
        #if [ "$SYSTEM_ARCH" = 'x86_64' ]; then 
            create_local_docker_aarch32
            JUPI_MINIO_DOCKERFILE=Dockerfile.arm.release docker-compose -f docker-compose-aarch32.yml build ${BALENA_BUILD_ARGS} ${SERVICES}
        else 
            JUPI_MINIO_DOCKERFILE=Dockerfile.arm.release balena build --arch armv7hf ${BALENA_BUILD_ARGS} 
        fi
    fi
}
  
sub_deploy_help(){
    echo '
    deploy can pass "amd64" | "aarch64" | "aarch32"
        default: aarch64
        alternativly can be set in env DEPLOY_ARCH
    '
}
sub_deploy(){
    sub_option=$1
    case $sub_option in
        "-h" | "--help")
            sub_deploy_help
            exit 0
            ;;
        "amd64" | "aarch64" | "aarch32")
            DEPLOY_ARCH="${sub_option}"
            echo "deploying ${DEPLOY_ARCH}"
            ;;
        "")
            echo "deploying ${DEPLOY_ARCH}"
            ;;
        *)
            echo "invalid deploy architecture ${DEPLOY_ARCH}"
            echo "valid include - amd64 | aarch64 | aarch32" 
            exit 1
            ;;
    esac
    configure_arch
    if [ "$DEPLOY_ARCH" = 'aarch64' ]; then 
        balena deploy --arch aarch64 ${BALENA_BUILD_ARGS} jupyter
    elif [ "$DEPLOY_ARCH" = 'amd64' ]; then 
        balena deploy --project-name jupyter-x86 --arch amd64 ${BALENA_BUILD_ARGS} jupyter-x86
    else #aarch32
        balena deploy --arch armv7hf ${BALENA_BUILD_ARGS} jupyter-arm32v7
    fi
}
  
subcommand=$1
case $subcommand in
    "" | "-h" | "--help")
        sub_help
        ;;
    *)
        shift
        sub_${subcommand} $@
        if [ $? = 127 ]; then
            echo "Error: '$subcommand' is not a known subcommand." >&2
            echo "       Run '$ProgName --help' for a list of known subcommands." >&2
            exit 1
        fi
        ;;
esac