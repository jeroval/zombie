extends SceneTree

const Settings = preload("res://scripts/settings.gd")
var failures: Array[String] = []

func _initialize() -> void:
	run.call_deferred()

func check(condition: bool, description: String) -> void:
	if not condition:
		failures.append(description)
		push_error(description)

func run() -> void:
	var path := "user://presentation-test-%d.cfg" % OS.get_process_id()
	var values := Settings.DEFAULTS.duplicate()
	values.master = 0.61
	values.music = 0.27
	values.sensitivity = 1.45
	values.fov = 92.0
	values.shake = false
	check(Settings.save_file(values, path) == OK, "Settings save")
	var loaded := Settings.load_file(path)
	check(is_equal_approx(loaded.master, 0.61), "Master volume persists")
	check(is_equal_approx(loaded.music, 0.27), "Music volume persists")
	check(is_equal_approx(loaded.sensitivity, 1.45), "Sensitivity persists")
	check(is_equal_approx(loaded.fov, 92.0), "FOV persists")
	check(not loaded.shake, "Camera shake preference persists")
	var impossible_result := Settings.record_result(loaded, 12.0, 2, true)
	check(impossible_result.best_time == 0, "Impossible accelerated victory is not a record")
	var first_result := Settings.record_result(loaded, 180.0, 12, true)
	var slower_result := Settings.record_result(first_result, 240.0, 18, true)
	check(is_equal_approx(slower_result.best_time, 180.0), "Slower victory preserves best time")
	check(slower_result.best_kills == 18, "Kill record persists independently")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	check(game.menu.find_children("*", "HSlider", true, false).size() == 6, "Six option sliders available")
	check(game.menu.find_children("*", "CheckBox", true, false).size() == 2, "Two option toggles available")
	check(game.audio.music.stream != null, "Ambient loop is configured")
	Input.action_release("shoot")
	game.start()
	check("voice:intro" in game.audio.events, "Intro radio voice is requested")
	check(game.player.weapon.find_child("fps_arms", true, false) != null, "Authored FPS arms imported")
	for enemy in game.enemies.get_children():
		enemy.free()
	game.spawn_enemy(game.player.position + Vector3(0, 0, -2.2), false)
	for frame in range(2):
		await physics_frame
	var ray_hit: Dictionary = game.player.ray(5)
	check(not ray_hit.is_empty() and ray_hit.collider.has_method("damage"), "Test target is on the firing ray")
	var ammo_before: int = game.player.ammo
	check(game.player.shoot(), "Pistol fires")
	check(game.player.ammo == ammo_before - 1, "Pistol consumes one round")
	check(game.player.flash_timer > 0 and game.player.muzzle.visible, "Muzzle feedback starts")
	check(game.player.recoil > 0, "Viewmodel recoil starts")
	check(game.hit_timer > 0, "Enemy hit feedback starts")
	check("sfx:shot" in game.audio.events and "sfx:hit" in game.audio.events, "Shot and hit sounds start")
	game.player.damage(10)
	check(game.damage_alpha > 0, "Damage overlay starts")
	check("sfx:hurt" in game.audio.events, "Damage sound starts")
	game.player.ammo = 0
	game.player.shot_timer = 0
	game.player.empty_timer = 0
	check(not game.player.shoot(), "Empty pistol does not fire")
	check(game.player.empty_timer > 0, "Empty trigger feedback is rate limited")
	game.queue_free()
	await process_frame
	await create_timer(0.15).timeout
	if failures.is_empty():
		print("PRESENTATION_CONTRACT_PASS: settings, audio, arms, muzzle, hit, hurt, empty")
	quit.call_deferred(0 if failures.is_empty() else 1)
