ARG BASE_IMAGE_ARCH 
FROM ${BASE_IMAGE_ARCH}/nginx:1.19-alpine
WORKDIR /usr/src/server
COPY ./nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
#CMD ["sleep", "infinity"]