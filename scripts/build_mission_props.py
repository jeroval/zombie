"""Build editable mission-critical props for the FPS objective loop."""

import hashlib
import json
import math
from pathlib import Path

import bpy

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "art/production/mission-props"
RUNTIME = ROOT / "game/assets/mission"
SOURCE.mkdir(parents=True, exist_ok=True)
RUNTIME.mkdir(parents=True, exist_ok=True)


def material(name, color, emission=0.0):
    value = bpy.data.materials.new(name)
    value.diffuse_color = (*color, 1)
    value.use_nodes = True
    shader = value.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = value.diffuse_color
    shader.inputs["Roughness"].default_value = 1
    if emission:
        shader.inputs["Emission Color"].default_value = value.diffuse_color
        shader.inputs["Emission Strength"].default_value = emission
    return value


def box(name, position, size, mat, bevel=0.012):
    x, y, z = position
    sx, sy, sz = size
    bpy.ops.mesh.primitive_cube_add(size=1, location=(x, -z, y))
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = (sx, sz, sy)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bevel:
        modifier = obj.modifiers.new("DrawnEdge", "BEVEL")
        modifier.width = bevel
        modifier.segments = 2
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.modifier_apply(modifier=modifier.name)
    obj.data.materials.append(mat)
    return obj


def cylinder(name, position, radius, depth, mat, vertices=12, rotation=(0, 0, 0)):
    x, y, z = position
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=vertices,
        radius=radius,
        depth=depth,
        location=(x, -z, y),
        rotation=rotation,
    )
    obj = bpy.context.object
    obj.name = name
    obj.data.materials.append(mat)
    return obj


def common_materials():
    return {
        "ink": material("StructuralInk", (0.008, 0.012, 0.017)),
        "metal": material("PaintedMetal", (0.18, 0.23, 0.25)),
        "cream": material("Lettering", (0.86, 0.83, 0.68)),
        "green": material("BatteryGreen", (0.22, 0.48, 0.34)),
        "orange": material("FuelOrange", (0.78, 0.29, 0.08)),
        "cyan": material("SignalCyan", (0.08, 0.57, 0.65), 0.35),
        "amber": material("RescueAmber", (0.95, 0.56, 0.12), 0.55),
    }


def move_to_collection(name):
    collection = bpy.data.collections.new(name)
    bpy.context.scene.collection.children.link(collection)
    for obj in list(bpy.context.scene.objects):
        collection.objects.link(obj)
        for owner in list(obj.users_collection):
            if owner != collection:
                owner.objects.unlink(obj)


def battery(mat):
    box("BatteryBody", (0, 0.26, 0), (0.62, 0.48, 0.34), mat["green"], 0.035)
    box("BatteryTop", (0, 0.53, 0), (0.56, 0.08, 0.31), mat["ink"])
    for x, color in [(-0.19, mat["cream"]), (0.19, mat["orange"])]:
        cylinder("Terminal", (x, 0.62, 0), 0.07, 0.12, color)
    for x in [-0.25, 0.25]:
        box("CaseSeam", (x, 0.27, -0.175), (0.022, 0.36, 0.012), mat["ink"], 0)
    box("ChargeMark", (0, 0.28, -0.183), (0.08, 0.24, 0.014), mat["cream"], 0)
    box("ChargeMark", (0, 0.28, -0.19), (0.20, 0.07, 0.014), mat["cream"], 0)


def fuel(mat):
    box("FuelCan", (0, 0.34, 0), (0.48, 0.66, 0.24), mat["orange"], 0.04)
    box("FuelCanInner", (0, 0.52, -0.13), (0.22, 0.15, 0.04), mat["ink"], 0.015)
    for x in [-0.18, 0.18]:
        box("Handle", (x, 0.69, 0), (0.07, 0.25, 0.08), mat["ink"])
    box("Handle", (0, 0.80, 0), (0.42, 0.07, 0.08), mat["ink"])
    cylinder("FuelCap", (0.17, 0.77, 0), 0.065, 0.10, mat["cream"])
    for sign in [-1, 1]:
        box("PressedRib", (sign * 0.10, 0.31, -0.13), (0.025, 0.42, 0.02), mat["ink"], 0)


