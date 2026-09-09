#!/usr/bin/env bash
set -euo pipefail

phase=inputs
blocked() {
  local status=$?
  echo "BLOCKED installed-upgrade phase=$phase status=$status; no fallback" >&2
  exit "$status"
}
trap blocked ERR
repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
fixture="$repo_root/nix/tests/installed-baseline/default.nix"
system="${1:?Usage: qualify-installed-baseline.sh <x86_64-linux|aarch64-darwin>}"
case "$system:$(uname -s):$(uname -m)" in
  x86_64-linux:Linux:x86_64) target=linux ;;
  aarch64-darwin:Darwin:arm64) target=inputs ;;
  *) echo "Unsupported qualification platform: $system" >&2; exit 1 ;;
esac
evidence_dir=$(mktemp -d "${RUNNER_TEMP:-${TMPDIR:-/tmp}}/installed-baseline.XXXXXX")
nix --version
git -C "$repo_root" rev-parse HEAD
# --file does not apply the imported flake's nixConfig. Read that immutable
# declaration before evaluating packages, then append exactly its cache settings.
nix eval --impure --json --file "$fixture" --argstr system "$system" cacheConfig >"$evidence_dir/cache.json"
cache_args=(
  --option extra-substituters "$(jq -er '[.[]."extra-substituters"[]] | unique | join(" ")' "$evidence_dir/cache.json")"
  --option extra-trusted-public-keys "$(jq -er '[.[]."extra-trusted-public-keys"[]] | unique | join(" ")' "$evidence_dir/cache.json")"
)
cat "$evidence_dir/cache.json"
nix eval "${cache_args[@]}" --impure --json --file "$fixture" --argstr system "$system" evidence >"$evidence_dir/inputs.json"
cat "$evidence_dir/inputs.json"
phase=build
bash "$repo_root/maintainers/scripts/ci-nix-build.sh" installed-baseline \
  "${cache_args[@]}" \
  --impure --file "$fixture" --argstr system "$system" "$target" \
  --out-link "$evidence_dir/result" --print-build-logs
if [[ "$target" == inputs ]]; then
  phase=installed-upgrade
  python3 -B "$repo_root/nix/tests/installed-baseline/probe.py" "$evidence_dir/result"
fi
echo "PASS installed-upgrade Node22 -> Node24 -> rollback; cleanup verified"
