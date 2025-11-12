#!/bin/sh
set -eu

STATE_DIR=${STATE_DIR:-/data}
mkdir -p "$STATE_DIR"

if [ -f /secrets/nodekey ]; then
  # raw 32 bytes
  cp /secrets/nodekey "$STATE_DIR/nodekey"
elif [ -f /secrets/nodekey-hex ]; then
  # 64 hex chars -> raw
  HEX="$(tr -d '\n\r' </secrets/nodekey-hex)"
  hex2raw "$HEX" > "$STATE_DIR/nodekey"
elif [ -n "${NODEKEY_HEX:-}" ]; then
  # env hex fallback
  hex2raw "$NODEKEY_HEX" > "$STATE_DIR/nodekey"
else
  echo "ERROR: provide /secrets/nodekey (raw 32 bytes), /secrets/nodekey-hex (64 hex), or NODEKEY_HEX env" >&2
  exit 1
fi

PUB=$(bootnode -nodekeyfile "$STATE_DIR/nodekey" -writeaddress)
PORT="${BOOTNODE_PORT:-30301}"
IP="${POD_IP:-0.0.0.0}"

echo "BOOTNODE_ENODE=enode://${PUB}@${IP}:${PORT}"
exec bootnode -nodekeyfile "$STATE_DIR/nodekey" -addr ":${PORT}"

