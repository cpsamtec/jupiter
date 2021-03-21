ARG SDS_BASE_IMAGE 
FROM $SDS_BASE_IMAGE as base

WORKDIR /sds

ENV APP_IMG_PATH=/sds/img.png

ENV BUILD_LIBS="rust cargo gfortran musl-dev git \
  libgcc musl libgfortran lapack-dev \
  build-base jpeg-dev zlib-dev i2c-tools-dev linux-headers jq \
  libffi-dev openssl-dev python3-dev dbus-dev glib-dev \
  freetype-dev pkgconfig"

ENV RUN_LIBS="freetype dbus glib openssh py3-dbus py3-aiohttp openssh"

RUN \
  apk update && apk add --no-cache $BUILD_LIBS && \
  apk add --no-cache $RUN_LIBS && \
  pip3.8 install --no-cache-dir samtecdeviceshare==2.6.2 && \
  apk del $BUILD_LIBS

RUN rm -rf /usr/local/lib/python3.8/test

COPY img.png /sds/img.png
COPY configuration.yml /sds/configuration.yml
ENV SDC_CONFIGURATION_PATH=/sds/configuration.yml

CMD [ "python3.8", "-m", "samtecdeviceshare.server" ]
