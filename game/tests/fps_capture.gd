extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.start()
	for frame in range(20):
		await process_frame
	await RenderingServer.frame_post_draw
	print("CAPTURE_CAMERA: ", game.player.camera.global_transform)
	var args := OS.get_cmdline_user_args()
	if args.size() != 1 or root.get_texture().get_image().save_png(args[0]) != OK:
		push_error("FPS capture failed")
		quit(1)
		return
	print("FPS_CAPTURE_PASS")
	game.queue_free()
	await process_frame
	await create_timer(0.15).timeout
	quit.call_deferred(0)
