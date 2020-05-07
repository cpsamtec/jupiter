ARG NOTEBOOK_BASE_IMAGE 
FROM $NOTEBOOK_BASE_IMAGE 

RUN apt-get update && \
 apt-get install -y build-essential vim \
 nano libopenmpi-dev libopenblas-dev libreadline-dev libffi-dev liblapack-dev libhdf5-openmpi-dev hdf5-tools \
  libfreetype6-dev openssl i2c-tools gfortran gcc llvm nodejs npm && \
 apt-get clean
RUN pip install jupyterlab


CMD [ "sleep", "infinity" ]