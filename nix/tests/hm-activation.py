import json
import shlex

start_all()

machine.wait_until_succeeds(
    "systemctl show -p Result home-manager-alice.service | grep -q '^Result=success$' && "
    "systemctl show -p SubState home-manager-alice.service | grep -Eq '^SubState=(dead|exited)$'"
)

config_path = shlex.quote("/home/alice/.openclaw/config with spaces and 'quotes'.json")
machine.wait_until_succeeds(f"test -f {config_path}")
machine.succeed(f"test -L {config_path}")
workspace = "'/home/alice/custom workspace'"
machine.wait_until_succeeds(f"test -f {workspace}/AGENTS.md")
machine.succeed(f"test ! -L {workspace}/AGENTS.md")
machine.succeed(f"test -f {workspace}/IDENTITY.md")
machine.succeed(f"test -f {workspace}/USER.md")
machine.succeed(f"test -f {workspace}/HEARTBEAT.md")
machine.succeed(f"test -f {workspace}/LORE.md")
machine.succeed(f"grep -q '\"skipBootstrap\":true' {config_path}")
machine.succeed(f"grep -q 'BEGIN NIX-REPORT' {workspace}/TOOLS.md")
machine.wait_until_succeeds(
    "test -x /home/alice/.openclaw/agents/main/agent/codex-home/home/.nix-profile/bin/jq"
)

skill_root = "/home/alice/.local/share/nix-openclaw/skills/default"
for skill in ["activation-skill", "copied-skill"]:
    machine.succeed(f"test -f {skill_root}/{skill}/SKILL.md")
machine.succeed(f'test -z "$(find {skill_root} -type l -print)"')
machine.succeed(f'test -z "$(find {skill_root} -type f ! -links 1 -print)"')
machine.succeed(f'test -z "$(find {skill_root} -type f ! -user alice -print)"')
skills_command = f"OPENCLAW_CONFIG_PATH={config_path} openclaw skills list --json"
skills_output = machine.succeed(f"su - alice -c {shlex.quote(skills_command)}")
assert {"activation-skill", "skill"} <= {entry["name"] for entry in json.loads(skills_output)["skills"]}

uid = machine.succeed("id -u alice").strip()
machine.succeed("loginctl enable-linger alice")
machine.succeed(f"systemctl start user@{uid}.service")
machine.wait_for_unit(f"user@{uid}.service")

machine.wait_until_succeeds("test -S /run/user/1000/bus")

machine.succeed("mkdir -p /tmp/openclaw")
machine.succeed("chmod 1777 /tmp/openclaw")

user_env = "XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus"
machine.succeed(f"su - alice -c '{user_env} systemctl --user daemon-reload'")
machine.succeed(f"su - alice -c '{user_env} systemctl --user start openclaw-gateway.service'")
machine.wait_for_unit("openclaw-gateway.service", user="alice")

try:
    machine.wait_for_open_port(18999)
except Exception:
    machine.succeed(
        f"su - alice -c '{user_env} systemctl --user status openclaw-gateway.service --no-pager -n 200 > /tmp/openclaw/systemctl-status.txt 2>&1' || true"
    )
    machine.succeed(
        f"su - alice -c '{user_env} journalctl --user -u openclaw-gateway.service --no-pager -n 200 -o cat > /tmp/openclaw/journalctl.txt 2>&1' || true"
    )
    machine.succeed("coredumpctl info --no-pager | tail -n 200 >&2 || true")
    machine.succeed("ls -la /tmp/openclaw 1>&2 || true")
    machine.succeed("ls -la /tmp/openclaw/node-report* 1>&2 || true")
    machine.succeed(
        f"su - alice -c '{user_env} systemctl --user show openclaw-gateway.service --no-pager -p Environment > /tmp/openclaw/systemctl-env.txt 2>&1' || true"
    )
    machine.succeed("sed -n '1,200p' /tmp/openclaw/systemctl-env.txt >&2 || true")
    machine.succeed("wc -c /tmp/openclaw/systemctl-env.txt >&2 || true")
    machine.succeed(
        f"su - alice -c '{user_env} systemctl --user cat openclaw-gateway.service --no-pager > /tmp/openclaw/systemctl-unit.txt 2>&1' || true"
    )
    machine.succeed("sed -n '1,200p' /tmp/openclaw/systemctl-unit.txt >&2 || true")
    machine.succeed("wc -c /tmp/openclaw/systemctl-unit.txt >&2 || true")
    machine.succeed("tail -n 40 /tmp/openclaw/systemctl-status.txt >&2 || true")
    machine.succeed("tail -n 40 /tmp/openclaw/journalctl.txt >&2 || true")
    raise
