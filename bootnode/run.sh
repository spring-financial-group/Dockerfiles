#!/bin/sh
set -eu

mkdir -p /data
# Priority: mounted secret (/secrets/nodekey) > env var NODEKEY_HEX
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

