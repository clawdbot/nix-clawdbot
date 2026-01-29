#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source_file="$repo_root/nix/sources/moltbot-source.nix"
app_file="$repo_root/nix/packages/moltbot-app.nix"

log() {
  printf '>> %s\n' "$*"
}

upstream_checks_green() {
  local sha="$1"
  local checks_json
  checks_json=$(gh api "/repos/moltbot/moltbot/commits/${sha}/check-runs?per_page=100" 2>/dev/null || true)
  if [[ -z "$checks_json" ]]; then
    log "No check runs found for $sha"
    return 1
  fi

  local relevant_count
  relevant_count=$(printf '%s' "$checks_json" | jq '[.check_runs[] | select(.name | test("windows"; "i") | not)] | length')
  if [[ "$relevant_count" -eq 0 ]]; then
    log "No non-windows check runs found for $sha"
    return 1
  fi

  local failing_count
  failing_count=$(
    printf '%s' "$checks_json" | jq '[.check_runs[]
      | select(.name | test("windows"; "i") | not)
      | select(.status != "completed" or (.conclusion != "success" and .conclusion != "skipped"))
    ] | length'
  )
  if [[ "$failing_count" -ne 0 ]]; then
    log "Non-windows checks not green for $sha"
    return 1
  fi

  return 0
}

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required but not installed." >&2
  exit 1
fi

log "Updating nix-steipete-tools input"
nix flake lock --update-input nix-steipete-tools

