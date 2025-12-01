# enemy.gd
extends CharacterBody3D

@export var grid_size: float = 2.0
@export var move_speed: float = 0.5  # Faster for responsiveness
@export var detection_range: float = 5.0
@export var gravity: float = 9.8
@export var attack_cooldown: float = 1.0  # Seconds between attacks
@export var health: int = 7
var tween: Tween = null  # Initialize as null
var last_attack_time: float = -attack_cooldown  # Allow attack at start
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var detection_area = $Area3D
@onready var front_ray = $FrontRay  # RayCast3D for -Z
@onready var back_ray = $BackRay    # RayCast3D for +Z
@onready var left_ray = $LeftRay    # RayCast3D for -X
@onready var right_ray = $RightRay  # RayCast3D for +X
@onready var sprite = $Sprite3D  # Reference to Sprite3D
@onready var hit_sprite =$hit_sprite

func snap_to_grid(pos: Vector3) -> Vector3:
	return Vector3(
		round(pos.x / grid_size) * grid_size,
		pos.y,
		round(pos.z / grid_size) * grid_size
	)

func _ready():
	add_to_group("Enemy")
	if detection_area.has_node("CollisionShape3D"):
		detection_area.get_node("CollisionShape3D").shape.radius = detection_range
		detection_area.set_collision_mask_value(3, true)  # Player layer
	for ray in [front_ray, back_ray, left_ray, right_ray]:
		if ray:
			ray.set_collision_mask_value(1, true)  # Walls layer
			ray.target_position = Vector3.ZERO  # Set dynamically
	print("Enemy ready, detection range: ", detection_range)

func _physics_process(delta: float):
	# Apply gravity to prevent sinking
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0
	move_and_slide()

	if tween and tween.is_running():
		#print("tween running")
		return
	
	if not player:
		print("Player not found!")
		return
	
	var player_pos = player.position
	var distance = position.distance_to(player_pos)
	#print("distance: ", distance)
	
	if distance <= detection_range + 0.05:
		if distance <= 0.5 + 0.05:
			attack_player()
			return
		
		var direction = (player_pos - position).normalized()
		direction.y = 0
		var move_vec = Vector3.ZERO
		if abs(direction.x) > abs(direction.z):
			move_vec.x = sign(direction.x) * grid_size
		else:
			move_vec.z = sign(direction.z) * grid_size
		
		if move_vec == Vector3.ZERO:
			print("No movement needed")
			return
		
		if not can_move_to(move_vec):
			print("Movement blocked by wall")
			return
		
		var target_pos = snap_to_grid(position + move_vec)
		var new_distance = target_pos.distance_to(player_pos)
		if abs(new_distance - distance) < 0.01:
			print("Target not closer")
			return
		
		print("Starting tween to: ", target_pos)
		tween = create_tween()
		tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		tween.tween_property(self, "position", target_pos, move_speed)
		tween.tween_callback(_on_tween_complete)

func can_move_to(move_vec: Vector3) -> bool:
	var ray: RayCast3D
	if move_vec.x > 0:
		ray = right_ray
	elif move_vec.x < 0:
		ray = left_ray
	elif move_vec.z > 0:
		ray = back_ray
	elif move_vec.z < 0:
		ray = front_ray
	
	if ray:
		ray.target_position = move_vec.normalized() * grid_size
		ray.force_raycast_update()
		print("Raycast check: ", ray.name, " colliding: ", ray.is_colliding())
		return not ray.is_colliding()
	print("No valid ray for move_vec: ", move_vec)
	return false

func can_attack_player(player_pos: Vector3) -> bool:
	var attack_ray = RayCast3D.new()
	add_child(attack_ray)
	attack_ray.set_collision_mask_value(1, true)  # Walls
	attack_ray.position = Vector3(0, 1, 0)
	attack_ray.target_position = player_pos - global_position
	attack_ray.force_raycast_update()
	var can_attack = not attack_ray.is_colliding()
	attack_ray.queue_free()
	return can_attack

func _on_tween_complete():
	position = snap_to_grid(position)
	print("Tween complete")

func attack_player():
	var current_time = Time.get_ticks_msec() / 1000.0  # Current time in seconds
	if current_time - last_attack_time < attack_cooldown:
		print("Attack on cooldown: ", attack_cooldown - (current_time - last_attack_time))
		return
	if can_attack_player(player.global_position):
		print("attacking player")
		if player.has_method("take_damage"):
			player.take_damage(1)
			last_attack_time = current_time
	else:
		print("Attack blocked by wall")

func take_damage(amount: int):
	print("took damage: ", amount)
	health -= amount
	if health <= 0:
		print("Enemy defeated!")
		queue_free()
		return
	
	# Blink red using Sprite3D modulate
	print("Starting blink")
	var original_color = sprite.modulate
	var og_tint = sprite
	var red_tween = create_tween()
	
	red_tween.tween_property(sprite, "modulate", Color.RED, 0.2)
	

	red_tween.tween_property(sprite, "modulate", original_color, 0.2)
	#sprite = og_tint
	
	red_tween.tween_callback(func(): 
		hit_sprite.visible = false
		sprite.visible = true
		sprite.modulate = original_color  # Ensure reset
		print("Blink complete")
	)
	
	# Bounce back
	print("Starting bounce")
	var direction_to_player = (player.global_position - global_position).normalized()
	direction_to_player.y = 0
	var bounce_vec = Vector3.ZERO
	if abs(direction_to_player.x) > abs(direction_to_player.z):
		bounce_vec.x = -sign(direction_to_player.x) * grid_size
	else:
		bounce_vec.z = -sign(direction_to_player.z) * grid_size
	
	if bounce_vec == Vector3.ZERO:
		print("No bounce direction")
		return
	
	var bounce_target = snap_to_grid(position + bounce_vec)
	if can_move_to(bounce_vec):
		tween = create_tween()
		tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		tween.tween_property(self, "position", bounce_target, 0.3)
		tween.tween_callback(_on_tween_complete)
		print("Bouncing back to: ", bounce_target)
	else:
		print("Bounce blocked by wall")

func _on_area_3d_2_area_entered(area: Area3D) -> void:
	print("area check One")
	if area.is_in_group("Weapon_Player") and player.is_attacking:
		print("WE GOT EM")
		take_damage(1)
		print("took damage!")
	else:
		print("couldnt take damage")
		print(area.get_groups())
