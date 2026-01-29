#!/bin/sh
set -e

store_path_file="${PNPM_STORE_PATH_FILE:-.pnpm-store-path}"
if [ -f "$store_path_file" ]; then
  store_path="$(cat "$store_path_file")"
  export PNPM_STORE_DIR="$store_path"
  export PNPM_STORE_PATH="$store_path"
  export NPM_CONFIG_STORE_DIR="$store_path"
  export NPM_CONFIG_STORE_PATH="$store_path"
fi
export HOME="$(mktemp -d)"
export TMPDIR="${HOME}/tmp"
mkdir -p "$TMPDIR"
export MOLTBOT_LOG_DIR="${TMPDIR}/moltbot-logs"
export MOLTBOT_LOG_PATH="${MOLTBOT_LOG_DIR}/moltbot-gateway.log"
mkdir -p "$MOLTBOT_LOG_DIR"
mkdir -p /tmp/moltbot || true
chmod 700 /tmp/moltbot || true
export VITEST_POOL="threads"
export VITEST_MIN_THREADS="1"
export VITEST_MAX_THREADS="1"
export VITEST_MIN_WORKERS="1"
export VITEST_MAX_WORKERS="1"

pnpm vitest run --config vitest.unit.config.ts --testTimeout=20000
pnpm vitest run --config vitest.gateway.config.ts --testTimeout=20000
