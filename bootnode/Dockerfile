# ---- builder: compile bootnode + hex2raw ----
FROM golang:1.22-alpine AS builder
ARG GETH_VER=v1.14.12

RUN apk add --no-cache git
RUN go install github.com/ethereum/go-ethereum/cmd/bootnode@${GETH_VER}

# build tiny helper to turn 64-hex -> raw 32 bytes
RUN printf '%s\n' \
  'package main' \
  '' \
  'import (' \
  '  "encoding/hex"' \
  '  "fmt"' \
  '  "os"' \
  ')' \
  '' \
  'func main() {' \
  '  if len(os.Args) != 2 {' \
  '    fmt.Fprintln(os.Stderr, "usage: hex2raw <64-hex-chars>"); os.Exit(2)' \
  '  }' \
  '  b, err := hex.DecodeString(os.Args[1])' \
  '  if err != nil || len(b) != 32 {' \
  '    fmt.Fprintln(os.Stderr, "invalid hex (need 32 bytes/64 hex chars)"); os.Exit(2)' \
  '  }' \
  '  os.Stdout.Write(b)' \
  '}' \
  > /tmp/hex2raw.go \
 && go build -o /hex2raw /tmp/hex2raw.go

# ---- final: minimal, non-root, no apk/go at runtime ----
FROM alpine:3.20

# non-root user
RUN addgroup -S app && adduser -S -G app app

# copy binaries from builder
COPY --from=builder /go/bin/bootnode /usr/local/bin/bootnode
COPY --from=builder /hex2raw            /usr/local/bin/hex2raw

# copy entrypoint script from context
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh && \
    mkdir -p /secrets /data && chown -R app:app /secrets /data

USER app
EXPOSE 30301/udp
ENTRYPOINT ["/usr/local/bin/run.sh"]

