FROM jx3mqubebuild.azurecr.io/docker-io/library/nginx:stable-alpine

RUN apk update

# CVE-2024-2398 & CVE-2024-45490
RUN apk add --upgrade curl libcurl libexpat

COPY conf/default.conf /etc/nginx/conf.d/
COPY conf/default /etc/nginx/sites-available/

ENV HTTPS_METHOD=noredirect
