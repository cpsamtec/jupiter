#!/usr/bin/env bash 
case "$(uname -m)" in
    "x86_64")
        export COMPOSE_PROJECT_NAME="${JUPI_PROJECT_NAME:-jupiter-amd64}"
    ;;
    "aarch64")
        export COMPOSE_PROJECT_NAME="${JUPI_PROJECT_NAME:-jupiter-aarch64}"
    ;;
    "aarch32")
        export COMPOSE_PROJECT_NAME="${JUPI_PROJECT_NAME:-jupiter-aarch32}"
        ;;
    *)
        echo "invalid ssytem architecture"
        echo "valid include - amd64 | aarch64 | aarch32" 
        ;;
esac



