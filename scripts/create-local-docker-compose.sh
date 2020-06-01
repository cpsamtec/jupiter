#!/usr/bin/env bash 
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR/.. 
cat docker-compose.yml | sed -e 's/2.0/2.4/' -e 's/#platform/platform/' > docker-compose-local.yml
