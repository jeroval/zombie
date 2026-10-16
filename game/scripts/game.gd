extends Node3D

const PlayerScript = preload("res://scripts/player.gd")
const EnemyScript = preload("res://scripts/enemy.gd")
const WorldScript = preload("res://scripts/world.gd")
const AudioDirectorScript = preload("res://scripts/audio_director.gd")
const Settings = preload("res://scripts/settings.gd")
enum Phase { MENU, SEARCH, DEFEND, EXTRACT, WON, LOST }
var phase := Phase.MENU
var player: CharacterBody3D
var world: Node3D
var enemies: Node3D
var collected := 0
var kills := 0
var elapsed := 0.0
var defense := 90.0
var spawn_timer := 5.0
var hud: Label
var prompt: Label
var menu: PanelContainer
var menu_title: Label
var start_button: Button
var message := ""
var message_time := 0.0
var rng := RandomNumberGenerator.new()
var audio: Node
var settings: Dictionary
var reticle: Label
var hit_timer := 0.0
var damage_overlay: ColorRect
var damage_alpha := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	settings = Settings.load_file()
	configure_inputs()
	create_ui()
	audio = AudioDirectorScript.new()
	add_child(audio)
	create_session()
	apply_settings()
	show_menu("DERNIER SIGNAL", "Commencer")

func _exit_tree() -> void:
	if is_instance_valid(audio):
		audio.shutdown()

func configure_inputs() -> void:
	var bindings := {"forward": [KEY_W, KEY_Z, KEY_UP], "back": [KEY_S, KEY_DOWN], "left": [KEY_A, KEY_Q, KEY_LEFT], "right": [KEY_D, KEY_RIGHT], "sprint": [KEY_SHIFT], "reload": [KEY_R], "interact": [KEY_E], "heal": [KEY_F], "melee": [KEY_V]}
	for action in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in bindings[action]:
			var event := InputEventKey.new()
			event.keycode = key
			InputMap.action_add_event(action, event)
	for action in ["shoot", "aim"]:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT if action == "shoot" else MOUSE_BUTTON_RIGHT
		InputMap.action_add_event(action, event)

func create_session() -> void:
	world = WorldScript.new()
	world.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(world)
	player = PlayerScript.new()
	world.add_child(player)
	player.position = Vector3(0, 0.1, 28)
	player.died.connect(func(): finish(false))
	player.noise.connect(alert_enemies)
	player.shot_fired.connect(on_shot)
	player.empty_triggered.connect(func(): audio.play_sfx("empty", -4))
	player.reload_started.connect(func(): audio.play_sfx("reload", -3))
	player.melee_performed.connect(on_melee)
	player.healed.connect(func(): audio.play_sfx("pickup", -3))
	player.damage_taken.connect(on_player_damage)
	enemies = Node3D.new()
	world.add_child(enemies)
	collected = 0
	kills = 0
	elapsed = 0
	defense = 90
	spawn_timer = 5
	rng.seed = 7319
	for i in range(14):
		spawn_enemy(Vector3(rng.randf_range(-10, 10), 0.1, rng.randf_range(-27, 6)), i % 4 == 0)

func start() -> void:
	if phase != Phase.MENU and phase != Phase.WON and phase != Phase.LOST:
		resume()
		return
	if phase != Phase.MENU:
		world.free()
		create_session()
	phase = Phase.SEARCH
	player.enabled = true
	menu.hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player.capture_settle = 0.15
	audio.play_voice("intro")
	notify("Radio : trouvez la batterie, le carburant et le module d'antenne.", 9)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and phase in [Phase.SEARCH, Phase.DEFEND, Phase.EXTRACT]:
		if menu.visible:
			resume()
		else:
			get_tree().paused = true
			show_menu("PAUSE", "Reprendre")
		get_viewport().set_input_as_handled()
	if event.is_action_pressed("interact") and not menu.visible:
		interact()

