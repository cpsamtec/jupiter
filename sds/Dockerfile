ARG SDS_BASE_IMAGE 
FROM $SDS_BASE_IMAGE as builder
WORKDIR /tmp


ENV BUILD_LIBS="build-base freetype-dev pkgconfig dbus-dev glib-dev"
ENV RUN_LIBS="openssh py3-dbus py3-aiohttp"

RUN \
  apk update && apk add --no-cache ${BUILD_LIBS} ${RUN_LIBS} 

COPY samtecdeviceshare ./samtecdeviceshare
RUN \
  cd samtecdeviceshare && pip3.8 install . && \
  echo "Finished installing samtecdeviceshare!!"

ARG SDS_BASE_IMAGE 
FROM $SDS_BASE_IMAGE 

RUN apk update --no-cache && apk add freetype dbus glib

ENV DBUS_SYSTEM_BUS_ADDRESS unix:path=/host/run/dbus/system_bus_socket
ENV APP_IMG_PATH=/usr/src/app/img.png

WORKDIR /usr/src/app

COPY img.png /usr/src/app/img.png
COPY --from=builder /usr/local/lib/python3.8/site-packages /usr/local/lib/python3.8/site-packages
RUN rm -rf /usr/local/lib/python3.8/test

CMD [ "python3.8", "-m", "samtecdeviceshare.server" ]
