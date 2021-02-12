ARG NOTEBOOK_BASE_IMAGE 
ARG BASE_IMAGE_ARCH 
FROM ${BASE_IMAGE_ARCH}/ubuntu:groovy as arch_loader

RUN mkdir -p /out/minio/bin
RUN mkdir -p /out/clang
ARG BASE_IMAGE_ARCH 
RUN apt-get update && apt-get install -y wget curl xz-utils
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
 DEBIAN_FRONTEND=noninteractive apt-get install -y golang git cmake avahi-utils iputils-ping sudo build-essential vim \
 nano libopenmpi-dev libopenblas-dev libreadline-dev libffi-dev liblapack-dev libhdf5-openmpi-dev hdf5-tools \
  libfreetype6-dev openssl dropbear wget curl rsync psmisc procps i2c-tools gfortran gcc llvm \
 nodejs npm zip gpiod libtinfo5 libzmq3-dev  \
 python3 python3-dev python3-botocore python3-boto3 python3-numpy python3-scipy \
 python3-matplotlib libhdf5-dev python3-pandas python3-h5py python3-arrow python3-dbus libdbus-glib-1-dev && \
 apt-get clean && \
 echo "Installed packages successfully."

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python3 get-pip.py --force-reinstall
COPY --from=arch_loader /out/clang/ /usr/local/
RUN useradd --create-home --shell /bin/bash dev && \
 usermod -aG sudo dev && \
 mkdir /lab && \
 chown -R dev:dev /lab && \
 mkdir /code && \
 chown -R dev:dev /code && \
 mkdir /dev-apps && \
 chown -R dev:dev /dev-apps && \
 mkdir /program 
VOLUME [ "/code", "/lab", "/program" ]
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
ENV PATH "$PATH:/home/dev/.local/bin"


RUN pip3 install wheel numpy pandas matplotlib numba cython scipy pipenv
RUN pip3 install jupyterlab>=3 
RUN pip3 install pyrpio pyrpiic 
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN curl -L "https://github.com/docker/compose/releases/download/1.28.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose && ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose



RUN apt-get update && \
    apt-get install -y apt-transport-https && \
    apt-get install -y software-properties-common wget bsdmainutils lsof && \
    wget -q -O - https://packages.grafana.com/gpg.key | apt-key add - && \
    echo "deb https://packages.grafana.com/oss/deb stable main" | tee -a /etc/apt/sources.list.d/grafana.list && \
    apt-get update && apt-get install grafana && sed -i 's/.*http_port = .*/http_port = 63000/' /etc/grafana/grafana.ini && \
    apt-get clean

RUN pip3 install --ignore-installed --upgrade boto3 minio plotly dash qgrid \
    aioboto3 psutil  fastparquet requests apache-airflow>=1.10.14 pyyaml \
    'dramatiq[rabbitmq, watch]' 

ENV CARGO_HOME=/dev-apps/sdk/cargo
ENV RUSTUP_HOME=/dev-apps/sdk/rustup
RUN su -w "CARGO_HOME,RUSTUP_HOME" - dev -c "mkdir -p ${CARGO_HOME} ${RUSTUP_HOME} && curl https://sh.rustup.rs -sSf | bash -s -- -y"
ENV PATH="${PATH}:${CARGO_HOME}/bin"
RUN su - dev -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash"
RUN su - dev -c "curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python"
ENV CARGO_HOME=/dev-apps/sdk/cargo
ENV RUSTUP_HOME=/dev-apps/sdk/rustup
RUN su -w "CARGO_HOME,RUSTUP_HOME" - dev -c "mkdir -p ${CARGO_HOME} ${RUSTUP_HOME} && curl https://sh.rustup.rs -sSf | bash -s -- -y"
ENV PATH="${PATH}:${CARGO_HOME}/bin"

RUN pip3 install lckr-jupyterlab-variableinspector ipywidgets 
ENV JUPYTERLAB_DIR_DEFAULT=/user-ext/dev/lab/default 
RUN mkdir -p ${JUPYTERLAB_DIR_DEFAULT} 
RUN chown -R dev:dev /user-ext/dev/
ENV JUPYTERLAB_DIR=${JUPYTERLAB_DIR_DEFAULT}
RUN jupyter-lab build


RUN npm install n -g && n stable
COPY --from=arch_loader /out/minio/bin/mc /usr/bin/mc
COPY /app/ /app/
ENV SHELL=/bin/bash
ENV PATH="${PATH}:/home/dev/.local/bin"
RUN echo "dev:${JUPI_DEFAULT_USER_PASSWORD:-dev}" | chpasswd
RUN usermod -aG i2c dev 
RUN usermod -aG dialout dev
RUN addgroup gpio && usermod -aG gpio dev
RUN addgroup spi && usermod -aG spi dev
RUN echo 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:${PATH}' > /etc/profile.d/01-path-fix.sh 
RUN addgroup docker --gid 988 && \
  usermod -aG docker dev 

RUN sed -i -e 's/.*serve_from_sub_path = .*/serve_from_sub_path = true/' -e 's!.*root_url = .*!root_url = %(protocol)s://%(domain)s:%(http_port)s/grafana/!' /etc/grafana/grafana.ini 
RUN export DOCKERVERSION=20.10.3 && export CURR_ARCH=$(uname -i) && echo ${CURR_ARCH} && \ 
   curl -fsSLO https://download.docker.com/linux/static/stable/${CURR_ARCH}/docker-${DOCKERVERSION}.tgz && \
   tar xzvf docker-${DOCKERVERSION}.tgz --strip 1  -C /usr/local/bin docker/docker && \
   rm docker-${DOCKERVERSION}.tgz
CMD [ "/bin/bash", "/app/progs_wrapper.sh" ]
