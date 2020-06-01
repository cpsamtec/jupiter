ARG NOTEBOOK_BASE_IMAGE 
FROM $NOTEBOOK_BASE_IMAGE 

RUN apt-get update && \
 apt-get install -y build-essential vim \
 nano libopenmpi-dev libopenblas-dev libreadline-dev libffi-dev liblapack-dev libhdf5-openmpi-dev hdf5-tools \
  libfreetype6-dev openssl i2c-tools gfortran gcc llvm nodejs npm python3-dev python-numpy && \
 apt-get clean

RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python3 get-pip.py --force-reinstall
RUN pip3 install jupyter jupyterlab
RUN pip3 install wheel pyrpio pyrpiic pandas
RUN pip3 install jupyter_contrib_nbextensions 
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager plotlywidget@4.8.1 \
     qgrid2 \
    jupyterlab-dash jupyterlab-plotly @jupyter-widgets/jupyterlab-manager \
    @karosc/jupyterlab_dracula @lckr/jupyterlab_variableinspector
#jupyterlab-cpustatus @jupyterlab/hdf5 @jupyterlab/dataregistry-extension
RUN jupyter nbextension enable --py --sys-prefix widgetsnbextension

RUN curl -fsSL https://code-server.dev/install.sh | sh


COPY progs_wrapper.sh /app/
WORKDIR /lab
#RUN jupyter notebook password

CMD [ "bash", "/app/progs_wrapper.sh" ]
#CMD ["jupyter", "notebook", "--allow-root", "--no-browser", "--ip=*", "--port=80" ]