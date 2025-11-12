# -------------------------
# builder: compile bootnode + a tiny hex->raw helper
# -------------------------
FROM golang:1.22-alpine AS builder
ARG GETH_VER=v1.14.12

RUN apk add --no-cache git
RUN go install github.com/ethereum/go-ethereum/cmd/bootnode@${GETH_VER}

# build a tiny helper that writes raw 32 bytes from a hex string to stdout
RUN cat > /tmp/hex2raw.go <<'EOF' && \
    go build -o /hex2raw /tmp/hex2raw.go
package main
import (
	"encoding/hex"
	"fmt"
	"os"
)
func main() {
	if len(os.Args) != 2 {
		fmt.Fprintln(os.Stderr, "usage: hex2raw <64-hex-chars>"); os.Exit(2)
	}
	b, err := hex.DecodeString(os.Args[1])
	if err != nil || len(b) != 32 {
		fmt.Fprintln(os.Stderr, "invalid hex (need 32 bytes/64 hex chars)"); os.Exit(2)
	}
	os.Stdout.Write(b)
}
EOF

# -------------------------
# final image: minimal Alpine, non-root, no package installs at runtime
# -------------------------
FROM alpine:3.20

# Create non-root user
RUN addgroup -S app && adduser -S -G app app

# Copy binaries
COPY --from=builder /go/bin/bootnode /usr/local/bin/bootnode
COPY --from=builder /hex2raw            /usr/local/bin/hex2raw

# tiny entrypoint that chooses nodekey source and runs bootnode
COPY --chown=app:app <<'EOF' /usr/local/bin/run.sh
#!/bin/sh
set -eu

mkdir -p /data
# priority: mounted secret > env var
if [ -f /secrets/nodekey ]; then
  cp /secrets/nodekey /data/nodekey
elif [ -n "${NODEKEY_HEX:-}" ]; then
  hex2raw "$NODEKEY_HEX" > /data/nodekey
else
  echo "ERROR: provide /secrets/nodekey (raw 32 bytes) or NODEKEY_HEX env" >&2
  exit 1
fi

PUB=$(bootnode -nodekey /data/nodekey -writeaddress)
PORT="${BOOTNODE_PORT:-30301}"
IP="${POD_IP:-0.0.0.0}"

echo "BOOTNODE_ENODE=enode://${PUB}@${IP}:${PORT}"
exec bootnode -nodekey /data/nodekey -addr ":${PORT}"
EOF

RUN chmod +x /usr/local/bin/run.sh && \
    mkdir -p /secrets /data && chown -R app:app /secrets /data

USER app
EXPOSE 30301/udp
ENTRYPOINT ["/usr/local/bin/run.sh"]

