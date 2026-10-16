extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for frame in range(8):
		await process_frame
	await RenderingServer.frame_post_draw
	var args := OS.get_cmdline_user_args()
	if args.size() != 1 or root.get_texture().get_image().save_png(args[0]) != OK:
		quit(1)
		return
	print("MENU_CAPTURE_PASS sliders=", game.menu.find_children("*", "HSlider", true, false).size())
	game.queue_free()
	await process_frame
	await create_timer(0.15).timeout
	quit.call_deferred(0)
