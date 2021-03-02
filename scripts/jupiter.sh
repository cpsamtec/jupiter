#!/usr/bin/env bash 
#set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR/.. 

#Initialize globals
SERVICES="sds nginx notebook"
SYSTEM_ARCH=$(uname -m)
BUILD_ARGS="BUILD_ARG BASE_IMAGE_ARCH=DOCKER_ARCH BUILD_ARG NOTEBOOK_BASE_IMAGE=${JUPI_NOTEBOOK_BASE_NAME:-DOCKER_ARCH/ubuntu:groovy} BUILD_ARG SDS_BASE_IMAGE=DOCKER_ARCH/python:3.8-alpine"

GLOBAL_JUPI_PROJECT_NAME=${JUPI_PROJECT_NAME}
GLOBAL_JUPI_DEPLOY_ARCH=${JUPI_DEPLOY_ARCH}
FIXED_COMPOSE_BUILD_ARGS=${BUILD_ARGS//BUILD_ARG/--build-arg}
FIXED_BALENA_BUILD_ARGS=${BUILD_ARGS//BUILD_ARG/-B}

set_deploy_arch() {
    case $1 in
        "amd64")
            JUPI_DEPLOY_ARCH="${1}"
            JUPI_PROJECT_NAME="${GLOBAL_JUPI_PROJECT_NAME:-jupiter-amd64}"
            COMPOSE_BUILD_ARGS=${FIXED_COMPOSE_BUILD_ARGS//DOCKER_ARCH/amd64}
            BALENA_BUILD_ARGS=${FIXED_BALENA_BUILD_ARGS//DOCKER_ARCH/amd64}
        ;;
        "aarch64")
            JUPI_DEPLOY_ARCH="${1}"
            JUPI_PROJECT_NAME="${GLOBAL_JUPI_PROJECT_NAME:-jupiter-aarch64}"
            COMPOSE_BUILD_ARGS=${FIXED_COMPOSE_BUILD_ARGS//DOCKER_ARCH/arm64v8}
            BALENA_BUILD_ARGS=${FIXED_BALENA_BUILD_ARGS//DOCKER_ARCH/arm64v8}
        ;;
        *)
            echo "invalid architecture ${JUPI_DEPLOY_ARCH}"
            echo "valid include - amd64 | aarch64" 
            exit 1
            ;;
    esac

}
# if JUPI_DEPLOY_ARCH not specified default to system. can be overriden with parameter
if [ -z $JUPI_DEPLOY_ARCH ]; then 
    case $SYSTEM_ARCH in
        "aarch64")
            set_deploy_arch "aarch64"
            ;;
        "x86_64")
            set_deploy_arch "amd64"
            ;;
        *)
            echo "${SYSTEM_ARCH} is not currently supported"
            exit 3
            ;;
    esac
else
    set_deploy_arch "${JUPI_DEPLOY_ARCH}"
fi

create_local_docker_aarch64() {
    cat docker-compose.yml | sed 's/#dockerfile/dockerfile/' > docker-compose-aarch64.yml
}

ProgName=$(basename $0)
  
sub_help(){
    echo "Usage: $ProgName <subcommand> [options]\n"
    echo "Subcommands:"
    echo "    build  - build the images"
    echo "    deploy - deploy images as application to balena"
    echo ""
    echo 'env JUPI_DEPLOY_ARCH be "amd64" | "aarch64"'
    echo ""
    echo "For help with each subcommand run:"
    echo "$ProgName <subcommand> -h|--help"
    echo ""
}
  
sub_build_help(){
    echo '
    build can pass "amd64" | "aarch64"
        default: system
        alternativly can be set in env JUPI_DEPLOY_ARCH
    '
}
sub_build(){
    sub_option=$1
    case $sub_option in
        "-h" | "--help")
            sub_build_help
            exit 0
            ;;
        "")
            echo "building ${JUPI_DEPLOY_ARCH}"
            ;;
        *)
            set_deploy_arch $sub_option
            echo "building ${JUPI_DEPLOY_ARCH}"
            ;;
    esac
    if command -v docker-compose &> /dev/null; then
        docker-compose --project-name ${JUPI_PROJECT_NAME} build ${COMPOSE_BUILD_ARGS} ${SERVICES} 
    else
        balena build --projectName ${JUPI_PROJECT_NAME} --application ${JUPI_PROJECT_NAME} ${BALENA_BUILD_ARGS} 
    fi
}
  
sub_deploy_help(){
    echo '
    deploy can pass "amd64" | "aarch64" 
        default: system
        alternativly can be set in env JUPI_DEPLOY_ARCH
    '
}
sub_deploy(){
    sub_option=$1
    case $sub_option in
        "-h" | "--help")
            sub_deploy_help
            exit 0
            ;;
        "")
            echo "deploying ${JUPI_DEPLOY_ARCH}"
            ;;
        *)
            set_deploy_arch $sub_option
            echo "deploying ${JUPI_DEPLOY_ARCH}"
            ;;
    esac
    balena deploy --projectName ${JUPI_PROJECT_NAME} ${BALENA_BUILD_ARGS} ${JUPI_PROJECT_NAME} 
    if [ $? -ne 0 ]; then 
        balena deploy ${JUPI_PROJECT_NAME} --projectName ${JUPI_PROJECT_NAME} ${BALENA_BUILD_ARGS} 
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