extends SceneTree


func fail(message: String) -> void:
	push_error(message)
	quit(1)


func _initialize() -> void:
	run.call_deferred()


func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 1:
		fail("Expected the disposable fixture directory")
		return
	var fixture := ProjectSettings.localize_path(args[0])
	var packed := load(fixture.path_join("probe.glb")) as PackedScene
	if packed == null:
		fail("Blender GLB did not import")
		return
	var instance := packed.instantiate()
	root.add_child(instance)
	var mesh := instance.find_child("StudioProbe", true, false) as MeshInstance3D
	var player: AnimationPlayer
	for node in instance.find_children("*", "AnimationPlayer", true, false):
		player = node as AnimationPlayer
	if mesh == null or player == null:
		fail("GLB mesh or AnimationPlayer missing")
		return
	for clip in player.get_animation_list():
		if clip != "RESET":
			player.play(clip)
			break
	player.advance(0.0)
	var before := mesh.transform
	player.advance(0.5)
	if mesh.transform.is_equal_approx(before):
		fail("Exported animation did not move the mesh")
		return
	var stream := load(fixture.path_join("tone.ogg")) as AudioStream
	if stream == null or stream.get_length() < 0.2:
		fail("Converted Ogg did not import")
		return
	var audio := AudioStreamPlayer.new()
	audio.stream = stream
	audio.bus = &"SFX"
	root.add_child(audio)
	audio.play()
	await create_timer(0.05).timeout
	if not audio.playing or AudioServer.get_bus_index(&"Voice") < 0:
		fail("Audio playback or configured buses unavailable")
		return
	print("STUDIO_ROUNDTRIP_PASS")
	audio.stop()
	audio.stream = null
	stream = null
	audio.queue_free()
	instance.queue_free()
	await create_timer(0.15).timeout
	quit.call_deferred(0)
