"""Author the editable district modules in Blender; coordinates below are Godot XYZ."""

import hashlib
import json
from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "art/production/district"
OUTPUT = ROOT / "game/assets/district"
SOURCE.mkdir(parents=True, exist_ok=True)
OUTPUT.mkdir(parents=True, exist_ok=True)


def material(name, color):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1)
    mat.use_nodes = True
    mat.node_tree.nodes.get("Principled BSDF").inputs[
        "Base Color"
    ].default_value = mat.diffuse_color
    mat.node_tree.nodes.get("Principled BSDF").inputs["Roughness"].default_value = 1
    return mat


def box(name, position, size, mat, bevel=0.02):
    x, y, z = position
    sx, sy, sz = size
    bpy.ops.mesh.primitive_cube_add(size=1, location=(x, -z, y))
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = (sx, sz, sy)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(mat)
    if bevel:
        modifier = obj.modifiers.new("ConstructionEdge", "BEVEL")
        modifier.width = bevel
        modifier.segments = 2
        bpy.ops.object.modifier_apply(modifier=modifier.name)
    return obj


def label(text, position, size, mat):
    x, y, z = position
    bpy.ops.object.text_add(location=(x, -z, y), rotation=(1.5707963, 0, 0))
    obj = bpy.context.object
    obj.name = "Sign_" + text
    obj.data.body = text
    obj.data.align_x = "CENTER"
    obj.data.size = size
    obj.data.extrude = 0.006
    obj.data.materials.append(mat)
    bpy.ops.object.convert(target="MESH")
    return obj


def move_to_collection(name):
    collection = bpy.data.collections.new(name)
    bpy.context.scene.collection.children.link(collection)
    for obj in list(bpy.context.scene.objects):
        collection.objects.link(obj)
        for owner in list(obj.users_collection):
            if owner != collection:
                owner.objects.unlink(obj)


