#!/bin/sh
set -e
mkdir -p "$out/lib/openclaw" "$out/bin"

cp -r dist node_modules package.json ui extensions docs "$out/lib/openclaw/"

if [ -z "${STDENV_SETUP:-}" ]; then
  echo "STDENV_SETUP is not set" >&2
  exit 1
fi
if [ ! -f "$STDENV_SETUP" ]; then
  echo "STDENV_SETUP not found: $STDENV_SETUP" >&2
  exit 1
fi

bash -e -c '. "$STDENV_SETUP"; patchShebangs "$out/lib/openclaw/node_modules/.bin"'
if [ -d "$out/lib/openclaw/ui/node_modules/.bin" ]; then
  bash -e -c '. "$STDENV_SETUP"; patchShebangs "$out/lib/openclaw/ui/node_modules/.bin"'
fi

# Work around missing dependency declaration in pi-coding-agent (strip-ansi).
# Ensure it is resolvable at runtime without changing upstream.
pi_pkg="$(find "$out/lib/openclaw/node_modules/.pnpm" -path "*/node_modules/@mariozechner/pi-coding-agent" -print | head -n 1)"
strip_ansi_src="$(find "$out/lib/openclaw/node_modules/.pnpm" -path "*/node_modules/strip-ansi" -print | head -n 1)"

if [ -n "$strip_ansi_src" ]; then
  if [ -n "$pi_pkg" ] && [ ! -e "$pi_pkg/node_modules/strip-ansi" ]; then
    mkdir -p "$pi_pkg/node_modules"
    ln -s "$strip_ansi_src" "$pi_pkg/node_modules/strip-ansi"
  fi

  if [ ! -e "$out/lib/openclaw/node_modules/strip-ansi" ]; then
    mkdir -p "$out/lib/openclaw/node_modules"
    ln -s "$strip_ansi_src" "$out/lib/openclaw/node_modules/strip-ansi"
  fi
fi
bash -e -c '. "$STDENV_SETUP"; makeWrapper "$NODE_BIN" "$out/bin/openclaw" --add-flags "$out/lib/openclaw/dist/index.js" --set-default MOLTBOT_NIX_MODE "1" --set-default CLAWDBOT_NIX_MODE "1"'
ln -s "$out/bin/openclaw" "$out/bin/moltbot"