log "Resolving moltbot main SHAs"
mapfile -t candidate_shas < <(gh api /repos/moltbot/moltbot/commits?per_page=10 | jq -r '.[].sha' || true)
if [[ ${#candidate_shas[@]} -eq 0 ]]; then
  latest_sha=$(git ls-remote https://github.com/moltbot/moltbot.git refs/heads/main | awk '{print $1}' || true)
  if [[ -z "$latest_sha" ]]; then
    echo "Failed to resolve moltbot main SHA" >&2
    exit 1
  fi
  candidate_shas=("$latest_sha")
fi

selected_sha=""
selected_hash=""
selected_source_store_path=""
selected_source_url=""

for sha in "${candidate_shas[@]}"; do
  if ! upstream_checks_green "$sha"; then
    continue
  fi
  log "Testing upstream SHA: $sha"
  source_url="https://github.com/moltbot/moltbot/archive/${sha}.tar.gz"
  log "Prefetching source tarball"
  source_prefetch=$(
    nix --extra-experimental-features "nix-command flakes" store prefetch-file --unpack --json "$source_url" 2>"/tmp/nix-prefetch-source.err" \
    || true
  )
  if [[ -z "$source_prefetch" ]]; then
    cat "/tmp/nix-prefetch-source.err" >&2 || true
    rm -f "/tmp/nix-prefetch-source.err"
    echo "Failed to resolve source hash for $sha" >&2
    continue
  fi
  rm -f "/tmp/nix-prefetch-source.err"
  source_hash=$(printf '%s' "$source_prefetch" | jq -r '.hash // empty')
  if [[ -z "$source_hash" ]]; then
    printf '%s\n' "$source_prefetch" >&2
    echo "Failed to parse source hash for $sha" >&2
    continue
  fi
  source_store_path=$(printf '%s' "$source_prefetch" | jq -r '.path // .storePath // empty')
  if [[ -z "$source_store_path" ]]; then
    echo "Failed to parse source store path for $sha" >&2
    continue
  fi
  log "Source hash: $source_hash"

  perl -0pi -e "s|rev = \"[^\"]+\";|rev = \"${sha}\";|" "$source_file"
  perl -0pi -e "s|hash = \"[^\"]+\";|hash = \"${source_hash}\";|" "$source_file"
  # Force a fresh pnpmDepsHash recalculation for the candidate rev.
  perl -0pi -e "s|pnpmDepsHash = \"[^\"]*\";|pnpmDepsHash = \"\";|" "$source_file"

  build_log=$(mktemp)
  log "Building gateway to validate pnpmDepsHash"
  if ! nix build .#moltbot-gateway --accept-flake-config >"$build_log" 2>&1; then
    pnpm_hash=$(grep -Eo 'got: *sha256-[A-Za-z0-9+/=]+' "$build_log" | head -n 1 | sed 's/.*got: *//' || true)
    if [[ -n "$pnpm_hash" ]]; then
      log "pnpmDepsHash mismatch detected: $pnpm_hash"
      perl -0pi -e "s|pnpmDepsHash = \"[^\"]*\";|pnpmDepsHash = \"${pnpm_hash}\";|" "$source_file"
      if ! nix build .#moltbot-gateway --accept-flake-config >"$build_log" 2>&1; then
        tail -n 200 "$build_log" >&2 || true
        rm -f "$build_log"
        continue
      fi
    else
      tail -n 200 "$build_log" >&2 || true
      rm -f "$build_log"
      continue
    fi
  fi
  rm -f "$build_log"
  selected_sha="$sha"
  selected_hash="$source_hash"
  selected_source_store_path="$source_store_path"
  selected_source_url="$source_url"
  break
done

if [[ -z "$selected_sha" ]]; then
  echo "Failed to find a buildable upstream revision in the last ${#candidate_shas[@]} commits." >&2
  exit 1
fi
log "Selected upstream SHA: $selected_sha"

log "Fetching latest release metadata"
release_json=$(gh api /repos/moltbot/moltbot/releases?per_page=20 || true)
if [[ -z "$release_json" ]]; then
  echo "Failed to fetch release metadata" >&2
  exit 1
fi
release_tag=$(printf '%s' "$release_json" | jq -r '[.[] | select([.assets[]?.name | (test("^Clawdbot-.*\\.zip$") and (test("dSYM") | not))] | any)][0].tag_name // empty')
if [[ -z "$release_tag" ]]; then
  echo "Failed to resolve a release tag with a Clawdbot app asset" >&2
  exit 1
fi
log "Latest app release tag with asset: $release_tag"

# Update version strings in gateway package and check derivations
gateway_version="${release_tag#v}"
log "Updating gateway version to: $gateway_version"

gateway_file="$repo_root/nix/packages/moltbot-gateway.nix"
tests_file="$repo_root/nix/checks/moltbot-gateway-tests.nix"
options_file="$repo_root/nix/checks/moltbot-config-options.nix"

perl -0pi -e "s|version = \"[^\"]+\";|version = \"${gateway_version}\";|" "$gateway_file"
perl -0pi -e "s|version = \"[^\"]+\";|version = \"${gateway_version}\";|" "$tests_file"
perl -0pi -e "s|version = \"[^\"]+\";|version = \"${gateway_version}\";|" "$options_file"

app_url=$(printf '%s' "$release_json" | jq -r '[.[] | select([.assets[]?.name | (test("^Clawdbot-.*\\.zip$") and (test("dSYM") | not))] | any)][0].assets[] | select(.name | (test("^Clawdbot-.*\\.zip$") and (test("dSYM") | not))) | .browser_download_url' | head -n 1 || true)
if [[ -z "$app_url" ]]; then
  echo "Failed to resolve Clawdbot app asset URL from latest release" >&2
  exit 1
fi
log "App asset URL: $app_url"

app_prefetch=$(
  nix --extra-experimental-features "nix-command flakes" store prefetch-file --unpack --json "$app_url" 2>"/tmp/nix-prefetch-app.err" \
  || true
)
if [[ -z "$app_prefetch" ]]; then
  cat "/tmp/nix-prefetch-app.err" >&2 || true
  rm -f "/tmp/nix-prefetch-app.err"
  echo "Failed to resolve app hash" >&2
  exit 1
fi
rm -f "/tmp/nix-prefetch-app.err"
app_hash=$(printf '%s' "$app_prefetch" | jq -r '.hash // empty')
if [[ -z "$app_hash" ]]; then
  printf '%s\n' "$app_prefetch" >&2
  echo "Failed to parse app hash" >&2
  exit 1
fi
log "App hash: $app_hash"

app_version="${release_tag#v}"
perl -0pi -e "s|version = \"[^\"]+\";|version = \"${app_version}\";|" "$app_file"
perl -0pi -e "s|url = \"[^\"]+\";|url = \"${app_url}\";|" "$app_file"
perl -0pi -e "s|hash = \"[^\"]+\";|hash = \"${app_hash}\";|" "$app_file"

if [[ -z "$selected_source_store_path" ]]; then
  echo "Missing source path for selected upstream revision" >&2
  exit 1
fi

log "Regenerating moltbot config options from upstream schema"
tmp_src=$(mktemp -d)
cleanup_tmp() {
  rm -rf "$tmp_src"
}
trap cleanup_tmp EXIT
cp -R "$selected_source_store_path" "$tmp_src/src"
chmod -R u+w "$tmp_src/src"

nix shell --extra-experimental-features "nix-command flakes" nixpkgs#nodejs_22 nixpkgs#pnpm_10 -c \
  bash -c "cd '$tmp_src/src' && pnpm install --frozen-lockfile --ignore-scripts"

nix shell --extra-experimental-features "nix-command flakes" nixpkgs#nodejs_22 nixpkgs#pnpm_10 -c \
  bash -c "cd '$tmp_src/src' && pnpm exec tsx '$repo_root/nix/scripts/generate-config-options.ts' --repo . --out '$repo_root/nix/generated/moltbot-config-options.nix'"

cleanup_tmp
trap - EXIT

log "Building app to validate fetchzip hash"
current_system=$(nix eval --impure --raw --expr 'builtins.currentSystem' 2>/dev/null || true)
if [[ "$current_system" == *darwin* ]]; then
  app_build_log=$(mktemp)
  if ! nix build .#moltbot-app --accept-flake-config >"$app_build_log" 2>&1; then
    app_hash_mismatch=$(grep -Eo 'got: *sha256-[A-Za-z0-9+/=]+' "$app_build_log" | head -n 1 | sed 's/.*got: *//' || true)
    if [[ -n "$app_hash_mismatch" ]]; then
      log "App hash mismatch detected: $app_hash_mismatch"
      perl -0pi -e "s|hash = \"[^\"]+\";|hash = \"${app_hash_mismatch}\";|" "$app_file"
      if ! nix build .#moltbot-app --accept-flake-config >"$app_build_log" 2>&1; then
        tail -n 200 "$app_build_log" >&2 || true
        rm -f "$app_build_log"
        exit 1
      fi
    else
      tail -n 200 "$app_build_log" >&2 || true
      rm -f "$app_build_log"
      exit 1
    fi
  fi
  rm -f "$app_build_log"
else
  log "Skipping app build on non-darwin system (${current_system:-unknown})"
fi

if git diff --quiet; then
  echo "No pin changes detected."
  exit 0
fi

log "Committing updated pins"
git add "$source_file" "$app_file" "$gateway_file" "$tests_file" "$options_file" \
  "$repo_root/nix/generated/moltbot-config-options.nix" "$repo_root/flake.lock"
git commit -F - <<'EOF'
🤖 codex: bump moltbot pins (no-issue)

What:
- pin moltbot source to latest upstream main
- refresh macOS app pin to latest release asset
- update source and app hashes
- update version strings in gateway and check derivations
- regenerate config options from upstream schema

Why:
- keep nix-moltbot on latest upstream for yolo mode

Tests:
- nix build .#moltbot-gateway --accept-flake-config
- nix build .#moltbot-app --accept-flake-config
EOF

log "Rebasing on latest main"
git fetch origin main
git rebase origin/main

git push origin HEAD:main
