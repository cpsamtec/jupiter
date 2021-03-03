#!/usr/bin/env bash 
set -ex
export CUDA_HOME=/usr/local/cuda-10.2
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${CUDA_HOME}/lib64
export PATH=${CUDA_HOME}/bin:${PATH}
export USE_NCCL=0
export USE_DISTRIBUTED=0                # skip setting this if you want to enable OpenMPI backend
export USE_QNNPACK=0
export USE_PYTORCH_QNNPACK=0
export TORCH_CUDA_ARCH_LIST="5.3;6.2;7.2"
export PYTORCH_BUILD_VERSION=1.7.1  # without the leading 'v', e.g. 1.3.0 for PyTorch v1.3.0
export PYTORCH_BUILD_NUMBER=1

#make sure gcc is at version 8
update-alternatives --set gcc  /usr/bin/gcc-8 && \
update-alternatives --set g++ /usr/bin/g++-8 

git clone --recursive --branch v1.7.1 https://github.com/pytorch/pytorch.git && \
    cd pytorch/third_party/sleef/ && git checkout master && cd - #fix compile errors in libm 
cd pytorch
pip3 install -r requirements.txt
pip3 install scikit-build
pip3 install ninja
git apply --stat /usr/src/app/pytorch-1_7-jetpack-4_4_1.patch  && git apply /usr/src/app/pytorch-1_7-jetpack-4_4_1.patch 
python3 setup.py bdist_wheel
python3 setup.py install
cd ..

sudo apt-get install libjpeg-dev zlib1g-dev libpython3-dev libavcodec-dev libavformat-dev libswscale-dev
git clone --recursive --branch v0.8.2 https://github.com/pytorch/vision.git
cd vision
export BUILD_VERSION=0.8.2
export FORCE_CUDA=1
python3 setup.py bdist_wheel
python3 setup.py install 
cd ..

export CUPY_NVCC_GENERATE_CODE="arch=compute_53,code=sm_53;arch=compute_62,code=sm_62;arch=compute_72,code=sm_72"
pip install -vvv cupy==8.5
#or git clone
git clone --branch v8.5.0 --recursive https://github.com/cupy/cupy.git
cd cupy
python3 setup.py bdist_wheel
cd ..
pip install fastai==2.2.6
# max performance
# sudo nvpmodel -m 0
# note: below will be needed to run 
#export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}/usr/lib/aarch64-linux-gnu/libgomp.so.1
#export CUDA_HOME=/usr/local/cuda-10.2
#export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${CUDA_HOME}/lib64
#export PATH=${PATH:+${PATH}:}${CUDA_HOME}/bin
# note: below for jupyter notebook only
#export LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libgomp.so.1