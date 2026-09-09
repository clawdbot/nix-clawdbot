"""Stage0 only: install one authentic HM generation and observe its gateway."""

import json
import os
from pathlib import Path
import platform
import pwd
import re
import subprocess
import sys
import time


LABEL = "org.openclaw.nix.installed-baseline"
UNIT = "openclaw-installed-baseline.service"


def run(args, env, check=True):
    result = subprocess.run(
        [str(arg) for arg in args], env=env, text=True,
        stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=120,
    )
    print(result.stdout, end="", flush=True)
    print(result.stderr, end="", file=sys.stderr, flush=True)
    if check:
        result.check_returncode()
    return result


def prepare_home(home, username, global_state=Path("/nix/var/nix")):
    # Locked HM migrates/removes old global profiles, even with an isolated HOME.
    profiles = global_state / "profiles/per-user" / username
    roots = global_state / "gcroots/per-user" / username
    if list(profiles.glob("home-manager*")) or os.path.lexists(roots / "current-home"):
        raise RuntimeError("existing global Home Manager ownership; refusing activation")
    home.mkdir(mode=0o700)  # Existing or dangling homes are never reused/deleted.
    local_profiles = home / ".local/state/nix/profiles"
    local_profiles.mkdir(parents=True)
    (home / ".nix-profile").symlink_to(local_profiles / "profile")
    return local_profiles / "home-manager"


def install_generation(generation, profile, env):
    # Locked HM doSwitch sets the profile before activate --driver-version 1.
    run(["nix-env", "--profile", profile, "--set", generation], env)
    run([generation / "activate", "--driver-version", "1"], env)
    if profile.resolve(strict=True) != generation:
        raise RuntimeError("installed generation differs from built baseline")


def verify_systemd_unit(home, generation, env):
    unit = Path(".config/systemd/user") / UNIT
    expected = (generation / "home-files" / unit).resolve(strict=True)
    fragment = run([
        "systemctl", "--user", "show", UNIT, "-p", "FragmentPath", "--value",
    ], env).stdout.strip()
    if (
        not fragment
        or (home / unit).resolve(strict=True) != expected
        or Path(fragment).resolve(strict=True) != expected
    ):
        raise RuntimeError("systemd did not load the baseline generation's unit")
    print(json.dumps({"fragmentPath": fragment, "generatedUnit": str(expected)}), flush=True)


def service_state(darwin, env):
    if darwin:
        result = run(["launchctl", "print", f"gui/{os.getuid()}/{LABEL}"], env, False)
        if result.returncode:
            return 0
        runs = re.search(r"^\s*runs = (\d+)$", result.stdout, re.M)
        if runs and int(runs[1]) > 1:
            raise RuntimeError("baseline launchd service restarted")
        if re.search(r"last exit code = [1-9]|last terminating signal", result.stdout):
            raise RuntimeError("baseline launchd service exited")
        pid = re.search(r"^\s*pid = (\d+)$", result.stdout, re.M)
        return int(pid[1]) if pid else 0
    result = run([
        "systemctl", "--user", "show", UNIT, "-p", "MainPID",
        "-p", "NRestarts", "-p", "ActiveState", "-p", "Result",
    ], env)
    values = dict(line.split("=", 1) for line in result.stdout.splitlines() if "=" in line)
    if values["NRestarts"] != "0" or values["Result"] != "success":
        raise RuntimeError("baseline systemd service failed or restarted")
    if values["ActiveState"] == "failed":
        raise RuntimeError("baseline systemd service failed")
    return int(values["MainPID"])


