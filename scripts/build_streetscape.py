"""Build the editable street, sidewalks, route markings and perimeter backdrop."""

import hashlib
import json
from pathlib import Path

import bpy

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "art/production/streetscape"
RUNTIME = ROOT / "game/assets/district"
SOURCE.mkdir(parents=True, exist_ok=True)
RUNTIME.mkdir(parents=True, exist_ok=True)


def material(name, color):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1)
    mat.use_nodes = True
    shader = mat.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = mat.diffuse_color
    shader.inputs["Roughness"].default_value = 1
    return mat


def box(name, position, size, mat, bevel=0.0):
    x, y, z = position
    sx, sy, sz = size
    bpy.ops.mesh.primitive_cube_add(size=1, location=(x, -z, y))
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = (sx, sz, sy)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bevel:
        modifier = obj.modifiers.new("ConstructedEdge", "BEVEL")
        modifier.width = bevel
        modifier.segments = 2
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.modifier_apply(modifier=modifier.name)
    obj.data.materials.append(mat)
    return obj


def move_to_collection(name):
    collection = bpy.data.collections.new(name)
    bpy.context.scene.collection.children.link(collection)
    for obj in list(bpy.context.scene.objects):
        collection.objects.link(obj)
        for owner in list(obj.users_collection):
            if owner != collection:
                owner.objects.unlink(obj)


bpy.ops.wm.read_factory_settings(use_empty=True)
asphalt = material("AsphaltBlue", (0.025, 0.035, 0.045))
sidewalk = material("DustyConcrete", (0.22, 0.21, 0.18))
curb = material("CurbInk", (0.035, 0.045, 0.05))
line = material("RoadCream", (0.82, 0.71, 0.42))
cyan = material("ExtractionCyan", (0.09, 0.53, 0.58))
amber = material("RefugeAmber", (0.79, 0.38, 0.08))
brick = material("PerimeterBrick", (0.14, 0.10, 0.09))
plaster = material("PerimeterPlaster", (0.22, 0.18, 0.13))
glass = material("WindowBlue", (0.025, 0.06, 0.08))

box("VerticalRoad", (0, 0.015, 0), (18, 0.03, 70), asphalt)
box("HorizontalRoad", (0, 0.018, 0), (70, 0.036, 14), asphalt)
for x in [-22, 22]:
    for z in [-21, 21]:
        box("SidewalkBlock", (x, 0.035, z), (25, 0.07, 27), sidewalk)
for x in [-9.2, 9.2]:
    box("LongCurb", (x, 0.07, 0), (0.22, 0.14, 70), curb, 0.02)
for z in [-7.2, 7.2]:
    box("CrossCurb", (0, 0.073, z), (70, 0.146, 0.22), curb, 0.02)
for z in range(-31, 32, 6):
    if abs(z) > 6:
        box("VerticalLaneDash", (0, 0.042, z), (0.14, 0.02, 2.6), line)
for x in range(-31, 32, 6):
    if abs(x) > 8:
        box("HorizontalLaneDash", (x, 0.045, 0), (2.6, 0.02, 0.14), line)
for x in range(-7, 8, 2):
    box("RefugeCrosswalk", (x, 0.05, 21.5), (1.1, 0.025, 3.0), line)
for index, width in enumerate([7.5, 5.5, 3.5]):
    box("ExtractionChevron", (0, 0.052, -26 - index * 1.8), (width, 0.028, 0.28), cyan)
for x, z, sx, sz in [(0, 25, 5.0, 3.8), (0, -29, 4.0, 4.0)]:
    accent = amber if z > 0 else cyan
    box("MissionGroundMark", (x, 0.055, z), (sx, 0.03, 0.16), accent)
    box("MissionGroundMark", (x, 0.056, z), (0.16, 0.03, sz), accent)

# Constructed perimeter masks the collision shell with recognizable urban facades.
for side in [-1, 1]:
    x = side * 34.5
    for z in [-28, -14, 0, 14, 28]:
        height = 5.0 + ((abs(z) // 14) % 2) * 2.0
        mat = brick if (z // 14) % 2 else plaster
        box("PerimeterFacade", (x, height / 2, z), (0.9, height, 13.6), mat, 0.05)
        for y in [1.8, 3.4, 5.0]:
            if y > height - 0.5:
                continue
            for dz in [-4.3, 0, 4.3]:
                box("FacadeWindow", (x - side * 0.48, y, z + dz), (0.04, 0.72, 1.65), glass, 0.02)
for side in [-1, 1]:
    z = side * 34.5
    for x in [-28, -14, 0, 14, 28]:
        height = 5.0 + ((abs(x) // 14) % 2) * 1.5
        mat = plaster if (x // 14) % 2 else brick
        box("PerimeterFacade", (x, height / 2, z), (13.6, height, 0.9), mat, 0.05)
        for y in [1.8, 3.4, 5.0]:
            if y > height - 0.5:
                continue
            for dx in [-4.3, 0, 4.3]:
                box("FacadeWindow", (x + dx, y, z - side * 0.48), (1.65, 0.72, 0.04), glass, 0.02)

move_to_collection("Streetscape")
bpy.ops.object.select_all(action="SELECT")
blend = SOURCE / "streetscape.blend"
glb = RUNTIME / "streetscape.glb"
bpy.ops.wm.save_as_mainfile(filepath=str(blend))
bpy.ops.export_scene.gltf(
    filepath=str(glb),
    export_format="GLB",
    use_selection=True,
    use_active_scene=True,
    export_animations=False,
)
metadata = {
    "id": "streetscape",
    "status": "EXPERIMENTAL",
    "author": "Project original",
    "license": "Project original",
    "bounds_m": [70, 7, 70],
    "source": str(blend.relative_to(ROOT)),
    "runtime": str(glb.relative_to(ROOT)),
    "source_sha256": hashlib.sha256(blend.read_bytes()).hexdigest(),
    "runtime_sha256": hashlib.sha256(glb.read_bytes()).hexdigest(),
}
(SOURCE / "metadata.json").write_text(json.dumps(metadata, indent=2), encoding="utf-8")
print("STREETSCAPE_EXPORTED", json.dumps(metadata))
