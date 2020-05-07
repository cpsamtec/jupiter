ARG NOTEBOOK_BASE_IMAGE 
FROM $NOTEBOOK_BASE_IMAGE 

RUN apt-get update && \
 apt-get install -y vim && \
 apt-get clean
RUN pip install jupyterlab


CMD [ "sleep", "infinity" ]