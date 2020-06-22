#!/bin/bash

jupyter labextension install --no-build @jupyter-widgets/jupyterlab-manager plotlywidget@4.8.1 \
     qgrid2 \
    jupyterlab-dash jupyterlab-plotly @jupyter-widgets/jupyterlab-manager \
    @karosc/jupyterlab_dracula @lckr/jupyterlab_variableinspector jupyterlab-s3-browser 

if [ ! -z "${VIM_USER}" ] && [ "${VIM_USER}" -ne 0 ]; then 
    jupyter labextension install @axlair/jupyterlab_vim
    jupyter labextension enable @axlair/jupyterlab_vim
fi

jupyter nbextension enable --py qgrid 
jupyter nbextension enable --py widgetsnbextension 
jupyter lab build
jupyter serverextension enable --py jupyterlab --user
jupyter serverextension enable --py jupyterlab_git --user