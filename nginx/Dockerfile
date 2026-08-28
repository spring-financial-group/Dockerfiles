FROM jx3mqubebuild.azurecr.io/docker-io/library/nginx:stable-alpine

RUN apk update

# CVE-2024-2398 & CVE-2024-45490
RUN apk add --upgrade curl libcurl libexpat

# CVE-2026-14456 & CVE-2026-14456
RUN apk add --upgrade libcrypto3 libssl3

COPY conf/default.conf /etc/nginx/conf.d/
COPY conf/default /etc/nginx/sites-available/

ENV HTTPS_METHOD=noredirect
