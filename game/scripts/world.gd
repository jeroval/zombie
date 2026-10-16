extends Node3D

const LIMIT := 34
var grid := AStarGrid2D.new()
var objectives: Array[Dictionary] = []
var radio := Vector3(0, 0, 25)
var extraction := Vector3(0, 0, -29)
var spawn_points := [Vector3(-28, 0, -25), Vector3(28, 0, -25), Vector3(-29, 0, 20), Vector3(29, 0, 20)]

func _ready() -> void:
	grid.region = Rect2i(-LIMIT, -LIMIT, LIMIT * 2 + 1, LIMIT * 2 + 1)
	grid.cell_size = Vector2.ONE
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	grid.update()
	box(Vector3(0, -0.25, 0), Vector3(70, 0.5, 70), Color("6b7370"), false)
	box(Vector3(-35, 2, 0), Vector3(1, 4, 70), Color("303c49"))
	box(Vector3(35, 2, 0), Vector3(1, 4, 70), Color("303c49"))
	box(Vector3(0, 2, -35), Vector3(70, 4, 1), Color("303c49"))
	box(Vector3(0, 2, 35), Vector3(70, 4, 1), Color("303c49"))
	# Temporary collision blockout; final authored meshes will retain these passages.
	for x in [-19.0, 19.0]:
		for z in [-12.0, 9.0]:
			box(Vector3(x, 2.5, z), Vector3(12, 5, 10), Color("b1aaa0"))
	for x in [-7.0, 7.0]:
		box(Vector3(x, 0.65, 2), Vector3(2, 1.3, 6), Color("b18352"))
	add_objective("Batterie", Vector3(-27, 0, -20), Color("7edb9b"))
	add_objective("Carburant", Vector3(27, 0, 15), Color("efb866"))
	add_objective("Antenne", Vector3(20, 0, -26), Color("75d2e5"))
	marker("REFUGE / RADIO", radio, Color("efc779"))
	marker("EVACUATION", extraction, Color("7be5d8"))
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45, -30, 0)
	sun.shadow_enabled = true
	sun.light_color = Color("ffe1b5")
	add_child(sun)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("728c9c")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("a5bdcc")
	env.environment.ambient_light_energy = 0.65
	add_child(env)

func box(pos: Vector3, size: Vector3, color: Color, blocks := true) -> void:
	var solid := StaticBody3D.new()
	solid.position = pos
	var shape := CollisionShape3D.new()
	var collision := BoxShape3D.new()
	collision.size = size
	shape.shape = collision
	solid.add_child(shape)
	var visual := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	visual.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	visual.material_override = mat
	solid.add_child(visual)
	add_child(solid)
	if blocks:
		for x in range(floori(pos.x - size.x / 2 - 0.45), ceili(pos.x + size.x / 2 + 0.45) + 1):
			for z in range(floori(pos.z - size.z / 2 - 0.45), ceili(pos.z + size.z / 2 + 0.45) + 1):
				if grid.is_in_boundsv(Vector2i(x, z)):
					grid.set_point_solid(Vector2i(x, z))

func marker(title: String, pos: Vector3, color: Color) -> Node3D:
	var root := Node3D.new()
	root.position = pos
	add_child(root)
	var mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(0.7, 0.8, 0.7)
	mesh.mesh = box_mesh
	mesh.position.y = 0.6
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color * 0.3
	mesh.material_override = mat
	root.add_child(mesh)
	var label := Label3D.new()
	label.text = title
	label.position.y = 2.5
	label.font_size = 48
	label.pixel_size = 0.009
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	root.add_child(label)
	return root

func add_objective(title: String, pos: Vector3, color: Color) -> void:
	objectives.append({"title": title, "position": pos, "collected": false, "node": marker(title, pos, color)})

func path(from: Vector3, to: Vector3) -> PackedVector3Array:
	var start := Vector2i(clampi(roundi(from.x), -LIMIT, LIMIT), clampi(roundi(from.z), -LIMIT, LIMIT))
	var end := Vector2i(clampi(roundi(to.x), -LIMIT, LIMIT), clampi(roundi(to.z), -LIMIT, LIMIT))
	var result := PackedVector3Array()
	if grid.is_point_solid(start) or grid.is_point_solid(end):
		return result
	for point in grid.get_id_path(start, end):
		result.append(Vector3(point.x, 0, point.y))
	return result
