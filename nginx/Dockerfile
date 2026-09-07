FROM jx3mqubebuild.azurecr.io/docker-io/library/nginx:stable-alpine

RUN apk update

# CVE-2024-2398 & CVE-2024-45490
RUN apk add --upgrade curl libcurl

# CVE-2026-14456 & CVE-2026-14456
RUN apk add --upgrade libcrypto3 libssl3

# CVE-2026-66046 & CVE-2026-76641
RUN apk add --upgrade libexpat

# CVE-2026-53612, CVE-2026-53613, CVE-2026-53614, CVE-2026-76642, CVE-2026-78408, CVE-2026-78409, CVE-2026-78410
RUN apk add --upgrade libuuid

COPY conf/default.conf /etc/nginx/conf.d/
COPY conf/default /etc/nginx/sites-available/

ENV HTTPS_METHOD=noredirect
