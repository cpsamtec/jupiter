FROM nginx:1.17-alpine
WORKDIR /usr/src/server
COPY ./nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
#CMD ["sleep", "infinity"]