"""Install old/current generations, then exercise the locked HM rollback CLI."""

import json
import os
from pathlib import Path
import platform
import pwd
import re
import signal
import sys
import time

from service import Service, run

WITNESS = "installed-upgrade-witness"
RPC = ["--url", "ws://127.0.0.1:18997", "--token", "fixture"]


def prepare_home(home, username, global_state=Path("/nix/var/nix")):
    # Locked HM migrates/removes old global profiles, even with an isolated HOME.
    profiles = global_state / "profiles/per-user" / username
    roots = global_state / "gcroots/per-user" / username
    if list(profiles.glob("home-manager*")) or os.path.lexists(roots / "current-home"):
        raise RuntimeError("existing global Home Manager ownership; refusing activation")
    home.mkdir(mode=0o700)
    local_profiles = home / ".local/state/nix/profiles"
    local_profiles.mkdir(parents=True)
    (home / ".nix-profile").symlink_to(local_profiles / "profile")
    return local_profiles / "home-manager"


def install_generation(generation, profile, env):
    # Locked HM doSwitch sets the profile before activate --driver-version 1.
    run(["nix-env", "--profile", profile, "--set", generation], env)
    run([generation / "activate", "--driver-version", "1"], env)
    if profile.resolve(strict=True) != generation:
        raise RuntimeError("installed generation differs from built generation")


def profile_state(profile, home_manager, env):
    listing = run([home_manager, "generations"], env).stdout
    generations = {}
    for line in listing.splitlines():
        match = re.search(r": id (\d+) -> (\S+)(?: \(current\))?$", line)
        if not match:
            raise RuntimeError("unrecognized Home Manager generation listing")
        generations[match[1]] = match[2]
    link = os.readlink(profile)
    match = re.fullmatch(r"home-manager-(\d+)-link", link)
    if not match or generations.get(match[1]) != str(profile.resolve(strict=True)):
        raise RuntimeError("Home Manager profile and generation listing disagree")
    return {"link": link, "id": match[1], "store": str(profile.resolve()),
            "generations": generations}


def verify_rollback(original, upgraded, rolled_back):
    if any(rolled_back[key] != original[key] for key in ("link", "id", "store")):
        raise RuntimeError("rollback did not restore the original generation identity")
    if rolled_back["generations"] != upgraded["generations"]:
        raise RuntimeError("rollback added, removed, or changed a generation")


def cron(executable, args, env):
    return json.loads(run([executable, "cron", *args, *RPC], env).stdout)


def verify_witness(job, expected_id=None):
    if (
        not isinstance(job.get("id"), str) or not job["id"]
        or (expected_id is not None and job["id"] != expected_id)
        or job.get("enabled") is not False or job.get("name") != WITNESS
        or job.get("payload") != {"kind": "systemEvent", "text": WITNESS}
        or job.get("sessionTarget") != "main"
        or any(job.get("state", {}).get(key) is not None
               for key in ("lastRunAtMs", "runningAtMs", "lastStatus", "lastRunStatus"))
    ):
        raise RuntimeError("disabled persisted cron witness changed or ran")
    return job["id"]


def check_witness(executable, expected_id, env):
    jobs = cron(executable, ["list", "--all", "--json"], env)["jobs"]
    if len(jobs) != 1:
        raise RuntimeError("isolated scheduler does not contain exactly the witness")
    verify_witness(jobs[0], expected_id)
    print(json.dumps({"persistedWitness": jobs[0], "noRun": True}), flush=True)


def observe(stage, generation, executable, service, previous):
    deadline = time.monotonic() + 90
    while time.monotonic() < deadline:
        state = service.state()
        if state["pid"]:
            health = run([executable, "gateway", "health", *RPC, "--json", "--timeout", "3000"],
                         service.env, False)
            if health.returncode == 0 and json.loads(health.stdout).get("ok") is True:
                break
        time.sleep(1)
    else:
        raise RuntimeError("gateway did not become healthy")
    if service.state() != state:
        raise RuntimeError("service identity changed during health probe")
    service.validate_transition(previous, state)
    service.verify_loaded(generation, state)
    pid = state["pid"]
    if previous and pid == previous["pid"]:
        raise RuntimeError("activation left the previous service running")
    service.wait_dead(service.observed - {pid})
    if service.darwin:
        mappings = run(["lsof", "-a", "-p", str(pid), "-d", "txt", "-Fn"], service.env).stdout
        nodes = [Path(line[1:]) for line in mappings.splitlines()
                 if line.startswith("n/nix/store/") and line.endswith("/bin/node")]
        if nodes != [Path(stage["node"])]:
            raise RuntimeError("gateway executable is not the locked Node runtime")
        actual_node = nodes[0]
    else:
        actual_node = Path(f"/proc/{pid}/exe").resolve(strict=True)
        if actual_node != Path(stage["node"]):
            raise RuntimeError("gateway executable is not the locked Node runtime")
    version = run([actual_node, "--version"], service.env).stdout.strip()
    if not version.startswith(f"v{stage['nodeMajor']}."):
        raise RuntimeError("service runtime has the wrong Node major")
    print(json.dumps({"pid": pid, "started": state["started"], "node": str(actual_node),
                      "nodeVersion": version, "health": json.loads(health.stdout)}), flush=True)
    return state


