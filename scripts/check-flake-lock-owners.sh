#!/usr/bin/env bash
set -euo pipefail

lock_file=${1:-flake.lock}
allow_file=${2:-scripts/allowed-flake-lock-owners.txt}

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required but not installed" >&2
  exit 1
fi

if [[ ! -f "$lock_file" ]]; then
  echo "flake.lock not found: $lock_file" >&2
  exit 1
fi

if [[ ! -f "$allow_file" ]]; then
  echo "allowlist not found: $allow_file" >&2
  exit 1
fi

mapfile -t allowed < <(
  sed -e 's/#.*$//' -e 's/[[:space:]]*$//' -e 's/^[[:space:]]*//' "$allow_file" | awk 'NF' | sort -u
)

if [[ ${#allowed[@]} -eq 0 ]]; then
  echo "allowlist is empty: $allow_file" >&2
  exit 1
fi

mapfile -t owners < <(
  jq -r '.nodes[].locked | select(.type == "github") | "\(.owner)/\(.repo)"' "$lock_file" | sort -u
)

unknown=()
for owner in "${owners[@]}"; do
  if ! printf '%s\n' "${allowed[@]}" | grep -Fxq "$owner"; then
    unknown+=("$owner")
  fi
done

if [[ ${#unknown[@]} -ne 0 ]]; then
  echo "Unexpected GitHub inputs found in $lock_file:" >&2
  printf '  - %s\n' "${unknown[@]}" >&2
  exit 1
fi

echo "OK: flake.lock GitHub owners are allowlisted"
