#!/usr/bin/env bash 
set -ex
services="sds notebook nginx"
archs="aarch64 amd64"
JUPI_REPOSITORY=${JUPI_REPOSITORY:-samtecdistro}
JUPI_TAG=${JUPI_TAG:-latest}
for service in $services; do 
    for arch in $archs; do 
        image=jupiter-${arch}_${service}:latest
        target="${JUPI_REPOSITORY}/jupiter-${service}-${arch}:${JUPI_TAG}"
        echo "tagging ${image} as ${target}"
        if docker inspect --type=image ${image} 2> /dev/null | grep Created; then 
            docker tag ${image} ${target}
            docker push ${target}
        fi
    done
done


