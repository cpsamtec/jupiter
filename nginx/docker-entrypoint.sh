#!/bin/sh

sh -c "/app/nginx-reloader.sh &"
exec "$@"