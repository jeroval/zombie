"""Disposable deterministic Blender export used by the studio self-test."""

import sys
from pathlib import Path

import bpy

target = Path(sys.argv[sys.argv.index("--") + 1])
source = Path(sys.argv[sys.argv.index("--") + 2])
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
bpy.ops.mesh.primitive_cube_add(size=1)
cube = bpy.context.object
cube.name = "StudioProbe"
cube.rotation_euler.z = 0
cube.keyframe_insert(data_path="rotation_euler", frame=1)
cube.rotation_euler.z = 1.0
cube.keyframe_insert(data_path="rotation_euler", frame=25)
bpy.context.scene.render.fps = 24
bpy.context.scene.frame_start = 1
bpy.context.scene.frame_end = 25
bpy.ops.wm.save_as_mainfile(filepath=str(source / "probe.blend"))
bpy.ops.export_scene.gltf(
    filepath=str(target / "probe.glb"),
    export_format="GLB",
    use_selection=True,
    use_active_scene=True,
    export_animations=True,
)
