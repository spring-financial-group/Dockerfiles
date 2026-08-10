# Use the official Bun alpine image as a base
FROM jx3mqubebuild.azurecr.io/docker-io/oven/bun:1.3.14-alpine

# Patch openssl for CVE-2026-45447 (heap use-after-free in PKCS7_verify)
RUN apk update && apk add --no-cache 'libssl3>=3.5.7-r0' 'libcrypto3>=3.5.7-r0'

CMD ["sh"]