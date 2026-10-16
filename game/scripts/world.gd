extends Node3D

const LIMIT := 34
var grid := AStarGrid2D.new()
var objectives: Array[Dictionary] = []
var supplies: Array[Dictionary] = []
var radio := Vector3(0, 0, 25)
var extraction := Vector3(0, 0, -29)
var spawn_points := [Vector3(-28, 0, -25), Vector3(28, 0, -25), Vector3(-29, 0, 20), Vector3(29, 0, 20)]
const ArtStyle = preload("res://scripts/art_style.gd")

func _ready() -> void:
	grid.region = Rect2i(-LIMIT, -LIMIT, LIMIT * 2 + 1, LIMIT * 2 + 1)
	grid.cell_size = Vector2.ONE
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	grid.update()
	box(Vector3(0, -0.25, 0), Vector3(70, 0.5, 70), Color("6b7370"), false)
	box(Vector3(-35, 2, 0), Vector3(1, 4, 70), Color.WHITE, true, false)
	box(Vector3(35, 2, 0), Vector3(1, 4, 70), Color.WHITE, true, false)
	box(Vector3(0, 2, -35), Vector3(70, 4, 1), Color.WHITE, true, false)
	box(Vector3(0, 2, 35), Vector3(70, 4, 1), Color.WHITE, true, false)
	var street: Node3D = load("res://assets/district/streetscape.glb").instantiate()
	add_child(street)
	ArtStyle.apply(street, Color.WHITE, 0.004)
	building("clinic", Vector3(-19, 0, -12))
	building("garage", Vector3(19, 0, 9))
	building("telecom", Vector3(19, 0, -12))
	for x in [-7.0, 7.0]:
		prop("vehicle_pickup", Vector3(x, 0, 2), Vector3(2.3, 1.8, 5.2))
	prop("container_green", Vector3(-20, 0, 11), Vector3(2.6, 2.8, 6.2))
	prop("vehicle_truck", Vector3(-20, 0, 23), Vector3(2.5, 2.3, 6.4))
	for pos in [Vector3(-9, 0, 18), Vector3(9, 0, 18), Vector3(-9, 0, -20), Vector3(9, 0, -20)]:
		prop("streetlights", pos, Vector3(0.35, 3.5, 0.35))
	for pos in [Vector3(-24, 0, -4), Vector3(24, 0, 17), Vector3(25, 0, -4)]:
		prop("barrel", pos, Vector3(0.8, 1.2, 0.8))
	prop("trafficbarrier_1", Vector3(-13, 0, 7), Vector3(2.4, 1.0, 0.55))
	prop("pallet", Vector3(-27, 0, -8), Vector3(1.3, 0.25, 1.3))
	decoration("trashbag_1", Vector3(-12, 0, -9))
	decoration("trashbag_1", Vector3(28, 0, 25))
	decoration("watertower", Vector3(-29, 0, -28))
	add_supply(Vector3(-25, 0, -17))
	add_supply(Vector3(25, 0, 11))
	add_supply(Vector3(12, 0, -25))
	add_objective("Batterie", Vector3(-19, 0, -15), Color("7edb9b"), "battery")
	add_objective("Carburant", Vector3(19, 0, 6), Color("efb866"), "fuel_can")
	add_objective("Antenne", Vector3(19, 0, -15), Color("75d2e5"), "antenna_module")
	marker("REFUGE / RADIO", radio, Color("efc779"), "radio_console")
	marker("EVACUATION", extraction, Color("7be5d8"), "extraction_beacon")
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

func building(kind: String, pos: Vector3) -> void:
	var model: Node3D = load("res://assets/district/" + kind + ".glb").instantiate()
	add_child(model)
	model.position = pos
	ArtStyle.apply(model, Color.WHITE, 0.006)
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/buildings.json"))
	for wall in data[kind].walls:
		var p: Array = wall.position
		var s: Array = wall.size
		box(pos + Vector3(p[0], p[1], p[2]), Vector3(s[0], s[1], s[2]), Color.WHITE, true, false)

func prop(asset: String, pos: Vector3, collision_size: Vector3) -> void:
	decoration(asset, pos)
	box(pos + Vector3.UP * collision_size.y / 2, collision_size, Color.WHITE, true, false)

func decoration(asset: String, pos: Vector3) -> Node3D:
	var model: Node3D = load("res://assets/models/" + asset + ".glb").instantiate()
	add_child(model)
	model.position = pos
	ArtStyle.apply(model)
	return model

func add_supply(pos: Vector3) -> void:
	var model := decoration("chest", pos)
	var label := Label3D.new()
	label.text = "RÉSERVES"
	label.position.y = 1.25
	label.font_size = 32
	label.pixel_size = 0.0045
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	model.add_child(label)
	supplies.append({"position": pos, "used": false, "node": model})

func box(pos: Vector3, size: Vector3, color: Color, blocks := true, visible_mesh := true) -> void:
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
	visual.visible = visible_mesh
	solid.add_child(visual)
	add_child(solid)
	if blocks:
		for x in range(ceili(pos.x - size.x / 2 - 0.45), floori(pos.x + size.x / 2 + 0.45) + 1):
			for z in range(ceili(pos.z - size.z / 2 - 0.45), floori(pos.z + size.z / 2 + 0.45) + 1):
				if grid.is_in_boundsv(Vector2i(x, z)):
					grid.set_point_solid(Vector2i(x, z))

func marker(title: String, pos: Vector3, color: Color, asset := "") -> Node3D:
	var root := Node3D.new()
	root.position = pos
	add_child(root)
	if asset:
		var model: Node3D = load("res://assets/mission/" + asset + ".glb").instantiate()
		root.add_child(model)
		ArtStyle.apply(model)
		if asset == "extraction_beacon":
			var light := OmniLight3D.new()
			light.position.y = 1.5
			light.light_color = color
			light.light_energy = 2.0
			light.omni_range = 5.0
			root.add_child(light)
	else:
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
	label.font_size = 36
	label.pixel_size = 0.005
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	root.add_child(label)
	return root

func add_objective(title: String, pos: Vector3, color: Color, asset: String) -> void:
	objectives.append({"title": title, "position": pos, "collected": false, "node": marker(title, pos, color, asset)})

func path(from: Vector3, to: Vector3) -> PackedVector3Array:
	var start := Vector2i(clampi(roundi(from.x), -LIMIT, LIMIT), clampi(roundi(from.z), -LIMIT, LIMIT))
	var end := Vector2i(clampi(roundi(to.x), -LIMIT, LIMIT), clampi(roundi(to.z), -LIMIT, LIMIT))
	var result := PackedVector3Array()
	if grid.is_point_solid(start) or grid.is_point_solid(end):
		return result
	for point in grid.get_id_path(start, end):
		result.append(Vector3(point.x, 0, point.y))
	return result
