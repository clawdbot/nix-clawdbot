#!/bin/sh
# Prove the gateway npm wrapper package-lock.json can be consumed without the
# registry before anything builds from it. `npm ci` does not validate nested
# edges: when the lock mis-resolves or lacks a transitive package (an in-place
# update of the previous release's lock leaves e.g. a stale nested p-limit@2 as
# the target of a new openclaw -> p-limit@^7 edge), npm silently re-resolves it
# against the registry, which surfaces later as an opaque ENOTCACHED inside the
# Nix sandbox. Running the same resolver offline against an empty cache, in a
# scratch copy, fails on exactly those edges while still accepting subtrees that
# upstream pins through npm-shrinkwrap.json (which npm never re-resolves). The
# scratch lock must also come back byte-identical: `npm ci` consumes the
# committed lock as-is, so a lock npm silently repairs offline is not proven.
set -eu

# As a stdenv postUnpack hook the cwd is still the build root; stdenv exposes
# the unpacked wrapper source as $sourceRoot before the hook runs.
wrapper_dir="${OPENCLAW_NPM_WRAPPER_DIR:-${sourceRoot:-$PWD}}"
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
# resolve against a live registry, and the real wrapper directory stays untouched.
mkdir -p "$scratch/home" "$scratch/work"
cp "$wrapper_dir/package.json" "$lock_file" "$scratch/work/"
HOME="$scratch/home"
export HOME
export npm_config_cache="$scratch/cache"
export npm_config_offline="true"
export npm_config_update_notifier="false"
export npm_config_fund="false"
export npm_config_audit="false"
export npm_config_progress="false"

echo "openclaw npm wrapper lock: validating $lock_file"
if ! (cd "$scratch/work" && npm install --package-lock-only --ignore-scripts --omit=dev --legacy-peer-deps >"$scratch/npm.log" 2>&1); then
  grep -E 'npm (ERR!|error)' "$scratch/npm.log" >&2 || tail -n 40 "$scratch/npm.log" >&2
  echo "npm wrapper package-lock.json cannot be resolved offline; a dependency edge is missing or mis-resolved: $lock_file" >&2
  echo "Regenerate it from scratch with scripts/update-pins.sh; never update the stale lock in place." >&2
  exit 1
fi
# A lock npm has to repair offline (for example a root entry that drifted from
# package.json) is not the lock `npm ci` will consume, so a rewrite fails too.
if ! cmp -s "$lock_file" "$scratch/work/package-lock.json"; then
  echo "npm rewrote the wrapper package-lock.json offline; the committed lock is not npm's settled tree: $lock_file" >&2
  echo "Regenerate it from scratch with scripts/update-pins.sh; never update the stale lock in place." >&2
  exit 1
fi
echo "openclaw npm wrapper lock: ok"
