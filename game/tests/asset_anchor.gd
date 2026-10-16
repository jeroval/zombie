extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.start()
	game.player.enabled = false
	game.player.position = Vector3(0, 0, 12)
	game.player.camera.rotation.x = -0.12
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for enemy in game.enemies.get_children():
		enemy.free()
	game.spawn_enemy(Vector3(0, 0, 8), false)
	var target = game.enemies.get_child(0)
	target.rotation.y = PI
	var vehicle = load("res://assets/models/vehicle_pickup.glb").instantiate()
	game.world.add_child(vehicle)
	vehicle.position = Vector3(4, 0, 6)
	preload("res://scripts/art_style.gd").apply(vehicle)
	var skeleton: Skeleton3D = target.body.find_child("Skeleton3D", true, false)
	if skeleton == null:
		push_error("No imported skeleton")
		quit(1)
		return
	var args := OS.get_cmdline_user_args()
	if args.size() != 1:
		quit(1)
		return
	var moved := false
	for action in ["Idle", "Walk", "Punch", "Death"]:
		target.animator.play(action)
		target.animator.advance(0)
		var poses: Array[Transform3D] = []
		for bone in range(skeleton.get_bone_count()):
			poses.append(skeleton.get_bone_global_pose(bone))
		target.animator.advance(0.4)
		for bone in range(skeleton.get_bone_count()):
			if not poses[bone].is_equal_approx(skeleton.get_bone_global_pose(bone)):
				moved = true
		target.animator.pause()
		for frame in range(4):
			await process_frame
		await RenderingServer.frame_post_draw
		var path: String = args[0].path_join("anchor-" + action.to_lower() + ".png")
		if root.get_texture().get_image().save_png(path) != OK:
			quit(1)
			return
	print("ASSET_ANCHOR_ANIMATION_MOVED: ", moved)
	print("ASSET_ANCHOR_CAPTURED: Idle Walk Punch Death; bones=", skeleton.get_bone_count())
	quit.call_deferred(0 if moved else 1)
