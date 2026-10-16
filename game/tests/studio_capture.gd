extends SceneTree


func _initialize() -> void:
	run.call_deferred()


func run() -> void:
	var scene := load("res://scenes/main.tscn") as PackedScene
	root.add_child(scene.instantiate())
	for frame in range(5):
		await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var args := OS.get_cmdline_user_args()
	if args.size() != 1 or image.save_png(args[0]) != OK:
		push_error("Studio capture failed")
		quit(1)
		return
	print("STUDIO_CAPTURE_PASS")
	quit.call_deferred(0)
