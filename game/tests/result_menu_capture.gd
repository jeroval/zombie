extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.start()
	game.elapsed = 213.0
	game.kills = 19
	game.finish(true)
	for frame in range(8):
		await process_frame
	var rect: Rect2 = game.menu.get_global_rect()
	var viewport: Rect2 = game.get_viewport().get_visible_rect()
	var fits: bool = viewport.encloses(rect)
	if not fits or not game.menu_title.text.contains("Record"):
		push_error("Result menu does not fit or omits persistent record")
		quit(1)
		return
	await RenderingServer.frame_post_draw
	var args := OS.get_cmdline_user_args()
	if args.size() != 1 or root.get_texture().get_image().save_png(args[0]) != OK:
		quit(1)
		return
	print("RESULT_MENU_CAPTURE_PASS rect=", rect, " viewport=", viewport)
	game.audio.shutdown()
	game.queue_free()
	await process_frame
	await create_timer(0.15).timeout
	quit.call_deferred(0)
