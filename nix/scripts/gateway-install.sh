#!/bin/sh
set -e
mkdir -p "$out/lib/moltbot" "$out/bin"

# Copy core files and bundled extensions (memory-core, etc.)
cp -r dist node_modules package.json ui "$out/lib/moltbot/"
# Copy docs (includes workspace templates like AGENTS.md)
if [ -d "docs" ]; then
  cp -r docs "$out/lib/moltbot/"
fi
if [ -d "extensions" ]; then
  cp -r extensions "$out/lib/moltbot/"
fi

if [ -z "${STDENV_SETUP:-}" ]; then
  echo "STDENV_SETUP is not set" >&2
  exit 1
fi
if [ ! -f "$STDENV_SETUP" ]; then
  echo "STDENV_SETUP not found: $STDENV_SETUP" >&2
  exit 1
fi

bash -e -c '. "$STDENV_SETUP"; patchShebangs "$out/lib/moltbot/node_modules/.bin"'
if [ -d "$out/lib/moltbot/ui/node_modules/.bin" ]; then
  bash -e -c '. "$STDENV_SETUP"; patchShebangs "$out/lib/moltbot/ui/node_modules/.bin"'
fi
# Patch shebangs in extensions node_modules if present
if [ -d "$out/lib/moltbot/extensions" ]; then
  for ext_bin in "$out/lib/moltbot/extensions"/*/node_modules/.bin; do
    if [ -d "$ext_bin" ]; then
      bash -e -c '. "$STDENV_SETUP"; patchShebangs "'"$ext_bin"'"'
    fi
  done
fi

# Work around missing dependency declaration in pi-coding-agent (strip-ansi).
# Ensure it is resolvable at runtime without changing upstream.
pi_pkg="$(find "$out/lib/moltbot/node_modules/.pnpm" -path "*/node_modules/@mariozechner/pi-coding-agent" -print | head -n 1)"
strip_ansi_src="$(find "$out/lib/moltbot/node_modules/.pnpm" -path "*/node_modules/strip-ansi" -print | head -n 1)"

if [ -n "$strip_ansi_src" ]; then
  if [ -n "$pi_pkg" ] && [ ! -e "$pi_pkg/node_modules/strip-ansi" ]; then
    mkdir -p "$pi_pkg/node_modules"
    ln -s "$strip_ansi_src" "$pi_pkg/node_modules/strip-ansi"
  fi

  if [ ! -e "$out/lib/moltbot/node_modules/strip-ansi" ]; then
    mkdir -p "$out/lib/moltbot/node_modules"
    ln -s "$strip_ansi_src" "$out/lib/moltbot/node_modules/strip-ansi"
  fi
fi
bash -e -c '. "$STDENV_SETUP"; makeWrapper "$NODE_BIN" "$out/bin/moltbot" --add-flags "$out/lib/moltbot/dist/index.js" --set-default MOLTBOT_NIX_MODE "1" --set-default CLAWDBOT_NIX_MODE "1"'
