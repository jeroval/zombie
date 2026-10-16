"""Render the original Dernier Signal application icon from vector-like primitives."""

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "game/assets/ui/dernier_signal_icon.png"
SCALE = 4


def point(value: int) -> int:
    return value * SCALE


def box(values: tuple[int, int, int, int]) -> tuple[int, int, int, int]:
    return tuple(point(value) for value in values)


image = Image.new("RGBA", (point(256), point(256)), "#00000000")
draw = ImageDraw.Draw(image)
draw.rounded_rectangle(
    box((8, 8, 248, 248)),
    radius=point(44),
    fill="#0b151d",
    outline="#d6b96d",
    width=point(12),
)
draw.line(box((128, 36, 128, 94)), fill="#67d6db", width=point(11))
draw.arc(box((103, 43, 153, 91)), 205, 335, fill="#67d6db", width=point(11))
draw.arc(box((86, 20, 170, 92)), 205, 335, fill="#67d6db", width=point(11))
draw.rounded_rectangle(
    box((79, 93, 177, 207)),
    radius=point(46),
    fill="#d8ce91",
    outline="#17242b",
    width=point(10),
)
draw.rectangle(box((108, 174, 148, 221)), fill="#d8ce91")
draw.ellipse(box((95, 136, 121, 162)), fill="#17242b")
draw.ellipse(box((135, 136, 161, 162)), fill="#17242b")
draw.polygon(
    [(point(128), point(160)), (point(119), point(177)), (point(137), point(177))], fill="#17242b"
)
for x, top in ((108, 183), (121, 183), (135, 183), (148, 183)):
    draw.line(box((x, top, x, 218 if x in (121, 135) else 211)), fill="#17242b", width=point(8))
draw.polygon(
    [(point(193), point(171)), (point(221), point(155)), (point(221), point(187))],
    fill="#d95f43",
    outline="#17242b",
)
image.resize((256, 256), Image.Resampling.LANCZOS).save(OUTPUT, optimize=True)
print(OUTPUT)
