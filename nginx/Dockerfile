FROM nginx:stable-alpine


RUN apk update
RUN apk add --upgrade libxml2
RUN apk add --upgrade libcrypto1.1
RUN apk add --upgrade libssl1.1
RUN apk add --upgrade libxslt

# security issue 'CVE-2022-22576'
RUN apk add --upgrade curl
RUN apk add --upgrade libcurl

# security issue 'CVE-2022-27404'
RUN apk add --upgrade freetype

# security issue 'CVE-2022-1586'
RUN apk add --upgrade pcre2

RUN apk add --upgrade libx11
RUN apk add --upgrade tiff

CMD ["bash"]
