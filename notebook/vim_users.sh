#!/usr/bin/env bash 
set -e
code-server --install-extension vscodevim.vim 
jupyter labextension enable @axlair/jupyterlab_vim
jupyter lab build