def stable_witness(executable, expected_id, service, state):
    # The transition may intentionally restart; the observation interval may not.
    for _ in range(3):
        time.sleep(1)
        check_witness(executable, expected_id, service.env)
        if service.state() != state:
            raise RuntimeError("service restarted inside the observation interval")


def main():
    inputs = json.loads(Path(sys.argv[1]).read_text())
    home = Path(inputs["homeDirectory"])
    darwin = platform.system() == "Darwin"
    username = pwd.getpwuid(os.getuid()).pw_name
    expected_home = Path("/tmp/openclaw-installed-baseline" if darwin else "/home/baseline/qualification")
    if home != expected_home or username != ("runner" if darwin else "baseline"):
        raise RuntimeError("probe requires its disposable runner user and HOME")
    for name in ("old", "current"):
        for key in ("activation", "bundle", "node", "homeManager"):
            value = Path(inputs[name][key]).resolve(strict=True)
            if not str(value).startswith("/nix/store/"):
                raise RuntimeError("fixture artifacts must be realized Nix store paths")
            inputs[name][key] = str(value)
    if inputs["old"]["activation"] == inputs["current"]["activation"]:
        raise RuntimeError("upgrade requires two distinct generations")
    env = {
        key: value for key, value in os.environ.items()
        if not key.startswith(("OPENCLAW_", "HOME_MANAGER_", "NIX_STATE"))
        and key not in {"DRY_RUN", "SKIP_SANITY_CHECKS", "NIX_PROFILES", "GH_TOKEN", "GITHUB_TOKEN"}
    }
    env.update(HOME=str(home), USER=username, LOGNAME=username, LC_ALL="C", NO_COLOR="1")
    env.update(OPENCLAW_STATE_DIR=str(home / ".openclaw-baseline"),
               OPENCLAW_CONFIG_PATH=str(home / ".openclaw-baseline/openclaw.json"))
    for name, suffix in {
        "XDG_STATE_HOME": ".local/state", "XDG_DATA_HOME": ".local/share",
        "XDG_CONFIG_HOME": ".config", "XDG_CACHE_HOME": ".cache",
    }.items():
        env[name] = str(home / suffix)
    service = Service(home, darwin, env)
    service.preflight()
    profile = prepare_home(home, username)
    previous = None
    witness_id = None
    receipts = []
    phase = "old"
    try:
        with service:
            for phase, stage in (("old", inputs["old"]), ("current", inputs["current"]),
                                 ("rollback", inputs["old"])):
                generation = Path(stage["activation"])
                if phase == "rollback":
                    run([inputs["current"]["homeManager"], "switch", "--rollback"], env)
                else:
                    install_generation(generation, profile, env)
                # Both locked HM versions use sd-switch. Observe the result
                # first; only the initial, inactive unit needs an explicit start.
                post_activation = service.state()
                print(json.dumps({"phase": phase, "postActivation": post_activation}), flush=True)
                if not darwin and phase == "old" and post_activation.get("active") == "inactive":
                    run(["systemctl", "--user", "start", "openclaw-installed-baseline.service"], env)
                elif not darwin and not stage["automaticServiceSwitch"]:
                    raise RuntimeError("locked HM no longer automatically switches services")
                executable = home / ".nix-profile/bin/openclaw"
                if executable.resolve(strict=True) != (Path(stage["bundle"]) / "bin/openclaw").resolve(strict=True):
                    raise RuntimeError("installed executable differs from the selected bundle")
                receipt = profile_state(profile, inputs["current"]["homeManager"], env)
                if receipt["store"] != str(generation):
                    raise RuntimeError("active profile differs from the selected generation")
                if phase == "current" and (
                    len(receipt["generations"]) != 2
                    or receipt["id"] == receipts[0]["id"]
                    or receipt["generations"].get(receipts[0]["id"]) != receipts[0]["store"]
                ):
                    raise RuntimeError("upgrade did not retain the old and new generations")
                if phase == "old" and len(receipt["generations"]) != 1:
                    raise RuntimeError("initial profile is not fresh")
                if phase == "rollback":
                    verify_rollback(receipts[0], receipts[1], receipt)
                receipts.append(receipt)
                print(json.dumps({"phase": phase, "profile": receipt,
                                  "bundle": stage["bundle"], "hm": stage["homeManager"]}), flush=True)
                run([executable, "--version"], env)
                previous = observe(stage, generation, executable, service, previous)
                if witness_id is None:
                    if cron(executable, ["list", "--all", "--json"], env)["jobs"]:
                        raise RuntimeError("initial scheduler is not empty")
                    job = cron(executable, [
                        "add", "--name", WITNESS, "--every", "24h", "--session", "main",
                        "--system-event", WITNESS, "--disabled", "--json",
                    ], env)
                    witness_id = verify_witness(job)
                stable_witness(executable, witness_id, service, previous)
    except BaseException:
        print(f"BLOCKED installed-upgrade phase={phase}; no fallback", flush=True)
        raise
    print(json.dumps({"result": "PASS", "scope": "installed-upgrade-rollback",
                      "witnessId": witness_id, "generations": receipts, "cleanup": "verified",
                      "trackB": "DEFERRED: source patch applicability; no migration proof"}), flush=True)


if __name__ == "__main__":
    def interrupted(signum, frame):
        raise RuntimeError(f"fixture interrupted by signal {signum}")

    signal.signal(signal.SIGTERM, interrupted)
    main()
