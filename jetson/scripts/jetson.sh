#!/usr/bin/env bash 
set -ex
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ProgName=$(basename $0)
cd $DIR/.. 
echo "from jetson dir located at: $(pwd)"
JUPI_NOTEBOOK_BASE_REPOSITORY=${JUPI_NOTEBOOK_BASE_REPOSITORY:-samtecdistro}
JUPI_NOTEBOOK_BASE_IMAGE=${JUPI_NOTEBOOK_BASE_IMAGE:-jetson}
JUPI_NOTEBOOK_BASE_TAG=${JUPI_NOTEBOOK_BASE_TAG:-latest}
JUPI_JETSON_TYPE=${JUPI_JETSON_TYPE:-xavier}
export JUPI_NOTEBOOK_BASE_NAME=${JUPI_NOTEBOOK_BASE_REPOSITORY}/${JUPI_NOTEBOOK_BASE_IMAGE}:${JUPI_NOTEBOOK_BASE_TAG}
export JUPI_PROJECT_NAME=jupiter-jetson

sub_help(){
    echo "Usage: $ProgName <subcommand> [options]\n"
    echo "Subcommands:"
    echo "    build  - build the images"
    echo "    deploy - deploy images as application to balena"
    echo ""
}
  
sub_build(){
    docker build -t ${JUPI_NOTEBOOK_BASE_IMAGE} .
    ${DIR}/../../scripts/jupiter.sh build aarch64
}
  
sub_deploy(){
    ${DIR}/../../scripts/jupiter.sh deploy aarch64
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