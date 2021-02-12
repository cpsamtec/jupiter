ARG SDS_BASE_IMAGE 
FROM $SDS_BASE_IMAGE as base
RUN apk add --no-cache --update curl 
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python3 get-pip.py --force-reinstall
ENV PYTHONFAULTHANDLER=1 \
  PYTHONUNBUFFERED=1 \
  PYTHONHASHSEED=random \
  PIP_NO_CACHE_DIR=off \
  PIP_DISABLE_PIP_VERSION_CHECK=on \
  PIP_DEFAULT_TIMEOUT=100 

FROM base as builder

RUN apk add --no-cache --update \
    gcc gfortran musl-dev git \
    libgcc musl libgfortran lapack-dev \
    build-base jpeg-dev zlib-dev i2c-tools-dev linux-headers jq \
    libffi-dev openssl-dev python3-dev dbus-dev glib-dev \
    freetype-dev pkgconfig 

ENV CARGO_HOME=/rust/sdk/cargo
ENV RUSTUP_HOME=/rust/sdk/rustup
RUN mkdir -p ${CARGO_HOME} && mkdir -p ${RUSTUP_HOME}
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
# Due to poetry bug, installing always removes unused packages from lock
# Right now will have to install with dev dependencies  
# https://github.com/python-poetry/poetry/issues/3139
#ENV SBS_ENV=production
ENV SDS_ENV=poetry_bug_use_dev
RUN source ${CARGO_HOME}/env && pip install "poetry"

FROM builder as sds_installer
WORKDIR /code
COPY samtecdeviceshare/poetry.lock samtecdeviceshare/poetry.toml samtecdeviceshare/pyproject.toml ./
RUN poetry config virtualenvs.create false && \
  poetry install $(test "$SDS_ENV" == production && echo "--no-dev") --no-interaction --no-ansi 

FROM builder as sds_builder
WORKDIR /code

COPY --from=sds_installer /usr/local/lib/python3.8/site-packages /usr/local/lib/python3.8/site-packages 
COPY samtecdeviceshare ./samtecdeviceshare
RUN cd samtecdeviceshare && \
  poetry config virtualenvs.create false && \
  poetry build --no-interaction --no-ansi

FROM base
WORKDIR /tmp

RUN apk update --no-cache && apk add freetype dbus glib openssh py3-dbus py3-aiohttp

#ENV DBUS_SYSTEM_BUS_ADDRESS unix:path=/host/run/dbus/system_bus_socket
ENV APP_IMG_PATH=/usr/src/app/img.png

WORKDIR /usr/src/app

COPY img.png /usr/src/app/img.png
COPY --from=sds_builder /usr/local/lib/python3.8/site-packages /usr/local/lib/python3.8/site-packages 
COPY --from=sds_builder /code/samtecdeviceshare/dist/* ./
RUN pip3 install --no-deps --force-reinstall samtec*.whl
RUN pip3 install --upgrade --force-reinstall uvicorn 
ENV PYTHONPATH=${PYTHONPATH}:/usr/lib/python3.8/site-package

RUN rm -rf /usr/local/lib/python3.8/test
ENV SDS_ROOT_PATH=/sds

CMD [ "python3.8", "-m", "samtecdeviceshare.server" ]

