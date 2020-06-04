#/usr/bin/env bash

echo "/lab token is"
jupyter notebook list | grep token | sed -n '0,/http/s/.*token=\([a-zA-Z0-9]\+\).*/\1/p'

echo "/code password is"
cat /program/code-server.yml | sed -n 's/^password: \([a-zA-Z0-9]\+\)/\1/p'