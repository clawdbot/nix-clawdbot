import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch
from types import SimpleNamespace


spec = importlib.util.spec_from_file_location("baseline_probe", Path(__file__).with_name("probe.py"))
probe = importlib.util.module_from_spec(spec)
spec.loader.exec_module(probe)


class ProfileOwnershipTests(unittest.TestCase):
    def test_systemd_must_load_the_generation_unit_not_an_identical_shadow(self):
        for shadowed in (False, True):
            with self.subTest(shadowed=shadowed), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                home, generation = root / "home", root / "generation"
                relative = Path(".config/systemd/user") / probe.UNIT
                generated = generation / "home-files" / relative
                generated.parent.mkdir(parents=True)
                generated.write_text("[Service]\nExecStart=/fixture/gateway\n")
                installed = home / relative
                installed.parent.mkdir(parents=True)
                installed.symlink_to(generated)
                shadow = root / "shadow.service"
                shadow.write_text(generated.read_text())
                fragment = shadow if shadowed else installed
                with patch.object(probe, "run", return_value=SimpleNamespace(stdout=str(fragment))):
                    if shadowed:
                        with self.assertRaisesRegex(RuntimeError, "baseline generation"):
                            probe.verify_systemd_unit(home, generation, {})
                    else:
                        with contextlib.redirect_stdout(io.StringIO()):
                            probe.verify_systemd_unit(home, generation, {})

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


if __name__ == "__main__":
    unittest.main()
