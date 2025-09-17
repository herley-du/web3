#!/usr/bin/env bash
# verify.sh - 一键查询并格式化 MyToken 合约状态 (fixed for Git Bash)
set -euo pipefail

CONTRACT=${1:-0x5FbDB2315678afecb367f032d93F642f64180aa3}
SECONDARY=${2:-0x70997970C51812dc3A010C7d01b50e0d17dc79C8}
RPC_URL=${RPC_URL:-http://127.0.0.1:8545}

command -v cast >/dev/null 2>&1 || { echo "Error: cast not found. Install foundry/cast first."; exit 1; }
command -v node >/dev/null 2>&1 || { echo "Error: node not found. Install Node.js."; exit 1; }

echo "RPC URL: $RPC_URL"
echo "Contract: $CONTRACT"
echo "Querying..."

# strip leading zeros from a 0x-padded hex address into normal 0x... address
stripAddr() {
  local hx="$1"
  # remove 0x prefix, then leading zeros, then re-add 0x
  hx=$(printf "%s" "$hx" | sed -E 's/^0x//; s/^0+//')
  if [ -z "$hx" ]; then
    echo "0x0"
  else
    echo "0x$hx"
  fi
}

# convert hex BigInt (0x...) to decimal token string with 18 decimals using node
hexToToken() {
  local hx="$1"
  # ensure hx starts with 0x
  if [[ ! "$hx" =~ ^0x ]]; then hx="0x${hx}"; fi
  node -e "const v=BigInt('${hx}'); const base=10n**18n; const int=v/base; const frac=v%base; const fracS=frac.toString().padStart(18,'0'); console.log(int.toString()+'.'+fracS);"
}

# read fields
NAME=$(cast call "$CONTRACT" "name()" --rpc-url "$RPC_URL" 2>/dev/null || echo "N/A")
SYMBOL=$(cast call "$CONTRACT" "symbol()" --rpc-url "$RPC_URL" 2>/dev/null || echo "N/A")
DECIMALS_HEX=$(cast call "$CONTRACT" "decimals()" --rpc-url "$RPC_URL" 2>/dev/null || echo "0x0")
OWNER_HEX=$(cast call "$CONTRACT" "owner()" --rpc-url "$RPC_URL" 2>/dev/null || echo "0x0")
TS_HEX=$(cast call "$CONTRACT" "totalSupply()" --rpc-url "$RPC_URL" 2>/dev/null || echo "0x0")

# sanitize owner address and call balances
OWNER_ADDR=$(stripAddr "$OWNER_HEX")
BAL_OWNER_HEX=$(cast call "$CONTRACT" "balanceOf(address)" "$OWNER_ADDR" --rpc-url "$RPC_URL" 2>/dev/null || echo "0x0")
BAL_SECOND_HEX=$(cast call "$CONTRACT" "balanceOf(address)" "$SECONDARY" --rpc-url "$RPC_URL" 2>/dev/null || echo "0x0")

# convert decimals safely
DECIMALS=$(node -e "console.log(Number(BigInt('${DECIMALS_HEX:-0}')))" 2>/dev/null || echo "18")

TOTAL_SUPPLY_TOKEN=$(hexToToken "${TS_HEX:-0x0}")
BAL_OWNER_TOKEN=$(hexToToken "${BAL_OWNER_HEX:-0x0}")
BAL_SECOND_TOKEN=$(hexToToken "${BAL_SECOND_HEX:-0x0}")

echo "------------------------------"
echo "name:      $NAME"
echo "symbol:    $SYMBOL"
echo "decimals:  $DECIMALS"
echo "owner (raw):   $OWNER_HEX"
echo "owner:     $OWNER_ADDR"
echo "totalSupply (wei hex): $TS_HEX"
echo "totalSupply (token):   $TOTAL_SUPPLY_TOKEN"
echo "balanceOf(owner) (wei hex): $BAL_OWNER_HEX"
echo "balanceOf(owner) (token):   $BAL_OWNER_TOKEN"
echo "balanceOf($SECONDARY) (wei hex): $BAL_SECOND_HEX"
echo "balanceOf($SECONDARY) (token):   $BAL_SECOND_TOKEN"
echo "------------------------------"
