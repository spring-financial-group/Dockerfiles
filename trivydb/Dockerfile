FROM ubuntu:20.04 as builder
WORKDIR /source
COPY ./downloader.sh .
RUN apt update && apt install -y wget curl && bash downloader.sh


FROM alpine:latest
WORKDIR /trivydb/
COPY --from=builder /source/trivy.db .
COPY --from=builder /source/metadata.json .
CMD ["sh"]