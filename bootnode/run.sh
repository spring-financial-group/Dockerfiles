#!/bin/sh
set -eu

STATE_DIR=${STATE_DIR:-/data}
mkdir -p "$STATE_DIR"

KEY_FLAG=""

if [ -f /secrets/nodekey ]; then
  # raw 32 bytes (preferred)
  cp /secrets/nodekey "$STATE_DIR/nodekey"
  KEY_FLAG="-nodekey $STATE_DIR/nodekey"
elif [ -f /secrets/nodekey-hex ]; then
  # 64 hex chars (no 0x)
  HEX="$(tr -d '\n\r' </secrets/nodekey-hex)"
  KEY_FLAG="-nodekeyhex $HEX"
elif [ -n "${NODEKEY_HEX:-}" ]; then
  # env fallback: 64 hex chars
  KEY_FLAG="-nodekeyhex $NODEKEY_HEX"
else
  echo "ERROR: provide /secrets/nodekey (raw 32 bytes), /secrets/nodekey-hex (64 hex), or NODEKEY_HEX env" >&2
  exit 1
fi

PORT="${BOOTNODE_PORT:-30301}"
IP="${POD_IP:-0.0.0.0}"

PUB=$(sh -c "bootnode $KEY_FLAG -writeaddress")
echo "BOOTNODE_ENODE=enode://${PUB}@${IP}:${PORT}"

exec sh -c "exec bootnode $KEY_FLAG -addr :${PORT}"

