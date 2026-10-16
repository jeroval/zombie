extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	Input.action_release("shoot")
	game.start()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for enemy in game.enemies.get_children():
		enemy.free()
	game.spawn_enemy(game.player.position + Vector3(0, 0, -2.2), false)
	for frame in range(20):
		await physics_frame
	if not game.player.shoot():
		push_error("Feedback shot did not fire")
		quit(1)
		return
	game._process(0.01)
	RenderingServer.force_draw()
	var args := OS.get_cmdline_user_args()
	if args.size() != 1 or root.get_texture().get_image().save_png(args[0]) != OK:
		quit(1)
		return
	print("FEEDBACK_CAPTURE_PASS hit_timer=", game.hit_timer, " flash=", game.player.flash_timer)
	game.queue_free()
	await process_frame
	await create_timer(0.15).timeout
	quit.call_deferred(0)
