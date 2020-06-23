#!/bin/bash
set -x
EXTENSIONS="@jupyter-widgets/jupyterlab-manager plotlywidget@4.8.1 \
     qgrid2 \
    jupyterlab-dash jupyterlab-plotly @jupyter-widgets/jupyterlab-manager \
    @karosc/jupyterlab_dracula @lckr/jupyterlab_variableinspector jupyterlab-s3-browser"

export JUPYTERLAB_DIR=${JUPYTERLAB_DIR_DEFAULT}
jupyter labextension install --app-dir=${JUPYTERLAB_DIR_DEFAULT} --no-build ${EXTENSIONS}
jupyter lab build --app-dir=${JUPYTERLAB_DIR_DEFAULT} --log-level=30

export JUPYTERLAB_DIR=${JUPYTERLAB_DIR_VIM}
jupyter labextension install --app-dir=${JUPYTERLAB_DIR_VIM} --no-build ${EXTENSIONS} @axlair/jupyterlab_vim
jupyter labextension enable --app-dir=${JUPYTERLAB_DIR_VIM} @axlair/jupyterlab_vim
jupyter lab build --app-dir=${JUPYTERLAB_DIR_VIM} --log-level=30

export JUPYTERLAB_DIR=${JUPYTERLAB_DIR_DEFAULT}
jupyter nbextension enable --py qgrid 
jupyter nbextension enable --py widgetsnbextension 
jupyter serverextension enable --py jupyterlab --user
jupyter serverextension enable --py jupyterlab_git --user
