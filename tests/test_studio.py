"""Behavioral checks for project boundaries and reliable failure reporting."""

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
import studio


class StudioTests(unittest.TestCase):
    def test_rejects_parent_and_absolute_escape(self):
        for value in ("../escape.wav", str(studio.ROOT.parent / "escape.wav")):
            with self.subTest(value=value), self.assertRaises(ValueError):
                studio.project_path(value)

    def test_refuses_overwrite(self):
        with (
            tempfile.TemporaryDirectory() as directory,
            patch.object(studio, "ROOT", Path(directory)),
        ):
            source, target = Path(directory) / "input.wav", Path(directory) / "output.ogg"
            source.write_bytes(b"fixture")
            target.write_bytes(b"preserve")
            with self.assertRaises(FileExistsError):
                studio.convert_audio("input.wav", "output.ogg")
            self.assertEqual(target.read_bytes(), b"preserve")

    def test_rejects_unsupported_rate_and_output(self):
        with (
            tempfile.TemporaryDirectory() as directory,
            patch.object(studio, "ROOT", Path(directory)),
        ):
            (Path(directory) / "input.wav").touch()
            for output, rate in (("out.exe", 48000), ("out.ogg", -1)):
                with self.subTest(output=output, rate=rate), self.assertRaises(ValueError):
                    studio.convert_audio("input.wav", output, rate)

    def test_nonzero_exit_is_an_error(self):
        with self.assertRaises(RuntimeError):
            studio.run_checked([sys.executable, "-c", "raise SystemExit(7)"])

    def test_godot_zero_exit_with_parse_error_is_an_error(self):
        with self.assertRaises(RuntimeError):
            studio.run_checked(
                [sys.executable, "-c", "print('SCRIPT ERROR: Parse Error')"], godot=True
            )

    def test_timeout_propagates(self):
        with patch.object(
            studio.subprocess, "run", side_effect=subprocess.TimeoutExpired("test", 1)
        ):
            with self.assertRaises(subprocess.TimeoutExpired):
                studio.run_checked(["test"], timeout=1)


if __name__ == "__main__":
    unittest.main()
