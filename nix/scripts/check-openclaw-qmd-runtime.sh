#!/bin/sh
set -eu

if [ -z "${OPENCLAW_PACKAGE:-}" ]; then
  echo "OPENCLAW_PACKAGE is not set" >&2
  exit 1
fi
if [ -z "${QMD_PACKAGE:-}" ]; then
  echo "QMD_PACKAGE is not set" >&2
  exit 1
fi

openclaw_bin="${OPENCLAW_PACKAGE}/bin/openclaw"
qmd_bin="${QMD_PACKAGE}/bin/qmd"

if [ ! -x "$openclaw_bin" ]; then
  echo "Missing executable: $openclaw_bin" >&2
  exit 1
fi
if [ ! -x "$qmd_bin" ]; then
  echo "Missing executable: $qmd_bin" >&2
  exit 1
fi

if ! "$qmd_bin" --version >/dev/null; then
  echo "qmd --version failed" >&2
  exit 1
fi

if ! grep -q "OPENCLAW_PINNED_WRITE_PYTHON" "$openclaw_bin"; then
  echo "openclaw wrapper does not pin a Nix Python for safe writes" >&2
  exit 1
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/home" "$tmp_dir/state" "$tmp_dir/config" "$tmp_dir/cache" "$tmp_dir/data" "$tmp_dir/logs"
mkdir -p "$tmp_dir/notes"
run_qmd() {
  env HOME="$tmp_dir/home" XDG_CONFIG_HOME="$tmp_dir/config" \
    XDG_CACHE_HOME="$tmp_dir/cache" XDG_DATA_HOME="$tmp_dir/data" \
    NO_COLOR=1 "$qmd_bin" "$@"
}
printf '# Packaging probe\nInitial document.\n' > "$tmp_dir/notes/proof.md"
run_qmd collection add "$tmp_dir/notes" --name nix-smoke >/dev/null
printf '# Packaging probe\nNixqmdproof verifies updated document retrieval.\n' > "$tmp_dir/notes/proof.md"
run_qmd update >/dev/null
run_qmd search nixqmdproof -c nix-smoke --json > "$tmp_dir/search.json"
if ! grep -Fq 'qmd://nix-smoke/proof.md' "$tmp_dir/search.json"; then
  echo "QMD did not retrieve the updated synthetic document" >&2
  cat "$tmp_dir/search.json" >&2
  exit 1
fi

cat > "$tmp_dir/state/openclaw.json" <<'JSON'
{
  "gateway": {
    "mode": "local"
  },
  "memory": {
    "backend": "qmd"
  }
}
JSON

env \
  HOME="$tmp_dir/home" \
  XDG_CONFIG_HOME="$tmp_dir/config" \
  XDG_CACHE_HOME="$tmp_dir/cache" \
  XDG_DATA_HOME="$tmp_dir/data" \
  OPENCLAW_CONFIG_PATH="$tmp_dir/state/openclaw.json" \
  OPENCLAW_STATE_DIR="$tmp_dir/state" \
  OPENCLAW_LOG_DIR="$tmp_dir/logs" \
  OPENCLAW_NIX_MODE=1 \
  PATH="${QMD_PACKAGE}/bin:$PATH" \
  NO_COLOR=1 \
  "$openclaw_bin" config validate --json >/dev/null

backend="$(
  env \
    HOME="$tmp_dir/home" \
    XDG_CONFIG_HOME="$tmp_dir/config" \
    XDG_CACHE_HOME="$tmp_dir/cache" \
    XDG_DATA_HOME="$tmp_dir/data" \
    OPENCLAW_CONFIG_PATH="$tmp_dir/state/openclaw.json" \
    OPENCLAW_STATE_DIR="$tmp_dir/state" \
    OPENCLAW_LOG_DIR="$tmp_dir/logs" \
    OPENCLAW_NIX_MODE=1 \
    PATH="${QMD_PACKAGE}/bin:$PATH" \
    NO_COLOR=1 \
    "$openclaw_bin" config get memory.backend --json
)"

if [ "$backend" != '"qmd"' ]; then
  echo "OpenClaw did not read opt-in QMD memory config: $backend" >&2
  exit 1
fi

echo "openclaw qmd runtime: ok"