func _process(delta: float) -> void:
	hit_timer = maxf(0, hit_timer - delta)
	reticle.text = "✕" if hit_timer > 0 else "+"
	reticle.modulate = Color("efb866") if hit_timer > 0 else Color.WHITE
	damage_alpha = move_toward(damage_alpha, 0.0, delta * 1.1)
	damage_overlay.color.a = damage_alpha
	if phase not in [Phase.SEARCH, Phase.DEFEND, Phase.EXTRACT] or get_tree().paused:
		return
	elapsed += delta
	message_time -= delta
	spawn_timer -= delta
	if phase == Phase.DEFEND:
		defense -= delta
		if defense <= 0:
			phase = Phase.EXTRACT
			audio.play_sfx("extract")
			audio.play_voice("extract")
			notify("Secours en approche ! Rejoignez la balise au nord du quartier.", 6)
	if spawn_timer <= 0:
		spawn_timer = 4.0 if phase != Phase.SEARCH else 15.0
		if enemies.get_child_count() < 35:
			var point: Vector3 = world.spawn_points[rng.randi_range(0, 3)]
			spawn_enemy(point + Vector3.UP * 0.1, rng.randf() < 0.3)
	if phase == Phase.EXTRACT and player.position.distance_to(world.extraction) < 3:
		finish(true)
	update_hud()

func interact() -> bool:
	if phase == Phase.SEARCH:
		for item in world.objectives:
			if not item.collected and player.position.distance_to(item.position) < 2.6:
				item.collected = true
				item.node.hide()
				collected += 1
				player.reserve += 24
				player.medicines += 1
				audio.play_sfx("pickup")
				notify(item.title + " récupéré. Munitions et soin trouvés.")
				return true
		if player.position.distance_to(world.radio) < 2.6:
			if collected == 3:
				phase = Phase.DEFEND
				alert_enemies(player.position, 100)
				audio.play_sfx("radio")
				audio.play_voice("defense")
				notify("Signal envoyé. Tenez 90 secondes avant l'arrivée des secours !", 6)
				return true
			notify("La radio nécessite les trois composants.")
	for supply in world.supplies:
		if not supply.used and player.position.distance_to(supply.position) < 2.5:
			supply.used = true
			supply.node.hide()
			player.reserve += 36
			player.medicines += 1
			audio.play_sfx("pickup")
			notify("Réserves récupérées : 36 cartouches et un soin.")
			return true
	return false

func spawn_enemy(pos: Vector3, fast: bool) -> void:
	var enemy := EnemyScript.new()
	enemy.player = player
	enemy.world = world
	enemy.runner = fast
	enemies.add_child(enemy)
	enemy.position = pos
	enemy.killed.connect(func(): kills += 1)
	if phase in [Phase.DEFEND, Phase.EXTRACT]:
		enemy.hear(player.position, 100)

func alert_enemies(origin: Vector3, radius: float) -> void:
	for enemy in enemies.get_children():
		enemy.hear(origin, radius)

func finish(won: bool) -> void:
	phase = Phase.WON if won else Phase.LOST
	player.enabled = false
	if won:
		audio.play_sfx("extract")
		audio.play_voice("victory")
	settings = Settings.record_result(settings, elapsed, kills, won)
	var save_error := Settings.save_file(settings)
	if save_error != OK:
		push_warning("Unable to save result: " + error_string(save_error))
	show_menu("ÉVACUATION RÉUSSIE" if won else "SIGNAL PERDU", "Recommencer")
	menu_title.text += "\n%d infectés neutralisés · %d min %02d s" % [kills, int(elapsed) / 60, int(elapsed) % 60]
	if settings.best_time > 0:
		menu_title.text += "\nRecord : %d min %02d s · %d neutralisations" % [int(settings.best_time) / 60, int(settings.best_time) % 60, settings.best_kills]

func notify(text: String, duration := 5.0) -> void:
	message = text
	message_time = duration

