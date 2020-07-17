#!/usr/bin/env bash 
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}/.."

echo "make sure to - source ${DIR}/scripts/env.sh"
source scripts/env.sh

ETH_DISABLE=1 SDC_WIFI_TYPE=DISABLED docker-compose up