"""Generate project-local French speech with offline Piper models."""

import argparse
import hashlib
import json
import math
import os
import subprocess
import tempfile
import wave
from pathlib import Path

from studio import ROOT, project_path, resolve_tool


def manifest() -> dict:
    return json.loads((ROOT / ".godot-studio/voices.json").read_text(encoding="utf-8"))


def models_directory() -> Path:
    override = os.environ.get("GAC_PIPER_VOICES_DIR")
    if override:
        return Path(override).resolve()
    base = Path(os.environ.get("LOCALAPPDATA", Path.home() / ".local/state"))
    return base / "GodotAssetCloud/AudioTools/piper-voices"


def generate_voice(
    text: str,
    output_path: str,
    voice: str = "siwis",
    speaker: int = 0,
    length_scale: float = 1.0,
) -> dict:
    if not text.strip() or len(text) > 5000:
        raise ValueError("Text must contain between 1 and 5000 characters")
    voices = manifest()["voices"]
    if voice not in voices:
        raise ValueError("Voice must be siwis or mls")
    specification = voices[voice]
    if not 0 <= speaker < specification["speakers"]:
        raise ValueError("Speaker is outside the selected voice's range")
    if not math.isfinite(length_scale) or not 0.5 <= length_scale <= 2.0:
        raise ValueError("Length scale must be between 0.5 and 2.0")
    target = project_path(output_path)
    if target.suffix.lower() != ".wav":
        raise ValueError("Speech output must be WAV")
    if target.exists():
        raise FileExistsError("Output already exists; choose a new path")
    model = models_directory() / (specification["model"] + ".onnx")
    config = model.with_suffix(".onnx.json")
    for file, digest_key in ((model, "model_sha256"), (config, "config_sha256")):
        if not file.is_file():
            raise FileNotFoundError("Voice model missing; run scripts/install_voices.py")
        with file.open("rb") as content:
            if hashlib.file_digest(content, "sha256").hexdigest() != specification[digest_key]:
                raise ValueError("Voice model integrity check failed")
    target.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="voice-", dir=target.parent) as directory:
        temporary = Path(directory) / "speech.wav"
        result = subprocess.run(
            [
                resolve_tool("piper"),
                "--model",
                str(model),
                "--config",
                str(config),
                "--output-file",
                str(temporary),
                "--speaker",
                str(speaker),
                "--length-scale",
                str(length_scale),
            ],
            input=text,
            capture_output=True,
            text=True,
            encoding="utf-8",
            timeout=120,
            cwd=ROOT,
            env={**os.environ, "PYTHONUTF8": "1"},
        )
        if result.returncode:
            raise RuntimeError(f"Piper failed ({result.returncode}): {result.stderr[-2000:]}")
        with wave.open(str(temporary), "rb") as audio:
            frames = audio.getnframes()
            sample_rate = audio.getframerate()
            if frames == 0 or sample_rate == 0:
                raise RuntimeError("Piper generated an empty audio file")
        os.link(temporary, target)
    return {
        "status": "PASS",
        "output": str(target.relative_to(ROOT)),
        "voice": voice,
        "speaker": speaker,
        "sample_rate": sample_rate,
        "duration_seconds": frames / sample_rate,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument("--text")
    source.add_argument("--text-file")
    parser.add_argument("--output", required=True)
    parser.add_argument("--voice", choices=["siwis", "mls"], default="siwis")
    parser.add_argument("--speaker", type=int, default=0)
    parser.add_argument("--length-scale", type=float, default=1.0)
    args = parser.parse_args()
    text = args.text
    if args.text_file:
        file = project_path(args.text_file)
        if file.suffix.lower() != ".txt" or file.stat().st_size > 20000:
            parser.error("Text file must be a project-local .txt file of at most 20 KB")
        text = file.read_text(encoding="utf-8-sig")
    print(
        json.dumps(
            generate_voice(text, args.output, args.voice, args.speaker, args.length_scale), indent=2
        )
    )


if __name__ == "__main__":
    main()