def build(kind, title, wall_color, accent_color, door_width):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    wall = material("PaintedPlaster", wall_color)
    accent = material("IdentityPaint", accent_color)
    ink = material("StructuralInk", (0.012, 0.018, 0.025))
    concrete = material("Concrete", (0.46, 0.49, 0.48))
    glass = material("IllustratedGlass", (0.15, 0.28, 0.33))
    white = material("SignLettering", (0.87, 0.85, 0.71))
    wood = material("Wood", (0.38, 0.24, 0.13))
    walls = []

    def wall_piece(name, position, size):
        box(name, position, size, wall)
        walls.append({"position": position, "size": size})

    wall_piece("RearWall", (0, 1.8, -5), (12, 3.6, 0.3))
    wall_piece("LeftWall", (-6, 1.8, 0), (0.3, 3.6, 10))
    wall_piece("RightWall", (6, 1.8, 0), (0.3, 3.6, 10))
    side = (12 - door_width) / 2
    for sign in [-1, 1]:
        wall_piece("FrontPier", (sign * (door_width / 2 + side / 2), 1.8, 5), (side, 3.6, 0.3))
        box("DoorJamb", (sign * (door_width / 2 + 0.02), 1.35, 5.05), (0.12, 2.7, 0.42), ink)
    # The lintel is above the player, so it does not block the 2D navigation grid.
    box("DoorLintel", (0, 3.15, 5), (door_width, 0.9, 0.3), wall)
    box("DoorHeaderInk", (0, 2.7, 5.05), (door_width + 0.2, 0.12, 0.42), ink)
    box("InteriorFloor", (0, 0.01, 0), (12, 0.02, 10), concrete, 0)
    box("RoofSlab", (0, 3.7, 0), (12.5, 0.2, 10.5), ink)
    box("RoofSurface", (0, 3.83, 0), (12.3, 0.08, 10.3), concrete)
    box("FacadeCornice", (0, 3.65, 5.23), (12.6, 0.18, 0.3), accent)
    box("SignBacking", (0, 3.14, 5.23), (door_width + 1.4, 0.62, 0.16), accent)
    label(title, (0, 2.98, 5.325), 0.31, white)
    for sign in [-1, 1]:
        x = sign * 4.6
        if door_width < 5:
            box("WindowFrame", (x, 1.95, 5.2), (1.65, 1.55, 0.13), ink)
            box("WindowPane", (x, 1.95, 5.28), (1.43, 1.34, 0.08), glass)
            box("WindowMullion", (x, 1.95, 5.34), (0.065, 1.4, 0.06), white)
            box("WindowSill", (x, 1.15, 5.25), (1.85, 0.12, 0.38), concrete)
        box("CornerColumn", (sign * 5.92, 1.8, 5.19), (0.15, 3.6, 0.18), accent)
    for x in [-5.2, -3.4, -1.6, 1.6, 3.4, 5.2]:
        box("PlasterConstructionJoint", (x, 0.48, 5.17), (0.014, 0.8, 0.015), ink, 0)
    for y in [0.12, 0.85]:
        for sign in [-1, 1]:
            box(
                "FoundationSeam",
                (sign * (door_width / 2 + side / 2), y, 5.17),
                (side - 0.1, 0.02, 0.02),
                ink,
                0,
            )
    # Fixtures are deliberately aligned to walls, leaving a clear central route.
    box("Workbench", (3.6, 0.88, -3.9), (3.4, 0.14, 1.1), wood)
    for x in [2.2, 5.0]:
        box("WorkbenchLeg", (x, 0.43, -3.9), (0.13, 0.8, 0.8), ink)
    box("StorageCabinet", (-4.7, 0.7, -3.8), (1.6, 1.4, 1.1), accent)
    for y in [0.4, 0.8, 1.2]:
        box("DrawerSeam", (-4.7, y, -3.235), (1.5, 0.025, 0.02), ink, 0)
        box("DrawerHandle", (-4.7, y + 0.1, -3.2), (0.36, 0.035, 0.04), white)
    if kind == "clinic":
        box("MedicalCrossVertical", (-4.6, 2.0, 5.4), (0.25, 0.95, 0.06), accent)
        box("MedicalCrossHorizontal", (-4.6, 2.0, 5.4), (0.85, 0.25, 0.06), accent)
        box("ExaminationBed", (-3.5, 0.65, 0), (1.5, 0.22, 2.6), white)
        for z in [-1, 1]:
            box("BedFrame", (-3.5, 0.3, z), (1.3, 0.5, 0.1), ink)
        walls.append({"position": [-3.5, 0.5, 0], "size": [1.5, 1, 2.6]})
    elif kind == "telecom":
        for x in [-4.8, -3.4]:
            box("EquipmentRack", (x, 1.3, -3.9), (1.1, 2.6, 0.8), ink)
            for y in [0.4, 0.8, 1.2, 1.6, 2.0, 2.4]:
                box("RackModule", (x, y, -3.46), (0.92, 0.28, 0.07), glass)
                box("StatusLight", (x - 0.32, y, -3.4), (0.08, 0.06, 0.03), accent)
        box("AntennaMast", (0, 6.4, 0), (0.12, 5.2, 0.12), ink)
        for y in [5.3, 6.2, 7.1, 8]:
            box("AntennaCrossbar", (0, y, 0), (2.3, 0.07, 0.07), concrete)
    elif kind == "garage":
        for x in [-4.5, 4.5]:
            box("LiftColumn", (x, 1.4, 0), (0.28, 2.8, 0.45), accent)
        for x in [-3, 0, 3]:
            box("ParkingBayLine", (x, 0.035, 0.4), (0.08, 0.01, 5.8), white, 0)
    move_to_collection("DistrictModule")
    bpy.ops.object.select_all(action="SELECT")
    blend = SOURCE / (kind + ".blend")
    glb = OUTPUT / (kind + ".glb")
    bpy.ops.wm.save_as_mainfile(filepath=str(blend))
    bpy.ops.export_scene.gltf(
        filepath=str(glb),
        export_format="GLB",
        use_selection=True,
        use_active_scene=True,
        export_animations=False,
    )
    points = [
        obj.matrix_world @ Vector(corner)
        for obj in bpy.context.scene.objects
        if obj.type == "MESH"
        for corner in obj.bound_box
    ]
    spans = [max(p[i] for p in points) - min(p[i] for p in points) for i in range(3)]
    return {
        "id": kind,
        "status": "EXPERIMENTAL",
        "walls": walls,
        "source": str(blend.relative_to(ROOT)),
        "runtime": str(glb.relative_to(ROOT)),
        "source_sha256": hashlib.sha256(blend.read_bytes()).hexdigest(),
        "runtime_sha256": hashlib.sha256(glb.read_bytes()).hexdigest(),
        "bounds_m": [spans[0], spans[2], spans[1]],
        "door_width_m": door_width,
        "license": "Project original",
        "front": "+Z",
        "up": "+Y",
    }


records = [
    build("clinic", "CLINIQUE", (0.73, 0.74, 0.64), (0.18, 0.45, 0.36), 2.6),
    build("garage", "GARAGE  /  SERVICE", (0.56, 0.45, 0.31), (0.72, 0.31, 0.09), 6.0),
    build("telecom", "RELAIS  TELECOM", (0.38, 0.48, 0.53), (0.15, 0.55, 0.60), 2.6),
]
(SOURCE / "build.json").write_text(json.dumps(records, indent=2), encoding="utf-8")
data = ROOT / "game/data"
data.mkdir(exist_ok=True)
(data / "buildings.json").write_text(
    json.dumps({r["id"]: {"walls": r["walls"]} for r in records}, indent=2), encoding="utf-8"
)
print("DISTRICT_MODULES_EXPORTED", len(records))
