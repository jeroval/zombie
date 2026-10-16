extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	run.call_deferred()

func check(condition: bool, description: String) -> void:
	if not condition:
		failures.append(description)
		push_error(description)

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	check(game.phase == game.Phase.MENU, "Starts in menu")
	game.start()
	check(game.player.enabled, "Player enabled on start")
	var initial: Vector3 = game.player.position
	Input.action_press("forward")
	for frame in range(30):
		await physics_frame
	Input.action_release("forward")
	check(game.player.position.z < initial.z - 1.0, "Forward input moves along view")
	check(absf(game.player.camera.position.y - 1.65) < 0.01, "First-person eye height")
	check(game.player.position.y > -0.1, "Ground collision holds player")
	check(not game.interact(), "Cannot activate radio without components")
	for item in game.world.objectives:
		var route: PackedVector3Array = game.world.path(game.world.radio, item.position)
		check(route.size() > 2, "Objective reachable: " + item.title)
		game.player.position = item.position
		check(game.interact(), "Collect objective: " + item.title)
		check(not game.interact(), "Cannot collect objective twice")
	check(game.collected == 3, "All three components recorded")
	game.player.position = game.world.radio
	check(game.interact(), "Radio activation with components")
	check(game.phase == game.Phase.DEFEND, "Defense phase entered")
	game.defense = 0.01
	game._process(0.02)
	check(game.phase == game.Phase.EXTRACT, "Defense completes into extraction")
	game.player.position = game.world.extraction
	game._process(0.02)
	check(game.phase == game.Phase.WON, "Extraction wins")
	game.start()
	check(game.collected == 0 and game.player.ammo == 12, "Restart resets mission and resources")
	check(game.enemies.get_child_count() == 14, "Restart resets enemy population")
	game.player.damage(100)
	check(game.phase == game.Phase.LOST, "Lethal damage loses")
	game.start()
	check(game.player.health == 100 and game.player.enabled, "Restart after death resets health")
	game.player.ammo = 0
	game.player.reserve = 5
	check(not game.player.shoot(), "Empty magazine cannot fire")
	game.player.reload()
	game.player._physics_process(1.7)
	check(game.player.ammo == 5 and game.player.reserve == 0, "Reload preserves total ammunition")
	game.player.position = Vector3(-19, 0, 20)
	game.player.rotation = Vector3.ZERO
	game.player.camera.rotation = Vector3.ZERO
	await physics_frame
	var hit: Dictionary = game.player.ray(50)
	check(not hit.is_empty() and hit.collider is StaticBody3D, "Walls block hitscan")
	check(game.world.path(Vector3(-19, 0, 20), Vector3(-19, 0, -25)).size() > 45, "Navigation routes around buildings")
	game.queue_free()
	await process_frame
	if failures.is_empty():
		print("GAMEPLAY_CONTRACT_PASS: movement, floor, mission, restart, death, ammo, walls, navigation")
	else:
		print("GAMEPLAY_CONTRACT_FAILED: ", failures)
	quit.call_deferred(0 if failures.is_empty() else 1)
