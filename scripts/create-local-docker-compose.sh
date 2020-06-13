#!/usr/bin/env bash 
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR/.. 
cat docker-compose.yml | sed 's/#dockerfile/dockerfile/' > docker-compose-aarch64.yml
cat docker-compose.yml | sed 's/#dockerfile.*/dockerfile: Dockerfile.arm.release/' > docker-compose-armv7hf.yml
#cat docker-compose.yml | sed -e 's/2.0/2.4/' -e 's/#platform/platform/' -e 's/#dockerfile/dockerfile/' > docker-compose-aarch64.yml
#cat docker-compose.yml | sed -e 's/2.0/2.4/' -e 's!#platform: '\''linux/arm64'\''!platform: '\''linux/amd64'\''!' > docker-compose-local-amd64.yml
