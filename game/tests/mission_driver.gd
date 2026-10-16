extends Node

signal completed(result: Dictionary)

var game
var route := PackedVector3Array()
var waypoint := 0
var last_target := Vector3.INF
var destination := Vector3.ZERO
var defense_corner := 0
var shots := 0
var last_ammo := 12
var corners := [Vector3(-8, 0, 22), Vector3(8, 0, 22), Vector3(8, 0, -22), Vector3(-8, 0, -22)]

func begin(target_game) -> void:
	game = target_game
	run.call_deferred()

func tap(action: String) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)
	var release := InputEventAction.new()
	release.action = action
	release.pressed = false
	Input.parse_input_event(release)

func release_inputs() -> void:
	for action in ["shoot", "forward", "back", "left", "right", "sprint"]:
		Input.action_release(action)

func run() -> void:
	game.start()
	for frame in range(24000):
		await get_tree().physics_frame
		if game.phase in [game.Phase.WON, game.Phase.LOST]:
			break
		var player = game.player
		if player.ammo < last_ammo:
			shots += last_ammo - player.ammo
		last_ammo = player.ammo
		if player.health < 65:
			tap("heal")
		if player.ammo == 0:
			tap("reload")
		if game.phase == game.Phase.SEARCH:
			destination = game.world.radio
			for item in game.world.objectives:
				if not item.collected:
					destination = item.position
					break
			if player.position.distance_to(destination) < 2.3:
				tap("interact")
		elif game.phase == game.Phase.DEFEND:
			destination = corners[defense_corner]
			if player.position.distance_to(destination) < 2:
				defense_corner = (defense_corner + 1) % corners.size()
		else:
			destination = game.world.extraction
		if destination != last_target or frame % 60 == 0:
			route = game.world.path(player.position, destination)
			waypoint = 1 if route.size() > 1 else 0
			last_target = destination
		while waypoint < route.size() and Vector2(player.position.x - route[waypoint].x, player.position.z - route[waypoint].z).length() < 0.55:
			waypoint += 1
		var move_to: Vector3 = route[waypoint] if waypoint < route.size() else destination
		var look_at := move_to + Vector3.UP * 1.65
		var closest := 24.0
		var target = null
		for enemy in game.enemies.get_children():
			if enemy.is_queued_for_deletion() or enemy.dead:
				continue
			var distance: float = enemy.position.distance_to(player.position)
			if distance < closest:
				var query := PhysicsRayQueryParameters3D.create(player.camera.global_position, enemy.global_position + Vector3.UP, 1)
				if player.get_world_3d().direct_space_state.intersect_ray(query).is_empty():
					target = enemy
					closest = distance
		if target != null:
			look_at = target.global_position + Vector3.UP
		var look: Vector3 = look_at - player.camera.global_position
		if look.length() > 0.01:
			var yaw := atan2(-look.x, -look.z)
			var pitch := atan2(look.y, Vector2(look.x, look.z).length())
			var mouse := InputEventMouseMotion.new()
			mouse.relative = Vector2(-wrapf(yaw - player.rotation.y, -PI, PI), player.camera.rotation.x - pitch) / player.sensitivity
			Input.parse_input_event(mouse)
		if target != null:
			Input.action_press("shoot")
			if closest < 1.9:
				tap("melee")
		else:
			Input.action_release("shoot")
		var movement: Vector3 = player.global_basis.inverse() * (move_to - player.position).normalized()
		for action in ["forward", "back", "left", "right"]:
			Input.action_release(action)
		if movement.z < -0.1:
			Input.action_press("forward", -movement.z)
		if movement.z > 0.1:
			Input.action_press("back", movement.z)
		if movement.x > 0.1:
			Input.action_press("right", movement.x)
		if movement.x < -0.1:
			Input.action_press("left", -movement.x)
		if closest < 7 and player.stamina > 5:
			Input.action_press("sprint")
		else:
			Input.action_release("sprint")
		if frame % 1800 == 0:
			print("INPUT_RUN_PROGRESS ", JSON.stringify({"time": game.elapsed, "phase": game.phase, "position": str(player.position), "health": player.health, "components": game.collected, "kills": game.kills}))
	release_inputs()
	var passed: bool = game.phase == game.Phase.WON
	var result := {"pass": passed, "time": game.elapsed, "phase": game.phase, "health": game.player.health, "components": game.collected, "kills": game.kills, "shots": shots, "position": str(game.player.position), "observation": "agent input traversal, not human playtest"}
	completed.emit(result)
