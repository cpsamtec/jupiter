#!/bin/bash

code-server --install-extension atlassian.atlascode \
    && code-server --install-extension  ms-python.python \
    && code-server --install-extension ms-pyright.pyright \
    && code-server --install-extension njpwerner.autodocstring

if [ ! -z "${JUPI_VIM_USER}" ] && [ "${JUPI_VIM_USER}" -ne 0 ]; then 
    code-server --install-extension vscodevim.vim 
fi

echo "done" > /home/dev/.code-server-ext-installed
sync