func on_shot(hit_enemy: bool, position: Vector3) -> void:
	audio.play_sfx("shot", -2)
	impact(position, hit_enemy)
	if hit_enemy:
		hit_timer = 0.13
		audio.play_sfx("hit", -7)

func on_melee(hit_enemy: bool, position: Vector3) -> void:
	audio.play_sfx("melee", -4)
	if hit_enemy:
		hit_timer = 0.16
		audio.play_sfx("hit", -4)
		impact(position, true)

func on_player_damage(_amount: float) -> void:
	damage_alpha = 0.32
	audio.play_sfx("hurt", -4)

func impact(position: Vector3, enemy_hit: bool) -> void:
	if not is_instance_valid(world):
		return
	var spark := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.055 if enemy_hit else 0.035
	mesh.height = mesh.radius * 2
	spark.mesh = mesh
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color("f4cc72") if not enemy_hit else Color("d94b3d")
	material.emission_enabled = true
	material.emission = material.albedo_color
	spark.material_override = material
	world.add_child(spark)
	spark.global_position = position
	var tween := spark.create_tween()
	tween.tween_property(spark, "scale", Vector3.ZERO, 0.18)
	tween.tween_callback(spark.queue_free)

func resume() -> void:
	menu.hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player.capture_settle = 0.15

func show_menu(title: String, button: String) -> void:
	menu_title.text = title
	start_button.text = button
	menu.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	start_button.grab_focus()

func apply_settings() -> void:
	for entry in [["Master", "master"], ["Music", "music"], ["SFX", "sfx"], ["Voice", "voice"]]:
		var index := AudioServer.get_bus_index(entry[0])
		if index >= 0:
			AudioServer.set_bus_volume_db(index, linear_to_db(maxf(0.001, settings[entry[1]])))
	if is_instance_valid(player):
		player.sensitivity = 0.0022 * settings.sensitivity
		player.base_fov = settings.fov
		player.camera.fov = settings.fov
		player.shake_enabled = settings.shake
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if settings.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)

func change_setting(key: String, value: Variant) -> void:
	settings[key] = value
	apply_settings()
	var error := Settings.save_file(settings)
	if error != OK:
		push_warning("Unable to save settings: " + error_string(error))

func update_hud() -> void:
	var objective := "Composants : %d / 3 — explorez le quartier" % collected
	if phase == Phase.SEARCH and collected == 3:
		objective = "Retournez à la radio du refuge et appuyez sur E"
	elif phase == Phase.DEFEND:
		objective = "Tenez jusqu'aux secours : %d secondes" % ceili(defense)
	elif phase == Phase.EXTRACT:
		objective = "Rejoignez la balise d'évacuation au NORD"
	hud.text = "DERNIER SIGNAL\n%s\n\nSanté %d   Endurance %d\nMunitions %d / %d   Soins %d\n%s" % [objective, player.health, player.stamina, player.ammo, player.reserve, player.medicines, "RECHARGEMENT…" if player.reload_timer > 0 else ""]
	var context := ""
	if phase == Phase.SEARCH:
		var nearest := 1000.0
		for item in world.objectives:
			if not item.collected:
				var distance: float = player.position.distance_to(item.position)
				if distance < nearest:
					nearest = distance
					context = "%s — %d m" % [item.title, distance]
				if distance < 2.6:
					context = "E — Récupérer " + item.title
					break
		if player.position.distance_to(world.radio) < 2.6:
			context = "E — Réparer et activer la radio" if collected == 3 else "Radio : trouvez les trois composants"
	for supply in world.supplies:
		if not supply.used and player.position.distance_to(supply.position) < 2.5:
			context = "E — Ouvrir les réserves"
	prompt.text = (message if message_time > 0 else context) + "\nZQSD / WASD : marcher  ·  Maj : courir  ·  E : interagir  ·  Échap : pause"

