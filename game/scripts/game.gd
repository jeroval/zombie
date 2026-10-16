extends Node3D

const PlayerScript = preload("res://scripts/player.gd")
const EnemyScript = preload("res://scripts/enemy.gd")
const WorldScript = preload("res://scripts/world.gd")
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

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	configure_inputs()
	create_ui()
	create_session()
	show_menu("DERNIER SIGNAL", "Commencer")

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
	notify("La radio est muette. Trouvez les trois composants du quartier.")

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
	if phase not in [Phase.SEARCH, Phase.DEFEND, Phase.EXTRACT] or get_tree().paused:
		return
	elapsed += delta
	message_time -= delta
	spawn_timer -= delta
	if phase == Phase.DEFEND:
		defense -= delta
		if defense <= 0:
			phase = Phase.EXTRACT
			notify("Secours en approche ! Rejoignez la balise au nord du quartier.")
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
				notify(item.title + " récupéré. Munitions et soin trouvés.")
				return true
		if player.position.distance_to(world.radio) < 2.6:
			if collected == 3:
				phase = Phase.DEFEND
				alert_enemies(player.position, 100)
				notify("Signal envoyé. Tenez 90 secondes avant l'arrivée des secours !")
				return true
			notify("La radio nécessite les trois composants.")
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
	show_menu("ÉVACUATION RÉUSSIE" if won else "SIGNAL PERDU", "Recommencer")
	menu_title.text += "\n%d infectés neutralisés · %d min %02d s" % [kills, int(elapsed) / 60, int(elapsed) % 60]

func notify(text: String) -> void:
	message = text
	message_time = 5

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
	var reticle := Label.new()
	reticle.text = "+"
	reticle.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	reticle.offset_left = -6
	reticle.offset_top = -12
	reticle.add_theme_font_size_override("font_size", 24)
	canvas.add_child(reticle)
	menu = PanelContainer.new()
	menu.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	menu.offset_left = -330
	menu.offset_top = -210
	menu.offset_right = 330
	menu.offset_bottom = 210
	canvas.add_child(menu)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 18)
	menu.add_child(layout)
	menu_title = Label.new()
	menu_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_title.add_theme_font_size_override("font_size", 32)
	layout.add_child(menu_title)
	var help := Label.new()
	help.text = "Trois composants. Une radio. Une dernière chance.\n\nExplorez le quartier, réparez la radio, survivez puis évacuez.\n\nZQSD / WASD : marcher · souris : regarder\nClic : tirer · clic droit : viser · R : recharger\nV : mêlée · Maj : courir · E : interagir · F : soin\nÉchap : pause"
	help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(help)
	start_button = Button.new()
	start_button.pressed.connect(start)
	layout.add_child(start_button)
	var quit_button := Button.new()
	quit_button.text = "Quitter"
	quit_button.pressed.connect(func(): get_tree().quit())
	layout.add_child(quit_button)
