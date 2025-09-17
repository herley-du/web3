#!/usr/bin/env bash
set -euo pipefail

RPC_URL=${RPC_URL:-http://127.0.0.1:8545}
PRIVATE_KEY=${PRIVATE_KEY:-}
if [ -z "$PRIVATE_KEY" ]; then
  echo "Error: please export PRIVATE_KEY in your shell (export PRIVATE_KEY=0x...)"
  exit 1
fi

echo "Deploying MyToken to $RPC_URL ..."
forge create src/MyToken.sol:MyToken --rpc-url "$RPC_URL" --private-key "$PRIVATE_KEY" --constructor-args 1000000000000000000000 --broadcast -vv
