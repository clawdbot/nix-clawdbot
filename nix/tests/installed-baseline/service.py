"""Service ownership and bounded teardown for the disposable installed fixture."""

import configparser
import json
import os
from pathlib import Path
import plistlib
import re
import signal
import subprocess
import sys
import time

LABEL = "org.openclaw.nix.installed-baseline"
UNIT = "openclaw-installed-baseline.service"


def run(args, env, check=True, echo=True, timeout=120):
    process = subprocess.Popen(
        [str(arg) for arg in args], env=env, text=True, start_new_session=True,
        stdout=subprocess.PIPE, stderr=subprocess.PIPE,
    )
    try:
        try:
            stdout, stderr = process.communicate(timeout=timeout)
        except BaseException:
            # A signal handler can interrupt activation, not just a timeout.
            # Reap only this new session; Popen.__exit__ would wait unboundedly.
            try:
                os.killpg(process.pid, signal.SIGTERM)
            except ProcessLookupError:
                pass
            try:
                process.communicate(timeout=5)
            except subprocess.TimeoutExpired:
                try:
                    os.killpg(process.pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass
                process.communicate(timeout=5)
            raise
    finally:
        process.stdout.close()
        process.stderr.close()
    result = subprocess.CompletedProcess(args, process.returncode, stdout, stderr)
    if echo:
        print(stdout, end="", flush=True)
        print(stderr, end="", file=sys.stderr, flush=True)
    if check:
        result.check_returncode()
    return result


def alive(pid):
    try:
        os.kill(pid, 0)
        return True
    except ProcessLookupError:
        return False


class Service:
    def __init__(self, home, darwin, env):
        self.home, self.darwin, self.env = home, darwin, env
        self.target = f"gui/{os.getuid()}/{LABEL}"
        self.observed = set()

    def state(self):
        if self.darwin:
            result = run(["launchctl", "print", self.target], self.env, False, False, 10)
            if result.returncode:
                if "Could not find service" not in result.stderr:
                    raise RuntimeError("cannot determine fixture launchd registration")
                return {"registered": False, "pid": 0}
            text = result.stdout
            fields = dict(re.findall(r"^\s*([\w ]+) = ([^\n{]+)$", text, re.M))
            arguments = re.search(r"^\s*arguments = \{\n(.*?)^\s*\}", text, re.M | re.S)
            state = {
                "registered": True, "pid": int(fields.get("pid", "0")),
                "runs": int(fields.get("runs", "0")), "path": fields.get("path"),
                "arguments": [line.strip() for line in arguments[1].splitlines()] if arguments else [],
                "lastExit": None if fields.get("last exit code") == "(never exited)"
                else fields.get("last exit code", "unknown"),
                "lastSignal": fields.get("last terminating signal", ""),
            }
        else:
            result = run([
                "systemctl", "--user", "show", UNIT, "-p", "MainPID", "-p", "NRestarts",
                "-p", "ActiveState", "-p", "Result", "-p", "LoadState",
                "-p", "FragmentPath", "-p", "ExecStart",
            ], self.env, check=False, echo=False, timeout=10)
            fields = dict(line.split("=", 1) for line in result.stdout.splitlines() if "=" in line)
            if fields.get("LoadState") == "not-found":
                return {"registered": False, "pid": 0, "active": "inactive"}
            result.check_returncode()
            state = {
                "registered": fields["LoadState"] != "not-found",
                "pid": int(fields["MainPID"]), "runs": int(fields["NRestarts"]),
                "active": fields["ActiveState"], "result": fields["Result"],
                "path": fields["FragmentPath"], "execStart": fields["ExecStart"],
            }
        if state["pid"]:
            self.observed.add(state["pid"])
            result = run(["ps", "-p", str(state["pid"]), "-o", "uid=,lstart="],
                         self.env, False, False, 10)
            identity = result.stdout.strip().split(maxsplit=1)
            if len(identity) != 2 or int(identity[0]) != os.getuid():
                raise RuntimeError("fixture service PID has no matching owner/start identity")
            state["started"] = identity[1]
        return state

    def preflight(self):
        if self.darwin:
            run(["launchctl", "print", f"gui/{os.getuid()}"], self.env, echo=False, timeout=10)
        if self.state()["registered"]:
            raise RuntimeError("fixture service already registered; refusing activation")

    def verify_loaded(self, generation, state):
        if self.darwin:
            relative = Path("Library/LaunchAgents") / f"{LABEL}.plist"
            expected = generation / "LaunchAgents" / f"{LABEL}.plist"
            installed = self.home / relative
            if installed.read_bytes() != expected.read_bytes():
                raise RuntimeError("installed plist differs from the selected generation")
            if not state["path"] or Path(state["path"]).resolve(strict=True) != installed.resolve(strict=True):
                raise RuntimeError("launchd did not load the selected generation's plist")
            contents = plistlib.loads(expected.read_bytes())
            if state["arguments"] != contents["ProgramArguments"]:
                raise RuntimeError("loaded launchd arguments differ from the generation")
        else:
            relative = Path(".config/systemd/user") / UNIT
            expected = (generation / "home-files" / relative).resolve(strict=True)
            if (
                not state["path"]
                or (self.home / relative).resolve(strict=True) != expected
                or Path(state["path"]).resolve(strict=True) != expected
            ):
                raise RuntimeError("systemd did not load the selected generation's unit")
            contents = expected.read_text()
            unit = configparser.ConfigParser(interpolation=None, strict=False)
            unit.read_string(contents)
            if f"argv[]={unit['Service']['ExecStart']} ;" not in state["execStart"]:
                raise RuntimeError("loaded systemd command differs from the generation")
        print(json.dumps({"loadedService": state, "definition": contents}), flush=True)

    def validate_transition(self, before, after):
        if self.darwin:
            # HM can re-register the plist; repo relinking can kickstart a retained
            # job. Budget only those activation operations, then freeze the counter.
            allowed = {1, 2}
            if before:
                allowed.add(before["runs"] + 1)
            if after["runs"] not in allowed or after["lastExit"] not in (None, "0"):
                raise RuntimeError("unexpected launchd exits/restarts during activation")
            if after["lastSignal"] and not after["lastSignal"].endswith(": 9"):
                raise RuntimeError("unexpected launchd termination during activation")
        elif after["runs"] != 0 or after["result"] != "success" or after["active"] != "active":
            raise RuntimeError("systemd service failed or restarted unexpectedly")
        print(json.dumps({"activationTransition": {"before": before, "after": after}}), flush=True)

    def wait_dead(self, pids, timeout=15):
        deadline = time.monotonic() + timeout
        while any(alive(pid) for pid in pids):
            if time.monotonic() >= deadline:
                raise RuntimeError("prior fixture service PID survived transition")
            time.sleep(0.2)

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc, tb):
        # Capture even failed-start PIDs before stopping the service. No success
        # receipt can escape until both the supervisor and observed PIDs are gone.
        observation_error = None
        try:
            self.state()
        except Exception as error:
            observation_error = error
        command = ["launchctl", "bootout", self.target] if self.darwin else [
            "systemctl", "--user", "stop", UNIT,
        ]
        try:
            run(command, self.env, False, False, 15)
        except subprocess.TimeoutExpired as error:
            observation_error = error
        deadline = time.monotonic() + 15
        while True:
            state = self.state()
            inactive = not state["registered"] if self.darwin else (
                state.get("active") == "inactive" and not state["pid"]
            )
            remaining = sorted(pid for pid in self.observed if alive(pid))
            if inactive and not remaining:
                if observation_error:
                    raise RuntimeError("cleanup had an observation/stop failure") from observation_error
                print(json.dumps({"cleanup": "verified", "service": state,
                                  "observedPids": sorted(self.observed)}), flush=True)
                return False
            if time.monotonic() >= deadline:
                raise RuntimeError(f"cleanup unproven: service={state}, survivingPids={remaining}")
            time.sleep(0.2)
