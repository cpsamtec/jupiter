ARG NOTEBOOK_BASE_IMAGE 
ARG BASE_IMAGE_ARCH 
FROM ${BASE_IMAGE_ARCH}/golang:buster as mc_builder

RUN mkdir -p /go/bin
RUN mkdir -p /out/clang
ARG BASE_IMAGE_ARCH 
RUN apt-get update && apt-get install xz-utils
RUN if [ "$BASE_IMAGE_ARCH" = "arm32v7" ] ; then \
        echo "Getting arm32 minio client" && \
        curl https://dl.min.io/client/mc/release/linux-arm/mc > /go/bin/mc; \
        wget -cO - https://github.com/llvm/llvm-project/releases/download/llvmorg-9.0.1/clang+llvm-9.0.1-armv7a-linux-gnueabihf.tar.xz > clang.tar.xz;  \
        tar xf clang.tar.xz -C /out/clang --strip-components=1; \
    elif [ "$BASE_IMAGE_ARCH" = "arm64v8" ] ; then \
        echo "Getting arm64 minio client" && \
        curl https://dl.min.io/client/mc/release/linux-arm64/mc > /go/bin/mc; \
        wget -cO - https://github.com/llvm/llvm-project/releases/download/llvmorg-9.0.1/clang+llvm-9.0.1-aarch64-linux-gnu.tar.xz > clang.tar.xz;  \
        tar xf clang.tar.xz -C /out/clang --strip-components=1; \
    else \ 
        echo "Getting amd64 minio client" && \
        curl https://dl.min.io/client/mc/release/linux-amd64/mc > /go/bin/mc; \
    fi
RUN chmod +x /go/bin/mc

ARG NOTEBOOK_BASE_IMAGE 
FROM $NOTEBOOK_BASE_IMAGE 

RUN apt-get update && \
 DEBIAN_FRONTEND=noninteractive apt-get install -y sudo build-essential vim \
 nano libopenmpi-dev libopenmpi-dev libopenblas-dev libreadline-dev libffi-dev liblapack-dev libhdf5-openmpi-dev hdf5-tools \
  libfreetype6-dev openssl dropbear wget curl rsync psmisc procps i2c-tools gfortran gcc llvm nodejs npm python3-dev zip gpiod libtinfo5 && \
 apt-get clean
#TODO add libblas-dev liblapack-dev libatlas-base-dev cython 
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python3 get-pip.py --force-reinstall
COPY --from=mc_builder /out/clang/ /usr/local/
ARG USER_PASSWORD 
RUN useradd --create-home --shell /bin/bash dev &&\
 usermod -aG sudo dev && \
 mkdir /lab && \
 chown -R dev:dev /lab && \
 mkdir /code && \
 chown -R dev:dev /code && \
 mkdir /program && \
 chown -R dev:dev /program 
VOLUME [ "/code", "/lab", "/program" ]
RUN adduser dev sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER dev

RUN pip3 install wheel numpy pandas matplotlib numba cython scipy pipenv
RUN pip3 install jupyter jupyterlab jupyter_contrib_nbextensions  
RUN pip3 install pyrpio pyrpiic 
RUN curl -fsSL https://code-server.dev/install.sh | sh

ENV PATH "$PATH:/home/dev/.local/bin"
RUN jupyter labextension install --no-build @jupyter-widgets/jupyterlab-manager plotlywidget@4.8.1 \
     qgrid2 \
    jupyterlab-dash jupyterlab-plotly @jupyter-widgets/jupyterlab-manager \
    @karosc/jupyterlab_dracula @lckr/jupyterlab_variableinspector jupyterlab-s3-browser 
#jupyterlab-cpustatus @jupyterlab/hdf5 @jupyterlab/dataregistry-extension

RUN pip3 install --upgrade jupyterlab-s3-browser jupyterlab-git boto3 minio \
    aioboto3 psutil plotly dash jupyter-dash qgrid fastparquet requests h5py

#RUN jupyter labextension install --no-build @axlair/jupyterlab_vim
#RUN jupyter labextension disable @axlair/jupyterlab_vim
RUN jupyter nbextension enable --py qgrid 
RUN jupyter nbextension enable --py widgetsnbextension 
RUN jupyter lab build
RUN jupyter serverextension enable --py jupyterlab --user
RUN jupyter serverextension enable --py jupyterlab_git --user
RUN code-server --install-extension atlassian.atlascode \
    #&& code-server --install-extension vscodevim.vim \
    && code-server --install-extension  ms-python.python \
    && code-server --install-extension ms-pyright.pyright \
    && code-server --install-extension njpwerner.autodocstring

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python

RUN mkdir -p /program/.vscode-server
RUN ln -s /program/.vscode-server ~/.vscode-server

COPY progs_wrapper.sh credentials.sh vim_users.sh /app/
COPY --from=mc_builder /go/bin/mc /usr/bin/mc
WORKDIR /lab
ENV SHELL=/bin/bash
#RUN echo "root:${USER_PASSWORD}" | chpasswd
RUN echo "dev:dev" | sudo chpasswd

CMD [ "/bin/bash", "/app/progs_wrapper.sh" ]