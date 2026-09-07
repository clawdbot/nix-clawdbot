#!/bin/sh
# Prove the gateway npm wrapper package-lock.json is closed under runtime
# dependency resolution before anything consumes it. `npm ci` does not validate
# nested edges: when the lock is missing or mis-resolves a transitive package,
# npm silently tries to fetch it from the registry, which surfaces later as an
# opaque ENOTCACHED inside the Nix sandbox. `npm ls --package-lock-only` walks
# the locked tree offline with npm's own resolver and fails on missing or
# invalid edges, so the same flags used for `npm ci` are used here.
set -eu

wrapper_dir="${OPENCLAW_NPM_WRAPPER_DIR:-$PWD}"
lock_file="$wrapper_dir/package-lock.json"

if [ ! -f "$wrapper_dir/package.json" ] || [ ! -f "$lock_file" ]; then
  echo "npm wrapper package.json or package-lock.json missing in $wrapper_dir" >&2
  exit 1
fi
if ! command -v npm >/dev/null 2>&1; then
  echo "npm is required to validate $lock_file" >&2
  exit 1
fi

scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT

# Isolate npm from the caller's home, cache, and network; nothing here may
# resolve against a live registry.
HOME="$scratch/home"
export HOME
mkdir -p "$HOME"
export npm_config_cache="$scratch/cache"
export npm_config_offline="true"
export npm_config_update_notifier="false"
export npm_config_fund="false"
export npm_config_audit="false"
export npm_config_progress="false"

echo "openclaw npm wrapper lock: validating $lock_file"
if ! (cd "$wrapper_dir" && npm ls --package-lock-only --omit=dev --legacy-peer-deps --all >"$scratch/npm-ls.log" 2>&1); then
  grep -E 'npm (ERR!|error)|missing:|invalid:|UNMET DEPENDENCY' "$scratch/npm-ls.log" >&2 || tail -n 40 "$scratch/npm-ls.log" >&2
  echo "npm wrapper package-lock.json does not resolve every runtime dependency: $lock_file" >&2
  echo "Regenerate it from scratch with scripts/update-pins.sh; never update the stale lock in place." >&2
  exit 1
fi
echo "openclaw npm wrapper lock: ok"
