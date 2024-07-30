FROM nginx:stable-alpine

RUN apk update

# CVE-2024-2398
RUN apk add --upgrade curl libcurl

COPY conf/default.conf /etc/nginx/conf.d/
COPY conf/default /etc/nginx/sites-available/

ENV HTTPS_METHOD=noredirect
