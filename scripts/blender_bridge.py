"""Enable the installed bridge in this Blender session, without saving preferences."""

import bpy

bpy.ops.preferences.addon_enable(module="blender_mcp")
bpy.context.scene.blendermcp_port = 9876
bpy.context.scene.blendermcp_use_polyhaven = True
bpy.ops.blendermcp.start_server()
