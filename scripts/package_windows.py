"""Build and package the standalone Windows release from a clean Git revision."""

from __future__ import annotations

import hashlib
import json
import shutil
import subprocess
import sys
import zipfile
from datetime import UTC, datetime
from pathlib import Path

from studio import GAME, ROOT, resolve_tool, run_checked

DIST_ROOT = ROOT / "dist"
BUNDLE = DIST_ROOT / "Dernier-Signal"
EXECUTABLE = BUNDLE / "Dernier-Signal.exe"
ARCHIVE = DIST_ROOT / "Dernier-Signal-windows-x86_64.zip"


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def git(*arguments: str) -> str:
    result = subprocess.run(
        ["git", *arguments],
        cwd=ROOT,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        check=True,
    )
    return result.stdout.strip()


def remove_previous_file(path: Path) -> None:
    resolved = path.resolve()
    if not resolved.is_relative_to(DIST_ROOT.resolve()):
        raise RuntimeError(f"Refusing to remove a path outside dist: {resolved}")
    if resolved.is_file():
        resolved.unlink()


def package() -> dict:
    dirty = git("status", "--porcelain", "--untracked-files=normal")
    source_changes = []
    for line in dirty.splitlines():
        path = line[3:].replace("\\", "/")
        if not path.startswith(".godot-studio/metrics/episodes/"):
            source_changes.append(line)
    if source_changes:
        raise RuntimeError(
            "Commit or discard source changes before packaging:\n" + "\n".join(source_changes)
        )
    BUNDLE.mkdir(parents=True, exist_ok=True)
    for path in (
        EXECUTABLE,
        BUNDLE / "GODOT_COPYRIGHT.txt",
        BUNDLE / "GUIDE_JOUEUR.md",
        BUNDLE / "THIRD_PARTY_NOTICES.md",
        BUNDLE / "BUILD_MANIFEST.json",
        BUNDLE / "SHA256SUMS.txt",
        ARCHIVE,
        ARCHIVE.with_suffix(ARCHIVE.suffix + ".sha256"),
    ):
        remove_previous_file(path)
    godot = resolve_tool("godot")
    run_checked(
        [
            godot,
            "--headless",
            "--path",
            str(GAME),
            "--export-release",
            "Windows Desktop",
            str(EXECUTABLE),
        ],
        timeout=300,
        godot=True,
    )
    run_checked(
        [
            godot,
            "--headless",
            "--path",
            str(GAME),
            "--script",
            "res://tests/dump_engine_licenses.gd",
            "--",
            str(BUNDLE / "GODOT_COPYRIGHT.txt"),
        ],
        timeout=60,
        godot=True,
    )
    shutil.copyfile(ROOT / "docs/PLAYER_GUIDE.md", BUNDLE / "GUIDE_JOUEUR.md")
    shutil.copyfile(ROOT / "THIRD_PARTY_NOTICES.md", BUNDLE / "THIRD_PARTY_NOTICES.md")
    startup = run_checked(
        [str(EXECUTABLE), "--headless", "--quit-after", "3"], timeout=60, godot=True
    )
    files = [
        EXECUTABLE,
        BUNDLE / "GODOT_COPYRIGHT.txt",
        BUNDLE / "GUIDE_JOUEUR.md",
        BUNDLE / "THIRD_PARTY_NOTICES.md",
    ]
    manifest = {
        "schema_version": 1,
        "game": "Dernier Signal",
        "version": "1.0.0",
        "platform": "Windows x86_64",
        "built_at_utc": datetime.now(UTC).isoformat(),
        "source_commit": git("rev-parse", "HEAD"),
        "godot": run_checked([godot, "--version"], timeout=30)["output"].strip(),
        "startup_smoke": "PASS" if "Godot Engine" in startup["output"] else "PASS_NO_HEADER",
        "files": {
            path.name: {"bytes": path.stat().st_size, "sha256": sha256(path)} for path in files
        },
    }
    manifest_path = BUNDLE / "BUILD_MANIFEST.json"
    manifest_path.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    files.append(manifest_path)
    sums = "".join(f"{sha256(path)}  {path.name}\n" for path in files)
    (BUNDLE / "SHA256SUMS.txt").write_text(sums, encoding="utf-8")
    with zipfile.ZipFile(ARCHIVE, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as bundle:
        for path in sorted(BUNDLE.iterdir()):
            bundle.write(path, Path(BUNDLE.name) / path.name)
    ARCHIVE.with_suffix(ARCHIVE.suffix + ".sha256").write_text(
        f"{sha256(ARCHIVE)}  {ARCHIVE.name}\n", encoding="utf-8"
    )
    return {
        "status": "PASS",
        "bundle": str(BUNDLE.relative_to(ROOT)),
        "archive": str(ARCHIVE.relative_to(ROOT)),
        "archive_sha256": sha256(ARCHIVE),
        "source_commit": manifest["source_commit"],
        "executable_bytes": EXECUTABLE.stat().st_size,
    }


if __name__ == "__main__":
    try:
        sys.stdout.write(json.dumps(package(), ensure_ascii=False, indent=2) + "\n")
    except (OSError, RuntimeError, subprocess.SubprocessError) as error:
        sys.stderr.write(f"PACKAGE_FAILED: {error}\n")
        raise SystemExit(1)
