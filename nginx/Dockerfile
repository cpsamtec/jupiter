ARG BASE_IMAGE_ARCH 
FROM ${BASE_IMAGE_ARCH}/nginx:1.19-alpine
WORKDIR /app
RUN apk update && apk add inotify-tools
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./nginx-reloader.sh ./docker-entrypoint.sh ./

RUN chmod +x nginx-reloader.sh docker-entrypoint.sh 
EXPOSE 80
VOLUME [ "/etc/nb-nginx/conf.d" ]
CMD ["nginx", "-g", "daemon off;"]
ENTRYPOINT [ "/app/docker-entrypoint.sh" ]