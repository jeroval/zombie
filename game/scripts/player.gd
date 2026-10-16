extends CharacterBody3D

signal changed
signal died
signal noise(origin: Vector3, radius: float)
signal shot_fired(hit_enemy: bool, position: Vector3)
signal empty_triggered
signal reload_started
signal melee_performed(hit_enemy: bool, position: Vector3)
signal healed
signal damage_taken(amount: float)

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
var empty_timer := 0.0
var flash_timer := 0.0
var motion_time := 0.0
var base_fov := 85.0
var shake_enabled := true
var muzzle: OmniLight3D
const ArtStyle = preload("res://scripts/art_style.gd")
const PISTOL = preload("res://assets/models/pistol.glb")
const ARMS = preload("res://assets/viewmodel/fps_arms.glb")

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
	camera.fov = base_fov
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
	var arms := ARMS.instantiate()
	weapon.add_child(arms)
	ArtStyle.apply(arms, Color.WHITE, 0.0015)
	muzzle = OmniLight3D.new()
	muzzle.position = Vector3(0.09, -0.12, -0.9)
	muzzle.light_color = Color("ffbf66")
	muzzle.light_energy = 0.7
	muzzle.omni_range = 1.8
	muzzle.shadow_enabled = false
	muzzle.visible = false
	weapon.add_child(muzzle)

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
		healed.emit()
		changed.emit()
	if event.is_action_pressed("melee"):
		melee()

func _physics_process(delta: float) -> void:
	if not enabled:
		return
	capture_settle = maxf(0, capture_settle - delta)
	shot_timer = maxf(0, shot_timer - delta)
	empty_timer = maxf(0, empty_timer - delta)
	flash_timer = maxf(0, flash_timer - delta)
	muzzle.visible = flash_timer > 0
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
	motion_time += delta * Vector2(velocity.x, velocity.z).length()
	recoil = move_toward(recoil, 0, delta * 2.8)
	var bob := sin(motion_time * 1.7) * 0.006
	weapon.position = Vector3(cos(motion_time * 0.85) * 0.004, bob, recoil * 0.1)
	weapon.rotation.x = recoil * 0.2 + (sin(reload_timer * 3.0) * 0.6 if reload_timer > 0 else 0.0)
	camera.fov = move_toward(camera.fov, base_fov - 18.0 if Input.is_action_pressed("aim") else base_fov, delta * 90)

func ray(distance: float) -> Dictionary:
	var start := camera.global_position
	var query := PhysicsRayQueryParameters3D.create(start, start - camera.global_basis.z * distance, 1 | 4)
	query.exclude = [get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(query)

func shoot() -> bool:
	if shot_timer > 0 or reload_timer > 0:
		return false
	if ammo <= 0:
		if empty_timer <= 0:
			empty_timer = 0.35
			empty_triggered.emit()
		return false
	ammo -= 1
	shot_timer = 0.24
	flash_timer = 0.055
	muzzle.visible = true
	recoil = 1
	var hit := ray(70)
	var hit_enemy: bool = not hit.is_empty() and hit.collider.has_method("damage")
	if hit_enemy:
		hit.collider.damage(34.0)
	var hit_position: Vector3 = hit.position if not hit.is_empty() else camera.global_position - camera.global_basis.z * 70
	shot_fired.emit(hit_enemy, hit_position)
	noise.emit(global_position, 28.0)
	changed.emit()
	return true

func reload() -> void:
	if reload_timer <= 0 and ammo < 12 and reserve > 0:
		reload_timer = 1.6
		reload_started.emit()

func melee() -> void:
	if melee_timer > 0 or reload_timer > 0:
		return
	melee_timer = 0.65
	recoil = 2
	var hit := ray(2.1)
	var hit_enemy: bool = not hit.is_empty() and hit.collider.has_method("damage")
	if hit_enemy:
		hit.collider.damage(55.0)
	var hit_position: Vector3 = hit.position if not hit.is_empty() else camera.global_position - camera.global_basis.z * 2.1
	melee_performed.emit(hit_enemy, hit_position)
	noise.emit(global_position, 7.0)

func damage(amount: float) -> void:
	if not enabled or hurt_timer > 0:
		return
	hurt_timer = 0.5
	health = maxf(0, health - amount)
	if shake_enabled:
		camera.rotation.z = randf_range(-0.025, 0.025)
		var tween := create_tween()
		tween.tween_property(camera, "rotation:z", 0.0, 0.2)
	damage_taken.emit(amount)
	changed.emit()
	if health <= 0:
		died.emit()
