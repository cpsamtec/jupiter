ARG JUPI_NOTEBOOK_BASE_NAME 
ARG BASE_IMAGE_ARCH 
FROM ${JUPI_NOTEBOOK_BASE_NAME} as arch_loader

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

ARG JUPI_NOTEBOOK_BASE_NAME 
FROM $JUPI_NOTEBOOK_BASE_NAME 
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' -y golang git cmake avahi-utils iputils-ping sudo build-essential vim \
    nano libopenmpi-dev libopenblas-dev libreadline-dev libffi-dev liblapack-dev libhdf5-openmpi-dev hdf5-tools \
    libfreetype6-dev openssl dropbear wget curl rsync psmisc procps i2c-tools gfortran gcc llvm \
    nodejs npm zip gpiod libtinfo5 libzmq3-dev  \
    python3 python3-dev python3-botocore python3-boto3 python3-numpy python3-scipy \
    python3-matplotlib libhdf5-dev python3-venv python3-pandas python3-h5py python3-arrow python3-dbus libdbus-glib-1-dev \
    less kmod nano net-tools ifupdown iputils-ping i2c-tools usbutils \
    apt-transport-https software-properties-common wget bsdmainutils lsof socat default-jre && \
    apt-get clean && rm -rf /var/lib/apt/lists/*  && \
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


RUN npm install n -g && n stable
RUN pip3 install --ignore-installed --upgrade --no-cache-dir wheel numpy pandas matplotlib numba cython scipy pipenv \
    jupyterlab>=3 \
    pyrpio pyrpiic \
    boto3 minio plotly dash qgrid \
    aioboto3 psutil  fastparquet requests pyyaml \
    'dramatiq[rabbitmq, watch]' \
    docker-compose \
    lckr-jupyterlab-variableinspector ipywidgets jupyterlab_widgets jupyter-dash \
    fastapi uvicorn

RUN curl -fsSL https://code-server.dev/install.sh | sh
#RUN curl -L "https://github.com/docker/compose/releases/download/1.28.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#RUN chmod +x /usr/local/bin/docker-compose && ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose


ENV CARGO_HOME=/dev-apps/sdk/cargo
ENV RUSTUP_HOME=/dev-apps/sdk/rustup
RUN su -w "CARGO_HOME,RUSTUP_HOME" - dev -c "mkdir -p ${CARGO_HOME} ${RUSTUP_HOME} && curl https://sh.rustup.rs -sSf | bash -s -- -y"
ENV PATH="${PATH}:${CARGO_HOME}/bin"
RUN su -w "PATH,CARGO_HOME,RUSTUP_HOME" - dev -c "/dev-apps/sdk/cargo/bin/cargo install --features=ssl websocat"

RUN su - dev -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash"
RUN su - dev -c "curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python"


ENV JUPYTERLAB_DIR_DEFAULT=/user-ext/dev/lab/default 
RUN mkdir -p ${JUPYTERLAB_DIR_DEFAULT} 
RUN chown -R dev:dev /user-ext/dev/
ENV JUPYTERLAB_DIR=${JUPYTERLAB_DIR_DEFAULT}
RUN jupyter labextension install jupyterlab-plotly && \
    jupyter-lab build

RUN wget -q -O - https://packages.grafana.com/gpg.key | apt-key add - && \
    echo "deb https://packages.grafana.com/oss/deb stable main" | tee -a /etc/apt/sources.list.d/grafana.list && \
    apt-get update && apt-get install grafana && sed -i 's/.*http_port = .*/http_port = 63000/' /etc/grafana/grafana.ini && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN sed -i -e 's/.*serve_from_sub_path = .*/serve_from_sub_path = true/' -e 's!.*root_url = .*!root_url = %(protocol)s://%(domain)s:%(http_port)s/grafana/!' /etc/grafana/grafana.ini 
RUN export DOCKERVERSION=20.10.3 && export CURR_ARCH=$(uname -i) && echo ${CURR_ARCH} && \ 
    curl -fsSLO https://download.docker.com/linux/static/stable/${CURR_ARCH}/docker-${DOCKERVERSION}.tgz && \
    tar xzvf docker-${DOCKERVERSION}.tgz --strip 1  -C /usr/local/bin docker/docker && \
    rm docker-${DOCKERVERSION}.tgz

RUN pip3 install --no-cache-dir apache-airflow==2.0.1 \
    --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.0.1/constraints-3.7.txt"

RUN printf '%s\n' \
    'if [ -e "/var/run/balena.sock" ]; then' \ 
    'export DOCKER_HOST=unix:///var/run/balena.sock' \
    'export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket' \
    'fi' \
    \
    >> /root/.bashrc && cat /root/.bashrc

ENV SHELL=/bin/bash
ENV PATH="${PATH}:/home/dev/.local/bin"
RUN echo "dev:${JUPI_DEFAULT_USER_PASSWORD:-dev}" | chpasswd
RUN usermod -aG i2c dev && usermod -aG dialout dev
RUN addgroup gpio && usermod -aG gpio dev
RUN addgroup spi && usermod -aG spi dev
RUN echo 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:${PATH}' > /etc/profile.d/01-path-fix.sh 
# video gives non root access to nvidia
RUN usermod -aG video dev 
RUN addgroup docker && \
    usermod -aG docker dev 

COPY --from=arch_loader /out/minio/bin/mc /usr/bin/mc
COPY /app/ /app/
CMD [ "/bin/bash", "/app/progs_wrapper.sh" ]
