#!/usr/bin/env bash 
PREV_DIR=$DIR
PREV_COMPOSE_PROJECT_NAME=$COMPOSE_PROJECT_NAME
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

case "$(uname -m)" in
    "x86_64")
        COMPOSE_PROJECT_NAME="${JUPI_PROJECT_NAME:-jupiter-amd64}"
    ;;
    "aarch64")
        COMPOSE_PROJECT_NAME="${JUPI_PROJECT_NAME:-jupiter-aarch64}"
    ;;
    *)
        echo "invalid ssytem architecture"
        echo "valid include - amd64 | aarch64" 
        ;;
esac
if [ -e "${DIR}/../jupiter-compose-override.yml" ]; then 
    alias jupiter-compose="COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} docker-compose -f docker-compose.yml -f jupiter-compose-override.yml"
else 
    alias jupiter-compose="COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} docker-compose -f docker-compose.yml"
fi

DIR=$PREV_DIR
COMPOSE_PROJECT_NAME=$PREV_COMPOSE_PROJECT_NAME


