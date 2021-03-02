#FROM arm64v8/ubuntu:focal as nb_pre_base
FROM balenalib/aarch64-ubuntu:focal-build as nb_pre_base
RUN echo "deb https://repo.download.nvidia.com/jetson/common r32.4 main" >>  /etc/apt/sources.list.d/nvidia.list \
    && echo "deb https://repo.download.nvidia.com/jetson/t194 r32.4 main" >>  /etc/apt/sources.list.d/nvidia.list \
    && apt-key adv --fetch-key http://repo.download.nvidia.com/jetson/jetson-ota-public.asc \
    && mkdir -p /opt/nvidia/l4t-packages/ && touch /opt/nvidia/l4t-packages/.nv-l4t-disable-boot-fw-update-in-preinstall


FROM nb_pre_base
#FROM balenalib/jetson-xavier-ubuntu:focal
#RUN sed -i 's/r32 main/r32.4 main/g' /etc/apt/sources.list.d/nvidia.list && apt-get update

WORKDIR /usr/src/app

ENV DEBIAN_FRONTEND noninteractive
ENV CUDA_HOME=/usr/local/cuda-10.2
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${CUDA_HOME}/lib64
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

RUN apt-get update && apt-get install -y wget tar lbzip2 python3 libegl1 unzip jq \
    build-essential libc6-dev git ninja-build libc6-dev gcc-8 g++-8 \
    cmake python3.8 python3-pip python3-venv binfmt-support

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 8 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 8 
RUN pip3 install --upgrade setuptools pyyaml

RUN wget https://developer.nvidia.com/embedded/L4T/r32_Release_v4.4/r32_Release_v4.4-GMC3/T186/Tegra186_Linux_R32.4.4_aarch64.tbz2 && \
    tar xf Tegra186_Linux_R32.4.4_aarch64.tbz2 
RUN \ 
    TEGRA_DRIVERS="Tegra186_Linux_R32.4.4_aarch64.tbz2" &&  \
    mkdir tegra && \
    mv $TEGRA_DRIVERS tegra && \
    cd tegra && \
    tar --strip-components=2 -xvf $TEGRA_DRIVERS --wildcards --no-anchored 'Linux_for_Tegra/nv_tegra/*.tbz2' 

RUN tar xjf tegra/nvidia_drivers.tbz2 -C / --skip-old-files \
    && tar xjf tegra/config.tbz2 -C / --skip-old-files --exclude=etc/hosts --exclude=etc/hostname --exclude=etc/fstab \
    && echo "/usr/lib/aarch64-linux-gnu/tegra" > /etc/ld.so.conf.d/nvidia-tegra.conf \
    && ldconfig \
    && tar xvf tegra/nv_tools.tbz2 -C / --exclude=/home --skip-old-files \
    && tar xvf tegra/nv_sample_apps/nvgstapps.tbz2 -C / --skip-old-files \
    && tar -C /usr/src/app --strip-components=2 -xvf tegra/nv_tools.tbz2 usr/bin/ --skip-old-files \
    && ln -s /etc/nvpmodel/nvpmodel_t186.conf /etc/nvpmodel.conf 

RUN \
    apt-get update && apt-get install -y cuda-toolkit-10-2 libopenblas-base libopenmpi-dev 

RUN \
    apt-get install -y libcudnn8 nvidia-cudnn8

COPY app/* ./

CMD ["bash", "sleep", "infinity"]