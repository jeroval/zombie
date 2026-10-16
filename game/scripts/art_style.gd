extends RefCounted

const TOON = preload("res://shaders/inked_toon.gdshader")
const OUTLINE = preload("res://shaders/black_outline.gdshader")
static var materials: Dictionary = {}

static func apply(root: Node, tint := Color.WHITE, width := 0.004) -> void:
	for node in root.find_children("*", "MeshInstance3D", true, false):
		if "StructuralInk" in node.name:
			continue
		for surface in range(node.mesh.get_surface_count()):
			var original: Material = node.mesh.surface_get_material(surface)
			if not original is BaseMaterial3D:
				continue
			var key := str(original.get_rid()) + str(tint) + str(width)
			if not materials.has(key):
				var material := ShaderMaterial.new()
				material.shader = TOON
				material.set_shader_parameter("base_color", original.albedo_color * tint)
				if original.albedo_texture != null:
					material.set_shader_parameter("color_texture", original.albedo_texture)
				var outline := ShaderMaterial.new()
				outline.shader = OUTLINE
				outline.set_shader_parameter("outline_width", width)
				material.next_pass = outline
				materials[key] = material
			node.set_surface_override_material(surface, materials[key])