def antenna(mat):
    box("Receiver", (0, 0.22, 0), (0.62, 0.42, 0.42), mat["cyan"], 0.035)
    box("ReceiverPanel", (0, 0.23, -0.22), (0.46, 0.24, 0.04), mat["ink"], 0.012)
    for x in [-0.14, 0, 0.14]:
        cylinder(
            "StatusLamp", (x, 0.25, -0.25), 0.035, 0.035, mat["amber"], rotation=(math.pi / 2, 0, 0)
        )
    cylinder("Antenna", (0, 0.91, 0), 0.025, 1.0, mat["ink"], 10)
    for y, width in [(0.65, 0.36), (0.90, 0.50), (1.15, 0.32)]:
        box("SignalBar", (0, y, 0), (width, 0.035, 0.035), mat["cream"], 0.005)


def radio(mat):
    box("RadioCase", (0, 0.46, 0), (1.30, 0.82, 0.58), mat["metal"], 0.055)
    box("RadioPanel", (0, 0.47, -0.31), (1.12, 0.62, 0.05), mat["ink"], 0.018)
    box("FrequencyDisplay", (-0.25, 0.60, -0.35), (0.45, 0.17, 0.04), mat["cyan"], 0.012)
    for x in [0.18, 0.38, 0.53]:
        cylinder(
            "RadioKnob", (x, 0.43, -0.37), 0.065, 0.05, mat["cream"], rotation=(math.pi / 2, 0, 0)
        )
    for x in [-0.48, -0.32, -0.16, 0, 0.16, 0.32, 0.48]:
        box("SpeakerSlot", (x, 0.25, -0.35), (0.035, 0.18, 0.025), mat["cream"], 0)
    cylinder(
        "RadioAntenna", (0.48, 1.30, 0.12), 0.018, 1.28, mat["ink"], 10, rotation=(0.18, 0, 0.08)
    )
    box("CarryHandle", (0, 0.94, 0), (0.72, 0.07, 0.08), mat["ink"])


def beacon(mat):
    cylinder("BeaconBase", (0, 0.12, 0), 0.55, 0.24, mat["ink"], 16)
    cylinder("BeaconColumn", (0, 0.78, 0), 0.12, 1.32, mat["metal"], 12)
    for y, radius in [(0.45, 0.24), (0.85, 0.30), (1.25, 0.36)]:
        cylinder("SignalRing", (0, y, 0), radius, 0.07, mat["cyan"], 16)
    cylinder("BeaconLamp", (0, 1.58, 0), 0.24, 0.38, mat["amber"], 16)
    cylinder("BeaconCap", (0, 1.81, 0), 0.30, 0.08, mat["ink"], 16)


def build(asset_id, builder):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    builder(common_materials())
    move_to_collection("MissionProp")
    bpy.ops.object.select_all(action="SELECT")
    blend = SOURCE / f"{asset_id}.blend"
    glb = RUNTIME / f"{asset_id}.glb"
    bpy.ops.wm.save_as_mainfile(filepath=str(blend))
    bpy.ops.export_scene.gltf(
        filepath=str(glb),
        export_format="GLB",
        use_selection=True,
        use_active_scene=True,
        export_animations=False,
    )
    triangles = sum(
        sum(len(poly.vertices) - 2 for poly in obj.data.polygons)
        for obj in bpy.context.scene.objects
        if obj.type == "MESH"
    )
    return {
        "id": asset_id,
        "status": "EXPERIMENTAL",
        "author": "Project original",
        "license": "Project original",
        "source": str(blend.relative_to(ROOT)),
        "runtime": str(glb.relative_to(ROOT)),
        "triangles": triangles,
        "source_sha256": hashlib.sha256(blend.read_bytes()).hexdigest(),
        "runtime_sha256": hashlib.sha256(glb.read_bytes()).hexdigest(),
        "godot_import": "NOT_RUN",
        "fps_view": "NOT_RUN",
    }


records = [
    build("battery", battery),
    build("fuel_can", fuel),
    build("antenna_module", antenna),
    build("radio_console", radio),
    build("extraction_beacon", beacon),
]
(SOURCE / "build.json").write_text(json.dumps(records, indent=2), encoding="utf-8")
print("MISSION_PROPS_EXPORTED", len(records))