func create_ui() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)
	hud = Label.new()
	hud.position = Vector2(24, 20)
	hud.add_theme_font_size_override("font_size", 20)
	canvas.add_child(hud)
	prompt = Label.new()
	prompt.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	prompt.offset_top = -80
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_theme_font_size_override("font_size", 18)
	canvas.add_child(prompt)
	reticle = Label.new()
	reticle.text = "+"
	reticle.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	reticle.offset_left = -6
	reticle.offset_top = -12
	reticle.add_theme_font_size_override("font_size", 24)
	canvas.add_child(reticle)
	damage_overlay = ColorRect.new()
	damage_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	damage_overlay.color = Color(0.55, 0.02, 0.01, 0)
	damage_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(damage_overlay)
	menu = PanelContainer.new()
	menu.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	menu.offset_left = -470
	menu.offset_top = -280
	menu.offset_right = 470
	menu.offset_bottom = 280
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.035, 0.055, 0.07, 0.98)
	panel_style.border_color = Color("d6b96d")
	panel_style.set_border_width_all(2)
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	panel_style.set_content_margin_all(22)
	menu.add_theme_stylebox_override("panel", panel_style)
	canvas.add_child(menu)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	menu.add_child(layout)
	menu_title = Label.new()
	menu_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_title.add_theme_font_size_override("font_size", 32)
	layout.add_child(menu_title)
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 28)
	layout.add_child(body)
	var help := Label.new()
	help.custom_minimum_size.x = 310
	help.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help.text = "Trois composants. Une radio. Une dernière chance.\n\nExplorez le quartier, réparez la radio, survivez puis évacuez.\n\nZQSD / WASD — marcher\nSouris — regarder\nClic — tirer · clic droit — viser\nR — recharger · V — mêlée\nMaj — courir · E — interagir\nF — soin · Échap — pause"
	help.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	body.add_child(help)
	var options := VBoxContainer.new()
	options.custom_minimum_size.x = 510
	options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	options.add_theme_constant_override("separation", 7)
	body.add_child(options)
	option_slider(options, "Volume général", "master", 0, 1, 0.05)
	option_slider(options, "Musique", "music", 0, 1, 0.05)
	option_slider(options, "Effets", "sfx", 0, 1, 0.05)
	option_slider(options, "Voix", "voice", 0, 1, 0.05)
	option_slider(options, "Sensibilité souris", "sensitivity", 0.35, 2.5, 0.05)
	option_slider(options, "Champ de vision", "fov", 70, 105, 1)
	option_check(options, "Secousses caméra", "shake")
	option_check(options, "Plein écran", "fullscreen")
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 12)
	layout.add_child(actions)
	start_button = Button.new()
	start_button.custom_minimum_size.y = 42
	start_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	start_button.pressed.connect(start)
	actions.add_child(start_button)
	var quit_button := Button.new()
	quit_button.text = "Quitter"
	quit_button.custom_minimum_size.y = 42
	quit_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quit_button.pressed.connect(func(): get_tree().quit())
	actions.add_child(quit_button)

func option_slider(parent: Control, title: String, key: String, minimum: float, maximum: float, step: float) -> void:
	var row := HBoxContainer.new()
	parent.add_child(row)
	var label := Label.new()
	label.text = title
	label.custom_minimum_size.x = 155
	row.add_child(label)
	var slider := HSlider.new()
	slider.custom_minimum_size.x = 220
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.min_value = minimum
	slider.max_value = maximum
	slider.step = step
	slider.value = settings[key]
	row.add_child(slider)
	var number := Label.new()
	number.custom_minimum_size.x = 50
	number.text = str(snappedf(slider.value, step))
	row.add_child(number)
	slider.value_changed.connect(func(value: float):
		number.text = str(snappedf(value, step))
		change_setting(key, value)
	)

func option_check(parent: Control, title: String, key: String) -> void:
	var check := CheckBox.new()
	check.text = title
	check.button_pressed = settings[key]
	check.toggled.connect(func(value: bool): change_setting(key, value))
	parent.add_child(check)
