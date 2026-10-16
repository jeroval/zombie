extends CharacterBody3D

signal killed
var player: CharacterBody3D
var world: Node3D
var health := 100.0
var speed := 1.6
var attack_timer := 0.0
var rethink := 0.0
var alert_time := 0.0
var destination := Vector3.ZERO
var route := PackedVector3Array()
var route_index := 0
var body: Node3D
var animator: AnimationPlayer
var dead := false
const ArtStyle = preload("res://scripts/art_style.gd")
const MODEL = preload("res://assets/models/zombie_basic.glb")
var runner := false

func _ready() -> void:
	collision_layer = 4
	collision_mask = 1 | 2
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.7
	shape.shape = capsule
	shape.position.y = 0.85
	add_child(shape)
	body = MODEL.instantiate()
	body.rotation.y = PI
	add_child(body)
	ArtStyle.apply(body, Color("f3bb8b") if runner else Color.WHITE)
	animator = body.find_child("AnimationPlayer", true, false)
	for animation_name in ["Walk", "Run", "Idle"]:
		if animator.has_animation(animation_name):
			animator.get_animation(animation_name).loop_mode = Animation.LOOP_LINEAR
	animator.play("Idle")
	if runner:
		speed = 3.3
		health = 70

func _physics_process(delta: float) -> void:
	if dead or not is_instance_valid(player) or not player.enabled:
		return
	attack_timer = maxf(0, attack_timer - delta)
	alert_time = maxf(0, alert_time - delta)
	rethink -= delta
	var distance := global_position.distance_to(player.global_position)
	if rethink <= 0:
		rethink = 0.45
		var query := PhysicsRayQueryParameters3D.create(global_position + Vector3.UP, player.global_position + Vector3.UP, 1)
		if distance < 17 and get_world_3d().direct_space_state.intersect_ray(query).is_empty():
			hear(player.global_position, 17)
		if alert_time > 0:
			route = world.path(global_position, destination)
			route_index = 1 if route.size() > 1 else 0
	velocity.x = 0
	velocity.z = 0
	if alert_time > 0 and route_index < route.size():
		var offset := route[route_index] - global_position
		offset.y = 0
		if offset.length() < 0.5:
			route_index += 1
		else:
			var direction := offset.normalized()
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			rotation.y = atan2(-direction.x, -direction.z)
	velocity.y -= 22 * delta
	if is_on_floor():
		velocity.y = -0.1
	move_and_slide()
	if attack_timer <= 0.5:
		var action := ("Run" if runner else "Walk") if Vector2(velocity.x, velocity.z).length() > 0.1 else "Idle"
		if animator.current_animation != action:
			animator.play(action, 0.15)
	if distance < 1.25 and attack_timer <= 0:
		var query := PhysicsRayQueryParameters3D.create(global_position + Vector3.UP, player.global_position + Vector3.UP, 1)
		if get_world_3d().direct_space_state.intersect_ray(query).is_empty():
			player.damage(12 if runner else 18)
			attack_timer = 1.1
			animator.play("Punch", 0.1)

func hear(origin: Vector3, radius: float) -> void:
	if global_position.distance_to(origin) <= radius:
		destination = origin
		alert_time = 8

func damage(amount: float) -> void:
	if dead:
		return
	health -= amount
	hear(player.global_position, 100)
	if health <= 0:
		dead = true
		collision_layer = 0
		collision_mask = 0
		killed.emit()
		animator.play("Death", 0.1)
		await get_tree().create_timer(3.0).timeout
		queue_free()
