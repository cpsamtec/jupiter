ARG NOTEBOOK_BASE_IMAGE 
ARG BASE_IMAGE_ARCH 
FROM ${BASE_IMAGE_ARCH}/debian:buster as arch_loader

RUN mkdir -p /out/minio/bin
RUN mkdir -p /out/clang
ARG BASE_IMAGE_ARCH 
RUN apt-get update && apt-get install -y curl xz-utils
RUN if [ "$BASE_IMAGE_ARCH" = "arm32v7" ] ; then \
        echo "Getting arm32 minio client" && \
        curl https://dl.min.io/client/mc/release/linux-arm/mc > /out/minio/bin/mc; \
        wget -cO - https://github.com/llvm/llvm-project/releases/download/llvmorg-9.0.1/clang+llvm-9.0.1-armv7a-linux-gnueabihf.tar.xz > clang.tar.xz;  \
        tar xf clang.tar.xz -C /out/clang --strip-components=1; \
    elif [ "$BASE_IMAGE_ARCH" = "arm64v8" ] ; then \
        echo "Getting arm64 minio client" && \
        curl https://dl.min.io/client/mc/release/linux-arm64/mc > /out/minio/bin/mc; \
        wget -cO - https://github.com/llvm/llvm-project/releases/download/llvmorg-9.0.1/clang+llvm-9.0.1-aarch64-linux-gnu.tar.xz > clang.tar.xz;  \
        tar xf clang.tar.xz -C /out/clang --strip-components=1; \
    else \ 
        echo "Getting amd64 minio client" && \
        curl https://dl.min.io/client/mc/release/linux-amd64/mc > /out/minio/bin/mc; \
    fi
RUN chmod +x /out/minio/bin/mc

ARG NOTEBOOK_BASE_IMAGE 
FROM $NOTEBOOK_BASE_IMAGE 

RUN apt-get update && \
 DEBIAN_FRONTEND=noninteractive apt-get install -y sudo build-essential vim \
 nano libopenmpi-dev libopenmpi-dev libopenblas-dev libreadline-dev libffi-dev liblapack-dev libhdf5-openmpi-dev hdf5-tools \
  libfreetype6-dev openssl dropbear wget curl rsync psmisc procps i2c-tools gfortran gcc llvm nodejs npm python3-dev zip gpiod libtinfo5 && \
 apt-get clean

RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python3 get-pip.py --force-reinstall
COPY --from=arch_loader /out/clang/ /usr/local/
RUN useradd --create-home --shell /bin/bash dev && \
 usermod -aG sudo dev && \
 mkdir /lab && \
 chown -R dev:dev /lab && \
 mkdir /code && \
 chown -R dev:dev /code && \
 mkdir /program 
VOLUME [ "/code", "/lab", "/program" ]
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
ENV PATH "$PATH:/home/dev/.local/bin"


RUN pip3 install wheel numpy pandas matplotlib numba cython scipy pipenv
RUN pip3 install jupyter jupyterlab jupyter_contrib_nbextensions 
RUN pip3 install pyrpio pyrpiic 
RUN curl -fsSL https://code-server.dev/install.sh | sh


RUN pip3 install --upgrade jupyterlab-s3-browser jupyterlab-git jupyter-dash boto3 minio plotly dash qgrid \
    aioboto3 psutil  fastparquet requests h5py

RUN su - dev -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash"
RUN su - dev -c "curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python"

RUN jupyter labextension install --no-build @jupyter-widgets/jupyterlab-manager plotlywidget@4.8.1 \
     qgrid2 \
    jupyterlab-dash jupyterlab-plotly @jupyter-widgets/jupyterlab-manager \
    @karosc/jupyterlab_dracula @lckr/jupyterlab_variableinspector jupyterlab-s3-browser 


RUN jupyter nbextension enable --py qgrid 
RUN jupyter nbextension enable --py widgetsnbextension 
RUN jupyter lab build --log-level=30
RUN jupyter serverextension enable --py jupyterlab 
RUN jupyter serverextension enable --py jupyterlab_git 

COPY --from=arch_loader /out/minio/bin/mc /usr/bin/mc
COPY /app/ /app/
ENV SHELL=/bin/bash
ENV PATH="${PATH}:/home/dev/.local/bin"
#ENV JUPYTERLAB_DIR=/home/dev/.local/share/jupyter/lab
RUN echo "dev:dev" | chpasswd

CMD [ "/bin/bash", "/app/progs_wrapper.sh" ]
#CMD [ "/bin/bash", "-c", "sleep infinity" ]
