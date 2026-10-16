extends SceneTree

const ArtStyle = preload("res://scripts/art_style.gd")
const ASSETS := ["battery", "fuel_can", "antenna_module", "radio_console", "extraction_beacon"]

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var stage := Node3D.new()
	root.add_child(stage)
	var positions := [-4.0, -2.1, -0.2, 1.9, 4.1]
	var titles := ["BATTERIE", "CARBURANT", "MODULE\nANTENNE", "CONSOLE\nRADIO", "BALISE\nEXTRACTION"]
	var meshes := 0
	for index in range(ASSETS.size()):
		var model: Node3D = load("res://assets/mission/" + ASSETS[index] + ".glb").instantiate()
		stage.add_child(model)
		model.position.x = positions[index]
		ArtStyle.apply(model)
		meshes += model.find_children("*", "MeshInstance3D", true, false).size()
		var label := Label3D.new()
		label.text = titles[index]
		label.position = Vector3(positions[index], 2.25, 0)
		label.font_size = 26
		label.pixel_size = 0.005
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stage.add_child(label)
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(12, 7)
	ground.mesh = plane
	var ground_material := StandardMaterial3D.new()
	ground_material.albedo_color = Color("5d6968")
	ground.material_override = ground_material
	stage.add_child(ground)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-52, -28, 0)
	light.shadow_enabled = true
	stage.add_child(light)
	var camera := Camera3D.new()
	camera.position = Vector3(0, 1.65, 7.5)
	camera.fov = 62
	stage.add_child(camera)
	camera.look_at(Vector3(0, 0.75, 0))
	camera.current = true
	for frame in range(8):
		await process_frame
	if meshes < 20:
		push_error("Mission prop meshes missing: " + str(meshes))
		quit(1)
		return
	await RenderingServer.frame_post_draw
	var args := OS.get_cmdline_user_args()
	if args.size() != 1 or root.get_texture().get_image().save_png(args[0]) != OK:
		quit(1)
		return
	print("MISSION_ASSETS_CAPTURE_PASS assets=5 meshes=", meshes)
	stage.queue_free()
	await process_frame
	quit.call_deferred(0)
