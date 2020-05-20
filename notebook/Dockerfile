ARG NOTEBOOK_BASE_IMAGE 
FROM $NOTEBOOK_BASE_IMAGE 

RUN apt-get update && \
 apt-get install -y build-essential vim \
 nano libopenmpi-dev libopenblas-dev libreadline-dev libffi-dev liblapack-dev libhdf5-openmpi-dev hdf5-tools \
  libfreetype6-dev openssl i2c-tools gfortran gcc llvm nodejs npm python3-dev && \
 apt-get clean

RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python3 get-pip.py --force-reinstall
RUN pip3 install jupyter jupyterlab
RUN pip3 install wheel pyrpio pyrpiic numpy 
WORKDIR /data
#RUN jupyter notebook password


#CMD [ "sleep", "infinity" ]
CMD ["jupyter", "notebook", "--allow-root", "--no-browser", "--ip=*", "--port=80" ]