"""Verify Blender GLB and FFmpeg audio import with actual Godot playback."""

import json
import math
import struct
import sys
import uuid
import wave

from studio import GAME, ROOT, convert_audio, godot_smoke, probe_audio, resolve_tool, run_checked


def verify_pipeline() -> dict:
    output = GAME / "studio_fixtures" / uuid.uuid4().hex
    output.mkdir(parents=True)
    source = ROOT / ".tools/verification" / output.name
    source.mkdir(parents=True)
    run_checked(
        [
            resolve_tool("blender"),
            "--background",
            "--factory-startup",
            "--python-exit-code",
            "1",
            "--python",
            str(ROOT / "scripts/blender_smoke.py"),
            "--",
            str(output),
            str(source),
        ],
        180,
    )
    with wave.open(str(output / "tone.wav"), "wb") as audio:
        audio.setparams((1, 2, 48000, 0, "NONE", "not compressed"))
        samples = (int(1000 * math.sin(2 * math.pi * 440 * i / 48000)) for i in range(12000))
        audio.writeframes(b"".join(struct.pack("<h", value) for value in samples))
    convert_audio(
        str((output / "tone.wav").relative_to(ROOT)), str((output / "tone.ogg").relative_to(ROOT))
    )
    probe = probe_audio(str((output / "tone.ogg").relative_to(ROOT)))
    godot_smoke()
    result = run_checked(
        [
            resolve_tool("godot"),
            "--headless",
            "--path",
            str(GAME),
            "--script",
            "res://tests/studio_roundtrip.gd",
            "--",
            str(output),
        ],
        60,
        godot=True,
    )
    if "STUDIO_ROUNDTRIP_PASS" not in result["output"]:
        raise RuntimeError("Godot did not report the roundtrip success marker")
    report = {
        "status": "PASS",
        "blender_glb_animation": "PASS",
        "godot_audio_playback": "PASS",
        "audio_duration_seconds": probe["format"]["duration"],
        "evidence": str(output.relative_to(ROOT)),
        "scope": "technical import and playback; visual/artistic/audible review not run",
    }
    (output / "report.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    return report


if __name__ == "__main__":
    sys.stdout.write(json.dumps(verify_pipeline(), indent=2) + "\n")
