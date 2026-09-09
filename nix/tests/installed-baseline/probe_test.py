import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import tempfile
import time
import unittest
from unittest.mock import patch
from types import SimpleNamespace

import service

spec = importlib.util.spec_from_file_location("baseline_probe", Path(__file__).with_name("probe.py"))
probe = importlib.util.module_from_spec(spec)
spec.loader.exec_module(probe)


class ProfileOwnershipTests(unittest.TestCase):
    def test_systemd_must_load_the_generation_unit_not_an_identical_shadow(self):
        for shadowed in (False, True):
            with self.subTest(shadowed=shadowed), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                home, generation = root / "home", root / "generation"
                relative = Path(".config/systemd/user") / service.UNIT
                generated = generation / "home-files" / relative
                generated.parent.mkdir(parents=True)
                generated.write_text("[Service]\nExecStart=/fixture/gateway\n")
                installed = home / relative
                installed.parent.mkdir(parents=True)
                installed.symlink_to(generated)
                shadow = root / "shadow.service"
                shadow.write_text(generated.read_text())
                fragment = shadow if shadowed else installed
                instance = service.Service(home, False, {})
                state = {"path": str(fragment), "execStart": "{ argv[]=/fixture/gateway ; }"}
                with contextlib.redirect_stdout(io.StringIO()):
                    if shadowed:
                        with self.assertRaisesRegex(RuntimeError, "selected generation"):
                            instance.verify_loaded(generation, state)
                    else:
                        instance.verify_loaded(generation, state)

    def test_health_json_remains_parseable_with_stderr_warning(self):
        stdout, stderr = io.StringIO(), io.StringIO()
        with contextlib.redirect_stdout(stdout), contextlib.redirect_stderr(stderr):
            result = probe.run([
                sys.executable, "-c",
                'import sys; print(\'{"ok": true}\'); '
                'print("ExperimentalWarning: SQLite is experimental", file=sys.stderr)',
            ], os.environ.copy())
        self.assertEqual(json.loads(result.stdout), {"ok": True})
        self.assertEqual(json.loads(stdout.getvalue()), {"ok": True})
        self.assertEqual(result.stderr, "ExperimentalWarning: SQLite is experimental\n")
        self.assertEqual(stderr.getvalue(), result.stderr)

    def test_fresh_home_uses_only_its_private_profile(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            home = root / "home"
            profile = probe.prepare_home(home, "fixture", root / "global")
            self.assertEqual(profile, home / ".local/state/nix/profiles/home-manager")
            self.assertEqual(os.readlink(home / ".nix-profile"), str(profile.parent / "profile"))
            self.assertFalse((root / "global").exists())

    def test_existing_or_dangling_home_is_never_reused(self):
        for dangling in (False, True):
            with self.subTest(dangling=dangling), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                home = root / "home"
                if dangling:
                    home.symlink_to(root / "missing")
                else:
                    home.mkdir()
                    (home / "keep").write_text("untouched")
                with self.assertRaises(FileExistsError):
                    probe.prepare_home(home, "fixture", root / "global")
                self.assertTrue(home.is_symlink() if dangling else (home / "keep").read_text() == "untouched")

    def test_global_hm_profile_or_gcroot_blocks_before_creating_home(self):
        for owner in ("profiles/per-user/fixture/home-manager-1-link", "gcroots/per-user/fixture/current-home"):
            with self.subTest(owner=owner), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                original = root / owner
                original.parent.mkdir(parents=True)
                original.symlink_to(root / "absent-generation")
                with self.assertRaisesRegex(RuntimeError, "global Home Manager"):
                    probe.prepare_home(root / "home", "fixture", root)
                self.assertTrue(original.is_symlink())
                self.assertFalse((root / "home").exists())

    def test_profile_failure_never_activates(self):
        with patch.object(probe, "run", side_effect=subprocess.CalledProcessError(1, "nix-env")) as run:
            with self.assertRaises(subprocess.CalledProcessError):
                probe.install_generation(Path("/fixture/generation"), Path("/fixture/profile"), {})
            self.assertEqual(run.call_count, 1)
            self.assertEqual(run.call_args.args[0][0], "nix-env")

    def test_activation_follows_profile_install_and_driver_one(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory).resolve()
            generation = root / "generation"
            generation.mkdir()
            profile = root / "profile"
            calls = []

            def execute(args, env):
                calls.append(args)
                if args[0] == "nix-env":
                    profile.symlink_to(generation)

            with patch.object(probe, "run", side_effect=execute):
                probe.install_generation(generation, profile, {})
            self.assertEqual(calls, [
                ["nix-env", "--profile", profile, "--set", generation],
                [generation / "activate", "--driver-version", "1"],
            ])


class UpgradeWitnessTests(unittest.TestCase):
    def test_native_never_exited_is_distinct_from_zero_and_unknown(self):
        instance = service.Service(Path("/fixture"), True, {})
        for raw, expected in (("(never exited)", None), ("0", "0"), ("1", "1"), ("", "unknown")):
            text = "runs = 1\n" + (f"last exit code = {raw}\n" if raw else "")
            with self.subTest(raw=raw), patch.object(service, "run", return_value=SimpleNamespace(
                returncode=0, stdout=text,
            )), contextlib.redirect_stdout(io.StringIO()):
                state = instance.state()
                self.assertEqual(state["lastExit"], expected)
                if expected in (None, "0"):
                    instance.validate_transition(None, state)
                else:
                    with self.assertRaisesRegex(RuntimeError, "unexpected launchd"):
                        instance.validate_transition(None, state)

    def test_disabled_job_identity_payload_and_no_run_survive_each_stage(self):
        job = {"id": "fixture-job", "enabled": False, "name": probe.WITNESS,
               "sessionTarget": "main", "payload": {"kind": "systemEvent", "text": probe.WITNESS},
               "state": {}}
        changes = [
            {}, {"id": "other"}, {"enabled": True}, {"name": "other"},
            {"payload": {"kind": "systemEvent", "text": "other"}},
            {"state": {"lastRunAtMs": 1}}, {"state": {"runningAtMs": 1}},
        ]
        for change in changes:
            with self.subTest(change=change):
                if change:
                    with self.assertRaisesRegex(RuntimeError, "changed or ran"):
                        probe.verify_witness(job | change, "fixture-job")
                else:
                    self.assertEqual(probe.verify_witness(job, "fixture-job"), "fixture-job")

    def test_rollback_must_reselect_original_without_creating_a_generation(self):
        old = {"link": "home-manager-1-link", "id": "1", "store": "/fixture/old",
               "generations": {"1": "/fixture/old"}}
        new = {"link": "home-manager-2-link", "id": "2", "store": "/fixture/new",
               "generations": {"1": "/fixture/old", "2": "/fixture/new"}}
        rollback = old | {"generations": new["generations"]}
        probe.verify_rollback(old, new, rollback)
        for changed in (rollback | {"id": "3"}, rollback | {"store": "/fixture/new"},
                        rollback | {"generations": new["generations"] | {"3": "/fixture/old"}}):
            with self.subTest(changed=changed), self.assertRaisesRegex(RuntimeError, "rollback"):
                probe.verify_rollback(old, new, changed)

    def test_generation_receipt_matches_real_cli_listing_and_link(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory).resolve()
            generation = root / "old"
            generation.mkdir()
            profile = root / "home-manager"
            (root / "home-manager-1-link").symlink_to(generation)
            profile.symlink_to("home-manager-1-link")
            listing = f"2026-09-09 00:00 : id 1 -> {generation} (current)\n"
            with patch.object(probe, "run", return_value=SimpleNamespace(stdout=listing)):
                receipt = probe.profile_state(profile, "/fixture/current-hm", {})
            self.assertEqual(receipt["id"], "1")
            self.assertEqual(receipt["store"], str(generation))

    def test_planned_darwin_transition_does_not_permit_restarts_during_observation(self):
        instance = service.Service(Path("/fixture"), True, {})
        before = {"runs": 2}
        after = {"pid": 100, "runs": 3, "started": "fixture-start",
                 "lastExit": "0", "lastSignal": "Killed: 9"}
        with contextlib.redirect_stdout(io.StringIO()):
            instance.validate_transition(before, after)
        with patch.object(probe, "check_witness"), patch.object(probe.time, "sleep"):
            for change in ({"pid": 101}, {"runs": 4}, {"started": "reused-pid"}):
                with self.subTest(change=change), patch.object(instance, "state", return_value=after | change):
                    with self.assertRaisesRegex(RuntimeError, "observation interval"):
                        probe.stable_witness("/fixture/cli", "fixture-job", instance, after)
        for state in (after | {"runs": 4}, after | {"lastExit": "1"},
                      after | {"lastSignal": "Segmentation fault: 11"}):
            with self.assertRaisesRegex(RuntimeError, "unexpected launchd"):
                instance.validate_transition(before, state)

    def test_systemd_automatic_restart_failure_is_rejected_not_repaired(self):
        instance = service.Service(Path("/fixture"), False, {})
        for state in ({"runs": 1, "result": "success", "active": "active"},
                      {"runs": 0, "result": "exit-code", "active": "failed"}):
            with self.subTest(state=state), self.assertRaisesRegex(RuntimeError, "systemd"):
                instance.validate_transition(None, state)


class CleanupTests(unittest.TestCase):
    def test_real_interrupted_child_is_terminated_and_reaped_before_propagating(self):
        def interrupted(signum, frame):
            raise RuntimeError("fixture interruption")

        with tempfile.TemporaryDirectory() as directory:
            pid_file = Path(directory) / "pid"
            handler = signal.signal(signal.SIGUSR1, interrupted)
            started = time.monotonic()
            try:
                with self.assertRaisesRegex(RuntimeError, "fixture interruption"):
                    service.run([
                        sys.executable, "-c",
                        "import os,signal,time,pathlib,sys; "
                        "pathlib.Path(sys.argv[1]).write_text(str(os.getpid())); "
                        "os.kill(os.getppid(), signal.SIGUSR1); time.sleep(3)",
                        str(pid_file),
                    ], os.environ.copy(), echo=False)
            finally:
                signal.signal(signal.SIGUSR1, handler)
            self.assertLess(time.monotonic() - started, 2)
            self.assertFalse(service.alive(int(pid_file.read_text())))

    def test_real_timed_out_child_is_reaped(self):
        with tempfile.TemporaryDirectory() as directory:
            pid_file = Path(directory) / "pid"
            with self.assertRaises(subprocess.TimeoutExpired):
                service.run([
                    sys.executable, "-c",
                    "import os,time,pathlib,sys; "
                    "pathlib.Path(sys.argv[1]).write_text(str(os.getpid())); time.sleep(3)",
                    str(pid_file),
                ], os.environ.copy(), echo=False, timeout=0.2)
            self.assertFalse(service.alive(int(pid_file.read_text())))

    def test_success_and_failure_both_stop_and_confirm_owned_processes_dead(self):
        for darwin in (False, True):
            for fail in (False, True):
                with self.subTest(darwin=darwin, fail=fail):
                    instance = service.Service(Path("/fixture"), darwin, {})
                    instance.observed = {100}
                    stopped = {"registered": not darwin, "active": "inactive", "pid": 0}
                    output = io.StringIO()
                    with patch.object(instance, "state", return_value=stopped), \
                         patch.object(service, "run") as execute, \
                         patch.object(service, "alive", return_value=False), \
                         contextlib.redirect_stdout(output):
                        if fail:
                            with self.assertRaisesRegex(ValueError, "phase failed"):
                                with instance:
                                    raise ValueError("phase failed")
                        else:
                            with instance:
                                pass
                    self.assertIn('"cleanup": "verified"', output.getvalue())
                    self.assertEqual(execute.call_args.args[0][0], "launchctl" if darwin else "systemctl")

    def test_leaked_pid_or_registered_service_blocks_cleanup_receipt(self):
        for darwin, leaked_pid in ((False, True), (True, False)):
            instance = service.Service(Path("/fixture"), darwin, {})
            instance.observed = {100}
            output = io.StringIO()
            with patch.object(instance, "state", return_value={
                "registered": True, "active": "inactive", "pid": 0,
            }), patch.object(service, "run"), \
                 patch.object(service, "alive", return_value=leaked_pid), \
                 patch.object(service.time, "monotonic", side_effect=[0, 16]), \
                 contextlib.redirect_stdout(output):
                with self.assertRaisesRegex(RuntimeError, "cleanup unproven"):
                    with instance:
                        pass
            self.assertNotIn('"cleanup": "verified"', output.getvalue())


if __name__ == "__main__":
    unittest.main()
