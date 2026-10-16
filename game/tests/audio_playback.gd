extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	run.call_deferred()

func check(condition: bool, description: String) -> void:
	if not condition:
		failures.append(description)
		push_error(description)

func run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Audio playback verification requires a graphical audio backend")
		quit(2)
		return
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	check(game.audio.music.playing, "Ambient music playback starts")
	game.start()
	game.audio.play_sfx("pickup")
	await create_timer(0.25).timeout
	check(game.audio.music.get_playback_position() > 0, "Ambient loop advances")
	check(game.audio.voice.playing and game.audio.voice.get_playback_position() > 0, "French radio voice advances")
	var sfx_playing := false
	for player in game.audio.sfx_pool:
		if player.playing and player.get_playback_position() > 0:
			sfx_playing = true
	check(sfx_playing, "Sound effect advances")
	check(game.audio.music.stream.get_length() >= 44, "Ambient loop has expected duration")
	check(game.audio.voice.stream.get_length() >= 8, "Intro voice has expected duration")
	game.audio.shutdown()
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	if failures.is_empty():
		print("AUDIO_PLAYBACK_PASS: music, French voice and SFX advanced on the real audio backend")
	quit.call_deferred(0 if failures.is_empty() else 1)
