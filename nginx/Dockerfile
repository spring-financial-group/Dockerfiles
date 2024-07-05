FROM nginx:stable-alpine

RUN apk update

COPY conf/default.conf /etc/nginx/conf.d/
COPY conf/default /etc/nginx/sites-available/

ENV HTTPS_METHOD=noredirect
