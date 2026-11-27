FROM jx3mqubebuild.azurecr.io/docker-io/library/nginx:1.30.8-alpine

RUN apk upgrade --no-cache

COPY conf/default.conf /etc/nginx/conf.d/
COPY conf/default /etc/nginx/sites-available/

ENV HTTPS_METHOD=noredirect
