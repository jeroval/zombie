extends SceneTree

const WARMUP_FRAMES := 180
const SAMPLE_FRAMES := 900
const TARGET_FRAME_MS := 1000.0 / 60.0

func _initialize() -> void:
	run.call_deferred()

func percentile(sorted_values: Array[float], fraction: float) -> float:
	var index := clampi(ceili(sorted_values.size() * fraction) - 1, 0, sorted_values.size() - 1)
	return sorted_values[index]

func run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Performance probe requires the graphical renderer")
		quit(2)
		return
	var args := OS.get_cmdline_user_args()
	if args.size() != 1:
		push_error("Performance probe requires one report path")
		quit(2)
		return
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1152, 648))
	game.start()
	game.player.health = 100000
	var positions := [
		Vector3(-8, 0.1, 15), Vector3(8, 0.1, 15), Vector3(-14, 0.1, 9),
		Vector3(14, 0.1, 9), Vector3(-8, 0.1, 2), Vector3(8, 0.1, 2),
		Vector3(-14, 0.1, -5), Vector3(14, 0.1, -5), Vector3(-8, 0.1, -12),
		Vector3(8, 0.1, -12), Vector3(-14, 0.1, -20), Vector3(14, 0.1, -20),
		Vector3(-8, 0.1, -27), Vector3(8, 0.1, -27), Vector3(0, 0.1, -30),
	]
	var index := 0
	while game.enemies.get_child_count() < 35:
		game.spawn_enemy(positions[index % positions.size()], index % 3 == 0)
		index += 1
	game.alert_enemies(game.player.position, 100)
	for frame in range(WARMUP_FRAMES):
		await process_frame
		await RenderingServer.frame_post_draw
	var frame_ms: Array[float] = []
	var previous := Time.get_ticks_usec()
	for frame in range(SAMPLE_FRAMES):
		await process_frame
		await RenderingServer.frame_post_draw
		var now := Time.get_ticks_usec()
		frame_ms.append((now - previous) / 1000.0)
		previous = now
	frame_ms.sort()
	var total := 0.0
	var over_budget := 0
	for value in frame_ms:
		total += value
		if value > TARGET_FRAME_MS:
			over_budget += 1
	var p95 := percentile(frame_ms, 0.95)
	var p99 := percentile(frame_ms, 0.99)
	var result := {
		"pass": p95 <= TARGET_FRAME_MS,
		"observation": "graphical automated stress probe, not a player experience assessment",
		"gpu": RenderingServer.get_video_adapter_name(),
		"renderer": RenderingServer.get_current_rendering_driver_name(),
		"resolution": "1152x648",
		"enemy_count": game.enemies.get_child_count(),
		"sample_frames": SAMPLE_FRAMES,
		"warmup_frames": WARMUP_FRAMES,
		"mean_frame_ms": total / frame_ms.size(),
		"median_frame_ms": percentile(frame_ms, 0.5),
		"p95_frame_ms": p95,
		"p99_frame_ms": p99,
		"one_percent_low_fps": 1000.0 / p99,
		"frames_over_16_67_ms": over_budget,
		"draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		"primitives": Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),
		"objects": Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME),
	}
	var report := FileAccess.open(args[0], FileAccess.WRITE)
	if report == null:
		push_error("Cannot save performance report")
		quit(1)
		return
	report.store_string(JSON.stringify(result, "\t"))
	report.close()
	print("PERFORMANCE_PROBE_RESULT ", JSON.stringify(result))
	game.audio.shutdown()
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	quit.call_deferred(0 if result.pass else 1)
