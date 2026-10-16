"""Generate original, deterministic sound effects and a restrained ambient loop."""

import hashlib
import json
import math
import random
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "game/audio/generated"
OUTPUT.mkdir(parents=True, exist_ok=True)
RATE = 48_000
random.seed(7319)


def write(name, seconds, sample):
    path = OUTPUT / f"{name}.wav"
    frames = bytearray()
    peak = 0.0
    for index in range(round(seconds * RATE)):
        value = max(-1.0, min(1.0, sample(index / RATE)))
        peak = max(peak, abs(value))
        integer = round(value * 32767)
        frames += int(integer).to_bytes(2, "little", signed=True) * 2
    with wave.open(str(path), "wb") as audio:
        audio.setnchannels(2)
        audio.setsampwidth(2)
        audio.setframerate(RATE)
        audio.writeframes(frames)
    return {
        "file": str(path.relative_to(ROOT)),
        "duration_seconds": seconds,
        "sample_rate_hz": RATE,
        "channels": 2,
        "peak": peak,
        "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
    }


def noise():
    return random.random() * 2 - 1


assets = []
assets.append(
    write(
        "pistol_shot",
        0.34,
        lambda t: (
            (0.72 * noise() + 0.30 * math.sin(2 * math.pi * (115 - 80 * t) * t)) * math.exp(-18 * t)
        ),
    )
)
assets.append(
    write(
        "empty_click",
        0.11,
        lambda t: (noise() * 0.25 + math.sin(2 * math.pi * 1700 * t) * 0.18) * math.exp(-55 * t),
    )
)


def reload_sample(t):
    value = 0.0
    for at, frequency in [(0.04, 850), (0.32, 620), (0.71, 1100), (1.02, 760)]:
        age = t - at
        if 0 <= age < 0.1:
            value += (0.22 * noise() + 0.16 * math.sin(2 * math.pi * frequency * age)) * math.exp(
                -42 * age
            )
    return value


assets.append(write("reload", 1.18, reload_sample))
assets.append(
    write(
        "melee_swing",
        0.30,
        lambda t: noise() * 0.24 * math.sin(math.pi * min(1, t / 0.3)) * (1 - t / 0.3),
    )
)
assets.append(
    write(
        "hit_enemy",
        0.18,
        lambda t: (noise() * 0.32 + math.sin(2 * math.pi * 105 * t) * 0.25) * math.exp(-24 * t),
    )
)
assets.append(
    write(
        "hurt",
        0.42,
        lambda t: (
            (math.sin(2 * math.pi * (64 - 20 * t) * t) + noise() * 0.2) * 0.32 * math.exp(-6 * t)
        ),
    )
)
assets.append(
    write(
        "pickup",
        0.42,
        lambda t: 0.20 * math.sin(2 * math.pi * (500 + 900 * t) * t) * math.exp(-3 * t),
    )
)
assets.append(
    write(
        "radio_on",
        0.85,
        lambda t: (
            noise() * 0.12 * (1 - t / 0.85)
            + 0.10 * math.sin(2 * math.pi * 220 * t) * math.exp(-2 * t)
        ),
    )
)
assets.append(
    write(
        "extract",
        1.35,
        lambda t: (
            0.14
            * sum(math.sin(2 * math.pi * frequency * t) for frequency in (262, 330, 392))
            * min(1, t * 4)
            * (1 - t / 1.35)
        ),
    )
)


def ambience(t):
    wind = noise() * 0.025
    drone = 0.05 * math.sin(2 * math.pi * 49 * t) + 0.025 * math.sin(2 * math.pi * 73.5 * t)
    pulse = 0.0
    beat = t % 2.4
    if beat < 0.32:
        pulse = 0.055 * math.sin(2 * math.pi * 92 * beat) * math.exp(-8 * beat)
    return (wind + drone + pulse) * min(1, t / 3) * min(1, (45 - t) / 3)


assets.append(write("empty_city_loop", 45.0, ambience))
manifest = {
    "schema_version": 1,
    "author": "Project original, generated deterministically",
    "license": "Project original",
    "generator": "scripts/build_audio.py",
    "seed": 7319,
    "assets": assets,
}
(OUTPUT / "manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
print("AUDIO_ASSETS_GENERATED", len(assets))
