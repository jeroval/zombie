extends CharacterBody3D

signal changed
signal died
signal noise(origin: Vector3, radius: float)

var health := 100.0
var stamina := 100.0
var ammo := 12
var reserve := 72
var medicines := 2
var sensitivity := 0.0022
var shot_timer := 0.0
var reload_timer := 0.0
var melee_timer := 0.0
var hurt_timer := 0.0
var camera: Camera3D
var weapon: Node3D
var recoil := 0.0
var enabled := false
var capture_settle := 0.0
const ArtStyle = preload("res://scripts/art_style.gd")
const PISTOL = preload("res://assets/models/pistol.glb")

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1 | 4
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.32
	capsule.height = 1.8
	shape.shape = capsule
	shape.position.y = 0.9
	add_child(shape)
	camera = Camera3D.new()
	camera.position.y = 1.65
	camera.fov = 85
	camera.near = 0.04
	add_child(camera)
	camera.current = true
	weapon = Node3D.new()
	camera.add_child(weapon)
	var model := PISTOL.instantiate()
	model.position = Vector3(0.22, -0.25, -0.48)
	model.rotation.y = PI
	weapon.add_child(model)
	ArtStyle.apply(model, Color.WHITE, 0.0015)

func _unhandled_input(event: InputEvent) -> void:
	if not enabled or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	if event is InputEventMouseMotion:
		# Ignore the OS cursor recenter event when entering captured mode.
		if capture_settle > 0:
			return
		rotate_y(-event.relative.x * sensitivity)
		camera.rotation.x = clampf(camera.rotation.x - event.relative.y * sensitivity, -1.45, 1.45)
	if event.is_action_pressed("reload"):
		reload()
	if event.is_action_pressed("heal") and medicines > 0 and health < 100:
		medicines -= 1
		health = minf(100, health + 45)
		changed.emit()
	if event.is_action_pressed("melee"):
		melee()

func _physics_process(delta: float) -> void:
	if not enabled:
		return
	capture_settle = maxf(0, capture_settle - delta)
	shot_timer = maxf(0, shot_timer - delta)
	melee_timer = maxf(0, melee_timer - delta)
	hurt_timer = maxf(0, hurt_timer - delta)
	if reload_timer > 0:
		reload_timer -= delta
		if reload_timer <= 0:
			var amount := mini(12 - ammo, reserve)
			ammo += amount
			reserve -= amount
			changed.emit()
	if Input.is_action_pressed("shoot"):
		shoot()
	var axis := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(axis.x, 0, axis.y)).normalized()
	var running := Input.is_action_pressed("sprint") and stamina > 1 and axis.length() > 0
	var speed := 7.0 if running else 4.3
	stamina = clampf(stamina + (-24.0 if running else 18.0) * delta, 0, 100)
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	velocity.y -= 22.0 * delta
	if is_on_floor():
		velocity.y = -0.1
	move_and_slide()
	recoil = move_toward(recoil, 0, delta * 2.8)
	weapon.position.z = recoil * 0.1
	weapon.rotation.x = recoil * 0.2 + (sin(reload_timer * 3.0) * 0.6 if reload_timer > 0 else 0.0)
	camera.fov = move_toward(camera.fov, 65.0 if Input.is_action_pressed("aim") else 85.0, delta * 90)

func ray(distance: float) -> Dictionary:
	var start := camera.global_position
	var query := PhysicsRayQueryParameters3D.create(start, start - camera.global_basis.z * distance, 1 | 4)
	query.exclude = [get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(query)

func shoot() -> bool:
	if shot_timer > 0 or reload_timer > 0 or ammo <= 0:
		return false
	ammo -= 1
	shot_timer = 0.24
	recoil = 1
	var hit := ray(70)
	if not hit.is_empty() and hit.collider.has_method("damage"):
		hit.collider.damage(34.0)
	noise.emit(global_position, 28.0)
	changed.emit()
	return true

func reload() -> void:
	if reload_timer <= 0 and ammo < 12 and reserve > 0:
		reload_timer = 1.6

func melee() -> void:
	if melee_timer > 0 or reload_timer > 0:
		return
	melee_timer = 0.65
	recoil = 2
	var hit := ray(2.1)
	if not hit.is_empty() and hit.collider.has_method("damage"):
		hit.collider.damage(55.0)
	noise.emit(global_position, 7.0)

func damage(amount: float) -> void:
	if not enabled or hurt_timer > 0:
		return
	hurt_timer = 0.5
	health = maxf(0, health - amount)
	changed.emit()
	if health <= 0:
		died.emit()