def main():
    home, generation, bundle, node = map(Path, sys.argv[1:])
    generation, bundle, node = (path.resolve(strict=True) for path in (generation, bundle, node))
    if any(not str(path).startswith("/nix/store/") for path in (generation, bundle, node)):
        raise RuntimeError("baseline artifacts must be realized Nix store paths")
    darwin = platform.system() == "Darwin"
    expected_home = Path("/tmp/openclaw-installed-baseline" if darwin else "/home/baseline/qualification")
    username = pwd.getpwuid(os.getuid()).pw_name
    if home != expected_home or username != ("runner" if darwin else "baseline"):
        raise RuntimeError("probe requires its disposable runner user and HOME")
    env = {
        key: value for key, value in os.environ.items()
        if not key.startswith(("OPENCLAW_", "HOME_MANAGER_"))
        and key not in {"DRY_RUN", "SKIP_SANITY_CHECKS", "NIX_PROFILES"}
    }
    env.update(HOME=str(home), USER=username, LOGNAME=username)
    env.update(
        OPENCLAW_STATE_DIR=str(home / ".openclaw-baseline"),
        OPENCLAW_CONFIG_PATH=str(home / ".openclaw-baseline/openclaw.json"),
    )
    for name, suffix in {
        "XDG_STATE_HOME": ".local/state", "XDG_DATA_HOME": ".local/share",
        "XDG_CONFIG_HOME": ".config", "XDG_CACHE_HOME": ".cache",
    }.items():
        env[name] = str(home / suffix)
    if darwin and run(["launchctl", "print", f"gui/{os.getuid()}/{LABEL}"], env, False).returncode == 0:
        raise RuntimeError("qualification launchd label already exists")
    profile = prepare_home(home, username)
    phase = "activation"
    try:
        install_generation(generation, profile, env)
        executable = home / ".nix-profile/bin/openclaw"
        if executable.resolve(strict=True) != (bundle / "bin/openclaw").resolve(strict=True):
            raise RuntimeError("installed executable does not belong to the baseline bundle")
        print(json.dumps({
            "phase": "installed", "generation": str(generation),
            "profile": str(profile), "generationLink": os.readlink(profile),
            "executable": str(executable.resolve()), "bundle": str(bundle),
        }), flush=True)
        run([executable, "--version"], env)
        phase = "service-start"
        if not darwin:
            run(["systemctl", "--user", "daemon-reload"], env)
            verify_systemd_unit(home, generation, env)
            run(["systemctl", "--user", "start", UNIT], env)
        deadline = time.monotonic() + 90
        while time.monotonic() < deadline:
            pid = service_state(darwin, env)
            if pid:
                health = run([
                    executable, "gateway", "health", "--url", "ws://127.0.0.1:18997",
                    "--token", "installed-baseline-fixture-token", "--json", "--timeout", "3000",
                ], env, False)
                if health.returncode == 0 and json.loads(health.stdout).get("ok") is True:
                    break
            time.sleep(1)
        else:
            raise RuntimeError("baseline gateway did not become healthy")
        if service_state(darwin, env) != pid:
            raise RuntimeError("baseline gateway PID changed during health probe")
        if darwin:
            mappings = run(["lsof", "-a", "-p", str(pid), "-d", "txt", "-Fn"], env).stdout
            nodes = [Path(line[1:]) for line in mappings.splitlines() if line.startswith("n/nix/store/") and line.endswith("/bin/node")]
            if nodes != [node]:
                raise RuntimeError("gateway executable is not the locked Node runtime")
            actual_node = nodes[0]
        else:
            actual_node = Path(f"/proc/{pid}/exe").resolve(strict=True)
            if actual_node != node:
                raise RuntimeError("gateway executable is not the locked Node runtime")
        version = run([actual_node, "--version"], env).stdout.strip()
        if not version.startswith("v22."):
            raise RuntimeError(f"baseline runtime is not Node.js 22: {version}")
        print(json.dumps({
            "result": "PASS", "scope": "installed-baseline-only", "pid": pid,
            "node": str(actual_node), "nodeVersion": version, "health": json.loads(health.stdout),
            "acpx": "NOT_QUALIFIED: historical baseline, no discovery or session proof",
        }), flush=True)
    except Exception:
        print(f"BLOCKED stage0 phase={phase}; no fallback or transition attempted", flush=True)
        log = home / "gateway.log"
        if log.is_file():
            print(log.read_text()[-16000:], flush=True)
        raise
    finally:
        if darwin:
            run(["launchctl", "bootout", f"gui/{os.getuid()}/{LABEL}"], env, False)
        else:
            run(["systemctl", "--user", "stop", UNIT], env, False)


if __name__ == "__main__":
    main()
