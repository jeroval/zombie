"""Build the editable first-person arms for Dernier Signal with Blender."""

import hashlib
import json
from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "art/production/viewmodel"
RUNTIME = ROOT / "game/assets/viewmodel"
SOURCE.mkdir(parents=True, exist_ok=True)
RUNTIME.mkdir(parents=True, exist_ok=True)


def material(name, color):
    value = bpy.data.materials.new(name)
    value.diffuse_color = (*color, 1)
    value.use_nodes = True
    shader = value.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = value.diffuse_color
    shader.inputs["Roughness"].default_value = 1
    return value


def godot(point):
    """Convert a Godot-local XYZ point to Blender XYZ."""
    return Vector((point[0], -point[2], point[1]))


def limb(name, start, end, radius, mat, vertices=8):
    start_blender, end_blender = godot(start), godot(end)
    midpoint = (start_blender + end_blender) * 0.5
    direction = end_blender - start_blender
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=vertices,
        radius=radius,
        depth=direction.length,
        location=midpoint,
    )
    obj = bpy.context.object
    obj.name = name
    obj.rotation_mode = "QUATERNION"
    obj.rotation_quaternion = Vector((0, 0, 1)).rotation_difference(direction.normalized())
    obj.data.materials.append(mat)
    bevel = obj.modifiers.new("SoftFunctionalEdge", "BEVEL")
    bevel.width = 0.008
    bevel.segments = 2
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.modifier_apply(modifier=bevel.name)
    return obj


def rounded_box(name, center, dimensions, mat, bevel_width=0.015):
    bpy.ops.mesh.primitive_cube_add(size=1, location=godot(center))
    obj = bpy.context.object
    obj.name = name
    # Godot dimensions convert X,Y,Z to Blender X,Z,Y.
    obj.dimensions = (dimensions[0], dimensions[2], dimensions[1])
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    bevel = obj.modifiers.new("DrawnRound", "BEVEL")
    bevel.width = bevel_width
    bevel.segments = 2
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.modifier_apply(modifier=bevel.name)
    obj.data.materials.append(mat)
    return obj


def rounded_hand(name, center, dimensions, mat):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=1, location=godot(center))
    obj = bpy.context.object
    obj.name = name
    obj.scale = (dimensions[0] / 2, dimensions[2] / 2, dimensions[1] / 2)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
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
sleeve = material("WarmJacket", (0.55, 0.19, 0.08))
sleeve_dark = material("JacketFoldInk", (0.10, 0.025, 0.018))
skin = material("PaintedSkin", (0.63, 0.34, 0.20))
ink = material("StructuralInk", (0.008, 0.011, 0.016))

# Arms enter from the bottom corners and converge on the grip without hiding the sights.
limb("RightSleeve", (0.43, -0.56, -0.08), (0.28, -0.30, -0.34), 0.058, sleeve)
limb("RightCuff", (0.30, -0.32, -0.31), (0.25, -0.25, -0.40), 0.055, sleeve_dark)
rounded_hand("RightPalm", (0.235, -0.235, -0.435), (0.085, 0.115, 0.07), skin)
for index, x in enumerate([0.195, 0.222, 0.249, 0.276]):
    limb(f"RightFinger{index + 1}", (x, -0.205, -0.435), (x, -0.205, -0.505), 0.013, skin, 7)
limb("RightThumb", (0.19, -0.20, -0.425), (0.245, -0.18, -0.465), 0.017, skin, 7)

limb("LeftSleeve", (-0.34, -0.58, -0.09), (0.07, -0.32, -0.37), 0.06, sleeve)
limb("LeftCuff", (0.035, -0.34, -0.34), (0.115, -0.27, -0.435), 0.055, sleeve_dark)
rounded_hand("LeftPalm", (0.13, -0.255, -0.465), (0.095, 0.10, 0.075), skin)
for index, z in enumerate([-0.43, -0.455, -0.48, -0.505]):
    limb(f"LeftFinger{index + 1}", (0.105, -0.205, z), (0.18, -0.195, z), 0.013, skin, 7)
limb("LeftThumb", (0.14, -0.19, -0.43), (0.19, -0.18, -0.455), 0.017, skin, 7)

# Sparse seams read as authored interior ink under the same comic grammar.
for side, x in [("R", 0.355), ("L", -0.235)]:
    limb(
        f"SleeveSeam{side}",
        (x, -0.41, -0.15),
        (x - (0.08 if side == "R" else -0.15), -0.29, -0.33),
        0.004,
        ink,
        6,
    )

move_to_collection("FPSArms")
bpy.ops.object.select_all(action="SELECT")
blend_path = SOURCE / "fps_arms.blend"
glb_path = RUNTIME / "fps_arms.glb"
bpy.ops.wm.save_as_mainfile(filepath=str(blend_path))
bpy.ops.export_scene.gltf(
    filepath=str(glb_path),
    export_format="GLB",
    use_selection=True,
    use_active_scene=True,
    export_animations=False,
)
triangles = sum(
    sum(len(polygon.vertices) - 2 for polygon in obj.data.polygons)
    for obj in bpy.context.scene.objects
    if obj.type == "MESH"
)
metadata = {
    "id": "fps-arms",
    "status": "EXPERIMENTAL",
    "author": "Project original",
    "license": "Project original",
    "units": "meters",
    "front": "Godot -Z",
    "up": "Godot +Y",
    "triangles": triangles,
    "source": str(blend_path.relative_to(ROOT)),
    "runtime": str(glb_path.relative_to(ROOT)),
    "source_sha256": hashlib.sha256(blend_path.read_bytes()).hexdigest(),
    "runtime_sha256": hashlib.sha256(glb_path.read_bytes()).hexdigest(),
    "intended_camera": "First person, 85 degree vertical field of view",
    "validation": {"godot_import": "NOT_RUN", "camera_view": "NOT_RUN", "motion": "NOT_RUN"},
}
(SOURCE / "metadata.json").write_text(json.dumps(metadata, indent=2), encoding="utf-8")
print("FPS_VIEWMODEL_EXPORTED", json.dumps(metadata))
