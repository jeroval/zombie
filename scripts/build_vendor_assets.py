"""Run with Blender --background --factory-startup --python this_file.

Preserve downloaded originals, add editable structural ink, export candidates.
Godot owns instance placement, collisions, toon response and contour rendering.
"""

import hashlib
import json
import math
from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[1]
VENDOR = ROOT / "art/vendor/quaternius-zombie"
SOURCE = ROOT / "art/production/quaternius"
OUTPUT = ROOT / "game/assets/models"
SOURCE.mkdir(parents=True, exist_ok=True)
OUTPUT.mkdir(parents=True, exist_ok=True)


def add_structural_ink(obj):
    """Skin narrow surface strips to the same vertices as their source edges."""
    mesh = obj.data
    edge_faces = {}
    for face in mesh.polygons:
        for edge in face.edge_keys:
            edge_faces.setdefault(tuple(sorted(edge)), []).append(face)
    vertices, faces, weights = [], [], []
    for pair, adjacent in edge_faces.items():
        if len(adjacent) != 2:
            continue
        first, second = adjacent
        angle = first.normal.angle(second.normal, 0)
        if angle < math.radians(48):
            continue
        a, b = (mesh.vertices[i] for i in pair)
        if (a.co - b.co).length < 0.06:
            continue
        for face in adjacent:
            midpoint = (a.co + b.co) / 2
            inward = face.center - midpoint
            inward -= (b.co - a.co).normalized() * inward.dot((b.co - a.co).normalized())
            if inward.length < 0.0001:
                continue
            inward.normalize()
            normal_offset = face.normal * 0.0012
            width = min(0.003, (a.co - b.co).length * 0.03)
            start = len(vertices)
            vertices.extend(
                [
                    a.co + normal_offset,
                    b.co + normal_offset,
                    b.co + normal_offset + inward * width,
                    a.co + normal_offset + inward * width,
                ]
            )
            faces.append((start, start + 1, start + 2, start + 3))
            for vertex in [a, b, b, a]:
                weights.append([(g.group, g.weight) for g in vertex.groups])
    if not faces:
        return
    ink_mesh = bpy.data.meshes.new(obj.name + "_StructuralInk")
    ink_mesh.from_pydata(vertices, [], faces)
    ink_mesh.update()
    ink = bpy.data.objects.new(ink_mesh.name, ink_mesh)
    bpy.context.collection.objects.link(ink)
    ink.parent = obj.parent
    ink.matrix_local = obj.matrix_local.copy()
    for group in obj.vertex_groups:
        ink.vertex_groups.new(name=group.name)
    for index, groups in enumerate(weights):
        for group, weight in groups:
            ink.vertex_groups[group].add([index], weight, "REPLACE")
    for modifier in obj.modifiers:
        if modifier.type == "ARMATURE":
            copy = ink.modifiers.new("FollowOriginalRig", "ARMATURE")
            copy.object = modifier.object
    material = bpy.data.materials.get("StructuralInk") or bpy.data.materials.new("StructuralInk")
    material.diffuse_color = (0.009, 0.012, 0.018, 1)
    material.use_nodes = True
    bsdf = material.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = material.diffuse_color
    bsdf.inputs["Roughness"].default_value = 1
    ink.data.materials.append(material)


def build(relative):
    original = VENDOR / relative
    asset_id = original.stem.lower()
    bpy.ops.wm.open_mainfile(filepath=str(original))
    for obj in list(bpy.context.scene.objects):
        if obj.type not in {"MESH", "ARMATURE", "EMPTY"}:
            bpy.data.objects.remove(obj, do_unlink=True)
    for image in bpy.data.images:
        if "Zombie_Atlas" in image.name or "Zombie_Atlas" in image.filepath:
            if image.packed_file:
                image.unpack(method="REMOVE")
            image.filepath = str(original.parent / "Zombie_Atlas.png")
            image.reload()
            image.pack()
    rigs = [o for o in bpy.context.scene.objects if o.type == "ARMATURE"]
    for rig in rigs:
        if "Idle" in bpy.data.actions:
            rig.animation_data_create()
            rig.animation_data.action = bpy.data.actions["Idle"]
    bpy.context.scene.frame_set(0)
    bpy.context.view_layer.update()
    meshes = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    points = [obj.matrix_world @ Vector(corner) for obj in meshes for corner in obj.bound_box]
    height = max(p.z for p in points) - min(p.z for p in points)
    root = bpy.data.objects.new(asset_id, None)
    bpy.context.collection.objects.link(root)
    for obj in list(bpy.context.scene.objects):
        if obj != root and obj.parent is None:
            obj.parent = root
    factor = 1.75 / height if rigs else 1.0
    if original.stem == "Pistol":
        factor = 0.34
    root.scale = (factor,) * 3
    root.location.z = -min(p.z for p in points) * factor
    for obj in meshes:
        add_structural_ink(obj)
    bpy.ops.object.select_all(action="DESELECT")
    for obj in bpy.context.scene.objects:
        obj.hide_set(False)
        obj.hide_viewport = False
        obj.hide_render = False
        obj.select_set(True)
    bpy.context.view_layer.objects.active = root
    bpy.context.scene.render.fps = 30
    bpy.context.view_layer.update()
    blend = SOURCE / (asset_id + ".blend")
    glb = OUTPUT / (asset_id + ".glb")
    bpy.ops.wm.save_as_mainfile(filepath=str(blend))
    bpy.ops.export_scene.gltf(
        filepath=str(glb),
        export_format="GLB",
        use_selection=True,
        use_active_scene=True,
        export_animations=bool(rigs),
        export_animation_mode="ACTIONS",
        export_force_sampling=True,
    )
    return {
        "id": asset_id,
        "status": "EXPERIMENTAL",
        "source_original": str(original.relative_to(ROOT)),
        "source": str(blend.relative_to(ROOT)),
        "runtime": str(glb.relative_to(ROOT)),
        "source_sha256": hashlib.sha256(blend.read_bytes()).hexdigest(),
        "runtime_sha256": hashlib.sha256(glb.read_bytes()).hexdigest(),
        "normalization_scale": factor,
        "animations": [a.name for a in bpy.data.actions] if rigs else [],
        "triangles_source": sum(
            sum(len(p.vertices) - 2 for p in o.data.polygons)
            for o in bpy.context.scene.objects
            if o.type == "MESH"
        ),
        "front": "Source -Y, imported Godot +Z; validate runtime rotation",
        "up": "Godot +Y",
        "ink": "Editable skinned strips on selected sharp construction edges",
        "validation": {
            "import": "NOT_RUN",
            "animation": "NOT_RUN",
            "visual": "NOT_RUN",
            "sheet": "NOT_RUN",
        },
    }


records = []
for relative in [
    "Characters/Zombie_Basic.blend",
    "Weapons/Pistol.blend",
    "Environment/Barrel.blend",
    "Environment/Chest.blend",
    "Environment/Container_Green.blend",
    "Environment/Pallet.blend",
    "Environment/StreetLights.blend",
    "Environment/TrafficBarrier_1.blend",
    "Environment/TrashBag_1.blend",
    "Vehicles/Vehicle_Pickup.blend",
    "Vehicles/Vehicle_Truck.blend",
    "Environment/WaterTower.blend",
]:
    records.append(build(relative))
(SOURCE / "build.json").write_text(
    json.dumps({"blender": bpy.app.version_string, "assets": records}, indent=2), encoding="utf-8"
)
print("VENDOR_CANDIDATES_EXPORTED", len(records))
