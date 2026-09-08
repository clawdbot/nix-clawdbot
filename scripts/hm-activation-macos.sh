#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
test_dir="$repo_root/nix/tests/hm-activation-macos"
home_dir="/tmp/hm-activation-home"
label="com.steipete.openclaw.gateway.hm-test"
plist="$home_dir/Library/LaunchAgents/$label.plist"

cleanup() {
  if command -v launchctl >/dev/null 2>&1; then
    launchctl bootout "gui/$UID/$label" >/dev/null 2>&1 || true
    if [ -e "$plist" ]; then
      launchctl bootout "gui/$UID" "$plist" >/dev/null 2>&1 || true
    fi
  fi
}
trap cleanup EXIT

rm -rf "$home_dir"
mkdir -p "$home_dir"
cleanup

export HOME="$home_dir"
export USER="runner"
export LOGNAME="$USER"

activation_package="${OPENCLAW_HM_ACTIVATION_PACKAGE:-}"

if [ -n "$activation_package" ]; then
  if [ ! -x "$activation_package/activate" ]; then
    echo "OPENCLAW_HM_ACTIVATION_PACKAGE must point at a package with an activate script: $activation_package" >&2
    exit 1
  fi
else
  cd "$test_dir"
  nix build --accept-flake-config "$repo_root#checks.aarch64-darwin.hm-activation-macos-package"
  activation_package="$test_dir/result"
fi

test ! -e "$HOME/custom workspace"
"$activation_package/activate"

config_path="$HOME/openclaw state/config with spaces and 'quotes'.json"
test -f "$config_path"
test -L "$config_path"
test ! -e "$HOME/~"
grep -q '"workspace":"/tmp/hm-activation-home/custom workspace"' "$config_path"
test -f "$HOME/custom workspace/LORE.md"
test ! -L "$HOME/custom workspace/LORE.md"
test -f "$plist"
test -L "$HOME/openclaw state/agents/main/agent/codex-home/home/.nix-profile/bin"
test -x "$HOME/openclaw state/agents/main/agent/codex-home/home/.nix-profile/bin/jq"

jq_bin="$HOME/openclaw state/agents/main/agent/codex-home/home/.nix-profile/bin/jq"
implicit_root="$HOME/.openclaw-implicit"
roster_root="$HOME/.openclaw-roster"
if "$jq_bin" -e '.agents | has("entries")' "$roster_root/openclaw.json" >/dev/null; then
  "$jq_bin" -e '.agents.entries == {"Writer": {}, "research": {}, "_worker--": {}, "a--": {}}' "$roster_root/openclaw.json"
  "$jq_bin" -e '.agents.entries == {"main": {}}' "$config_path"
  "$jq_bin" -e '.agents == {"entries": {"main": {}}}' "$implicit_root/openclaw.json"
  expected_ids=(_worker a-- research writer)
else
  "$jq_bin" -e '.agents.list == [{"id": "writer"}, {"id": "research"}]' "$roster_root/openclaw.json"
  "$jq_bin" -e 'has("agents") | not' "$implicit_root/openclaw.json"
  expected_ids=(main research writer)
fi
test "$(ls -1 "$implicit_root/agents")" = main
test -L "$implicit_root/agents/main/agent/codex-home/home/.nix-profile/bin"
test -x "$implicit_root/agents/main/agent/codex-home/home/.nix-profile/bin/jq"
test "$(LC_ALL=C ls -1 "$roster_root/agents")" = "$(printf '%s\n' "${expected_ids[@]}")"
for agent_id in "${expected_ids[@]}"; do
  profile="$roster_root/agents/$agent_id/agent/codex-home/home/.nix-profile/bin"
  test -L "$profile"
  test -x "$profile/jq"
done

skill_root="$HOME/.local/share/nix-openclaw/skills/default"
for skill in activation-skill copied-skill; do
  test -f "$skill_root/$skill/SKILL.md"
done
test -z "$(find "$skill_root" -type l -print)"
test -z "$(find "$skill_root" -type f ! -links 1 -print)"
test -z "$(find "$skill_root" -type f ! -user "$(id -un)" -print)"

if command -v launchctl >/dev/null 2>&1; then
  test "$(/usr/libexec/PlistBuddy -c 'Print :WorkingDirectory' "$plist")" = "$HOME/openclaw state"
  test "$(/usr/libexec/PlistBuddy -c 'Print :EnvironmentVariables:OPENCLAW_STATE_DIR' "$plist")" = "$HOME/openclaw state"
  test "$(/usr/libexec/PlistBuddy -c 'Print :EnvironmentVariables:OPENCLAW_CONFIG_PATH' "$plist")" = "$config_path"
  state_file="$home_dir/launchd-state.txt"
  running=false
  for _ in {1..20}; do
    if launchctl print "gui/$UID/$label" >"$state_file" 2>&1 && grep -q "state = running" "$state_file"; then
      running=true
      break
    fi
    sleep 0.5
  done
  if [ "$running" != true ]; then
    cat "$state_file" >&2
    exit 1
  fi

  openclaw_bin=$(/usr/libexec/PlistBuddy -c "Print :ProgramArguments:0" "$plist")
  if [ "$openclaw_bin" = "/bin/sh" ]; then
    launcher_command=$(/usr/libexec/PlistBuddy -c "Print :ProgramArguments:2" "$plist")
    openclaw_bin=${launcher_command#*exec }
    openclaw_bin=${openclaw_bin%% gateway*}
  fi
  grep -q OPENCLAW_TEST_SECRET "$openclaw_bin"
  OPENCLAW_CONFIG_PATH="$config_path" \
    "$openclaw_bin" skills list --json > "$home_dir/skills.json"
  grep -Eq '"name"[[:space:]]*:[[:space:]]*"activation-skill"' "$home_dir/skills.json"
  grep -Eq '"name"[[:space:]]*:[[:space:]]*"skill"' "$home_dir/skills.json"
  health_file="$home_dir/gateway-health.json"
  healthy=false
  for _ in {1..30}; do
    if "$openclaw_bin" gateway health \
      --url "ws://127.0.0.1:18999" \
      --token "hm-activation-test-token" \
      --json \
      --timeout 3000 >"$health_file" 2>&1 \
      && grep -q '"ok"[[:space:]]*:[[:space:]]*true' "$health_file"; then
      healthy=true
      break
    fi
    sleep 0.5
  done
  if [ "$healthy" != true ]; then
    cat "$health_file" >&2
    exit 1
  fi
fi
