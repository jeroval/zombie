"""Project commands shared by the CLI, VS Code and the bounded MCP server."""

from __future__ import annotations

import argparse
import importlib.util
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GAME = ROOT / "game"
AUDIO_INPUTS = {".wav": "wav", ".ogg": "ogg", ".mp3": "mp3", ".flac": "flac"}
TOOL_NAMES = ("blender", "ffmpeg", "ffprobe", "sox", "audacity", "lmms", "piper")


def machine_directory() -> Path:
    return Path(os.environ.get("LOCALAPPDATA", Path.home() / ".local/state")) / "GodotAssetCloud"


def read_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8-sig")) if path.is_file() else {}


def plugin_root() -> Path:
    local = read_json(ROOT / ".godot-studio/machine.local.json")
    receipt = read_json(machine_directory() / "studio-3d-capabilities.json")
    value = os.environ.get("GAC_PLUGIN_ROOT") or local.get("plugin_root")
    value = value or receipt.get("plugin", {}).get("path")
    if not value or not (Path(value) / "scripts/gac.py").is_file():
        raise FileNotFoundError(
            "Configure GAC_PLUGIN_ROOT for the installed Godot Asset Cloud plugin"
        )
    return Path(value)


def godot_module():
    path = plugin_root() / "scripts/godot_resolver.py"
    spec = importlib.util.spec_from_file_location("gac_godot_resolver", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def resolve_tool(name: str) -> str:
    if name == "godot":
        report = godot_module().resolve_godot(GAME, save_cache=False)
        selected = report.get("selected") or {}
        if report["status"] != "PASS" or not selected.get("path"):
            raise RuntimeError(f"Canonical Godot discovery failed: {report}")
        return selected["path"]
    if name not in TOOL_NAMES:
        raise ValueError(f"Unsupported tool: {name}")
    # Use the project's pinned TTS rather than an inherited path into another game.
    if name == "piper":
        local = Path(sys.executable).parent / ("piper.exe" if os.name == "nt" else "piper")
        if local.is_file():
            return str(local)
    override = os.environ.get(f"GAC_{name.upper()}_EXE")
    cache = read_json(machine_directory() / "studio-toolchain.json")
    value = override or cache.get("tools", {}).get(name, {}).get("path")
    if value:
        if not Path(value).is_file():
            raise FileNotFoundError(f"Invalid configured path for {name}")
        return str(value)
    if name == "ffprobe":
        candidate = Path(resolve_tool("ffmpeg")).with_name(
            "ffprobe.exe" if os.name == "nt" else "ffprobe"
        )
        if candidate.is_file():
            return str(candidate)
    found = shutil.which(name)
    if not found:
        raise FileNotFoundError(f"{name} unavailable; configure GAC_{name.upper()}_EXE")
    return found


def project_path(value: str) -> Path:
    path = (ROOT / value).resolve()
    if not path.is_relative_to(ROOT):
        raise ValueError("Path must stay inside this project")
    return path


def run_checked(args: list[str], timeout: int = 120, *, godot: bool = False) -> dict:
    startup = None
    if os.name == "nt":
        startup = subprocess.STARTUPINFO()
        startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        startup.wShowWindow = subprocess.SW_HIDE
    result = subprocess.run(
        args,
        cwd=ROOT,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=timeout,
        startupinfo=startup,
    )
    output = result.stdout + result.stderr
    if result.returncode or (godot and ("SCRIPT ERROR:" in output or "ERROR:" in output)):
        raise RuntimeError(f"Command failed ({result.returncode}): {output[-6000:]}")
    return {"status": "PASS", "output": output}


def capabilities() -> dict:
    report = {
        "project_root": str(ROOT),
        "godot": godot_module().resolve_godot(GAME, save_cache=False),
        "tools": {},
    }
    for name in TOOL_NAMES:
        try:
            executable = resolve_tool(name)
        except FileNotFoundError as error:
            report["tools"][name] = {"status": "MISSING", "detail": str(error)}
            continue
        version_arg = "-version" if name in {"ffmpeg", "ffprobe"} else "--version"
        if name == "piper":
            version_arg = "--help"
        try:
            result = run_checked([executable, version_arg], timeout=20)
            report["tools"][name] = {
                "status": "PASS",
                "path": executable,
                "evidence": result["output"].splitlines()[:2],
            }
        except (RuntimeError, subprocess.TimeoutExpired) as error:
            report["tools"][name] = {"status": "WARN", "detail": str(error)}
    return report


def godot_smoke() -> dict:
    executable = resolve_tool("godot")
    checks = []
    for args in (["--editor", "--quit"], ["--quit-after", "3"]):
        checks.append(
            run_checked(
                [executable, "--headless", "--path", str(GAME), *args], timeout=180, godot=True
            )
        )
    return {"status": "PASS", "scope": "technical startup only", "checks": checks}


def probe_audio(relative_path: str) -> dict:
    source = project_path(relative_path)
    if source.suffix.lower() not in AUDIO_INPUTS or not source.is_file():
        raise ValueError("Input must be an existing project-local WAV, Ogg, MP3 or FLAC")
    result = run_checked(
        [
            resolve_tool("ffprobe"),
            "-v",
            "error",
            "-protocol_whitelist",
            "file",
            "-f",
            AUDIO_INPUTS[source.suffix.lower()],
            "-show_format",
            "-show_streams",
            "-of",
            "json",
            str(source),
        ],
        timeout=30,
    )
    return json.loads(result["output"])


def convert_audio(input_path: str, output_path: str, sample_rate: int = 48000) -> dict:
    source, target = project_path(input_path), project_path(output_path)
    if source.suffix.lower() not in AUDIO_INPUTS or not source.is_file():
        raise ValueError("Input must be an existing project-local audio file")
    if target.suffix.lower() not in {".wav", ".ogg"}:
        raise ValueError("Output must be WAV or Ogg")
    if sample_rate not in {22050, 24000, 44100, 48000, 96000}:
        raise ValueError("Unsupported sample rate")
    if target.exists():
        raise FileExistsError("Output already exists; choose a new path")
    target.parent.mkdir(parents=True, exist_ok=True)
    codec = "libvorbis" if target.suffix.lower() == ".ogg" else "pcm_s16le"
    run_checked(
        [
            resolve_tool("ffmpeg"),
            "-nostdin",
            "-n",
            "-v",
            "error",
            "-protocol_whitelist",
            "file",
            "-f",
            AUDIO_INPUTS[source.suffix.lower()],
            "-i",
            str(source),
            "-vn",
            "-ar",
            str(sample_rate),
            "-c:a",
            codec,
            str(target),
        ]
    )
    return {"status": "PASS", "output": str(target.relative_to(ROOT))}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["doctor", "smoke", "check", "open", "blender", "gac"])
    parser.add_argument("arguments", nargs=argparse.REMAINDER)
    args = parser.parse_args()
    if args.action == "gac":
        result = subprocess.run(
            [sys.executable, str(plugin_root() / "scripts/gac.py"), *args.arguments], cwd=ROOT
        )
        raise SystemExit(result.returncode)
    if args.action in {"open", "blender"}:
        command = (
            [resolve_tool("godot"), "--editor", "--path", str(GAME)]
            if args.action == "open"
            else [resolve_tool("blender"), "--python", str(ROOT / "scripts/blender_bridge.py")]
        )
        startup = None
        if os.name == "nt":
            startup = subprocess.STARTUPINFO()
            startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW
            startup.wShowWindow = subprocess.SW_HIDE
        subprocess.Popen(command, cwd=ROOT, startupinfo=startup)
        return
    if args.action == "doctor":
        result = capabilities()
    elif args.action == "smoke":
        result = godot_smoke()
    else:
        from verify_pipeline import verify_pipeline

        result = verify_pipeline()
    print(json.dumps(result, ensure_ascii=False, indent=2))
    if args.action == "doctor" and result["godot"]["status"] != "PASS":
        raise SystemExit(1)


if __name__ == "__main__":
    main()
